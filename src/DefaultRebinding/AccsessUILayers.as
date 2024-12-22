namespace VoteMenuBinds {

    string originalManialink = "";

    string foundLikeKey = "";
    string foundDislikeKey = "";

    string gameDefaultLikeKey = "PageDown";
    string gameDefaultDislikeKey = "PageUp";


    void EditTrackVoteDefaultKeybinds() {
        auto cMap = GetCMAP();
        if (cMap is null) return;
        if (cMap.UILayers.Length <= 22) return;
        auto ui = cast<CGameUILayer>(cMap.UILayers[22]);
        if (ui is null) return;

        string ml = ui.ManialinkPage;
        if (originalManialink == "") {
            originalManialink = ml;
        }

        string search_DislikeLine_prefix = "case CMlScriptEvent::EMenuNavAction::"; string search_DislikeLine_suffix = ": if (!Event.IsActionAutoRepeat) State = Select(State, State.Controls.Button_VoteDislike);";
        string search_LikeLine_prefix = "case CMlScriptEvent::EMenuNavAction::"; string search_LikeLine_suffix = ": if (!Event.IsActionAutoRepeat) State = Select(State, State.Controls.Button_VoteLike);";

        auto lines = ml.Split("\n");
        lines.Reserve(lines.Length);

        for (uint i = 0; i < lines.Length; i++) {
            if (lines[i].Contains(search_DislikeLine_prefix) && lines[i].Contains(search_DislikeLine_suffix)) {
                log("Found Dislike Line!", LogLevel::Info, 32, "EditTrackVoteDefaultKeybinds");

                int startIndex = lines[i].IndexOf(search_DislikeLine_prefix) + search_DislikeLine_prefix.Length;
                int endIndex = lines[i].IndexOf(search_DislikeLine_suffix);

                gameDefaultDislikeKey = lines[i].SubStr(startIndex, endIndex - startIndex);
                foundDislikeKey = gameDefaultDislikeKey;
                break;
            }
        }

        for (uint i = 0; i < lines.Length; i++) {
            if (lines[i].Contains(search_LikeLine_prefix) && lines[i].Contains(search_LikeLine_suffix)) {
                log("Found Like Line!", LogLevel::Info, 45, "EditTrackVoteDefaultKeybinds");

                int startIndex = lines[i].IndexOf(search_LikeLine_prefix) + search_LikeLine_prefix.Length;
                int endIndex = lines[i].IndexOf(search_LikeLine_suffix);

                gameDefaultLikeKey = lines[i].SubStr(startIndex, endIndex - startIndex);
                foundLikeKey = gameDefaultLikeKey;
                break;
            }
        }

        string oldLineDislike = "case CMlScriptEvent::EMenuNavAction::" + foundDislikeKey + ": if (!Event.IsActionAutoRepeat) State = Select(State, State.Controls.Button_VoteDislike);";
        string oldLineLike = "case CMlScriptEvent::EMenuNavAction::" +     foundLikeKey +   ": if (!Event.IsActionAutoRepeat) State = Select(State, State.Controls.Button_VoteLike);";

        string newLineDislike = "case CMlScriptEvent::EMenuNavAction::" + S_dislikeKeyBind + ": if (!Event.IsActionAutoRepeat) State = Select(State, State.Controls.Button_VoteDislike);";
        string newLineLike = "case CMlScriptEvent::EMenuNavAction::" +    S_likeKeyBind +    ": if (!Event.IsActionAutoRepeat) State = Select(State, State.Controls.Button_VoteLike);";

        ml = ml.Replace(oldLineDislike, newLineDislike);
        ml = ml.Replace(oldLineLike, newLineLike);

        ui.ManialinkPage = ml;

        foundDislikeKey = "";
        foundLikeKey = "";

        log("Keybinds have been updated!", LogLevel::Info, 70, "EditTrackVoteDefaultKeybinds");

    }

    void Cleanup() {
        auto cMap = GetCMAP();
        if (cMap !is null && cMap.UILayers.Length > 22) {
            auto ui = cast<CGameUILayer>(cMap.UILayers[22]);
            if (ui !is null && originalManialink != "") {
                ui.ManialinkPage = originalManialink;
            }
        }
        originalManialink = "";
    }

    CGameManiaAppPlayground@ GetCMAP() {
        auto app = cast<CTrackMania>(GetApp());
        if (app is null || app.Network is null) return null;
        return cast<CGameManiaAppPlayground>(app.Network.ClientManiaAppPlayground);
    }
}

void OnDestroyed() {
    VoteMenuBinds::Cleanup();
}




// https://bigbang1112.github.io/maniascript-reference/trackmania/class_c_ml_script_event.html

// enum  	EMenuNavAction {
//   Up , Right , Left , Down ,
//   Select , Cancel , PageUp , PageDown ,
//   AppMenu , Action1 , Action2 , Action3 ,
//   Action4 , ScrollUp , ScrollDown
// }