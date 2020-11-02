int weapon_csknife_pos = 7;
class MurderWeaponNone : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iSwing;
	TraceResult m_trHit;
	bool isinvisible = false;
	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/null.mdl"));
	}
	bool isUserZombie(CBasePlayer@ cPlayer)
	{
		if(cPlayer is null) return false;
		KeyValueBuffer@ nPysc = g_EngineFuncs.GetPhysicsKeyBuffer(cPlayer.edict());
		if(nPysc is null) return false;
		if(nPysc.GetValue("zombie") == "1")
		{
			return true;
		}
		return false;
	}
	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( "models/null.mdl" );
		g_Game.PrecacheModel( "models/cs16/csknife/v_knife.mdl" );
		g_Game.PrecacheModel("models/csknife/v_knife_tr.mdl");
		g_Game.PrecacheModel("models/invisible.mdl");
		g_Game.PrecacheModel( "models/cs16/csknife/p_knife.mdl" );
		g_Game.PrecacheModel( "models/xpzombi/zombimodels/v_knife_zombie.mdl" );
		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud10.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud11.spr" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_hit1.wav" );
        g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_hit2.wav" );
        g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_hit3.wav" );
        g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_hit4.wav" );
        g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_hitwall1.wav" );
        g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_slash1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_slash2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_stab.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/knife_deploy1.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_hit1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_hit2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_hit3.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_hit4.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_hitwall1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_slash1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_slash2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_stab.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/knife_deploy1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud10.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud11.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_csknife.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		if(cvar_KnifeThrow.GetInt() == 0)
		{
			info.iMaxAmmo1		= 1;
		}
		else
		{
			info.iMaxAmmo1		= 5;
		}

		info.iMaxAmmo2		= -1;
		info.iMaxClip		= WEAPON_NOCLIP;
		info.iSlot			= 0;
		info.iPosition		= weapon_csknife_pos;
		info.iWeight		= 0;
		info.iFlags			= ITEM_FLAG_SELECTONEMPTY | ITEM_FLAG_NOAUTOSWITCHEMPTY;
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csknife( MSG_ONE_UNRELIABLE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csknife.WriteLong( g_ItemRegistry.GetIdForName("weapon_csknife") );
			csknife.End();
			if(isUserZombie(pPlayer))
			{
				self.DefaultDeploy( self.GetV_Model( "models/xpzombi/zombimodels/v_knife_zombie.mdl" ), self.GetP_Model( "models/cs16/csknife/p_knife.mdl" ), KNIFE_DRAW, "crowbar" );
			}
			return true;
		}
		return false;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			if(isUserZombie(m_pPlayer))
			{
				bResult = self.DefaultDeploy( self.GetV_Model( "models/xpzombi/zombimodels/v_knife_zombie.mdl" ), self.GetP_Model( "models/cs16/csknife/p_knife.mdl" ), KNIFE_DRAW, "crowbar" );
			}
			else
			{
				bResult = self.DefaultDeploy( self.GetV_Model( "models/csknife/v_knife_tr.mdl" ), self.GetP_Model( "models/cs16/csknife/p_knife.mdl" ), KNIFE_DRAW, "crowbar" );
			}
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_deploy1.wav", 1, ATTN_NORM );
			return bResult;
		}
	}
	
	void WeaponIdle()
	{
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;
		
		self.SendWeaponAnim( KNIFE_IDLE );
		self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat( 10, 15 );
	}
		
	
	void Holster( int skiplocal )
	{
		self.m_fInReload = false;// cancel any reload in progress.
		m_iSwing = 0;
		SetThink( null );

		m_pPlayer.m_flNextAttack = g_Engine.time + 0.5; 

		m_pPlayer.pev.viewmodel = string_t();
	}
	
	void PrimaryAttack()
	{
		if( !Swing( 1 ) )
		{
			SetThink( ThinkFunction( this.SwingAgain ) );
			self.pev.nextthink = g_Engine.time + 0.01;
		}
	}
	
	void SecondaryAttack()
	{
		if( !HeavySmack( 1 ) )
		{	
			SetThink( ThinkFunction( this.DoHeavyAttack ) );
			self.pev.nextthink = g_Engine.time + 0.01;
		}
	}
	void TertiaryThink()
	{
		g_EntityFuncs.SetModel( self, "models/invisible.mdl" );
		m_pPlayer.pev.viewmodel = "models/invisible.mdl";
		self.pev.nextthink = g_Engine.time + 3.60;
		SetThink( ThinkFunction( this.ModelThink ) );
	}
	void ModelThink()
	{

		g_EntityFuncs.SetModel( self, self.GetW_Model( "models/cs16/csknife/w_knife.mdl") );
		m_pPlayer.pev.viewmodel = "models/csknife/v_knife_tr.mdl";
		SetThink(null);
		self.SendWeaponAnim( KNIFE_DRAW );
	}
	void TertiaryAttack()
	{
		if(cvar_KnifeThrow.GetInt() == 0 || isUserZombie(m_pPlayer)) return;
		int ammo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		if(ammo <= 1)
		{
			return;
		}
		self.m_flNextTertiaryAttack = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = g_Engine.time + 4.0;
		self.pev.nextthink = g_Engine.time + 0.30;
		SetThink( ThinkFunction( this.TertiaryThink ) );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
		self.SendWeaponAnim( KNIFE_MIDSLASH1 );
		CSKnifeNS::Throw(@m_pPlayer);
		m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType, ammo - 1);

	}
	
	void DoHeavyAttack()
	{
		HeavySmack( 0 );
	}
	
	void Smack()
	{
		g_WeaponFuncs.DecalGunshot( m_trHit, BULLET_PLAYER_CROWBAR );
	}
	
	void SwingAgain()
	{
		Swing( 0 );
	}
	
	bool HeavySmack( int fFirst )
	{
		TraceResult tr;
		bool fDidHit = false;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * 37;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if ( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if ( tr.flFraction >= 1.0 )
		{
			if( fFirst != 0 )
			{
				// miss
				switch( ( m_iSwing++ ) % 1 )
				{
				case 0:
					self.SendWeaponAnim( KNIFE_STABMISS ); break;
				}
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = g_Engine.time + 0.9;
				// play wiff or swish sound
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_slash1.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );

				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
			}
		}
		else
		{
			// hit
			fDidHit = true;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			switch( ( ( m_iSwing++ ) % 2 ) )
			{
			case 0:
				self.SendWeaponAnim( KNIFE_STAB ); break;
			case 1:
				self.SendWeaponAnim( KNIFE_STAB ); break;
			}

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 

			// AdamR: Custom damage option
			float flDamage = 70;
			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;
			// AdamR: End
			if(isUserZombie(m_pPlayer))
			{
				flDamage *= 7;
			}
			g_WeaponFuncs.ClearMultiDamage();
			if ( self.m_flNextSecondaryAttack + 1 < g_Engine.time )
			{
				// first swing does full damage
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB );  
			}
			else
			{
				// subsequent swings do 13% (Changed -Sniper/kerncore) (Half)
				pEntity.TraceAttack( m_pPlayer.pev, flDamage * 0.40, g_Engine.v_forward, tr, DMG_CLUB );  
			}	
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			//m_flNextPrimaryAttack = gpGlobals->time + 0.30; //0.25

			// play thwack, smack, or dong sound
			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = g_Engine.time + 0.9; //0.25

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
	// aone
					if( pEntity.IsPlayer() )		// lets pull them
					{
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}
	// end aone
					// play thwack or smack sound
					switch( Math.RandomLong( 0, 0 ) )
					{
					case 0:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_stab.wav", 1, ATTN_NORM ); break;
					}
					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			// play texture hit sound
			// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
				
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = g_Engine.time + 0.9; //0.25
				
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.

				fvolbar = 1;

				// also play crowbar strike
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_hitwall1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) );
			}

			// delay the decal a bit
			m_trHit = tr;
			SetThink( ThinkFunction( this.Smack ) );
			self.pev.nextthink = g_Engine.time + 0.1;

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}
	
	bool Swing( int fFirst )
	{
		bool fDidHit = false;

		TraceResult tr;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * 47;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if ( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if ( tr.flFraction >= 1.0 )
		{
			if( fFirst != 0 )
			{
				// miss
				switch( ( m_iSwing++ ) % 2 )
				{
				case 0:
					self.SendWeaponAnim( KNIFE_MIDSLASH1 ); break;
				case 1:
					self.SendWeaponAnim( KNIFE_MIDSLASH2 ); break;
				}
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.35;
				// play wiff or swish sound
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_slash2.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );

				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
			}
		}
		else
		{
			// hit
			fDidHit = true;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			switch( ( ( m_iSwing++ ) % 2 ) )
			{
			case 0:
				self.SendWeaponAnim( KNIFE_MIDSLASH1 ); break;
			case 1:
				self.SendWeaponAnim( KNIFE_MIDSLASH2 ); break;
			}

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 

			// AdamR: Custom damage option
			float flDamage = 30;
			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;
			// AdamR: End
			if(isUserZombie(m_pPlayer))
			{
				flDamage *= 10;
			}
			g_WeaponFuncs.ClearMultiDamage();
			if ( self.m_flNextPrimaryAttack + 1 < g_Engine.time )
			{
				// first swing does full damage
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB );  
			}
			else
			{
				// subsequent swings do 13% (Changed -Sniper/kerncore) (Half)
				pEntity.TraceAttack( m_pPlayer.pev, flDamage * 0.30, g_Engine.v_forward, tr, DMG_CLUB );  
			}	
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			//m_flNextPrimaryAttack = gpGlobals->time + 0.30; //0.25

			// play thwack, smack, or dong sound
			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.35; //0.25

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
	// aone
					if( pEntity.IsPlayer() )		// lets pull them
					{
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}
	// end aone
					// play thwack or smack sound
					switch( Math.RandomLong( 0, 3 ) )
					{
					case 0:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_hit1.wav", 1, ATTN_NORM ); break;
					case 1:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_hit2.wav", 1, ATTN_NORM ); break;
					case 2:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_hit3.wav", 1, ATTN_NORM ); break;
					case 3:
						g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_hit4.wav", 1, ATTN_NORM ); break;
					}
					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			// play texture hit sound
			// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
				
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.35; //0.25
				
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.

				fvolbar = 1;

				// also play crowbar strike
				
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/knife_hitwall1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); 
			}

			// delay the decal a bit
			m_trHit = tr;
			SetThink( ThinkFunction( this.Smack ) );
			self.pev.nextthink = g_Engine.time + 0.2;

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}
}

string GetCSKNIFEName()
{
	return "weapon_csknife";
}

void RegisterCSKNIFE(int ipos)
{
	if(cvar_KnifeThrow is null)
	{
		@cvar_KnifeThrow = @CCVar("knife_allow_throw", 0, "Enable throwing knife", ConCommandFlag::AdminOnly); 
	}
	if(cvar_KnifeDefaultGive is null)
	{
		@cvar_KnifeDefaultGive = @CCVar("knife_default_give", 3, "Default give for knife ammo", ConCommandFlag::AdminOnly);
	}	
	if(cvar_KnifeGlowThrowingDrop is null)
	{
		@cvar_KnifeGlowThrowingDrop = @CCVar("knife_glow_throwing_drop", 1, "Glow dropped throwed knife", ConCommandFlag::AdminOnly);
	}
	weapon_csknife_pos = ipos;
	g_CustomEntityFuncs.RegisterCustomEntity( GetCSKNIFEName(), GetCSKNIFEName() );
	g_ItemRegistry.RegisterWeapon( GetCSKNIFEName(), "cs16", "projectile_knife" );
	g_CustomEntityFuncs.RegisterCustomEntity( "KnifeProjectileEntity", "projectile_knife");
	
}
namespace CSKnifeNS
{
	CBaseEntity@ Throw(CBaseEntity@ owner, float speed = 1600.0, dictionary@ keys = null)
	{
		CBaseEntity@ ent = g_EntityFuncs.CreateEntity( "projectile_knife", @keys, false);
		
		g_EngineFuncs.MakeVectors(owner.pev.v_angle);
		Vector velocity = g_Engine.v_forward * speed;
		Vector origin = owner.Center();
		if(owner.IsPlayer())
		{
			CBasePlayer@ player = cast<CBasePlayer@>(owner);
			origin = player.GetGunPosition();
			
		}
		origin.z += 10;
		ent.SetOrigin(origin);
		ent.pev.velocity = velocity;

		@ent.pev.owner = @owner.edict();
		g_EntityFuncs.DispatchSpawn(@ent.edict());
		Vector angles;
		g_EngineFuncs.VecToAngles(velocity, angles);
		ent.pev.angles = angles;
		ent.pev.angles.x += 135;
		return @ent;
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
}
