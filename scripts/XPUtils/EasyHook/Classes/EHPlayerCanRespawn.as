class EHPlayerCanRespawn : EasyHookTypes
{
	private PlayerCanRespawnHook@ innerHook;
	EHPlayerCanRespawn(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerCanRespawn";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerCanRespawnHook(@this.EasyHookBase.PlayerCanRespawn);
		g_Hooks.RegisterHook(Hooks::Player::PlayerCanRespawn, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerCanRespawn, @this.innerHook);
		@this.innerHook = null;
	}
}