#include  "Classes/_XPEasyHookIncludes"
abstract class XPHookBinderBase : XPHookMixin
{
}
abstract class XPHookBase : XPEasyHook
{
	bool opEquals(IEasyHookRegisters@  other)
	{
		return this !is null && @this == @other;
	}
}
mixin class XPEasyHook : IEasyHookRegisters
{
	private bool isenabled = true;
	private string name;
	private bool bindingsenabled = true;
	string GetName()
	{
		return this.name;
	}
	void SetName(string value)
	{
		this.name = value;
	}
	bool IsEnabled()
	{
		return this.isenabled;
	}
	void SetEnabled(bool value)
	{
		this.isenabled = value;
	}
	bool BindingsEnabled()
	{
		return this.bindingsenabled;
	}
	void SetBindingsEnabled(bool value)
	{
		this.bindingsenabled = value;
	}
	private array<IEasyHookRegisters@> bindings;
	private array<dictionary@> binderHooks;
	private array<EasyHookTypes@> allHooks = 
	{
		@EHCanPlayerUseReservedSlot(@this),
		@EHClientConnected(@this),
		@EHClientPutInServer(@this),
		@EHClientDisconnect(@this),
		@EHClientSay(@this),
		@EHMapChange(@this),
		@EHEntityCreated(@this),
		@EHPlayerTakeDamage(@this),
		@EHWeaponPrimaryAttack(@this),
		@EHWeaponSecondaryAttack(@this),
		@EHWeaponTertiaryAttack(@this),
		@EHPlayerSpawn(@this),
		@EHPlayerCanRespawn(@this),
		@EHPlayerKilled(@this),
		@EHPlayerUse(@this),
		@EHPlayerPreThink(@this),
		@EHPlayerPostThink(@this),
		@EHGetPlayerSpawnSpot(@this),
		@EHPlayerPreDecal(@this),
		@EHPlayerDecal(@this),
		@EHPlayerEnteredObserver(@this),
		@EHPlayerLeftObserver(@this),
		@EHCanCollect(@this),
		@EHCollected(@this),
		@EHMaterialize(@this)
	};
	void AddBinder(IEasyHookRegisters@ binder, string allowedhooks = "*", bool registerhookIfNotRegister = false)
	{
		if(this.bindings.find(@binder) >= 0) return;
		if(allowedhooks.IsEmpty()) allowedhooks = "*";
		dictionary@ d = null;
		if(allowedhooks != "*")
		{
			array<string> allowed = allowedhooks.Split(' ');
			@d = @dictionary();
			for(uint i = 0; i < allowed.length(); i++)
			{
				d.set(allowed[i], true);
			}
		}
		this.binderHooks.insertLast(@d);
		this.bindings.insertLast(@binder);
		if(registerhookIfNotRegister)
		{
			this.RegisterHook(allowedhooks);
		}
		
	}
	bool RemoveBinder(IEasyHookRegisters@ binder)
	{
		int index = this.bindings.find(@binder);
		if(index >= 0)
		{
			this.bindings.removeAt(index);
			this.binderHooks.removeAt(index);
			return true;
		}
		return false;
	}
	void ClearBinders()
	{
		this.bindings.resize(0);
		this.binderHooks.resize(0);
	}
	void RegisterHook(string hook) final
	{
		if(hook == "*")
		{
			this.RegisterRemoveHookAll(true);
			return;
		}
		array<string> hooks = hook.Split(" ");
		this.RegisterHook(hooks);
	}
	void RegisterHook(array<string> hooks) final
	{
		RegisterRemoveHook(hooks);
	}
	void RemoveHook(string hook) final
	{
		if(hook == "*")
		{
			this.RegisterRemoveHookAll(false);
			return;
		}
		array<string> hooks = hook.Split(" ");
		this.RemoveHook(hooks);
	}
	void RemoveHook(array<string> hooks) final
	{
		RegisterRemoveHook(hooks, false);
	}	
	void RegisterHookExcept(array<string> exceptions)
	{
		this.RegisterRemoveHookAll(true, exceptions);
	}
	void RemoveHookExcept(array<string> exceptions)
	{
		this.RegisterRemoveHookAll(false, exceptions);
	}
	private void RegisterRemoveHook(array<string> hooks, bool register = true)
	{
		if(hooks.length() == 0) return;
		for(uint i = 0; i < hooks.length(); i++)
		{
			EasyHookTypes@ hook = this.GetHookByName(hooks[i]);
			if(hook !is null)
			{
				if(register) hook.Register();
				else hook.Unregister();
			}
		}
		return;
	}
	private void RegisterRemoveHookAll(bool register, array<string> exceptions = {})
	{
		for(uint i = 0; i < this.allHooks.length(); i++)
		{
			if(exceptions.find(this.allHooks[i].Name) >= 0) continue;
			if(register) this.allHooks[i].Register();
			else this.allHooks[i].Unregister();
		}
	}
	private EasyHookTypes@ GetHookByName(string name)
	{
		if(name.IsEmpty() || name == "*") return null;
		for(uint i = 0; i < this.allHooks.length(); i++)
		{
			if(this.allHooks[i].Name == name) return this.allHooks[i];
		}
		return null;
	}
	private bool BinderValid(IEasyHookRegisters@ binder)
	{
		return binder !is null && binder.IsEnabled();
	}
	private bool BinderPreCalled(IEasyHookRegisters@ binder, string name, int index)
	{
		dictionary@ vars = @this.binderHooks[index];
		if(vars is null) return true;
		return vars.exists(name);
	}
	private void BinderPostCalled(IEasyHookRegisters@ binder, string name)
	{
		
	}
	HookReturnCode CanPlayerUseReservedSlot( edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bAllowJoin)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "CanPlayerUseReservedSlot", i)) continue;
				binder.CanPlayerUseReservedSlot(@pEntity, szPlayerName, szIPAddress, bAllowJoin);
				this.BinderPostCalled(@binder, "CanPlayerUseReservedSlot");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientConnected(  edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason)	
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "ClientConnected", i)) continue;
				binder.ClientConnected(@pEntity, szPlayerName, szIPAddress, bDisallowJoin, szRejectReason);
				this.BinderPostCalled(@binder, "ClientConnected");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "ClientPutInServer", i)) continue;
				binder.ClientPutInServer(@pPlayer);
				this.BinderPostCalled(@binder, "ClientPutInServer");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "ClientDisconnect", i)) continue;
				binder.ClientDisconnect(@pPlayer);
				this.BinderPostCalled(@binder, "ClientDisconnect");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientSay( SayParameters@ pParams )
	{	
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "ClientSay", i)) continue;
				binder.ClientSay(@pParams);
				this.BinderPostCalled(@binder, "ClientSay");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode MapChange()
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "MapChange", i)) continue;
				binder.MapChange();
				this.BinderPostCalled(@binder, "MapChange");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode EntityCreated(CBaseEntity@ pEntity)
	{		
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "EntityCreated", i)) continue;
				binder.EntityCreated(@pEntity);
				this.BinderPostCalled(@binder, "EntityCreated");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
	{		
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerSpawn", i)) continue;
				binder.PlayerSpawn(@pPlayer);
				this.BinderPostCalled(@binder, "PlayerSpawn");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerCanRespawn(CBasePlayer@ pPlayer, bool& out bCanRespawn)
	{		
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerCanRespawn", i)) continue;
				binder.PlayerCanRespawn(@pPlayer, bCanRespawn);
				this.BinderPostCalled(@binder, "PlayerCanRespawn");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerKilled", i)) continue;
				binder.PlayerKilled(@pPlayer, @pAttacker, iGib);
				this.BinderPostCalled(@binder, "PlayerKilled");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerUse(CBasePlayer@ pPlayer, uint& out uiFlags)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerUse", i)) continue;
				binder.PlayerUse(@pPlayer, uiFlags);
				this.BinderPostCalled(@binder, "PlayerUse");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerPreThink(CBasePlayer@ pPlayer, uint& out uiFlags)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerPreThink", i)) continue;
				binder.PlayerPreThink(@pPlayer, uiFlags);
				this.BinderPostCalled(@binder, "PlayerPreThink");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerPostThink(CBasePlayer@ pPlayer)
	{	
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];

				if(this.CheckIsRemove(@binder, i, i)) continue;

				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerPostThink", i)) continue;
				binder.PlayerPostThink(@pPlayer);
				this.BinderPostCalled(@binder, "PlayerPostThink");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerTakeDamage(DamageInfo@ pDamageInfo)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerTakeDamage", i)) continue;
				binder.PlayerTakeDamage(@pDamageInfo);
				this.BinderPostCalled(@binder, "PlayerTakeDamage");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode GetPlayerSpawnSpot(CBasePlayer@ pPlayer, CBaseEntity@& out ppEntSpawnSpot)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "GetPlayerSpawnSpot", i)) continue;
				binder.GetPlayerSpawnSpot(@pPlayer, @ppEntSpawnSpot);
				this.BinderPostCalled(@binder, "GetPlayerSpawnSpot");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerPreDecal(CBasePlayer@ pPlayer, const TraceResult& in trace, bool& out bResult)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerPreDecal", i)) continue;
				binder.PlayerPreDecal(@pPlayer, trace, bResult);
				this.BinderPostCalled(@binder, "PlayerPreDecal");
			}
		}	
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerDecal(CBasePlayer@ pPlayer, const TraceResult& in trace)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerDecal", i)) continue;
				binder.PlayerDecal(@pPlayer, trace);
				this.BinderPostCalled(@binder, "PlayerDecal");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerEnteredObserver(CBasePlayer@ pPlayer)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerEnteredObserver", i)) continue;
				binder.PlayerEnteredObserver(@pPlayer);
				this.BinderPostCalled(@binder, "PlayerEnteredObserver");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerLeftObserver(CBasePlayer@ pPlayer)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "PlayerLeftObserver", i)) continue;
				binder.PlayerLeftObserver(@pPlayer);
				this.BinderPostCalled(@binder, "PlayerLeftObserver");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "WeaponPrimaryAttack", i)) continue;
				binder.WeaponPrimaryAttack(@pPlayer, @pWeapon);
				this.BinderPostCalled(@binder, "WeaponPrimaryAttack");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode WeaponSecondaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "WeaponSecondaryAttack", i)) continue;
				binder.WeaponSecondaryAttack(@pPlayer, @pWeapon);
				this.BinderPostCalled(@binder, "WeaponSecondaryAttack");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode WeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "WeaponTertiaryAttack", i)) continue;
				binder.WeaponTertiaryAttack(@pPlayer, @pWeapon);
				this.BinderPostCalled(@binder, "WeaponTertiaryAttack");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode CanCollect(CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult)
	{
		bResult = true;
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "CanCollect", i)) continue;
					
				binder.CanCollect(@pPickup, @pOther, bResult);
				this.BinderPostCalled(@binder, "CanCollect");
			}
		}

		return HOOK_CONTINUE;
	}
	HookReturnCode Collected(CBaseEntity@ pPickup, CBaseEntity@ pOther)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "Collected", i)) continue;
				binder.Collected(@pPickup, @pOther);
				this.BinderPostCalled(@binder, "Collected");
			}
		}
		return HOOK_CONTINUE;
	}
	HookReturnCode Materialize(CBaseEntity@ pPickup)
	{
		if(this.BindingsEnabled())
		{
			for(uint i = 0; i < this.bindings.length(); i++)
			{
				auto binder = @this.bindings[i];
				if(this.CheckIsRemove(@binder, i, i)) continue;
				if(!this.BinderValid(@binder) || !this.BinderPreCalled(@binder, "Materialize", i)) continue;
				binder.Materialize(@pPickup);
				this.BinderPostCalled(@binder, "Materialize");
			}
		}
		return HOOK_CONTINUE;
	}
	private bool CheckIsRemove(IEasyHookRegisters@ binder, int index, int & out outindex)
	{
		outindex = index;
		if(binder is null)
		{
			this.bindings.removeAt(index);
			this.binderHooks.removeAt(index);
			outindex--;
			return true;
		}
		return false;
	}
}