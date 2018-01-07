/* Base Plugins+
*
* Copyright (C) 2017-2018 Oscar Wos // github.com/OSCAR-WOS | theoscar@protonmail.com
*
* This program is free software: you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the Free
* Software Foundation, either version 3 of the License, or (at your option)
* any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this program. If not, see http://www.gnu.org/licenses/.
*/

// Compiler Info: Pawn 1.8 - build 6040

#define PLUGIN_VERSION "1.10"

#include <sourcemod>
#include <csgocolors>
#include <sdktools>

enum CONFIGS {
	CONFIG_PREFIX,
	CONFIG_TEXT,
	CONFIG_DATA,
	CONFIG_ADMIN,
	CONFIG_TARGET
}

enum PLUGINS {
	PLUGIN_BASECOMMANDS,
	PLUGIN_FUNCOMMANDS,
	PLUGIN_PLAYERCOMMANDS
}

char g_cConfig[CONFIGS][64];
bool g_bPluginEnabled[PLUGINS];

StringMap g_smProtectedCvars;

public Plugin myinfo = {
	name = "BasePlugins+",
	author = "Oscar Wos (OSWO)",
	description = "A customisable version of the base plugins included with SourceMod",
	version = PLUGIN_VERSION,
	url = "https://github.com/OSCAR-WOS / https://steamcommunity.com/id/OSWO",
}

#include "Base-Plugins-Plus/basecommands.sp"
#include "Base-Plugins-Plus/funcommands.sp"
#include "Base-Plugins-Plus/playercommands.sp"

public void OnPluginStart() {
	LoadTranslations("base-plugins-plus.phrases");

	RegAdminCmd("sm_reloadbaseconfig", Command_ReloadBaseConfig, ADMFLAG_RCON, "Reload the Config file for BasePlugins+");
	LoadConfig();

	AddCommandListener(Listener_Global);
	CreateTimer(1.0, Timer_Second, _, TIMER_REPEAT);

	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
}

public Action Listener_Global(int iClient, const char[] cCommand, int iArgc) {
	if (!IsValidClient(iClient)) return Plugin_Continue;

	if (CommandExists(cCommand)) {
		if (!CheckCommandAccess(iClient, cCommand, 0, false)) {
			CReplyToCommand(iClient, "{red}%t", "No Access");
			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

public Action Timer_Second(Handle hTimer, any aData) {
	Timer_FunCommands();
}

public Action Event_RoundEnd(Event eEvent, const char[] cName, bool bDontBroadcast) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && g_iFreeze[i] != -1) {
			UnfreezePlayer(i);
		}
	}
}

public Action Command_ReloadBaseConfig(int iClient, int iArgs) {
	LoadConfig();

	CReplyToCommand(iClient, "%s %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_TEXT], "Reloaded Config", g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT]);
	return Plugin_Handled;
}

void LoadConfig() {
	char cPath[512];
	BuildPath(Path_SM, cPath, sizeof(cPath), "configs/base-plugins-plus.txt");
	if (!FileExists(cPath)) SetFailState("[Base-Plugins-Plus] - Couldn't Find configs/base-plugins-plus.txt");

	KeyValues kConfig = new KeyValues("");
	kConfig.ImportFromFile(cPath);

	kConfig.JumpToKey("BasePlugins");
	kConfig.GotoFirstSubKey();

	kConfig.GetString("prefix", g_cConfig[CONFIG_PREFIX], 64);
	kConfig.GetString("text", g_cConfig[CONFIG_TEXT], 64);
	kConfig.GetString("data", g_cConfig[CONFIG_DATA], 64);
	kConfig.GetString("admin", g_cConfig[CONFIG_ADMIN], 64);
	kConfig.GetString("target", g_cConfig[CONFIG_TARGET], 64);

	g_bPluginEnabled[PLUGIN_BASECOMMANDS] = view_as<bool>(kConfig.GetNum("basecommands"));
	g_bPluginEnabled[PLUGIN_FUNCOMMANDS] = view_as<bool>(kConfig.GetNum("funcommands"));
	g_bPluginEnabled[PLUGIN_PLAYERCOMMANDS] = view_as<bool>(kConfig.GetNum("playercommands"));

	if (g_bPluginEnabled[PLUGIN_BASECOMMANDS]) {
		if (!CommandExists("sm_kick")) RegAdminCmd("sm_kick", Command_Kick, ADMFLAG_KICK, "sm_kick <#userid|name> [reason]");
		if (!CommandExists("sm_reloadadmins")) RegAdminCmd("sm_reloadadmins", Command_ReloadAdmins, ADMFLAG_BAN, "sm_reloadadmins");
		if (!CommandExists("sm_cancelvote")) RegAdminCmd("sm_cancelvote", Command_CancelVote, ADMFLAG_VOTE, "sm_cancelvote");
		if (!CommandExists("sm_map")) RegAdminCmd("sm_map", Command_Map, ADMFLAG_CHANGEMAP, "sm_map <map>");
		if (!CommandExists("sm_rcon")) RegAdminCmd("sm_rcon", Command_Rcon, ADMFLAG_RCON, "sm_rcon <args>");
		if (!CommandExists("sm_execcfg")) RegAdminCmd("sm_execcfg", Command_ExecCfg, ADMFLAG_RCON, "sm_execcfg <cfg>");

		if (!CommandExists("sm_cvar")) RegAdminCmd("sm_cvar", Command_Cvar, ADMFLAG_CONVARS, "sm_cvar <cvar> [value]");
		if (!CommandExists("sm_protectcvar")) RegAdminCmd("sm_protectcvar", Command_ProtectCvar, ADMFLAG_ROOT, "sm_protectcvar <cvar>");
		if (!CommandExists("sm_resetcvar")) RegAdminCmd("sm_resetcvar", Command_ResetCvar, ADMFLAG_CONVARS, "sm_resetcvar <cvar>");

		if (!CommandExists("sm_reloadplugin")) RegAdminCmd("sm_reloadplugin", Command_ReloadPlugin, ADMFLAG_RCON, "sm_reloadplugin <plugin>");
		if (!CommandExists("sm_unloadplugin")) RegAdminCmd("sm_unloadplugin", Command_UnloadPlugin, ADMFLAG_RCON, "sm_unloadplugin <plugin>");
		if (!CommandExists("sm_loadplugin")) RegAdminCmd("sm_loadplugin", Command_LoadPlugin, ADMFLAG_RCON, "sm_loadplugin <plugin>");

		g_cvMapChangeDelay = CreateConVar("sm_mapchange_delay", "5.0", "Sets the delay for map changes when using sm_map", 0, true, 0.0, true, 60.0);
	}

	if (g_bPluginEnabled[PLUGIN_FUNCOMMANDS]) {
		if (!CommandExists("sm_noclip")) RegAdminCmd("sm_noclip", Command_Noclip, ADMFLAG_SLAY|ADMFLAG_CHEATS, "sm_noclip <#userid|name>");
		if (!CommandExists("sm_gravity")) RegAdminCmd("sm_gravity", Command_Gravity, ADMFLAG_SLAY, "sm_gravity <#userid|name> [amount]");
		if (!CommandExists("sm_burn")) RegAdminCmd("sm_burn", Command_Burn, ADMFLAG_SLAY, "sm_burn <#userid|name> [time]");
		if (!CommandExists("sm_freeze")) RegAdminCmd("sm_freeze", Command_Freeze, ADMFLAG_SLAY, "sm_freeze <#userid|name> [time]");

		g_cvBurnDuration = CreateConVar("sm_burn_duration", "20.0", "Sets the default duration of sm_burn victims.", 0, true, 0.5, true, 20.0);
		g_cvFreezeDuration = CreateConVar("sm_freeze_duration", "10.0", "Sets the default duration for sm_freeze victims", 0, true, 1.0, true, 120.0);
	}

	if (g_bPluginEnabled[PLUGIN_PLAYERCOMMANDS]) {
		if (!CommandExists("sm_slay")) RegAdminCmd("sm_slay", Command_Slay, ADMFLAG_SLAY, "sm_slay <#userid|name>");
		if (!CommandExists("sm_slap")) RegAdminCmd("sm_slap", Command_Slap, ADMFLAG_SLAY, "sm_slap <#userid|name> [damage]");
		if (!CommandExists("sm_rename")) RegAdminCmd("sm_rename", Command_Rename, ADMFLAG_SLAY, "sm_rename <#userid|name> [newname]");
	}

	AutoExecConfig(true, "basepluginsplus");

	g_smProtectedCvars = new StringMap();

	BuildPath(Path_SM, cPath, sizeof(cPath), "configs/protected-cvars.txt");
	if (!FileExists(cPath)) SetFailState("[Base-Plugins-Plus] - Couldn't Find configs/protected-cvars.txt");

	char cBuffer[512];
	File fProtectedCvars = OpenFile(cPath, "r");

	while (!fProtectedCvars.EndOfFile()) {
		if (fProtectedCvars.ReadLine(cBuffer, sizeof(cBuffer))) {
			if (!IsCvarProtected(cBuffer)) {
				ProtectCvar(cBuffer, false);
			}
		}
	}

	delete kConfig;
	delete fProtectedCvars;
}

void ReplyToProcessTargetError(int iClient, int iReason) {
	char cTranslations[64];
	Format(cTranslations, sizeof(cTranslations), "Target Error %i", iReason * -1);

	CReplyToCommand(iClient, "%s %sError! %s%t", g_cConfig[CONFIG_PREFIX], g_cConfig[CONFIG_DATA], g_cConfig[CONFIG_TEXT], cTranslations);
}

bool AllowedToModifyCvar(int iClient, const char[] cCvarName) {
	ConVar cvConvar = FindConVar(cCvarName);

	int iClientFlags = (iClient == 0 ? ADMFLAG_ROOT : GetUserFlagBits(iClient));

	if (iClientFlags & ADMFLAG_ROOT) return true;
	if (cvConvar.Flags & FCVAR_PROTECTED) return ((iClientFlags & ADMFLAG_PASSWORD) == ADMFLAG_PASSWORD);
	if (StrEqual(cCvarName, "sv_cheats")) return ((iClientFlags & ADMFLAG_CHEATS) == ADMFLAG_CHEATS);
	if (!IsCvarProtected(cCvarName)) return true;

	return false;
}

void ProtectCvar(const char[] cCvarName, bool bWriteToFile) {
	g_smProtectedCvars.SetValue(cCvarName, 1);

	if (bWriteToFile) {
		char cPath[512];
		BuildPath(Path_SM, cPath, sizeof(cPath), "configs/protected-cvars.txt");

		File fProtectedCvars = OpenFile(cPath, "a");
		fProtectedCvars.WriteLine(cCvarName);

		delete fProtectedCvars;
	}
}

bool IsCvarProtected(const char[] cCvarName) {
	int iTemp;
	return g_smProtectedCvars.GetValue(cCvarName, iTemp);
}

bool IsValidClient(int iClient) {
	if (iClient > 0 && iClient <= MaxClients && IsValidEntity(iClient) && IsClientConnected(iClient) && IsClientInGame(iClient) && !IsFakeClient(iClient)) {
		return true;
	}

	return false;
}
