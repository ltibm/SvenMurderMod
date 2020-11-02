class MurderKillerEntity : MurderEntityBase
{
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		return MurderEntityBase::KeyValue( szKey, szValue );
	}
	void PlayerThink(CBasePlayer@ cPlayer)
	{
		if(!cPlayer.IsAlive() || cPlayer.pev.targetname != "killer") return;
		if(g_Engine.time - g_CurrentGame.RoundStartedTime < 4)
		{
			MurderGameAction::FadeBlack(@cPlayer);
		}
		else
		{
			g_PlayerFuncs.ScreenFade(@cPlayer, Vector(255, 0, 0), 1, 1, 30, FFADE_IN);
		}

		if(MurderGameCvar::Killer_SmokeTime.GetInt() > 0)
		{
			MurderGame@ game = cast<MurderGame@>(@g_CurrentGame);
			float lastKilledAt =  game.MurderKillerData.GetLastKilledTime(@cPlayer);
			if(lastKilledAt + MurderGameCvar::Killer_SmokeTime.GetFloat() < g_Engine.time)
			{
				Effects::Smoke(cPlayer.EyePosition());
			}
		}
	}
}
namespace MurderKillerEntityNS
{
	void Register()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "MurderKillerEntity", "murder_killer" );
	}
	void Spawn(dictionary@ keys = null)
	{
		CBaseEntity@ entity = g_EntityFuncs.CreateEntity( "murder_killer", @keys, false);
	}
}
