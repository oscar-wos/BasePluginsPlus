public Action Command_Slay(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_PLAYERCOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_slay <#userid|name>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	char cTargetName[MAX_TARGET_LENGTH];
	int iTargetList[MAXPLAYERS + 1], iTargetCount;
	bool bTnIsMl;

	iTargetCount = ProcessTargetString(cArgs1, iClient, iTargetList, sizeof(iTargetList), COMMAND_FILTER_ALIVE, cTargetName, sizeof(cTargetName), bTnIsMl);

	if (iTargetCount <= 0) {
		ReplyToProcessTargetError(iClient, iTargetCount);
		return Plugin_Handled;
	}

	for (int i = 0; i < iTargetCount; i++) {
		ForcePlayerSuicide(iTargetList[i]);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Slayed", g_cConfig[CONFIG_TARGET], cTargetName);

	return Plugin_Handled;
}

public Action Command_Slap(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_PLAYERCOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_slap <#userid|name> [damage]", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	int iAmount = 0;

	if (iArgs > 1) {
		char cArgs2[255];
		GetCmdArg(2, cArgs2, sizeof(cArgs2));

		if (StringToIntEx(cArgs2, iAmount) == 0 || iAmount < 0) {
			CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Amount", g_cConfig[CONFIG_DATA], cArgs2, g_cConfig[CONFIG_TEXT]);
			return Plugin_Handled;
		}
	}

	char cTargetName[MAX_TARGET_LENGTH];
	int iTargetList[MAXPLAYERS + 1], iTargetCount;
	bool bTnIsMl;

	iTargetCount = ProcessTargetString(cArgs1, iClient, iTargetList, sizeof(iTargetList), COMMAND_FILTER_ALIVE, cTargetName, sizeof(cTargetName), bTnIsMl);

	if (iTargetCount <= 0) {
		ReplyToProcessTargetError(iClient, iTargetCount);
		return Plugin_Handled;
	}

	for (int i = 0; i < iTargetCount; i++) {
		SlapPlayer(iTargetList[i], iAmount, true);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Slapped", g_cConfig[CONFIG_TARGET], cTargetName, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_DATA], iAmount, g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

public Action Command_Rename(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_PLAYERCOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_rename <#userid|name> [newname]", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255], cArgs2[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));
	GetCmdArg(2, cArgs2, sizeof(cArgs2));

	char cTargetName[MAX_TARGET_LENGTH];
	int iTargetList[MAXPLAYERS + 1], iTargetCount;
	bool bTnIsMl;

	iTargetCount = ProcessTargetString(cArgs1, iClient, iTargetList, sizeof(iTargetList), COMMAND_FILTER_ALIVE, cTargetName, sizeof(cTargetName), bTnIsMl);

	if (iTargetCount <= 0) {
		ReplyToProcessTargetError(iClient, iTargetCount);
		return Plugin_Handled;
	}

	char cBuffer[255];

	for (int i = 0; i < iTargetCount; i++) {
		if (strlen(cArgs2) == 0 || StrEqual(cArgs2, "random")) {
			Format(cArgs2, sizeof(cArgs2), "random");

			RandomizeName(iTargetList[i], cBuffer);
		} else {
			Format(cBuffer, sizeof(cBuffer), "%s", cArgs2);
		}

		SetClientName(iTargetList[i], cBuffer);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Renamed", g_cConfig[CONFIG_TARGET], cTargetName, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_DATA], cArgs2);
	return Plugin_Handled;
}

void RandomizeName(int iTarget, char[] cBuffer) {
	char cTargetName[MAX_NAME_LENGTH];
	GetClientName(iTarget, cTargetName, sizeof(cTargetName));

	int iNameLength = strlen(cTargetName);
	cBuffer[0] = '\0';

	for (int i = 0; i < iNameLength; i++) {
		cBuffer[i] = cTargetName[GetRandomInt(0, iNameLength - 1)];
	}

	cBuffer[iNameLength] = '\0';
}
