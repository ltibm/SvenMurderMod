class EHPlayerDecal : EasyHookTypes
{
	private PlayerDecalHook@ innerHook;
	EHPlayerDecal(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerDecal";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerDecalHook(@this.EasyHookBase.PlayerDecal);
		g_Hooks.RegisterHook(Hooks::Player::PlayerDecal, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerDecal, @this.innerHook);
		@this.innerHook = null;
	}
}