interface IEasyHookRegisters
{
	bool IsEnabled();
	void SetEnabled(bool);
	string GetName();
	void SetName(string);
	HookReturnCode CanPlayerUseReservedSlot(edict_t@, const string& in, const string& in, bool& out);
	HookReturnCode ClientConnected(edict_t@, const string& in, const string& in, bool& out, string& out);
	HookReturnCode ClientPutInServer(CBasePlayer@);
	HookReturnCode ClientDisconnect(CBasePlayer@);
	HookReturnCode ClientSay(SayParameters@);
	HookReturnCode MapChange();
	HookReturnCode EntityCreated(CBaseEntity@);
	HookReturnCode PlayerSpawn(CBasePlayer@);
	HookReturnCode PlayerCanRespawn(CBasePlayer@, bool& out);
	HookReturnCode PlayerKilled(CBasePlayer@, CBaseEntity@, int);
	HookReturnCode PlayerUse(CBasePlayer@, uint& out);
	HookReturnCode PlayerPreThink(CBasePlayer@, uint& out);
	HookReturnCode PlayerPostThink(CBasePlayer@);
	HookReturnCode PlayerTakeDamage(DamageInfo@);
	HookReturnCode GetPlayerSpawnSpot(CBasePlayer@, CBaseEntity@& out);
	HookReturnCode PlayerPreDecal(CBasePlayer@, const TraceResult& in, bool& out);
	HookReturnCode PlayerDecal(CBasePlayer@, const TraceResult& in);
	HookReturnCode PlayerEnteredObserver(CBasePlayer@);
	HookReturnCode PlayerLeftObserver(CBasePlayer@);
	HookReturnCode WeaponPrimaryAttack(CBasePlayer@, CBasePlayerWeapon@);
	HookReturnCode WeaponSecondaryAttack(CBasePlayer@, CBasePlayerWeapon@);
	HookReturnCode WeaponTertiaryAttack(CBasePlayer@, CBasePlayerWeapon@);
	HookReturnCode CanCollect(CBaseEntity@, CBaseEntity@, bool& out);
	HookReturnCode Collected(CBaseEntity@, CBaseEntity@);
	HookReturnCode Materialize(CBaseEntity@);
	bool opEquals(IEasyHookRegisters@);
}