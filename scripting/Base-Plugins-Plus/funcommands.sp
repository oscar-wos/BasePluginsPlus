ConVar g_cvBurnDuration;
ConVar g_cvFreezeDuration;

int g_iFreeze[MAXPLAYERS + 1] = { -1, ... };

public Action Command_Noclip(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_FUNCOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_noclip <#userid|name>", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
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
		NoclipPlayer(iTargetList[i]);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Noclip Toggled", g_cConfig[CONFIG_TARGET], cTargetName);

	return Plugin_Handled;
}

public Action Command_Gravity(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_FUNCOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_gravity <#userid|name> [amount]", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	float fAmount = 1.0;

	if (iArgs > 1) {
		char cArgs2[255];
		GetCmdArg(2, cArgs2, sizeof(cArgs2));

		if (StringToFloatEx(cArgs2, fAmount) == 0) {
			CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Amount", g_cConfig[CONFIG_DATA], cArgs2, g_cConfig[CONFIG_TEXT]);
			return Plugin_Handled;
		}

		if (fAmount < 0.0) {
			fAmount = 0.0;
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
		SetEntityGravity(iTargetList[i], fAmount);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Set Gravity", g_cConfig[CONFIG_TARGET], cTargetName, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_DATA], fAmount);

	return Plugin_Handled;
}

public Action Command_Burn(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_FUNCOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_burn <#userid|name> [time]", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	float fAmount = g_cvBurnDuration.FloatValue;

	if (iArgs > 1) {
		char cArgs2[255];
		GetCmdArg(2, cArgs2, sizeof(cArgs2));

		if (StringToFloatEx(cArgs2, fAmount) == 0) {
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
		IgniteEntity(iTargetList[i], fAmount);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Set Burn", g_cConfig[CONFIG_TARGET], cTargetName, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_DATA], RoundToFloor(fAmount), g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

public Action Command_Freeze(int iClient, int iArgs) {
	if (!g_bPluginEnabled[PLUGIN_FUNCOMMANDS]) {
		CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reload Plugin", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	if (iArgs < 1) {
		CReplyToCommand(iClient, "%s %s%t sm_freeze <#userid|name> [time]", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Invalid Args", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
		return Plugin_Handled;
	}

	char cArgs1[255];
	GetCmdArg(1, cArgs1, sizeof(cArgs1));

	float fAmount = g_cvFreezeDuration.FloatValue;

	if (iArgs > 1) {
		char cArgs2[255];
		GetCmdArg(2, cArgs2, sizeof(cArgs2));

		if (StringToFloatEx(cArgs2, fAmount) == 0) {
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
		FreezePlayer(iTargetList[i], fAmount);
	}

	char cTag[64];
	Format(cTag, sizeof(cTag), "%s %s", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_ADMIN]);

	CShowActivity2(iClient, cTag, "%s%t", g_cConfig[CONFIG_TEXT], "Set Freeze", g_cConfig[CONFIG_TARGET], cTargetName, g_cConfig[CONFIG_TEXT], g_cConfig[CONFIG_DATA], RoundToFloor(fAmount), g_cConfig[CONFIG_TEXT]);

	return Plugin_Handled;
}

void Timer_FunCommands() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i)) {
			if (g_iFreeze[i] > 0) g_iFreeze[i]--;

			if (g_iFreeze[i] == 0) UnfreezePlayer(i);
		}
	}
}

void NoclipPlayer(int iTarget) {
	MoveType mtTarget = GetEntityMoveType(iTarget);

	if (mtTarget != MOVETYPE_NOCLIP) {
		SetEntityMoveType(iTarget, MOVETYPE_NOCLIP);
	} else {
		SetEntityMoveType(iTarget, MOVETYPE_WALK);
	}
}

void FreezePlayer(int iTarget, float fAmount) {
	g_iFreeze[iTarget] = RoundToFloor(fAmount);

	SetEntityMoveType(iTarget, MOVETYPE_NONE);
	SetEntityRenderColor(iTarget, 0, 128, 255, 192);
}

void UnfreezePlayer(int iTarget) {
	g_iFreeze[iTarget] = -1;

	if (IsPlayerAlive(iTarget) && GetEntityMoveType(iTarget) == MOVETYPE_NONE) {
		SetEntityMoveType(iTarget, MOVETYPE_WALK);
		SetEntityRenderColor(iTarget, 255, 255, 255, 255);
	}
}
