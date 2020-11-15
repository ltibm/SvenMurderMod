final class MurderGame : GameType
{
	private XPMurderGeneralData@ murderGeneralData;
	XPMurderGeneralData@ MurderGeneralData
	{
		get
		{
			return this.murderGeneralData;
		}
	}
	private XPMurderKillerData@ murderKillerData;
	XPMurderKillerData@ MurderKillerData
	{
		get
		{
			return this.murderKillerData;
		}
	}
	array<int> TeamScores(3);
	private bool initialised = false;
	private bool inround = false;
	private bool m_isenabled = false;
	private bool isBonusRound = false;
	float timeReamin = 0;
	float lastSheriffFoundTime = 0;
	void ResetAllScores()
	{
		this.TeamScores.resize(3);
	}
	bool InRound() override
	{
		return this.inround;
	}
	float GetTimeLeft()
	{
		if(!this.InRound()) return -1;
		return this.timeReamin;
	}
	void SetTimeLeft(float value)
	{
		this.timeReamin = value;
	}
	bool IsMapSupported()
	{
		return FileUtils::FileHasAnyInLines(MurderGameAction::MurderMapsFile, function(line){
				return line == g_Engine.mapname;
			});
	}
	bool IsBonusRound()
	{
		return this.isBonusRound;
	}
	void SetEnabled(bool value)
	{
		this.m_isenabled = value;
		if(value && !this.initialised)
		{
			this.SetupTimers();
			timeReamin = 30;
			@this.murderGeneralData = @XPMurderGeneralData();
			@this.murderKillerData = @XPMurderKillerData();
			g_HookEngine.AddBinder(@this, "PlayerSpawn PlayerKilled ClientPutInServer ClientDisconnect PlayerTakeDamage CanCollect Collected", true);
			this.initialised = true;
			
		}
	}
	HookReturnCode ClientSay( SayParameters@ pParams )
	{	
		return HOOK_CONTINUE;
	}
	bool IsEnabled()
	{
		return this.m_isenabled;
	}
	MurderGame()
	{
		MurderGameCvar::Register();
	}
	~MurderGame()
	{
		@this.murderGeneralData = null;
		@this.murderKillerData = null;
		g_HookEngine.RemoveBinder(@this);
	}
	void MapInit()
	{
		MurderGeneralEntityNS::Register();
		MurderCivilEntityNS::Register();
		MurderSheriffEntityNS::Register();
		MurderKillerEntityNS::Register();
		this.ExecuteCFG("config/murder_mapinit.cfg");
		for(uint i = 0; i < MurderGameAction::MusicThemes.length(); i++)
		{
			g_Game.PrecacheGeneric( "sound/" + MurderGameAction::MusicThemes[i] );
			g_SoundSystem.PrecacheSound(MurderGameAction::MusicThemes[i] );
		}
		g_Game.PrecacheGeneric( "sound/" + MurderGameAction::MusicKillerWin );
		g_Game.PrecacheGeneric( "sound/" + MurderGameAction::MusicSheriffWin );
		g_Game.PrecacheGeneric( "sound/" + MurderGameAction::MusicBonusTheme );
		g_SoundSystem.PrecacheSound(MurderGameAction::MusicBonusTheme);	
		
	}
	void MapActivate()
	{
		MurderGeneralEntityNS::Spawn();
		MurderCivilEntityNS::Spawn();
		MurderSheriffEntityNS::Spawn();
		MurderKillerEntityNS::Spawn();
		auto@ world = g_EntityFuncs.Instance(0);
		if( world !is null ) 
		{
			world.KeyValue("forcepmodels", "helmet");
		}
		this.ExecuteCFG("config/murder_mapactivate.cfg");
	}
	string GetPath()
	{
		return MurderGameAction::Path;
	}
	void MapStart()
	{
		this.ExecuteCFG("config/murder_mapstart.cfg");
	}
	HookReturnCode Collected(CBaseEntity@ pPickup, CBaseEntity@ pOther)
	{
		if(pPickup.pev.classname == MurderGameAction::SheriffWeapon)
		{
			if(pOther.pev.targetname == "civil")
			{
				pOther.pev.targetname = "sheriff";
			}
		}

		return HOOK_CONTINUE;
	}

	HookReturnCode CanCollect(CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult)
	{
		bResult = true;
		if(!this.IsEnabled()) return HOOK_CONTINUE;
		if(pPickup.pev.classname == MurderGameAction::DefaultWeapon) return HOOK_CONTINUE;
		if(pPickup.pev.classname != MurderGameAction::SheriffWeapon && pOther.pev.targetname != "killer")
		{
		
			bResult = false;
			return HOOK_CONTINUE;
		}
		if(pOther.pev.targetname == "killer" || pPickup.pev.iuser3 == pOther.entindex())
		{
			if(pOther.pev.targetname == "killer" && (pPickup.pev.classname == MurderGameAction::MeeleWeapon || pPickup.pev.classname == "weapon_rpg"))
			{
				return HOOK_CONTINUE;
			}
			bResult = false;
		}
		else
		{
			pPickup.pev.iuser3 = 0;
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerTakeDamage(DamageInfo@ pDamageInfo)
	{
		if(!this.IsEnabled()) return HOOK_CONTINUE;
		if(!this.InRound())
		{
			pDamageInfo.flDamage = 0.0;

			return HOOK_CONTINUE;
		}
		pDamageInfo.pAttacker.pev.iuser2 = 0;
		float newdamage = pDamageInfo.flDamage;
		if(pDamageInfo.pAttacker.IsPlayer() && pDamageInfo.pVictim.IsPlayer())
		{
			CBasePlayer@ attacker = cast<CBasePlayer@>(@pDamageInfo.pAttacker);
			CBasePlayer@ victim = cast<CBasePlayer@>(@pDamageInfo.pVictim); 
			pDamageInfo.pVictim.pev.iuser2 = pDamageInfo.pAttacker.entindex();
			@pDamageInfo.pAttacker = @pDamageInfo.pVictim;

			if(attacker.pev.targetname == "sheriff")
			{
				if(victim.pev.targetname != "killer")
				{
					ClientPrintAllML("MURDER_CIVIL_BY_SHERIFF", {victim.pev.netname, attacker.pev.netname});
					auto newentitiy = @MurderGameAction::Drop357(@attacker);
					newentitiy.pev.iuser3 = attacker.entindex();
					attacker.pev.targetname = "civil";
					this.MurderGeneralData.SetLastBlindTime(@attacker, g_Engine.time);
				}
				newdamage = 400;
			}
			else if(attacker.pev.targetname == "killer")
			{
				if(newdamage < 50)
				{
					newdamage *= 3.35;
				}
				else
				{
					newdamage *= 2.6;
				}
			}
		}
		pDamageInfo.flDamage = newdamage;
		return HOOK_CONTINUE;
	}

	void SetPlayerDefaultAbilites(CBasePlayer@ cPlayer)
	{
		cPlayer.GiveNamedItem(MurderGameAction::DefaultWeapon);
	}
	void MessageTick()
	{
		for (int i = 1; i <= g_Engine.maxClients; i++) {
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			string message = "";
			if(this.IsBonusRound())
			{
				message = MLText(@cPlayer, "MURDER_BONUS_ROUND") + "\r\n";
			}
			message += this.GetScoreMessage(@cPlayer);
			GameType::ShowScoreMessage(@cPlayer, message, false);
		}
	}
	void GameTick()
	{
		if(this.InRound())
		{
			if(timeReamin != -1)
			{
				timeReamin--;
				if(timeReamin <= 0)
				{
					this.OnRoundEnd(MurderGameAction::TeamSheriff);
				}
			}
			this.CheckRound();
		}
		else
		{

			if(this.RoundReady())
			{
				if(this.OnRoundStart())
				{
					this.AttemptRoundStart();
					if(this.IsBonusRound())
					{
						this.PlayMusic(MurderGameAction::MusicBonusTheme);
					}
					else
					{
						int mid = this.RoundCount % MurderGameAction::MusicThemes.length();
						string theme = MurderGameAction::MusicThemes[mid];
						this.PlayMusic(theme);
					}
					

				}
			}
			this.timeReamin--;
		}
		this.ChangeUserTeamAuto();
	}

	private void ChangeUserTeamAuto()
	{
		array<int> dmPlayerClasses = {-1, 1, 2, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32};
		for (int i = 1; i <= g_Engine.maxClients; ++i) 
		{
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			int nnum = RandLongEx(0, dmPlayerClasses.length() - 1);
			int index = dmPlayerClasses[nnum];
			cPlayer.m_fOverrideClass = true;
			cPlayer.m_iClassSelection = index;
			dmPlayerClasses.removeAt(nnum);
		}
	}
	private string GetScoreMessage(CBasePlayer@ cPlayer)
	{
		string message = MLText(cPlayer, "MURDER_SCORE", {this.TeamScores[MurderGameAction::TeamKiller], this.TeamScores[MurderGameAction::TeamSheriff], this.TeamScores[0]});
		message += "\r\n";
		if(this.InRound())
		{
			
			if(timeReamin == -1)
			{
				message += MLText(cPlayer, "MURDER_ROUND_TIME_REM_INF", {int(this.timeReamin)});
			}
			else
			{
				message += MLText(cPlayer, "MURDER_ROUND_TIME_REM", {int(this.timeReamin)});
			}
		}
		else
		{
			message += MLText(cPlayer, "MURDER_ROUND_WAITTIME_REM", {int(this.timeReamin)});
		}
		return message;
	}
	void CheckRound()
	{
		if(!this.InRound()) return;
		int civil_alive = 0;
		int civil_total = 0;
		int killer_alive = 0;
		int killer_total = 0;
		int sheriff_count = 0;
		int total = 0;
		for (int i = 1; i <= g_Engine.maxClients; i++) 
		{
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			if(cPlayer.IsAlive())
			{
				if(cPlayer.pev.targetname == "killer")
				{
					killer_alive++;
				}
				else
				{
					if(cPlayer.pev.targetname == "sheriff")
					{
						sheriff_count++;
					}
					civil_alive++;
				}
			}
			if(cPlayer.pev.targetname == "killer")
			{
				killer_total++;
			}
			else
			{
				civil_total++;
			}
			total++;
		}
		if(total == 0)
		{
			this.OnRoundEnd(0);
			return;
		}
		if(civil_alive <= 0 && killer_alive > 0)
		{
			this.OnRoundEnd(MurderGameAction::TeamKiller);
		}
		else if(killer_alive <= 0 && civil_alive > 0)
		{
			this.OnRoundEnd(MurderGameAction::TeamSheriff);
		}
		else
		{
			if(sheriff_count > 0)
			{
				lastSheriffFoundTime = g_Engine.time;
			}
			else
			{
				if(g_Engine.time - lastSheriffFoundTime > 40)
				{
					lastSheriffFoundTime = g_Engine.time;
					auto allCivils = PlayerActions::Get(function(player, parameters) {
						return player.pev.targetname == "civil";
					});
					if(allCivils.length() > 0)
					{
						int rnd = RandLongEx(0, allCivils.length() - 1);
						allCivils[rnd].pev.targetname = "sheriff";
						allCivils[rnd].GiveNamedItem(MurderGameAction::SheriffWeapon);
					}
				}
			}
		}
	}
	bool OnRoundStart()
	{
		if(this.InRound()) return false;
		
		if(MurderGameCvar::BonusEnabled.GetInt() > 0 && this.RoundCount % 5 == 0 && this.RoundCount != 0 && !this.IsBonusRound())
		{
			this.isBonusRound = true;
		}
		else
		{
			this.isBonusRound = false;
		}
		this.lastSheriffFoundTime = g_Engine.time;
		float time = MurderGameCvar::RoundTime.GetFloat();
		if(time == 0)
		{
			timeReamin = -1;
		}
		else
		{
			timeReamin = time;
		}
		if(timeReamin < 30) timeReamin = 30;
		this.inround = true;

		MurderGameAction::ResetAllPlayer();
		SelectRandomlyPlayer();
		TeleportPlayerRandomly();
		return true;
	}
	void TeleportPlayerRandomly()
	{
		auto entities = EntityActions::GetEntitiesByClassname("info_player_start");
		auto entities2 =  EntityActions::GetEntitiesByClassname("info_player_deathmatch");
		auto entities_org = entities;
		auto entities2_org = entities2;
		if(entities.length() == 0 || entities2_org.length() == 0) return;
		int inum = 0;
		for (int i = 1; i <= g_Engine.maxClients; i++) {
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			Vector origin;
			int rnd = 0;
			if(inum % 2 == 0)
			{
				rnd = RandLongEx(0, entities.length() - 1);
				origin = entities[rnd].GetOrigin();
			}
			else
			{
				rnd = RandLongEx(0, entities2.length() - 1);
				origin = entities2[rnd].GetOrigin();
			}
			
			 
			cPlayer.SetOrigin(origin);
			if(inum % 2 == 0)
			{
				entities.removeAt(rnd);
				if(entities.length() == 0)
				{
					entities = entities_org;
				}
			}
			else
			{
				entities2.removeAt(rnd);
				if(entities2.length() == 0)
				{
					entities2 = entities2_org;
				}
			}

			inum++;
			
		}
	}
	void SetUserVars(CBasePlayer@ cPlayer)
	{
		if(cPlayer.IsAlive())
		{
			cPlayer.pev.health = 100.0;
			cPlayer.pev.armorvalue = 0.0;
		}
		else
		{
			g_PlayerFuncs.RespawnPlayer(@cPlayer, true, true);
		}
		this.MurderKillerData.SetLastKilledTime(@cPlayer, 0);
		this.MurderKillerData.SetLastKilledKillerTime(@cPlayer, -1);
		SetRandomGlow(@cPlayer);
	}
	void SetRandomGlow(CBasePlayer@ cPlayer)
	{
		this.MurderGeneralData.SetUserDataInt(@cPlayer, "glow_color_index", RandLongEx(0, MurderGameAction::playerGlows.length() - 1));
	}
	void SetPlayerAbilitesLazy(CBasePlayer@ cPlayer)
	{
		cPlayer.GiveNamedItem(MurderGameAction::DefaultWeapon);
		if(cPlayer.pev.targetname == "killer")
		{
			cPlayer.GiveNamedItem(MurderGameAction::MeeleWeapon);
		}
		else if(cPlayer.pev.targetname == "sheriff")
		{
			cPlayer.GiveNamedItem(MurderGameAction::SheriffWeapon);
		}
		if(this.IsBonusRound())
		{
			auto curmod = this.GetBonusType();
			if(curmod == MurderBonusType_OneKillerAllSheriff)
			{
				if(cPlayer.pev.targetname == "killer")
				{
					cPlayer.GiveNamedItem("weapon_rpg", 0, 10);
				}
				cPlayer.pev.armorvalue = 100;
			}
			else if(curmod == MurderBonusType_OneSheriffAllKiller)
			{
				if(cPlayer.pev.targetname == "sheriff")
				{
					cPlayer.pev.health = 200;
					cPlayer.pev.armorvalue = 50;
				}
			}
		}
		g_Scheduler.SetTimeout(@this, "SwitchDefaultWeapon", 0.25, @cPlayer);

		
	}
	private void SwitchDefaultWeapon(CBasePlayer@ cPlayer)
	{
		auto weaponItem = PlayerActions::GetUserWeaponByName(@cPlayer, MurderGameAction::DefaultWeapon);
		if(weaponItem is null) return;
		cPlayer.SwitchWeapon(@weaponItem);
		
	}
	private void SetKiller(CBasePlayer@ cPlayer)
	{
		cPlayer.pev.targetname = "killer";
		this.RemoveAllItems(@cPlayer);
		this.SetPlayerAbilites(@cPlayer, true);
		this.SetUserVars(@cPlayer);
		if(!this.IsBonusRound())
		{
			this.MurderGeneralData.SetUserDataBool(@cPlayer, "last_killer", true);
		}
	}
	private void SetSherrif(CBasePlayer@ cPlayer)
	{
		cPlayer.pev.targetname = "sheriff";
		this.RemoveAllItems(@cPlayer);
		this.SetPlayerAbilites(@cPlayer, true);
		this.SetUserVars(@cPlayer);
		if(!this.IsBonusRound())
		{
			this.MurderGeneralData.SetUserDataBool(@cPlayer, "last_sheriff", true);
		}
	}
	private void SetCivil(CBasePlayer@ cPlayer)
	{
		this.RemoveAllItems(@cPlayer);
		this.SetPlayerAbilites(@cPlayer, true);
		this.SetUserVars(@cPlayer);
	}
	int GetRandomWithoutOption(array<CBasePlayer@> players, string name)
	{
		int index = RandLongEx(0, players.length() - 1);
		bool result = this.MurderGeneralData.GetUserDataBool(players[index], name);
		if(result)
		{
			index++;
			if(index >= int(players.length())) index = 0;
		}
		return index;
	}
	MurderBonusType GetBonusType()
	{
		if(!this.IsBonusRound()) return MurderBonusType_Start;
		int total = this.RoundCount / 5;
		return MurderBonusType((total % 3 + 1));
	}
	void SelectRandomlyPlayer()
	{

		auto all = PlayerActions::Get();
		if(all.length() < 3) return;
		if(this.IsBonusRound())
		{

			auto curmode = this.GetBonusType();
			int rnd = RandLongEx(0, all.length() - 1);
			if(curmode == MurderBonusType_OneKillerAllSheriff)
			{
				this.SetKiller(all[rnd]);
				all.removeAt(rnd);
			}
			else if(curmode == MurderBonusType_OneSheriffAllKiller)
			{
				this.SetSherrif(all[rnd]);
				all.removeAt(rnd);
			}
	
			for(uint i = 0; i < all.length(); i++)
			{
				if(curmode == MurderBonusType_OneKillerAllSheriff)
				{
					this.SetSherrif(all[i]);
				}
				else if(curmode == MurderBonusType_OneSheriffAllKiller)
				{
					this.SetKiller(all[i]);
				}
				else if(curmode == MurderBonusType_MidSheriffMidKiller)
				{
					if(i % 2 == 0)
					{
						this.SetSherrif(all[i]);
					}
					else
					{
						this.SetKiller(all[i]);
					}
				}
			}
			
		}
		else
		{
			int killercount = 1;
			int sheriffcount = 1;

			if(all.length() >= 10)
			{
				killercount = 3;

			}
			else if(all.length() > 4)
			{
				killercount = 2;
			}
			if(all.length() >= 11)
			{
				sheriffcount = 3;
			}
			else if(all.length() > 5)
			{
				sheriffcount = 2;
			}
			int index = 0;
			for(int i = 0; i < sheriffcount; i++)
			{
				index = this.GetRandomWithoutOption(all, "last_sheriff");
				SetSherrif(all[index]);
				all.removeAt(index);
			}
			for(int i = 0; i < killercount; i++)
			{
				index = this.GetRandomWithoutOption(all, "last_killer");
				SetKiller(all[index]);
				all.removeAt(index);
			}
			for(uint i = 0; i < all.length(); i++)
			{
				this.MurderGeneralData.DeleteUserDataKey(@all[i], "last_killer");
				this.MurderGeneralData.DeleteUserDataKey(@all[i], "last_sheriff");
				this.SetCivil(@all[i]);
			}
		}
	
		
	}
	bool OnRoundEnd(int winnerTeam = -2, bool flash = true)
	{
		if(!this.InRound()) return false;
		this.inround = false;
		if(this.ActiveMusic !is null)
		{
			g_EntityFuncs.Remove(@this.ActiveMusic);
			@this.ActiveMusic = null;
		}
		if(winnerTeam == -1)
		{
			this.TeamScores[0]++;
			if(flash)
			{
				GameType::FlashMessage(null, "MURDER_DRAW", true);
			}
		}
		else if(winnerTeam > 0)
		{
			if(flash)
			{
				if(winnerTeam == MurderGameAction::TeamKiller)
				{
					PlayerActions::PlayMusic(null, "sound/" + MurderGameAction::MusicKillerWin);
					GameType::FlashMessage(null, "MURDER_KILLER_WIN", true);
				}
				else
				{
					PlayerActions::PlayMusic(null, "sound/" + MurderGameAction::MusicSheriffWin);
					GameType::FlashMessage(null, "MURDER_SHERIFF_WIN", true);
				}
			}
			this.TeamScores[winnerTeam]++;
		}
		timeReamin = MurderGameCvar::RoundWaitTime.GetFloat();
		if(timeReamin < 3) timeReamin = 3;
		if(winnerTeam != -2)
		{
			this.roundCount++;
		}
		MurderGameAction::RemoveAll357();
		return true;
	}
	bool RoundReady()
	{
		if(this.InRound() || this.timeReamin > 0) return false;
		if(this.timeReamin <= 0)
		{
			auto all = MurderGameAction::GetPlayer(MurderPlayerType_Any);	
			if(all.length() < 3)
			{
				timeReamin = MurderGameCvar::RoundWaitTime.GetFloat();
				if(timeReamin < 3) timeReamin = 3;
				GameType::FlashMessage(null, "MURDER_ROUND_START_FAIL", true);
				return false;
			}
		}
		return true;
	}
	HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer) override
	{		
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib ) override
	{
		if(@pPlayer == @pAttacker && pPlayer.pev.iuser2 > 0)
		{
			CBasePlayer@ realAttacker = g_PlayerFuncs.FindPlayerByIndex(pPlayer.pev.iuser2);
			if(realAttacker !is null && realAttacker.IsConnected())
			{
				if(pPlayer.pev.targetname == "civil" && realAttacker.pev.targetname == "killer")
				{
					ClientPrintAllML("MURDER_CIVIL_BY_KILLER", {pPlayer.pev.netname});
				}
				else if(pPlayer.pev.targetname == "killer" && realAttacker.pev.targetname == "sheriff")
				{
					ClientPrintAllML("MURDER_KILLER_BY_SHERIFF", {pPlayer.pev.netname});
				}
				else if(pPlayer.pev.targetname == "killer" && realAttacker.pev.targetname == "killer")
				{
					ClientPrintAllML("MURDER_KILLER_BY_KILLER", {pPlayer.pev.netname, realAttacker.pev.netname});
					this.MurderKillerData.SetLastKilledKillerTime(@realAttacker,g_Engine.time);
					
				}
				else if(pPlayer.pev.targetname == "sheriff" && realAttacker.pev.targetname == "killer")
				{
					ClientPrintAllML("MURDER_SHERIFF_BY_KILLER", {pPlayer.pev.netname});
				}
				if(realAttacker.pev.targetname == "killer")
				{
					this.MurderKillerData.SetLastKilledTime(@realAttacker,g_Engine.time);
				}
				else
				{
					this.MurderKillerData.SetLastKilledTime(@realAttacker, 0);
				}
			}
			if(pPlayer.pev.targetname == "sheriff")
			{
				/*if(pPlayer.m_hActiveItem)
				{
					CBaseEntity@ item = pPlayer.m_hActiveItem;
					if(item.pev.classname != MurderGameAction::SheriffWeapon)
					{
					
					}
				}*/
				MurderGameAction::Drop357(@pPlayer);
			}
			pPlayer.pev.iuser2 = 0;
		}
		this.CheckRound();

		return HOOK_CONTINUE;
	}
	private void RemoveAllItems(CBasePlayer@ cPlayer)
	{
		cPlayer.RemoveAllItems(false);
	}
	HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer) override
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer) override
	{
		this.CheckRound();
		return HOOK_CONTINUE;
	}
	void PlayerMessageTick(CBasePlayer@ cPlayer)
	{
		if(!cPlayer.IsAlive()) return;
		string type = cPlayer.pev.targetname;
		if(type != "civil" && type != "killer" && type != "sheriff")
		{
			type = "civil";
			cPlayer.pev.targetname = type;
		}
		string message = "";
		HUDTextParams hudText;
		hudText.channel      = 2;
		if(type == "sheriff")
		{
			message = MLText(@cPlayer, "MURDER_HUD_MESSAGE_START", {MLText(@cPlayer, "MURDER_SHERIFF")});
			message += MurderGameMessage::GetSheriffMessage(@cPlayer);
			hudText.r1           = 0;
			hudText.g1           = 50;
			hudText.b1           = 255;
			hudText.r2           = 0;
			hudText.g2           = 50;
			hudText.b2           = 255;
		}
		else if(type == "killer")
		{
			message = MLText(@cPlayer, "MURDER_HUD_MESSAGE_START", {MLText(@cPlayer, "MURDER_KILLER")});
			message += MurderGameMessage::GetKillerMessage(@cPlayer);
			hudText.r1           = 255;
			hudText.g1           = 50;
			hudText.b1           = 0;
			hudText.r2           = 255;
			hudText.g2           = 50;
			hudText.b2           = 0;
		}
		else
		{
			message = MLText(@cPlayer, "MURDER_HUD_MESSAGE_START", {MLText(@cPlayer, "MURDER_CIVIL")});
			message += MurderGameMessage::GetCivilMessage(@cPlayer);
			hudText.r1           = 50;
			hudText.g1           = 0;
			hudText.b1           = 255;
			hudText.r2           = 50;
			hudText.g2           = 0;
			hudText.b2           = 255;
		}
		hudText.effect       = 1;
		hudText.fadeinTime   = 0;
		hudText.fadeoutTime  = 0;
		hudText.fxTime       = 0.1;
		hudText.holdTime     = 1.1;
		hudText.x            = 0.1;
		hudText.y            = 0.25;
		g_PlayerFuncs.HudMessage(cPlayer, hudText, message);
	}
}