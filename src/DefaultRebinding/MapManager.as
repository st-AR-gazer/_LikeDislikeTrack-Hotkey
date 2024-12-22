// Code yoinked from ARL

namespace MapTracker {
    string oldMapUid = "";

    [Setting category="General" name="Enable Ghosts" hidden]
    bool enableGhosts = true;

    void MapMonitor() {
        while (true) {
            sleep(273);

            if (!enableGhosts) continue;

            if (HasMapChanged()) {
                oldMapUid = get_CurrentMapUID();
                if (S_applyVoteKeybindsAutomatically) {
                    startnew(OnMapChangedRoutine);
                }
            }
        }
    }

    bool HasMapChanged() {
        return oldMapUid != get_CurrentMapUID();
    }

    void OnMapChangedRoutine() {
        yield(S_autoApplyVoteKeybindsDelay);

        for (uint i = 0; i < 3; i++) {
            if (_Game::IsMapLoaded() && HasUILayers()) {
                log("Calling EditTrackVoteDefaultKeybinds after map change.", LogLevel::Info, 33, "OnMapChangedRoutine");
                VoteMenuBinds::EditTrackVoteDefaultKeybinds();
                return;
            }
            sleep(500);
        }
        log("UILayers not ready or map might have changed again. Skipping automatic EditTrackVoteDefaultKeybinds.", LogLevel::Info, 39, "OnMapChangedRoutine");
    }

    bool HasUILayers() {
        auto cMap = VoteMenuBinds::GetCMAP();
        if (cMap is null) return false;
        return cMap.UILayers.Length > 22;
    }
}

string get_CurrentMapUID() {
    if (_Game::IsMapLoaded()) {
        auto app = cast<CTrackMania>(GetApp());
        if (app is null) return "";
        auto map = app.RootMap;
        if (map is null) return "";
        return map.MapInfo.MapUid;
    }
    return "";
}

string get_CurrentMapName() {
    if (_Game::IsMapLoaded()) {
        auto app = cast<CTrackMania>(GetApp());
        if (app is null) return "";
        auto map = app.RootMap;
        if (map is null) return "";
        return map.MapInfo.Name;
    }
    return "";
}
