abstract class EasyHookTypes
{
	EasyHookTypes(){}
	EasyHookTypes(IEasyHookRegisters@ registers)
	{
		@this.EasyHookBase = @registers;
	}
	private string name;
	string Name
	{
		get const
		{
			return this.name;
		}
		set
		{
			this.name = value;
		}
	}
	IEasyHookRegisters@ easyHookBase;
	IEasyHookRegisters@ EasyHookBase
	{
		get const
		{
			return this.easyHookBase;
		}
		set
		{
			@this.easyHookBase = @value;
		}
	}	
	bool IsRegistered()
	{
		return false;
	}
	void Register()
	{
	}
	void Unregister()
	{
	}
}