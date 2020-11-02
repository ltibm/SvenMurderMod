class EHPlayerPreDecal : EasyHookTypes
{
	private PlayerPreDecalHook@ innerHook;
	EHPlayerPreDecal(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "PlayerPreDecal";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @PlayerPreDecalHook(@this.EasyHookBase.PlayerPreDecal);
		g_Hooks.RegisterHook(Hooks::Player::PlayerPreDecal, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::PlayerPreDecal, @this.innerHook);
		@this.innerHook = null;
	}
}