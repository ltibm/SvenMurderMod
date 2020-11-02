class EHPlayerLeftObserver : EasyHookTypes
{
	private PlayerLeftObserverHook@ innerHook;
	EHPlayerLeftObserver(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerLeftObserver";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerLeftObserverHook(@this.EasyHookBase.PlayerLeftObserver);
		g_Hooks.RegisterHook(Hooks::Player::PlayerLeftObserver, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerLeftObserver, @this.innerHook);
		@this.innerHook = null;
	}
}