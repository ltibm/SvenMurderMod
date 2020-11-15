#include "Classes/_Includes"
#include "Entity/_Includes"
enum MurderPlayerType
{
	MurderPlayerType_Any,
	MurderPlayerType_Civil,
	MurderPlayerType_Killer,
	MurderPlayerType_Sheriff,
	MurderPlayerType_SheriffAndCivil
}
enum MurderBonusType
{
	MurderBonusType_Start,
	MurderBonusType_OneKillerAllSheriff,
	MurderBonusType_OneSheriffAllKiller,
	MurderBonusType_MidSheriffMidKiller,
	MurderBonusType_End
}
class HookEngine : XPHookBase
{
}
namespace MurderGameCvar
{
	bool cvarRegistered = false;
	CCVar@ Killer_SmokeTime;
	CCVar@ Sheriff_BlindTime;
	CCVar@ RoundTime;
	CCVar@ RoundWaitTime;
	CCVar@ BonusEnabled;
	CCVar@ Killer_SpeedFixedTime;
	void Register()
	{
		if(cvarRegistered) return;
		@Killer_SmokeTime = @CCVar("murdermode_killer_smoke_time", 60.0, "0: Disabled", ConCommandFlag::AdminOnly);
		@Sheriff_BlindTime = @CCVar("murdermode_sheriff_blind_time", 10.0, "0: Disabled", ConCommandFlag::AdminOnly); 
		@RoundTime = @CCVar("murdermode_round_time", 180.0, "0: Infinite", ConCommandFlag::AdminOnly); 
		@RoundWaitTime = @CCVar("murdermode_round_wait_time", 15.0, "Minimum 3", ConCommandFlag::AdminOnly); 
		@BonusEnabled = @CCVar("murdermode_bonus_enabled", 1, "Enable bonus map", ConCommandFlag::AdminOnly); 
		@Killer_SpeedFixedTime = @CCVar("murdermode_killer_slowspeed_time", 10, "Set killer speed slowly killing killer", ConCommandFlag::AdminOnly); 
		cvarRegistered = true;
	}
}
namespace MurderGameAction
{
	array<string> MusicThemes = 
	{
		"misc/xpss/murder_theme.mp3",
		"misc/xpss/murder_wup.mp3"
	};
	const string MusicBonusTheme = "misc/xpss/murder_bonus.mp3";
	const string MusicKillerWin = "misc/xpss/killer_win.mp3";
	const string MusicSheriffWin = "misc/xpss/sheriff_win.mp3";
	const string DefaultWeapon = "weapon_medkit";
	const string MeeleWeapon = "weapon_csknifem";
	const string SheriffWeapon = "weapon_357";
	const string MurderMapsFile = "scripts/plugins/MurderMode/murder_maps.ini";
	const string Path = "scripts/plugins/MurderMode/";
	
	
	array<Vector> playerGlows =
	{
		Vector(255, 0, 0),
		Vector(0, 255, 0),
		Vector(0, 0, 255),
		Vector(255, 165, 0),
		Vector(0, 255, 255),
		Vector(255, 0, 255),
		Vector(255, 255, 0),
		Vector(154, 205, 50),
		Vector(173, 255, 47),
		Vector(128, 0, 0),
		Vector(0, 128, 128)
	};
	void RemoveAll357()
	{
		auto entities = EntityActions::GetEntitiesByClassname(SheriffWeapon);
		for(uint i = 0; i < entities.length(); i++)
		{
			if(g_EntityFuncs.IsValidEntity(@entities[i].edict()))
			{
				entities[i].SetOrigin(Vector(9999, 9999, 9999));
			}

			
		}
		
	}
	const int TeamKiller = 1;
	const int TeamSheriff = 2;
	array<CBasePlayer@> GetPlayer(MurderPlayerType type = MurderPlayerType_Any, bool isalive = false)
	{
		return PlayerActions::Get(function(player, parameters) {
			MurderPlayerType type;
			bool isalive;
			int typenum = 0;
			parameters.get("type", typenum);
			parameters.get("isalive", isalive);
			type = MurderPlayerType(typenum);
			if(type == MurderPlayerType_Any) return true;
			if(isalive && !player.IsAlive()) return false;
			auto playerType = StringToMurderType(player.pev.targetname);
			if(type == MurderPlayerType_SheriffAndCivil)
			{
				if(playerType == MurderPlayerType_Civil || playerType == MurderPlayerType_Sheriff) return true;
				return false;
			}
			return playerType == type;
		}, {{"type", type}, {"isalive", isalive}});
	}
	int GetPlayerCount(MurderPlayerType type = MurderPlayerType_Any, bool isalive = false)
	{
		return GetPlayer(type, isalive).length();
	}
	void ResetAllPlayer()
	{
		PlayerActions::ForEach(function(player, parameters) {
			ResetPlayer(@player);
		});
	}
	void ResetPlayer(CBasePlayer@ cPlayer)
	{
		cPlayer.pev.targetname = "civil";
	}
	void SetSherrif(CBasePlayer@ cPlayer)
	{
		cPlayer.pev.targetname = "sheriff";
	}
	void SetKiller(CBasePlayer@ cPlayer)
	{
		cPlayer.pev.targetname = "killer";
	}
	MurderPlayerType StringToMurderType(string name)
	{
		if(name == "sheriff")
		{
			return MurderPlayerType_Sheriff;
		}
		else if(name == "killer")
		{
			return MurderPlayerType_Killer;
		}
		return MurderPlayerType_Civil;
	}
	void SetMedkitAmmoToZero(CBasePlayer@ pPlayer)
	{
		if(DefaultWeapon != "weapon_medkit") return;
		auto weaponItem = PlayerActions::GetUserWeaponByName(@pPlayer, "weapon_medkit");
		if(weaponItem !is null)
		{
			pPlayer.m_rgAmmo(weaponItem.PrimaryAmmoIndex(),  1);
			auto weaopon = cast<CBasePlayerWeapon@>(weaponItem);
			weaopon.m_flNextPrimaryAttack = weaopon.m_flNextSecondaryAttack = weaopon.m_flNextTertiaryAttack = g_Engine.time + 100;

		}
	}
	void CheckWeaponClipAndUnAmmo(CBasePlayer@ pPlayer)
	{
		auto weaponItem = PlayerActions::GetUserWeaponByName(@pPlayer, SheriffWeapon);


		if(weaponItem !is null)
		{
			MurderGame@ game = cast<MurderGame@>(@g_CurrentGame);
			int maxAmmo = weaponItem.iMaxAmmo1();
			int prindex = weaponItem.PrimaryAmmoIndex();
			int iminclip = 1;
			maxAmmo = 1;
			if(game.IsBonusRound())
			{
				if(game.GetBonusType() == MurderBonusType_OneSheriffAllKiller)
				{
					maxAmmo = 72;
					iminclip = 6;
					
				}
			}

			//pPlayer.m_rgAmmo(prindex,  maxAmmo);
			pPlayer.m_rgAmmo(prindex,  maxAmmo);
			auto weaponPtr  = @weaponItem.GetWeaponPtr();
			if(weaponPtr.m_iClip > iminclip) weaponPtr.m_iClip = iminclip;
		}
	}
	CBaseEntity@ Drop357(CBasePlayer@ pPlayer)
	{
		auto weaponItem = PlayerActions::GetUserWeaponByName(@pPlayer, SheriffWeapon);
		if(weaponItem !is null)
		{
			pPlayer.RemovePlayerItem(@weaponItem);
		}	
		Vector v_src = pPlayer.GetOrigin() + pPlayer.pev.view_ofs;
		Vector v_forward = VectorUtils::AngleVector(pPlayer.pev.v_angle, VectorUtils::ANGLEVECTORS_FORWARD);		
		Vector v_dest = v_src + v_forward * 100;
		auto droppedItem = @pPlayer.DropItem(SheriffWeapon, v_dest, pPlayer.pev.angles);
		EntityActions::SetRendering(@droppedItem, kRenderFxGlowShell, 0, 255, 255, kRenderNormal, 25);
		return droppedItem;
	}
	void FadeBlack(CBasePlayer@ cPlayer)
	{
		g_PlayerFuncs.ScreenFade(@cPlayer, Vector(0, 0, 0), 1, 1, 255, FFADE_IN);
	}
}
namespace MurderGameMessage
{
	string GetCivilMessage(CBasePlayer@ cPlayer)
	{
		MurderGame@ game = cast<MurderGame@>(@g_CurrentGame);
		float lastBlindTime = game.MurderGeneralData.GetLastBlindTime(@cPlayer);
		string extraMsg = "";
		float blindTime = MurderGameCvar::Sheriff_BlindTime.GetFloat();
		if(blindTime > 0)
		{
			if(lastBlindTime + blindTime > g_Engine.time)
			{
				int leftSec = int((lastBlindTime + blindTime) - g_Engine.time);
				extraMsg = "\r\n" + MLText(@cPlayer, "MURDER_HUD_CIVIL_BLIND", {leftSec});
			}
		}
		string message = "\r\n" + MLText(@cPlayer, "MURDER_HUD_CIVIL") + extraMsg;
		return message;	
	}
	string GetSheriffMessage(CBasePlayer@ cPlayer)
	{
		string extraMsg = "\r\n" +  MLText(@cPlayer, "MURDER_HUD_SHERIFF_CIVIL");
		string message = "\r\n" + MLText(@cPlayer, "MURDER_HUD_SHERIFF") + extraMsg;
		return message;
	}
	string GetKillerMessage(CBasePlayer@ cPlayer)
	{
		MurderGame@ game = cast<MurderGame@>(@g_CurrentGame);
		float lastkilled = game.MurderKillerData.GetLastKilledTime(@cPlayer);
		string extraMsg = "";
		float smokeTime = MurderGameCvar::Killer_SmokeTime.GetFloat();
		float slowTime = MurderGameCvar::Killer_SpeedFixedTime.GetFloat();
		if(smokeTime > 0)
		{
			if(g_Engine.time > lastkilled + smokeTime)
			{
				extraMsg = "\r\n" + MLText(@cPlayer, "MURDER_HUD_KILLER_SMOKE_ON");
			}
			else
			{
				int leftSec = int((lastkilled + smokeTime) - g_Engine.time);
				extraMsg = "\r\n" + MLText(@cPlayer, "MURDER_HUD_KILLER_SMOKE_REMAIN", {leftSec});
			}
		}
		if(slowTime > 0)
		{
			float lastkilledkiller = game.MurderKillerData.GetLastKilledKillerTime(@cPlayer);
			if(lastkilledkiller >= 0)
			{
				if(g_Engine.time < lastkilledkiller + slowTime)
				{
					int leftSec = int((lastkilledkiller + slowTime) - g_Engine.time);
					extraMsg += "\r\n" + MLText(@cPlayer, "MURDER_KILLER_SPEED_REDUCED", {leftSec});
				}
			}
		}
		string message = "\r\n" + MLText(@cPlayer, "MURDER_HUD_KILLER") + extraMsg;
		return message;
	}
}
