#include "CSKnife_Modded/weapon_csknifem"

CCVar@ cvar_KnifeThrow;
CCVar@ cvar_KnifeDefaultGive;
CCVar@ cvar_KnifeGlowThrowingDrop;
CCVar@ cvar_KnifeEnabled;
CCVar@ cvar_KnifeMaxAmmo;
CCVar@ cvar_UseTRModel;
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Lt." );
	g_Module.ScriptInfo.SetContactInfo( "https://steamcommunity.com/id/ibmlt/" );
	@cvar_KnifeEnabled = @CCVar("knife_enabled", 1, "Enable throwing knife", ConCommandFlag::AdminOnly); 
	@cvar_KnifeThrow = @CCVar("knife_allow_throw", 0, "Enable throwing knife", ConCommandFlag::AdminOnly); 
	@cvar_KnifeDefaultGive = @CCVar("knife_default_give", 3, "Default give for knife ammo", ConCommandFlag::AdminOnly);
	@cvar_KnifeMaxAmmo = @CCVar("knife_max_ammo", 6, "Default give for knife ammo", ConCommandFlag::AdminOnly);
	@cvar_KnifeGlowThrowingDrop = @CCVar("knife_glow_throwing_drop", 1, "Glow dropped throwed knife", ConCommandFlag::AdminOnly);
	@cvar_UseTRModel = @CCVar("knife_tr_model", 0, "Enable tr model", ConCommandFlag::AdminOnly); 
}

void MapInit()
{
	if(cvar_KnifeEnabled.GetInt() > 0)
	{
		//weapon_csknife_pos = 8;
		RegisterCSKNIFEM();
	}
}