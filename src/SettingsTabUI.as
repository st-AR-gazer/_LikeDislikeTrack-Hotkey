[Setting hidden]
bool S_displayVote = true;

[Setting hidden]
int S_maxDisplayDuration = 3000;
[Setting hidden]
int S_fadeDuration = 500;

[Setting hidden]
float S_squareSize = 0.04;
[Setting hidden]
float S_squarePositionX = 0.675;
[Setting hidden]
float S_squarePositionY = 0;

[Setting hidden]
string S_likeKeyBind = "PageDown";
[Setting hidden]
string S_dislikeKeyBind = "PageUp";

[Setting hidden]
bool S_applyVoteKeybindsAutomatically = true;

[Setting hidden]
int S_autoApplyVoteKeybindsDelay = 40;

string[] navActions = {
    "Up","Right","Left","Down","Select","Cancel","PageUp","PageDown",
    "AppMenu","Action1","Action2","Action3","Action4","ScrollUp","ScrollDown"
};

[SettingsTab name="Vote Settings" order="1"]
void RenderSettings() {
    UI::Text("Vote Settings");
    UI::Separator();
    UI::Text("Display Settings: ");

    S_displayVote = UI::Checkbox("Display Vote", S_displayVote);
    S_maxDisplayDuration = UI::InputInt("Max Display Duration (ms)", S_maxDisplayDuration);
    S_fadeDuration = UI::InputInt("Fade Duration (ms)", S_fadeDuration);
    S_squareSize = UI::InputFloat("Square Size (fraction of screen width)", S_squareSize, 0.01f);
    S_squarePositionX = UI::SliderFloat("Square Position X", S_squarePositionX, 0.0f, 1.0f - S_squareSize);
    S_squarePositionY = UI::SliderFloat("Square Position Y", S_squarePositionY, 0.0f, 1.0f - S_squareSize);

    if (UI::Button("Set Default")) {
        S_displayVote = true;
        S_maxDisplayDuration = 3000;
        S_fadeDuration = 500;
        S_squareSize = 0.04;
        S_squarePositionX = 0.675;
        S_squarePositionY = 0.0f;
    }

    UI::Separator();
    UI::Text("Menu Settings: ");
    UI::Text("(Sorry controller players, I couldn't find a way to make this work for y'all Sadge)");
    UI::Text("Due to how nadeo has implemented the menu, you can only use the following keybinds for \n" + 
             "interacting with the menu in any way (I could remake their entire implementation, but I'm \n" + 
             "not that great at maniascript/link code so sue me :xdd:)");

    UI::Text("Available EMenuNavAction options:");

    S_likeKeyBind = DrawNavActionCombo("Like Keybind", S_likeKeyBind);
    S_dislikeKeyBind = DrawNavActionCombo("Dislike Keybind", S_dislikeKeyBind);
    UI::Text("Note: If you want to disable these bindings you can change them to 'Action1/2/3/4'");

    if (UI::Button("Apply Keybind Changes")) {
        VoteMenuBinds::EditTrackVoteDefaultKeybinds();
    }

    S_applyVoteKeybindsAutomatically = UI::Checkbox("Apply Vote Keybinds Automatically", S_applyVoteKeybindsAutomatically);

    S_autoApplyVoteKeybindsDelay = UI::SliderInt("Auto Apply Vote Keybinds Delay (ms)", S_autoApplyVoteKeybindsDelay, 0, 500);

    if (UI::Button("Cleanup Keybind Changes")) {
        VoteMenuBinds::Cleanup();
    }
}

string DrawNavActionCombo(const string &in label, const string &in current) {
    int currentIndex = navActions.Find(current);
    if (currentIndex < 0) currentIndex = 0;

    if (UI::BeginCombo(label, navActions[currentIndex])) {
        for (uint i = 0; i < navActions.Length; i++) {
            bool isSelected = (i == uint(currentIndex));
            if (UI::Selectable(navActions[i], isSelected)) {
                currentIndex = i;
            }
            if (isSelected) UI::SetItemDefaultFocus();
        }
        UI::EndCombo();
    }
    return navActions[currentIndex];
}