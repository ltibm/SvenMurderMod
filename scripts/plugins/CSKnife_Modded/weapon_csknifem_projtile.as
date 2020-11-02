class KnifeProjectileEntity : ScriptBaseEntity
{
	private float thinkTime = 0.1;
	private float removeTime = 0;
	private CBaseEntity@ originalOwner = null;
	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/csknife/w_knife.mdl" );
		self.pev.movetype= MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;
		self.pev.nextthink = g_Engine.time + this.thinkTime;
		g_EntityFuncs.SetSize( self.pev, Vector(-0.5f, -0.5f, -0.5f), Vector(0.5f, 0.5f, 0.5f) );
		@this.originalOwner = g_EntityFuncs.Instance(@self.pev.owner);

	}
	void Precache()
	{
		g_Game.PrecacheModel( "models/cs16/csknife/w_knife.mdl" );
	}
	
	private bool GiveToPlayerAsAmmo(CBasePlayer@ player)
	{
		auto weaponItem = CSKnifeNS::GetUserWeaponByName(@player, "weapon_csknifem");
		if(weaponItem is null) return false;
		int curammo = player.m_rgAmmo(weaponItem.PrimaryAmmoIndex());
		if(curammo >= weaponItem.iMaxAmmo1()) return false;
		player.m_rgAmmo(weaponItem.PrimaryAmmoIndex(), curammo + 1);
		return true;
	}
	void Touch( CBaseEntity@ pOther )
	{
		if(this.originalOwner is null)
		{
			@this.originalOwner = g_EntityFuncs.Instance(@self.pev.owner);
		}
		if(this.originalOwner is null) return;
		if(self.pev.dmgtime > 0)
		{
			if(pOther.IsAlive() && (pOther.IsPlayer() || pOther.IsMonster()))
			{
				self.pev.movetype = MOVETYPE_TOSS;
				self.pev.velocity = Vector(0, 0, 0);
				g_SoundSystem.EmitSound( pOther.edict(), CHAN_WEAPON, "weapons/cs16/knife_hit4.wav", 1, ATTN_NORM );
				
				pOther.TakeDamage( @self.pev, @this.originalOwner.pev, 50, DMG_SLASH );
				this.SetThink( ThinkFunction(this.Remove) );
			}
		}
		else
		{
			if(pOther.entindex() == this.originalOwner.entindex() && pOther.IsPlayer())
			{
				CBasePlayer@ player = cast<CBasePlayer@>(pOther);
				if(!this.GiveToPlayerAsAmmo(@player)) return;
				this.Remove();
				@this.originalOwner = null;
			}
		}

	}
	
	void Remove()
	{
		g_EntityFuncs.Remove( self );
	}
	void RemoveThink()
	{
	
		self.pev.nextthink = g_Engine.time + 1.0f;
		if(g_Engine.time > this.removeTime)
		{
			this.Remove();
			return;
		}			

	}
	
	void Think()
	{
		Vector velocity = self.pev.velocity;
		if(velocity.Length() <= 10)
		{
			this.removeTime = g_Engine.time + 30;
			if(cvar_KnifeGlowThrowingDrop.GetInt() > 0)
			{
				self.pev.renderfx = kRenderFxGlowShell;
				Vector rClr;
				rClr.x = 0;
				rClr.y = 255;
				rClr.z = 255;
				self.pev.rendermode = kRenderNormal;
				self.pev.renderamt = 255;
				self.pev.rendercolor = rClr;
			}
			this.SetThink( ThinkFunction(this.RemoveThink) );
			self.pev.nextthink = g_Engine.time + this.thinkTime;
			self.pev.velocity = Vector(0, 0, 0);
			@self.pev.owner = null;
			self.pev.dmgtime = 0;
			return;
		}
		Vector origin = self.GetOrigin();
		if(self.pev.flags & FL_ONGROUND > 0)
		{
			
			self.pev.velocity = Vector(0, 0, 0);
			if(g_EngineFuncs.PointContents(origin) == CONTENTS_SKY)
			{
				if(this.originalOwner is null)
				{
					@this.originalOwner = g_EntityFuncs.Instance(@self.pev.owner);
				}
				if(this.originalOwner.IsPlayer())
				{
					CBasePlayer@ player = cast<CBasePlayer@>(this.originalOwner);
					this.GiveToPlayerAsAmmo(@player);
				}
				this.Remove();
				return;
			}
		}
		Vector angles;
		if(velocity.Length() < 200)
		{
			self.pev.movetype= MOVETYPE_TOSS;
			velocity = Vector(0, 0, 0);
		}
		else
		{
			velocity = velocity * 0.90;

		}
		g_EngineFuncs.VecToAngles(velocity, angles);
		self.pev.angles = angles;
		self.pev.velocity = velocity;	
		self.pev.dmgtime = 1;
		self.pev.nextthink = g_Engine.time + this.thinkTime;
	}
}