//#include  "Classes/_XPEasyHookIncludes"
class XPPlayerDataBase
{
	private dictionary@ userdata;
	XPPlayerDataBase()
	{
		this.Construct();
	}
	private void Construct()
	{
		@this.userdata = @dictionary();
	}
	~XPPlayerDataBase()
	{
		@this.userdata = null;
	}
	void DeleteUserData(CBasePlayer@ cPlayer)
	{
		this.userdata.delete(PlayerActions::GetUserSteamId(@cPlayer));
	}
	void DeleteUserDataKey(CBasePlayer@ cPlayer, string key)
	{
		if(cPlayer is null)
		{
			for (int i = 1; i <= g_Engine.maxClients; i++) {
				CBasePlayer@ player = g_PlayerFuncs.FindPlayerByIndex(i);
				if(player is null || !player.IsConnected()) continue;
				this.DeleteUserDataKey(@player, key);
			}
			return;
		}
		auto dict = GetUserDictionary(@cPlayer);
		dict.delete(key);
	}
	void ClearUserData(CBasePlayer@ cPlayer)
	{
		this.DeleteUserData(@cPlayer);
		this.userdata.set(PlayerActions::GetUserSteamId(@cPlayer), @dictionary());
	}
	dictionary@ GetUserDictionary(CBasePlayer@ cPlayer) final
	{
		dictionary@ userDict;
		this.userdata.get(PlayerActions::GetUserSteamId(@cPlayer), @userDict);
		if(userDict is null)
		{
			@userDict = @dictionary();
			this.userdata.set(PlayerActions::GetUserSteamId(@cPlayer), @userDict);
		}
		return userDict;
	}
	int GetUserDataInt(CBasePlayer@ cPlayer, string key, int defaultValue = 0) final
	{
		auto dict = GetUserDictionary(@cPlayer);
		int value = 0;
		if(dict is null) return defaultValue;
		if(dict.get(key, value)) return value;
		return defaultValue;
		
	}
	float GetUserDataFloat(CBasePlayer@ cPlayer, string key, float defaultValue = 0) final
	{
		auto dict = GetUserDictionary(@cPlayer);
		float value = 0;
		if(dict is null) return defaultValue;
		if(dict.get(key, value)) return value;
		return defaultValue;
	}
	Vector GetUserDataVector(CBasePlayer@ cPlayer, string key, Vector defaultValue = g_vecZero) final
	{
		auto dict = GetUserDictionary(@cPlayer);
		Vector value = g_vecZero;
		if(dict is null) return defaultValue;
		if(dict.get(key, value)) return value;
		return defaultValue;
	}
	bool GetUserDataBool(CBasePlayer@ cPlayer, string key, bool defaultValue = false) final
	{
		auto dict = GetUserDictionary(@cPlayer);
		bool value = false;
		if(dict is null) return defaultValue;
		if(dict.get(key, value)) return value;
		return defaultValue;
	}
	void SetUserDataFloat(CBasePlayer@ cPlayer, string key, float value) final
	{
		auto dict = GetUserDictionary(@cPlayer);
		dict.set(key, value);
	}
	void SetUserDataInt(CBasePlayer@ cPlayer, string key, int value) final
	{
		auto dict = GetUserDictionary(@cPlayer);
		dict.set(key, value);
	}
	void SetUserDataVector(CBasePlayer@ cPlayer, string key, Vector value) final
	{
		auto dict = GetUserDictionary(@cPlayer);
		dict.set(key, value);
	}
	void SetUserDataBool(CBasePlayer@ cPlayer, string key, bool value) final
	{
		if(cPlayer is null)
		{
			for (int i = 1; i <= g_Engine.maxClients; i++) {
				CBasePlayer@ player = g_PlayerFuncs.FindPlayerByIndex(i);
				if(player is null || !player.IsConnected()) continue;
				this.SetUserDataBool(@player, key, value);
			}
			return;
		}
		auto dict = GetUserDictionary(@cPlayer);
		dict.set(key, value);
	}

	bool opEquals(XPPlayerDataBase@  other)
	{
		if(other is null) return false;
		return (this !is null && ( @this == @other));
	}
}