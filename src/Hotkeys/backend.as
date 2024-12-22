// FIXME: Note that if a hotkey, when held can be used in later hotkeys after executing it's own hotkey, so if I press "P" 
// to open say, the interface, if I then continue to hold it I cannot press "T" to then like a map, the 'like' will then be 
// ignored and the interface will be the only thing to change... So yeah, not exactly ideal and needs a fix :xdd:¨
// Note that this is also dependent on the order at which the hotkey was added, if I add X then Y then Z "Z" will not override
// "X" and "Y", but "Y" will override "Z" and "X" will override "Y" and "Z"... So yeah, it's a bit of a mess :xdd:

// FIXME: A hotkey can sometimes be triggered twice from one button press, I need to look into this at some point :xdd:

namespace Hotkeys {

    interface IHotkeyModule {
        void Initialize();
        array<string> GetAvailableActions();
        bool ExecuteAction(const string &in action, Hotkey@ hotkey);
    }

    class Hotkey {
        string action;
        int extraValue = -1;

        bool isOrdered = false;       
        string comboString = "";      
        array<ComboStep@> steps;      

        Hotkey(const string &in action, const string &in comboString, bool isOrdered, int extraValue = -1) {
            this.action = action;
            this.isOrdered = isOrdered;
            this.comboString = comboString;
            this.extraValue = extraValue;
        }

        string get_description() const {
            return comboString + " : " + action;
        }
    }

    class ComboStep {
        array<ComboCondition@> conditions;
    }

    class ComboCondition {
        array<string> orKeys;
    }

    string configFilePath = IO::FromStorageFolder("hotkeys_config.ini");
    array<IHotkeyModule@> hotkeyModules;
    dictionary hotkeyMappings;

    dictionary currentlyPressedKeys;

    array<string> GenerateKeyList() {
        array<string> keys;
        for (uint i = 0; i <= 254; i++) {
            VirtualKey vKey = VirtualKey(i);
            string keyName = tostring(vKey);
            if (keyName != "Unknown") {
                keys.InsertLast(keyName);
            }
        }
        return keys;
    }

    void RegisterHotkey(const string &in action, const string &in comboString, bool isOrdered, int extraValue = -1) {
        Hotkey@ hotkey = Hotkey(action, comboString, isOrdered, extraValue);
        ParseComboString(hotkey, comboString, isOrdered);

        array<Hotkey@>@ hotkeysList;
        if (hotkeyMappings.Exists(action)) {
            @hotkeysList = cast<array<Hotkey@>@>(hotkeyMappings[action]);
        } else {
            @hotkeysList = array<Hotkey@>();
            hotkeyMappings.Set(action, @hotkeysList);
        }

        hotkeysList.InsertLast(hotkey);
        SaveHotkeysToFile();
    }

    void UpdateHotkey(const string &in action, int hotkeyIndex, const string &in comboString, bool isOrdered, int extraValue = -1) {
        if (hotkeyMappings.Exists(action)) {
            array<Hotkey@>@ hotkeysList = cast<array<Hotkey@>@>(hotkeyMappings[action]);
            if (hotkeyIndex >= 0 && hotkeyIndex < int(hotkeysList.Length)) {
                Hotkey@ hotkey = hotkeysList[hotkeyIndex];
                hotkey.isOrdered = isOrdered;
                hotkey.comboString = comboString;
                hotkey.extraValue = extraValue;
                hotkey.steps.RemoveRange(0, hotkey.steps.Length);
                ParseComboString(hotkey, comboString, isOrdered);
                SaveHotkeysToFile();
            }
        }
    }

    void RemoveHotkey(const string &in action, int hotkeyIndex) {
        if (hotkeyMappings.Exists(action)) {
            array<Hotkey@>@ hotkeysList = cast<array<Hotkey@>@>(hotkeyMappings[action]);
            if (hotkeyIndex >= 0 && hotkeyIndex < int(hotkeysList.Length)) {
                hotkeysList.RemoveAt(hotkeyIndex);
                if (hotkeysList.Length == 0) {
                    hotkeyMappings.Delete(action);
                }
                SaveHotkeysToFile();
            }
        }
    }

    void ParseComboString(Hotkey@ hotkey, const string &in comboString, bool isOrdered) {
        array<string> stepStrings = comboString.Split(">");
        for (uint i = 0; i < stepStrings.Length; i++) {
            string stepStr = stepStrings[i].Trim();
            ComboStep step;
            array<string> parts = stepStr.Split("+");
            for (uint p = 0; p < parts.Length; p++) {
                string part = parts[p].Trim();
                ComboCondition cond;
                array<string> ors = part.Split("|");
                for (uint o = 0; o < ors.Length; o++) {
                    cond.orKeys.InsertLast(ors[o].Trim());
                }
                step.conditions.InsertLast(cond);
            }
            hotkey.steps.InsertLast(step);
        }
    }

    void LoadHotkeysFromFile() {
        if (!IO::FileExists(configFilePath)) return;

        string configContent = _IO::File::ReadFileToEnd(configFilePath);
        array<string> lines = configContent.Split("\n");
        for (uint i = 0; i < lines.Length; i++) {
            string line = lines[i].Trim();
            if (line.Length == 0) continue;

            array<string> parts = line.Split("=");
            if (parts.Length == 2) {
                string action = parts[0].Trim();
                string right = parts[1].Trim();
                array<string> comboParts = right.Split(";");
                if (comboParts.Length == 2) {
                    bool isOrdered = comboParts[0].ToLower() == "true";
                    string comboStr = comboParts[1].Trim();
                    RegisterHotkey(action, comboStr, isOrdered);
                }
            }
        }
    }

    void SaveHotkeysToFile() {
        array<string> actions = hotkeyMappings.GetKeys();
        string content = "";

        for (uint i = 0; i < actions.Length; i++) {
            array<Hotkey@>@ hotkeysList = cast<array<Hotkey@>@>(hotkeyMappings[actions[i]]);
            for (uint j = 0; j < hotkeysList.Length; j++) {
                Hotkey@ hotkey = hotkeysList[j];
                string isOrderedStr = hotkey.isOrdered ? "true" : "false";
                content += hotkey.action + "=" + isOrderedStr + ";" + hotkey.comboString + "\n";
            }
        }

        IO::File configFile(configFilePath, IO::FileMode::Write);
        configFile.Write(content);
        configFile.Close();
    }

    bool ConditionIsMet(ComboCondition@ cond) {
        for (uint i = 0; i < cond.orKeys.Length; i++) {
            if (currentlyPressedKeys.Exists(cond.orKeys[i])) return true;
        }
        return false;
    }

    bool StepIsSatisfied(ComboStep@ step) {
        for (uint c = 0; c < step.conditions.Length; c++) {
            if (!ConditionIsMet(step.conditions[c])) return false;
        }
        return true;
    }

    bool CheckUnorderedCombo(Hotkey@ hotkey) {
        if (hotkey.steps.Length == 0) return false;
        for (uint s = 0; s < hotkey.steps.Length; s++) {
            if (!StepIsSatisfied(hotkey.steps[s])) return false;
        }
        return true;
    }

    bool CheckOrderedCombo(Hotkey@ hotkey) {
        for (uint s = 0; s < hotkey.steps.Length; s++) {
            if (!StepIsSatisfied(hotkey.steps[s])) return false;
        }
        return true;
    }

    bool CheckHotkey(Hotkey@ hotkey) {
        if (hotkey.isOrdered) {
            return CheckOrderedCombo(hotkey);
        } else {
            return CheckUnorderedCombo(hotkey);
        }
    }

    Hotkey@ GetHotkeyMatch() {
        array<string> actions = hotkeyMappings.GetKeys();
        for (uint i = 0; i < actions.Length; i++) {
            array<Hotkey@>@ hotkeysList = cast<array<Hotkey@>@>(hotkeyMappings[actions[i]]);
            for (uint j = 0; j < hotkeysList.Length; j++) {
                if (CheckHotkey(hotkeysList[j])) {
                    return hotkeysList[j];
                }
            }
        }
        return null;
    }

    void UpdatePressedKeys(bool down, const string &in key) {
        if (down) {
            currentlyPressedKeys[key] = true;
        } else {
            if (currentlyPressedKeys.Exists(key)) currentlyPressedKeys.Delete(key);
        }
    }

    array<string> GetAllAvailableActions() {
        array<string> allActions;
        for (uint i = 0; i < hotkeyModules.Length; i++) {
            auto actions = hotkeyModules[i].GetAvailableActions();
            for (uint j = 0; j < actions.Length; j++) {
                allActions.InsertLast(actions[j]);
            }
        }
        return allActions;
    }

    UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
        UI::InputBlocking uiRes = Hotkeys::HandleCapturingKeyPress(down, key);
        if (uiRes == UI::InputBlocking::Block) {
            return uiRes;
        }

        string k = tostring(key);
        UpdatePressedKeys(down, k);

        if (down) {
            Hotkey@ hotkey = GetHotkeyMatch();
            if (hotkey !is null) {
                ExecuteHotkeyAction(hotkey);
            }
        }
        return UI::InputBlocking::DoNothing;
    }

    void ExecuteHotkeyAction(Hotkey@ hotkey) {
        for (uint i = 0; i < hotkeyModules.Length; i++) {
            if (hotkeyModules[i].ExecuteAction(hotkey.action, hotkey)) {
                return;
            }
        }
        log("No module handled the action: " + hotkey.action, LogLevel::Warn, 260, "ExecuteHotkeyAction");
    }

    void InitializeHotkeyModules() {
        while (hotkeyModules.Length > 0) hotkeyModules.RemoveLast();
        
        // 

        hotkeyModules.InsertLast(InterfaceModule::CreateInstance());
        hotkeyModules.InsertLast(LikeDislikeModule::CreateInstance());

        // 

        InitializeAllModules();
    }

    void InitializeAllModules() {
        for (uint i = 0; i < hotkeyModules.Length; i++) {
            hotkeyModules[i].Initialize();
        }
    }

    void InitHotkeys() {
        InitializeHotkeyModules();
        LoadHotkeysFromFile();
    }
}

UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
    return Hotkeys::OnKeyPress(down, key);
}
