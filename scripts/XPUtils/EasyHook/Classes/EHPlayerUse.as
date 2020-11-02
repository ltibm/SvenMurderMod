class EHPlayerUse : EasyHookTypes
{
	private PlayerUseHook@ innerHook;
	EHPlayerUse(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerUse";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerUseHook(@this.EasyHookBase.PlayerUse);
		g_Hooks.RegisterHook(Hooks::Player::PlayerUse, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerUse, @this.innerHook);
		@this.innerHook = null;
	}
}