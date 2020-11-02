class EHPlayerSpawn : EasyHookTypes
{
	private PlayerSpawnHook@ innerHook;
	EHPlayerSpawn(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerSpawn";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerSpawnHook(@this.EasyHookBase.PlayerSpawn);
		g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerSpawn, @this.innerHook);
		@this.innerHook = null;
	}
}