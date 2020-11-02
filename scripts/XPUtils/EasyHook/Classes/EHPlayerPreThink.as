class EHPlayerPreThink : EasyHookTypes
{
	private PlayerPreThinkHook@ innerHook;
	EHPlayerPreThink(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerPreThink";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerPreThinkHook(@this.EasyHookBase.PlayerPreThink);
		g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerPreThink, @this.innerHook);
		@this.innerHook = null;
	}
}