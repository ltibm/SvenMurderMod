class EHMaterialize : EasyHookTypes
{
	private MaterializeHook@ innerHook;
	EHMaterialize(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "Materialize";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @MaterializeHook(@this.EasyHookBase.Materialize);
		g_Hooks.RegisterHook(Hooks::PickupObject::Materialize, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::PickupObject::Materialize, @this.innerHook);
		@this.innerHook = null;
	}
}