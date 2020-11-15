class MurderGeneralEntity : MurderEntityBase
{
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		return MurderEntityBase::KeyValue( szKey, szValue );
	}
	void PlayerThink(CBasePlayer@ cPlayer)
	{
		if(!cPlayer.IsAlive()) return;
		if(g_Engine.time - g_CurrentGame.RoundStartedTime < 10)
		{
			
			bool isenabled = ((cPlayer.pev.flags & FL_FROZEN) == FL_FROZEN);
			if(g_Engine.time - g_CurrentGame.RoundStartedTime < 3)
			{
				if(!isenabled)
				{
					cPlayer.pev.flags += FL_FROZEN;
				}
			}
			else
			{
				if(isenabled)
				{
					cPlayer.pev.flags -= FL_FROZEN;
				}
			}

		}
		float maxspeed = 270.0;
		MurderGame@ game = cast<MurderGame@>(@g_CurrentGame);
		if(cPlayer.pev.targetname == "killer")
		{
			float slowTime = MurderGameCvar::Killer_SpeedFixedTime.GetFloat();
			if(cPlayer.pev.button & IN_RELOAD > 0)
			{
				maxspeed = 370;
			}
			if(slowTime > 0)
			{
				float lastkilledkiller = game.MurderKillerData.GetLastKilledKillerTime(@cPlayer);
				if(lastkilledkiller >= 0)
				{
					if(g_Engine.time < lastkilledkiller + slowTime)
					{
						maxspeed = 180;
					}
				}
			}

		}
		if(cPlayer.pev.targetname == "sheriff" && cPlayer.IsAlive())
		{
			auto weaponItem = PlayerActions::GetUserWeaponByName(@cPlayer, MurderGameAction::SheriffWeapon); 
			if(weaponItem is null)
			{
				cPlayer.GiveNamedItem(MurderGameAction::SheriffWeapon);
			}
		}
		if(cPlayer.pev.targetname == "killer" && cPlayer.IsAlive())
		{
			auto weaponItem = PlayerActions::GetUserWeaponByName(@cPlayer, MurderGameAction::DefaultWeapon); 
			if(weaponItem is null)
			{
				cPlayer.GiveNamedItem(MurderGameAction::DefaultWeapon);
			}
		}
		if(cPlayer.pev.maxspeed != maxspeed) cPlayer.pev.maxspeed = maxspeed;

		int index = game.MurderGeneralData.GetUserDataInt(@cPlayer, "glow_color_index", 0);
		Vector color = MurderGameAction::playerGlows[index];
		EntityActions::SetRendering(@cPlayer, kRenderFxGlowShell, color.x, color.y, color.z, kRenderNormal, 25);
		if(cPlayer.pev.frags != 0)
		{
			cPlayer.pev.frags = 0;
		}
		if(cPlayer.m_iDeaths != 0)
		{
			cPlayer.m_iDeaths = 0;
		}
		MurderGameAction::SetMedkitAmmoToZero(@cPlayer);
	}
}
namespace MurderGeneralEntityNS
{
	void Register()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "MurderGeneralEntity", "murder_general" );
	}
	void Spawn(dictionary@ keys = null)
	{
		if(keys is null)
		{
			@keys = {{"ThinkTime", "2.0"}};
		}
		CBaseEntity@ entity = g_EntityFuncs.CreateEntity( "murder_general", @keys, false);
	}
}
