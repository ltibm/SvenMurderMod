class MurderCivilEntity : MurderEntityBase
{
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		return MurderEntityBase::KeyValue( szKey, szValue );
	}
	void PlayerThink(CBasePlayer@ cPlayer)
	{

		if(!cPlayer.IsAlive() || cPlayer.pev.targetname != "civil") return;
		float blindTime = MurderGameCvar::Sheriff_BlindTime.GetFloat();
		int alpha = 20;
		if(blindTime > 0)
		{
			MurderGame@ game = cast<MurderGame@>(@g_CurrentGame);
			float lastblindTime = game.MurderGeneralData.GetLastBlindTime(@cPlayer);
			if(blindTime + lastblindTime > g_Engine.time)
			{
				alpha = 255;
			}
		}
		int green = 255;
		if(alpha == 255) green = 0;
		if(g_Engine.time - g_CurrentGame.RoundStartedTime < 4)
		{
			MurderGameAction::FadeBlack(@cPlayer);
		}
		else
		{
			g_PlayerFuncs.ScreenFade(@cPlayer, Vector(0, green, 0), 1, 1, alpha, FFADE_IN);
		}

	}
}
namespace MurderCivilEntityNS
{
	void Register()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "MurderCivilEntity", "murder_civil" );
	}
	void Spawn(dictionary@ keys = null)
	{
		CBaseEntity@ entity = g_EntityFuncs.CreateEntity( "murder_civil", @keys, false);
	}
}
