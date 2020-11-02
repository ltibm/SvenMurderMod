class EHGetPlayerSpawnSpot : EasyHookTypes
{
	private GetPlayerSpawnSpotHook@ innerHook;
	EHGetPlayerSpawnSpot(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "GetPlayerSpawnSpot";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @GetPlayerSpawnSpotHook(@this.EasyHookBase.GetPlayerSpawnSpot);
		g_Hooks.RegisterHook(Hooks::Player::GetPlayerSpawnSpot, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::GetPlayerSpawnSpot, @this.innerHook);
		@this.innerHook = null;
	}
}