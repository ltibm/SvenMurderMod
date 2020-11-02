class EHClientConnected : EasyHookTypes
{
	private ClientConnectedHook@ innerHook;
	EHClientConnected(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "ClientConnected";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @ClientConnectedHook(@this.EasyHookBase.ClientConnected);
		g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::ClientConnected, @this.innerHook);
		@this.innerHook = null;
	}
}