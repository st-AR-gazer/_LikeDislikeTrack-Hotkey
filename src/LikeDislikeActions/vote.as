namespace Vote {
    void LikeTrack() {
        SetVote(1, "Map liked!", "LikeTrack");
        VoteDisplay::DisplayVote(VoteDisplay::VoteType::Like);
    }

    void DislikeTrack() {
        SetVote(-1, "Map disliked!", "DislikeTrack");
        VoteDisplay::DisplayVote(VoteDisplay::VoteType::Dislike);
    }

    void NeutralizeTrack() {
        SetVote(0, "Map rating set to neutral!", "NeutralizeTrack");
        VoteDisplay::DisplayVote(VoteDisplay::VoteType::Neutral);
    }

    CGameDataFileManagerScript@ GetDFM(const string &in context) {
        CGameManiaAppPlayground@ c_map = cast<CGameManiaAppPlayground>(GetApp().Network.ClientManiaAppPlayground);
        if (c_map is null) { return null; }
        CGameDataFileManagerScript@ dfm = cast<CGameDataFileManagerScript>(c_map.DataFileMgr);
        if (dfm is null) { return null; }

        return dfm;
    }

    void SetVote(int voteValue, const string &in logMessage, const string &in context) {
        CGameDataFileManagerScript@ dfm = GetDFM(context);
        if (dfm is null) return;

        MwId userId = get_UserID();
        string mapUid = get_MapUid();

        if (mapUid == "") {
            log("Error: Could not retrieve valid MapUid.", LogLevel::Error, 34, "SetVote");
            return;
        }

        dfm.Map_NadeoServices_Vote(userId, mapUid, voteValue);
        log(logMessage, LogLevel::Info, 39, "SetVote");
    }

    void GetVote(const string &in context) {
        CGameDataFileManagerScript@ dfm = GetDFM(context);
        if (dfm is null) return;

        MwId userId = get_UserID();
        string mapUid = get_MapUid();

        if (mapUid == "") {
            log("Error: Could not retrieve valid MapUid.", LogLevel::Error, 50, "GetVote");
            return;
        }

        int vote = dfm.Map_NadeoServices_GetVote(userId, mapUid);
        log("Vote: " + vote, LogLevel::Info, 55, "GetVote");
    }

    MwId get_UserID() {
        return GetApp().UserManagerScript.Users[0].Id;
    }

    string get_MapUid() {
        auto app = GetApp();
        if (app.RootMap !is null && app.RootMap.MapInfo !is null) {
            return app.RootMap.MapInfo.MapUid;
        }
        return "";
    }
}