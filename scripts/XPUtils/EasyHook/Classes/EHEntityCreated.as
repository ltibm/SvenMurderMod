class EHEntityCreated : EasyHookTypes
{
	private EntityCreatedHook@ innerHook;
	EHEntityCreated(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "EntityCreated";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @EntityCreatedHook(@this.EasyHookBase.EntityCreated);
		g_Hooks.RegisterHook(Hooks::Game::EntityCreated, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Game::EntityCreated, @this.innerHook);
		@this.innerHook = null;
	}
}