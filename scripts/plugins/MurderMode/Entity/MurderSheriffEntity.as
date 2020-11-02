class MurderSheriffEntity : MurderEntityBase
{
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		return MurderEntityBase::KeyValue( szKey, szValue );
	}
	void PlayerThink(CBasePlayer@ cPlayer)
	{
		if(!cPlayer.IsAlive() || cPlayer.pev.targetname != "sheriff") return;
		if(g_Engine.time - g_CurrentGame.RoundStartedTime < 4)
		{
			MurderGameAction::FadeBlack(@cPlayer);
		}
		else
		{
			g_PlayerFuncs.ScreenFade(@cPlayer, Vector(0, 0, 255), 1, 1, 30, FFADE_IN);
		}
		MurderGameAction::CheckWeaponClipAndUnAmmo(@cPlayer);
	}
}
namespace MurderSheriffEntityNS
{
	void Register()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "MurderSheriffEntity", "murder_sheriff" );
	}
	void Spawn(dictionary@ keys = null)
	{
		CBaseEntity@ entity = g_EntityFuncs.CreateEntity( "murder_sheriff", @keys, false);
	}
}
