class EHCollected : EasyHookTypes
{
	private CollectedHook@ innerHook;
	EHCollected(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "Collected";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @CollectedHook(@this.EasyHookBase.Collected);
		g_Hooks.RegisterHook(Hooks::PickupObject::Collected, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::PickupObject::Collected, @this.innerHook);
		@this.innerHook = null;
	}
}