class EHClientPutInServer : EasyHookTypes
{
	private ClientPutInServerHook@ innerHook;
	EHClientPutInServer(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "ClientPutInServer";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @ClientPutInServerHook(@this.EasyHookBase.ClientPutInServer);
		g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::ClientPutInServer, @this.innerHook);
		@this.innerHook = null;
	}
}