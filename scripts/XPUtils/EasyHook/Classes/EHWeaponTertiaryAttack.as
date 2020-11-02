class EHWeaponTertiaryAttack : EasyHookTypes
{
	private WeaponTertiaryAttackHook@ innerHook;
	EHWeaponTertiaryAttack(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "WeaponTertiaryAttack";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @WeaponTertiaryAttackHook(@this.EasyHookBase.WeaponTertiaryAttack);
		g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Weapon::WeaponTertiaryAttack, @this.innerHook);
		@this.innerHook = null;
	}
}