#include "../xp_phrase"
#include "../XPUtils/EasyHook/XPEasyHook"
#include "../XPUtils/PlayerData/XPPlayerData"
#include "MurderMode/MurderMode"
GameType@ g_CurrentGame = null;
HookEngine@ g_HookEngine = null;
CCVar@ cvar_BgMusicEnabled;
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Lt." );
	g_Module.ScriptInfo.SetContactInfo( "https://steamcommunity.com/id/ibmlt/" );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
	RegisterML("lt_murder.txt");
	@g_HookEngine = HookEngine();
	@g_CurrentGame = MurderGame();
	@cvar_BgMusicEnabled = @CCVar("gametype_bg_enabled", 1, "Enable background music", ConCommandFlag::AdminOnly); 
	if(g_CurrentGame.IsMapSupported())
	{
		g_CurrentGame.SetEnabled(true);
	}
	PrintLine("Murder Mode Is Loaded");
}
void PluginExit()
{
	if(g_HookEngine !is null)
	{	
		g_HookEngine.RemoveHook("*");
		g_HookEngine.ClearBinders();
		g_CurrentGame.ClearTimers();
	}
	if(g_CurrentGame !is null && g_CurrentGame.ActiveMusic !is null)
	{
		g_EntityFuncs.Remove(@g_CurrentGame.ActiveMusic);
	}
	@g_CurrentGame = null;
	@g_HookEngine = null;
}
void MapInit()
{
	if(g_HookEngine is null)
	{
		@g_HookEngine = HookEngine();
	}
	if(g_CurrentGame is null)
	{
		@g_CurrentGame = MurderGame();
	}
	if(g_CurrentGame.IsMapSupported())
	{
		g_CurrentGame.SetEnabled(true);
		g_CurrentGame.MapInit();
	}
	else
	{
		g_HookEngine.ClearBinders();
		@g_HookEngine = null;
		g_CurrentGame.ClearTimers();
		@g_CurrentGame = null;
	}
}
void MapStart()
{
	if(g_CurrentGame !is null && g_CurrentGame.IsEnabled())
	{
		g_CurrentGame.MapStart();
	}
}
void MapActivate()
{
	if(g_CurrentGame !is null && g_CurrentGame.IsEnabled())
	{
		g_CurrentGame.MapActivate();
	}
}
HookReturnCode MapChange(const string& in szNextMap)
{
	if(g_HookEngine !is null)
	{
		g_HookEngine.MapChange(szNextMap);
	}
	PluginExit();
	return HOOK_CONTINUE;
}

abstract class GameType : XPHookBinderBase
{
	private CScheduledFunction@ gametypeTick;
	private CScheduledFunction@ gameMessageTick;
	private CScheduledFunction@ playerMessageTick;
	private float roundStartedTime;
	float RoundStartedTime
	{
		get const
		{
			return this.roundStartedTime;
		}
		set
		{
			this.roundStartedTime = value;
		}
	}
	void MapInit()
	{
	}
	void MapActivate()
	{
		
	}
	void MapStart()
	{
	}
	private int roundCount = 0;
	int RoundCount
	{
		get const
		{
			return this.roundCount;
		}
		set
		{
			this.roundCount = value;
		}
	}
	CBaseEntity@ ActiveMusic;
	void RoundStart() final
	{
		if(!this.InRound() && this.RoundReady())
		{
			this.OnRoundStart();
		}
	}
	//-1 draw, -2  only reset timer position e.g
	void RoundEnd(int winnerTeam = -2) final
	{
		if(this.InRound())
		{
			this.OnRoundEnd(winnerTeam);
		}
	}
	protected bool OnRoundStart()
	{
		return true;
	}
	protected bool OnRoundEnd(int winnerTeam = -2, bool flash = true)
	{
		return true;
	}
	protected void AttemptRoundStart()
	{
		this.RoundStartedTime = g_Engine.time;
	}
	void SetEnabled(bool value)
	{
	}
	bool IsEnabled()
	{
		return false;
	}
	bool IsMapSupported()
	{
		return false;
	}
	void ResetAllScores()
	{
	}
	bool RoundReady()
	{
		return false;
	}
	bool IsBonusRound()
	{
		return false;
	}
	bool InRound()
	{
		return false;
	}
	void CheckRound()
	{
	}
	//-1 is infinite
	float GetTimeLeft()
	{
		return -1;
	}
	void SetTimeLeft(float value)
	{
	}
	GameType()
	{
	}
	protected void SetupTimers() final
	{
		@this.gametypeTick = @g_Scheduler.SetInterval(@this, "GameTick", 1.00);
		@this.gameMessageTick = @g_Scheduler.SetInterval(@this, "MessageTick", 1.00);
		@this.playerMessageTick = @g_Scheduler.SetInterval(@this, "PlayerMessageTickTimer", 1.00);		
	}
	~GameType()
	{
		this.ClearTimers();
	}
	private void PlayerMessageTickTimer()
	{
		for (int i = 1; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			this.PlayerMessageTick(@cPlayer);
		}
	}
	void PlayerMessageTick(CBasePlayer@ cPlayer)
	{
		
	}
	void GameTick()
	{
	}
	void MessageTick()
	{
	}
	void PlayMusic(string name) final
	{
		
		if(this.ActiveMusic !is null)
		{
			if(g_EntityFuncs.IsValidEntity(this.ActiveMusic.edict()))
			{
				g_EntityFuncs.Remove(@this.ActiveMusic);
			}
			@this.ActiveMusic = null;

		}
		if(cvar_BgMusicEnabled.GetInt() == 0) return;
		@this.ActiveMusic = EntityActions::PlayAmbientMusic(name, 2.0);
	}
	void ClearTimers()
	{
		g_Scheduler.RemoveTimer(@this.gametypeTick);
		@this.gametypeTick = null;
		g_Scheduler.RemoveTimer(@this.gameMessageTick);
		@this.gameMessageTick = null;		
		g_Scheduler.RemoveTimer(@this.playerMessageTick);
		@this.playerMessageTick = null;
	}
	void SetPlayerAbilites(CBasePlayer@ cPlayer, bool islazy = false)
	{
		if(islazy)
		{
			g_Scheduler.SetTimeout(@this, "SetPlayerAbilitesLazy", Math.RandomFloat(0.20, 0.35), @cPlayer);
		}
	}
	void SetPlayerAbilitesLazy(CBasePlayer@ cPlayer)
	{
	}
	string GetPath()
	{
		return "";
	}
	void ExecuteCFG(string name) final
	{
		GameType::ExecuteConfig(this.GetPath() + name);
	}
}

namespace Effects
{
	void Smoke(Vector pos, string sprite="sprites/steam1.spr", int scale=10, int frameRate=15,
	NetworkMessageDest msgType=MSG_BROADCAST, edict_t@ dest=null)
	{
		NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
		m.WriteByte(TE_SMOKE);
		m.WriteCoord(pos.x);
		m.WriteCoord(pos.y);
		m.WriteCoord(pos.z);
		m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
		m.WriteByte(scale);
		m.WriteByte(frameRate);
		m.End();
	}
}
namespace GameType
{
	void ExecuteConfig(string cfgname)
	{
		g_EngineFuncs.ServerCommand("exec " + cfgname + "\r\n");
	}
	void ShowScoreMessage(CBasePlayer@ cPlayer, string message, bool isml = true)
	{
		if(cPlayer is null)
		{
			PlayerActions::ForEach(function(player, parameters) {
				string message;
				bool isml;
				parameters.get("message", message);
				parameters.get("isml", isml);
				GameType::ShowScoreMessage(@player, message, isml);
			}, {{"message", message}});
			return;
		}
		HUDTextParams htp;
		htp.x = 0.2;
		htp.y = 0.1;
		htp.effect = 0;
		htp.r1 = 125;
		htp.g1 = 255;
		htp.b2 = 170;
		htp.holdTime = 1;
		htp.fxTime = 0.1;
		htp.fadeinTime = 0.1;
		htp.fadeoutTime = 0.2;
		htp.channel = 1;
		if(isml) message = MLText(@cPlayer, message);
		g_PlayerFuncs.HudMessage(cPlayer, htp, message);
	}
	void FlashMessage(CBasePlayer@ cPlayer, string message, bool isml = true)
	{
		if(cPlayer is null)
		{
			PlayerActions::ForEach(function(player, parameters) {
				string message;
				bool isml;
				parameters.get("message", message);
				parameters.get("isml", isml);
				GameType::FlashMessage(@player, message, isml);
			}, {{"message", message}, {'isml', isml}});
			return;
		}
		HUDTextParams hudText;
		hudText.x = 0.4;
		hudText.y = 0.4;
		hudText.effect = 0;
		hudText.r1 = 125;
		hudText.g1 = 255;
		hudText.b2 = 0;
		hudText.holdTime = 5;
		hudText.fxTime = 0.1;
		hudText.fadeinTime = 0.1;
		hudText.fadeoutTime = 0.2;
		hudText.channel = 3;
		if(isml) message = MLText(@cPlayer, message);
		g_PlayerFuncs.HudMessage(cPlayer, hudText, message);
	}
}


void PrintLine(string str)
{
	g_EngineFuncs.ServerPrint("\r\n" + str + "\r\n");
}
namespace VectorUtils
{
	enum ANGLEVECTORSFLAG
	{
		ANGLEVECTORS_FORWARD = 0,
		ANGLEVECTORS_RIGHT,
		ANGLEVECTORS_UP
	}
	Vector AngleVector(Vector flAngle, ANGLEVECTORSFLAG Aflag)
	{
		Vector v_forward, v_right, v_up, v_return;
		g_EngineFuncs.AngleVectors(flAngle, v_forward, v_right, v_up);
		switch (Aflag)
		{
			case ANGLEVECTORS_FORWARD:
				v_return = v_forward;
				break;
			case ANGLEVECTORS_RIGHT:
				v_return = v_right;
				break;
			case ANGLEVECTORS_UP:
				v_return = v_up;
				break;
		}
		return v_return;
	}
	Vector VelocityByAim( CBaseEntity@ entity, float velocity)
	{
		//Math.MakeVectors(entity.pev.v_angle);
		g_EngineFuncs.MakeVectors(entity.pev.v_angle);
		return g_Engine.v_forward * velocity;
	}
}

namespace EntityActions
{
	array<CBaseEntity@> GetEntitiesByClassname(string nm, string filter = "")
	{
		array<CBaseEntity@> aEnts;
		CBaseEntity@ pEnt = null;
		while( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, nm ) ) !is null )
		{
			aEnts.insertLast(@pEnt);
		}
		return aEnts;
	}
	void SetRendering(CBaseEntity@ entity, int rfx = kRenderFxNone, float r = 255, float g = 255, float b = 255, int rmode = kRenderNormal, float namt = 16)
	{
		if(entity is null) return;
		entity.pev.renderfx = rfx;
		Vector rClr;
		rClr.x = r;
		rClr.y = g;
		rClr.z = b;
		entity.pev.rendermode = rmode;
		entity.pev.renderamt = namt;
		entity.pev.rendercolor = rClr;
	}
	void SetDefaultRender(CBaseEntity@ entity)
	{
		SetRendering(@entity, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
	}
	CBaseEntity@ PlayAmbientMusic(string fileloc, float volume)
	{
		CBaseEntity@ mTEnt = g_EntityFuncs.CreateEntity("ambient_music", null, false);
		if(mTEnt is null) return null;
		edict_t@ edict_mTEnt = @mTEnt.edict();
		g_EntityFuncs.DispatchKeyValue(@edict_mTEnt, "message", fileloc);
		g_EntityFuncs.DispatchKeyValue(@edict_mTEnt, "volume", volume);
		edict_mTEnt.vars.flags = 0;
		edict_mTEnt.vars.spawnflags = 0;
		g_EntityFuncs.DispatchSpawn(@edict_mTEnt);
		return @mTEnt;
	}
}
namespace PlayerActions
{
	funcdef bool PlayerPredicateHandler(CBasePlayer@, dictionary@);
	funcdef void PlayerActionHandler(CBasePlayer@, dictionary@);
	array<CBasePlayer@> Get(PlayerPredicateHandler@ predicate = null, dictionary@ parameters = null)
	{
		array<CBasePlayer@> players;
		for (int i = 1; i <= g_Engine.maxClients; i++) {
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			if(predicate !is null && !predicate(@cPlayer, @parameters)) continue;
			players.insertLast(@cPlayer);
		}
		return players;
		
	}
	void ForEach(PlayerActionHandler@ action, dictionary@ parameters = null)
	{
		if(action is null) return;
		for (int i = 1; i <= g_Engine.maxClients; i++) {
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			action(@cPlayer, @parameters);
		}
	}
	string GetUserSteamId(CBasePlayer@ cPlayer)
	{
		return g_EngineFuncs.GetPlayerAuthId(cPlayer.edict());
	}
	CBasePlayerItem@ GetUserWeaponByName(CBasePlayer@ cPlayer, string wname)
	{
		if(cPlayer is null) return null;
		for( size_t uiIndex = 0; uiIndex < MAX_ITEM_TYPES; ++uiIndex )
		{
			CBasePlayerItem@ pEnt = cPlayer.m_rgpPlayerItems(uiIndex);
			if( pEnt !is null )
			{
				do
				{
					if(pEnt.pev.classname == wname) return @pEnt;
				}
				while( ( @pEnt = cast<CBasePlayerItem@>(pEnt.m_hNextItem.GetEntity()) ) !is null );
			}

		}
		return null;
	}
	string GetInfoValue(CBasePlayer@ cPlayer, string key)
	{
		if(cPlayer is null) return "";
		KeyValueBuffer@ nBuf = null;
		@nBuf = g_EngineFuncs.GetInfoKeyBuffer(cPlayer.edict());
		if(nBuf is null) return "";
		return nBuf.GetValue(key);
	}
	void SetInfoValue(CBasePlayer@ cPlayer, string key, string value)
	{
		if(cPlayer is null) return;
		KeyValueBuffer@ nBuf = null;
		@nBuf = g_EngineFuncs.GetInfoKeyBuffer(cPlayer.edict());
		if(nBuf is null) return;
		nBuf.SetValue(key, value);
	}
	void ClientCmd(CBasePlayer@ cPlayer, string Cmd)
	{
		ClientCmd(cPlayer.edict(), Cmd);
	}
	void ClientCmd(edict_t@ peditct, string Cmd)
	{
		NetworkMessage m(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_STUFFTEXT, peditct);
			m.WriteString( Cmd );
		m.End();
	}
	
	void StopAllMusic()
	{
		for (int i = 1; i <= g_Engine.maxClients; i++)
		{
			CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(tPlayer is null) continue;
			if(!tPlayer.IsConnected()) continue;
			//client_cmd(tPlayer, "");
			ClientCmd(tPlayer, "mp3 stop;stopsound;");

		}
	}
	void PlayMusic(CBasePlayer@ cPlayer, string musicname, bool stoponly = false, CBasePlayer@ except = null, bool nostop = false)
	{
		if(!nostop)
		{
			StopAllMusic();
			g_Scheduler.SetTimeout( "PlayMusic", 0.4, @cPlayer, musicname, stoponly, @except, true);
			return;
		}
		string sparams = "mp3 play \"" + musicname + "\"";
		if(musicname.ToLowercase().EndsWith(".wav"))
		{
			sparams = "play \"" + musicname + "\"";
		}
		if(cPlayer is null)
		{
			for (int i = 1; i <= g_Engine.maxClients; i++) {
				CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if(tPlayer is null || tPlayer == except || !tPlayer.IsConnected()) continue;
				if(stoponly)
				{
					ClientCmd(tPlayer, "mp3 stop;stopsound;");
				}
				else
				{
					ClientCmd(tPlayer, sparams);
				}
				
			}
			return;
		}
		if(!cPlayer.IsConnected()) return;
		if(stoponly)
		{
			ClientCmd(cPlayer, "mp3 stop;stopsound;");
			return;
		}
		ClientCmd(cPlayer, sparams);
	}
}
namespace FileUtils
{
	funcdef bool FileReadLineHandler(string& in, string& out);
	funcdef bool FileIsAnyLineHander(string& in);
	array<string> ReadAllLines(string filelocation, bool autotrim = false, FileReadLineHandler@ predicate = null)
	{
		array<string> readedLines;
		::File@ pFile = g_FileSystem.OpenFile(filelocation, OpenFile::READ);
		if(pFile is null ||!pFile.IsOpen()) return readedLines;  
		string cline;
		while(!pFile.EOFReached())
		{
			pFile.ReadLine(cline);
			if(autotrim) cline.Trim();

			bool insummary = false;
			string outtext = "";
			if(predicate !is null && !predicate(cline, outtext))
			{
				continue;
			}
			if(outtext != "") cline = outtext;
			readedLines.insertLast(cline);
		}		
		pFile.Close();
		return readedLines;
	}
	bool FileHasAnyInLines(string filelocation, FileIsAnyLineHander@ predicate, bool autotrim = true)
	{
		if(predicate is null) return false;
		::File@ pFile = g_FileSystem.OpenFile(filelocation, OpenFile::READ);
		if(pFile is null ||!pFile.IsOpen()) return false;  
		string cline;
		while(!pFile.EOFReached())
		{
			pFile.ReadLine(cline);
			if(autotrim) cline.Trim();
			if(cline.IsEmpty()) continue;
			if(predicate(cline))
			{
				pFile.Close();
				return true;
			}
		}		
		pFile.Close();
		return false;		
	}
}
void PlayMusic(CBasePlayer@ cPlayer, string musicname, bool stoponly = false, CBasePlayer@ except = null, bool nostop = false)
{
	PlayerActions::PlayMusic(@cPlayer, musicname, stoponly, @except, nostop);
}
void ClientPrintAllML(string mlName, array<string> params = {})
{
	for (int i = 1; i <= g_Engine.maxClients; i++) {
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if (pPlayer is null ||!pPlayer.IsPlayer() or !pPlayer.IsConnected()) continue;
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, MLText(pPlayer, mlName, params));
	}
}
int RandLongEx(int min, int max)
{
	Math.RandomLong(min, max);
	return Math.RandomLong(min, max);
	//DateTime d;
	//return g_PlayerFuncs.SharedRandomLong(d.ToUnixTimestamp(), min, max);
	
}
