class EHCanCollect : EasyHookTypes
{
	private CanCollectHook@ innerHook;
	EHCanCollect(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "CanCollect";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @CanCollectHook(@this.EasyHookBase.CanCollect);
		g_Hooks.RegisterHook(Hooks::PickupObject::CanCollect, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::PickupObject::CanCollect, @this.innerHook);
	}
}