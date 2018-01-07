ConVar g_cvMapChangeDelay;

public Action Command_Kick(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_kick <#userid|name> [reason]", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	char cTargetName[MAX_TARGET_LENGTH];
	int iTargetList[MAXPLAYERS + 1], iTargetCount;
	bool bTnIsMl;

	iTargetCount = ProcessTargetString(cArgs1, iClient, iTargetList, sizeof(iTargetList), COMMAND_FILTER_CONNECTED, cTargetName, sizeof(cTargetName), bTnIsMl);

	if (iTargetCount <= 0) {
		ReplyToProcessTargetError(iClient, iTargetCount);
		return Plugin_Handled;
	}

	char cReason[512], cBuffer[255];

	for (int i = 2; i <= iArgs; i++) {
		GetCmdArg(i, cBuffer, sizeof(cBuffer));
		Format(cReason, sizeof(cReason), "%s %s", cReason, cBuffer);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	if (strlen(cReason) == 0) {
		CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Kicked Player", g_cConfig[CONFIG_TARGET], cTargetName);
		Format(cReason, sizeof(cReason), "none");
	} else {
		CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Kicked Player Reason", g_cConfig[CONFIG_TARGET], cTargetName, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_DATA], cReason);
	}

	for (int i = 0; i < iTargetCount; i++) {
		KickClient(iTargetList[i], "%t", "Kicked Target", cReason);
	}

	return Plugin_Handled;
}

public Action Command_ReloadAdmins(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	DumpAdminCache(AdminCache_Groups, true);
	DumpAdminCache(AdminCache_Overrides, true);

	CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Admins Reloaded");

	return Plugin_Handled;
}

public Action Command_Cvar(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_cvar <cvar> [value]", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	ConVar cvConvar = FindConVar(cArgs1);

	if (cvConvar == null) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Not Found", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (!AllowedToModifyCvar(iClient, cArgs1)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Is Protected", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 2) {
		char cValue[255];
		cvConvar.GetString(cValue, sizeof(cValue));

		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Value", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_TARGET], cValue);
		return Plugin_Handled;
	}

	char cArgs2[255];
	GetCmdArg(2, cArgs2, sizeof(cArgs2));

	cvConvar.SetString(cArgs2, true);

	if ((cvConvar.Flags & FCVAR_PROTECTED) != FCVAR_PROTECTED) {
		char cTag[64];
		Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);
		CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "ConVar Changed", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_TARGET], cArgs2);
	} else {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Changed", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_TARGET], cArgs2);
	}

	return Plugin_Handled;
}

public Action Command_ProtectCvar(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_protectcvar <cvar>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	ConVar cvConvar = FindConVar(cArgs1);

	if (cvConvar == null) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Not Found", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (!AllowedToModifyCvar(iClient, cArgs1)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Is Protected", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (IsCvarProtected(cArgs1)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Already Protected", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	ProtectCvar(cArgs1, true);

	if ((cvConvar.Flags & FCVAR_PROTECTED) != FCVAR_PROTECTED) {
		char cTag[64];
		Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);
		CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "ConVar Protected", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
	} else {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Protected", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
	}

	return Plugin_Handled;
}

public Action Command_ResetCvar(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_resetcvar <cvar>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	ConVar cvConvar = FindConVar(cArgs1);
	if (cvConvar == null) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Not Found", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (!AllowedToModifyCvar(iClient, cArgs1)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Is Protected", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	cvConvar.RestoreDefault();

	char cValue[255];
	cvConvar.GetString(cValue, sizeof(cValue));

	if ((cvConvar.Flags & FCVAR_PROTECTED) != FCVAR_PROTECTED) {
		char cTag[64];
		Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);
		CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "ConVar Reset", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_TARGET], cValue);
	} else {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "ConVar Reset", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_TARGET], cValue);
	}

	return Plugin_Handled;
}

public Action Command_CancelVote(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (!IsVoteInProgress()) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "No Vote In Progress");
		return Plugin_Handled;
	}

	CancelVote();

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);
	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Vote Cancelled");

	return Plugin_Handled;
}

public Action Command_Map(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_map <map>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	if (!IsMapValid(cArgs1)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Map Not Found", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	DataPack dpMapChange;
	CreateDataTimer(g_cvMapChangeDelay.FloatValue, Timer_Map, dpMapChange);

	dpMapChange.WriteString(cArgs1);

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);
	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Changing Map", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_TARGET], g_cvMapChangeDelay.IntValue, g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

public Action Command_Rcon(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_rcon <args>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgsString[512];
	GetCmdArgString(cArgsString, sizeof(cArgsString));

	if (iClient == 0) {
		ServerCommand(cArgsString);
	} else {
		char cReponseBuffer[4096];
		ServerCommandEx(cReponseBuffer, sizeof(cReponseBuffer), cArgsString);
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Rcon Executed");
	}

	return Plugin_Handled;
}

public Action Command_ExecCfg(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_execcfg <cfg>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));
	Format(cArgs1, sizeof(cArgs1), "cfg/%s", cArgs1);

	if (!FileExists(cArgs1)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Config Not Found", g_cConfig[CONFIG_DATA], cArgs1[4], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	ServerCommand("exec \"%s\"", cArgs1[4]);

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);
	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Config Executed", g_cConfig[CONFIG_DATA], cArgs1[4], g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

public Action Command_ReloadPlugin(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_reloadplugin <plugin>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	char cPath[512];
	BuildPath(Path_SM, cPath, sizeof(cPath), "plugins/%s.smx", cArgs1);

	if (!FileExists(cPath)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Plugin Not Found", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	ServerCommand("sm plugins reload %s", cArgs1);
	CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Plugin Reloaded", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

public Action Command_UnloadPlugin(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_unloadplugin <plugin>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	char cPath[512];
	BuildPath(Path_SM, cPath, sizeof(cPath), "plugins/%s.smx", cArgs1);

	if (!FileExists(cPath)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Plugin Not Found", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	ServerCommand("sm plugins unload %s", cArgs1);
	CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Plugin Unloaded", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

public Action Command_LoadPlugin(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_loadplugin <plugin>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	char cPath[512];
	BuildPath(Path_SM, cPath, sizeof(cPath), "plugins/%s.smx", cArgs1);

	if (!FileExists(cPath)) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Plugin Not Found", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	ServerCommand("sm plugins load %s", cArgs1);
	CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Plugin Loaded", g_cConfig[CONFIG_DATA], cArgs1, g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

public Action Timer_Map(Handle hTimer, DataPack dpMapChange) {
	char cMap[255];

	dpMapChange.Reset();
	dpMapChange.ReadString(cMap, sizeof(cMap));

	ForceChangeLevel(cMap, "sm_map");

	delete dpMapChange;
}
