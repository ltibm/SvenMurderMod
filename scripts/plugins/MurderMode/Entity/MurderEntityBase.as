class MurderEntityBase : ScriptBaseEntity
{
	private float thinkTime = 0.6;
	float ThinkTime
	{
		get const
		{
			return this.thinkTime;
		}
		set
		{
			if(value < 0) value = 0;
			this.thinkTime = value;
		}
	}
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if(szKey == "ThinkTime")
		{
			this.ThinkTime = atof(szValue);
			return true;
		}
		return BaseClass.KeyValue( szKey, szValue );
	}
	
	void OnCreate()
	{
		self.pev.nextthink = g_Engine.time;
	}
	void Think()
	{
		if(!g_CurrentGame.InRound()) 
		{
			self.pev.nextthink = g_Engine.time + this.ThinkTime;
			return;
		}
		for (int i = 1; i <= g_Engine.maxClients; i++) 
		{
			CBasePlayer@ cPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(cPlayer is null || !cPlayer.IsConnected()) continue;
			PlayerThink(@cPlayer);
		}
		self.pev.nextthink = g_Engine.time + this.ThinkTime;
	}
	void PlayerThink(CBasePlayer@ cPlayer)
	{
	}
}