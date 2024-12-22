namespace LikeDislikeModule {
    class LikeDislikeHotkeyModule : Hotkeys::IHotkeyModule {
        array<string> actions = {
            "Like Current Map", "Dislike Current Map", "Neutralize Current Map"
        };

        void Initialize() { }

        array<string> GetAvailableActions() {
            return actions;
        }

        bool ExecuteAction(const string &in action, Hotkeys::Hotkey@ hotkey) {
            if (action == "Like Current Map") {
                Vote::LikeTrack();
                return true;
            } else if (action == "Dislike Current Map") {
                Vote::DislikeTrack();
                return true;
            } else if (action == "Neutralize Current Map") {
                Vote::NeutralizeTrack();
                return true;
            }
            return false;
        }
    }

    Hotkeys::IHotkeyModule@ CreateInstance() {
        return LikeDislikeHotkeyModule();
    }
}