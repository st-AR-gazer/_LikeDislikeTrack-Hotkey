namespace VoteDisplay {
    bool isVisible = false;
    vec3 baseColor = vec3(1.0, 1.0, 1.0);
    float opacity = 1.0;
    vec4 boxColor = vec4(baseColor, opacity);

    enum VoteType {
        Like,
        Dislike,
        Neutral
    }

    const int kDriftCorrectionThreshold = 10;

    int countdownStartTime = -1;
    int remainingTime      = 0;

    VoteType currentVote = VoteType::Neutral;

    void DisplayVote(VoteType vote) {
        currentVote = vote;
        SetBoxColorForVote(vote);

        remainingTime = S_maxDisplayDuration;
        countdownStartTime = -1;
        isVisible = true;
    }

    void SetBoxColorForVote(VoteType vote) {
        switch (vote) {
            case VoteType::Like:
                baseColor = HexToRgb("009b5f");
                break;
            case VoteType::Dislike:
                baseColor = HexToRgb("ff0d0d");
                break;
            case VoteType::Neutral:
                baseColor = HexToRgb("000a05");
                break;
        }
        baseColor /= 255.0;
        boxColor = vec4(baseColor, opacity);
    }

    void UpdateCountdown(float dt) {
        if (!isVisible || remainingTime <= 0) return;

        if (remainingTime >= S_maxDisplayDuration && countdownStartTime == -1) {
            countdownStartTime = Time::Now;
        }

        remainingTime -= int(dt);

        if (remainingTime > 0) {
            int elapsed = Time::Now - countdownStartTime;
            int expectedRemaining = S_maxDisplayDuration - elapsed;

            if (Math::Abs(remainingTime - expectedRemaining) > kDriftCorrectionThreshold) {
                remainingTime = expectedRemaining;
            }
        }
    }

    void Render() {
        if (!isVisible) return;
        if (remainingTime <= 0) {
            isVisible = false;
            return;
        }

        int elapsed = S_maxDisplayDuration - remainingTime;

        int tFadeInEnd   = S_fadeDuration;
        int tFadeOutStart = S_maxDisplayDuration - S_fadeDuration;

        if (elapsed < tFadeInEnd) {
            // Fade in
            opacity = float(elapsed) / float(S_fadeDuration);
        }
        else if (elapsed < tFadeOutStart) {
            // Fully visible
            opacity = 1.0;
        }
        else {
            // Fade out
            float fadeElapsed = float(elapsed - tFadeOutStart);
            opacity = 1.0 - (fadeElapsed / float(S_fadeDuration));
        }

        boxColor = vec4(baseColor, opacity);

        float screenW = Draw::GetWidth();
        float screenH = Draw::GetHeight();

        float boxSize = screenW * S_squareSize;

        float boxX = screenW * S_squarePositionX;
        float boxY = screenH * S_squarePositionY;

        nvg::Save();
        nvg::BeginPath();
        nvg::Rect(boxX, boxY, boxSize, boxSize);
        nvg::FillColor(boxColor);
        nvg::Fill();

        string iconStr = VoteTypeToIcon(currentVote);
        vec4 iconColor = GetIconColorForVote(currentVote, opacity);

        float centerX = boxX + boxSize * 0.5;
        float centerY = boxY + boxSize * 0.5;

        nvg::FontSize(boxSize * 0.6);
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        nvg::FillColor(iconColor);
        nvg::Text(centerX, centerY, iconStr);

        nvg::Restore();
    }

    string VoteTypeToIcon(VoteType vote) {
        switch (vote) {
            case VoteType::Like:    return Icons::ThumbsUp;
            case VoteType::Dislike: return Icons::ThumbsDown;
            case VoteType::Neutral: return Icons::ThumbsOUp;
        }
        return Icons::ThumbsOUp;
    }

    vec4 GetIconColorForVote(VoteType vote, float alpha) {
        if (vote == VoteType::Neutral) {
            vec3 c = HexToRgb("6efaa0") / 255.0;
            return vec4(c, alpha);
        }
        return vec4(1.0, 1.0, 1.0, alpha);
    }

    vec3 HexToRgb(const string &in hexValue) {
        string hex = hexValue;
        if (hex.StartsWith("#")) hex = hex.SubStr(1);

        if (hex.Length == 3) {
            return vec3(
                Text::ParseInt(hex.SubStr(0, 1) + hex.SubStr(0, 1), 16),
                Text::ParseInt(hex.SubStr(1, 1) + hex.SubStr(1, 1), 16),
                Text::ParseInt(hex.SubStr(2, 1) + hex.SubStr(2, 1), 16)
            );
        }
        else if (hex.Length == 6) {
            return vec3(
                Text::ParseInt(hex.SubStr(0, 2), 16),
                Text::ParseInt(hex.SubStr(2, 2), 16),
                Text::ParseInt(hex.SubStr(4, 2), 16)
            );
        }
        else {
            return vec3(255, 255, 255);
        }
    }
}

void Update(float dt) {
    VoteDisplay::UpdateCountdown(dt);
}

void Render() {
    VoteDisplay::Render();
}