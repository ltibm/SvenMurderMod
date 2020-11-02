class EHWeaponSecondaryAttack : EasyHookTypes
{
	private WeaponSecondaryAttackHook@ innerHook;
	EHWeaponSecondaryAttack(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "WeaponSecondaryAttack";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @WeaponSecondaryAttackHook(@this.EasyHookBase.WeaponSecondaryAttack);
		g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Weapon::WeaponSecondaryAttack, @this.innerHook);
		@this.innerHook = null;
	}
}