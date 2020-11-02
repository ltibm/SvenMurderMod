class EHClientSay : EasyHookTypes
{
	private ClientSayHook@ innerHook;
	EHClientSay(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "ClientSay";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @ClientSayHook(@this.EasyHookBase.ClientSay);
		g_Hooks.RegisterHook(Hooks::Player::ClientSay, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::ClientSay, @this.innerHook);
		@this.innerHook = null;
	}
}