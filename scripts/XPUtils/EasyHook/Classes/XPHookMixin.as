mixin class XPHookMixin : IEasyHookRegisters
{
	private bool isenabled = true;
	private string name;
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
	HookReturnCode CanPlayerUseReservedSlot( edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bAllowJoin)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientConnected(  edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason)	
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode ClientSay( SayParameters@ pParams )
	{		
		return HOOK_CONTINUE;
	}
	HookReturnCode MapChange()
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode EntityCreated(CBaseEntity@ pEntity)
	{		
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
	{		
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerCanRespawn(CBasePlayer@ pPlayer, bool& out bCanRespawn)
	{		
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerUse(CBasePlayer@ pPlayer, uint& out uiFlags)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerPreThink(CBasePlayer@ pPlayer, uint& out uiFlags)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerPostThink(CBasePlayer@ pPlayer)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerTakeDamage(DamageInfo@ pDamageInfo)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode GetPlayerSpawnSpot(CBasePlayer@ pPlayer, CBaseEntity@& out ppEntSpawnSpot)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerPreDecal(CBasePlayer@ pPlayer, const TraceResult& in trace, bool& out bResult)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerDecal(CBasePlayer@ pPlayer, const TraceResult& in trace)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerEnteredObserver(CBasePlayer@ pPlayer)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode PlayerLeftObserver(CBasePlayer@ pPlayer)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode WeaponSecondaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode WeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode CanCollect(CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode Collected(CBaseEntity@ pPickup, CBaseEntity@ pOther)
	{
		return HOOK_CONTINUE;
	}
	HookReturnCode Materialize(CBaseEntity@ pPickup)
	{
		return HOOK_CONTINUE;
	}
	bool opEquals(IEasyHookRegisters@  other)
	{
		return this !is null && @this == @other;
	}
}