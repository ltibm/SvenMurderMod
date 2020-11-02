class EHPlayerKilled : EasyHookTypes
{
	private PlayerKilledHook@ innerHook;
	EHPlayerKilled(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerKilled";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerKilledHook(@this.EasyHookBase.PlayerKilled);
		g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerKilled, @this.innerHook);
		@this.innerHook = null;
	}
}