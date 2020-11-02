class EHCanPlayerUseReservedSlot : EasyHookTypes
{
	private CanPlayerUseReservedSlotHook@ innerHook;
	EHCanPlayerUseReservedSlot(IEasyHookRegisters@ registers)
	{
		super(@registers);
		this.Name = "CanPlayerUseReservedSlot";
	}
	bool IsRegistered()
	{
		return this.innerHook !is null;
	}
	void Register()
	{
		if(this.IsRegistered()) return;
		@this.innerHook = @CanPlayerUseReservedSlotHook(@this.EasyHookBase.CanPlayerUseReservedSlot);
		g_Hooks.RegisterHook(Hooks::Player::CanPlayerUseReservedSlot, @this.innerHook);
	}
	void Unregister()
	{
		if(!this.IsRegistered()) return;
		g_Hooks.RemoveHook(Hooks::Player::CanPlayerUseReservedSlot, @this.innerHook);
		@this.innerHook = null;
	}
}