class EHPlayerTakeDamage : EasyHookTypes
{
	private PlayerTakeDamageHook@ innerHook;
	EHPlayerTakeDamage(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerTakeDamage";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerTakeDamageHook(@this.EasyHookBase.PlayerTakeDamage);
		g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerTakeDamage, @this.innerHook);
		@this.innerHook = null;
	}
}