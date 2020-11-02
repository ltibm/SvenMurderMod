class EHPlayerPostThink : EasyHookTypes
{
	private PlayerPostThinkHook@ innerHook;
	EHPlayerPostThink(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerPostThink";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerPostThinkHook(@this.EasyHookBase.PlayerPostThink);
		g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerPostThink, @this.innerHook);
		@this.innerHook = null;
	}
}