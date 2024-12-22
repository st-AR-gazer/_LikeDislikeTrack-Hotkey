[Setting hidden]
bool S_windowOpen = false;

namespace InterfaceModule {
    class InterfaceHotkeyModule : Hotkeys::IHotkeyModule {
        array<string> actions = {
            "Open/Close Interface", "Open Interface", "Close Interface"
        };

        void Initialize() { }

        array<string> GetAvailableActions() {
            return actions;
        }

        bool ExecuteAction(const string &in action, Hotkeys::Hotkey@ hotkey) {
            if (action == "Open/Close Interface") {
                S_windowOpen = !S_windowOpen;
                return true;
            } else if (action == "Open Interface") {
                S_windowOpen = true;
                return true;
            } else if (action == "Close Interface") {
                S_windowOpen = false;
                return true;
            }
            return false;
        }
    }

    Hotkeys::IHotkeyModule@ CreateInstance() {
        return InterfaceHotkeyModule();
    }
}

void RenderInterface() {
    if (S_windowOpen) {
        Hotkeys::RT_Hotkeys_Popout();
    }
}