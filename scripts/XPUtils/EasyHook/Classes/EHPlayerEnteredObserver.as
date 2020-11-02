class EHPlayerEnteredObserver : EasyHookTypes
{
	private PlayerEnteredObserverHook@ innerHook;
	EHPlayerEnteredObserver(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerEnteredObserver";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerEnteredObserverHook(@this.EasyHookBase.PlayerEnteredObserver);
		g_Hooks.RegisterHook(Hooks::Player::PlayerEnteredObserver, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerEnteredObserver, @this.innerHook);
		@this.innerHook = null;
	}
}