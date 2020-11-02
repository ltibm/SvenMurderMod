class EHWeaponPrimaryAttack : EasyHookTypes
{
	private WeaponPrimaryAttackHook@ innerHook;
	EHWeaponPrimaryAttack(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "WeaponPrimaryAttack";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @WeaponPrimaryAttackHook(@this.EasyHookBase.WeaponPrimaryAttack);
		g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Weapon::WeaponPrimaryAttack, @this.innerHook);
		@this.innerHook = null;
	}
}