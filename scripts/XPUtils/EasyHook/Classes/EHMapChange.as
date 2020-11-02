class EHMapChange : EasyHookTypes
{
	private MapChangeHook@ innerHook;
	EHMapChange(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "MapChange";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @MapChangeHook(@this.EasyHookBase.MapChange);
		g_Hooks.RegisterHook(Hooks::Game::MapChange, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Game::MapChange, @this.innerHook);
		@this.innerHook = null;
	}
}