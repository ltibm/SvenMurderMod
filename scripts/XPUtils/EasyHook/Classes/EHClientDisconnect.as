class EHClientDisconnect : EasyHookTypes
{
	private ClientDisconnectHook@ innerHook;
	EHClientDisconnect(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "ClientDisconnect";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @ClientDisconnectHook(@this.EasyHookBase.ClientDisconnect);
		g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::ClientDisconnect, @this.innerHook);
		@this.innerHook = null;
	}
}