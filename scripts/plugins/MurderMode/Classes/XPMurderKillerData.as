final class XPMurderKillerData : XPPlayerDataBase
{
	float GetLastKilledTime(CBasePlayer@ cPlayer)
	{
		float lastKilledAt = GetUserDataFloat(@cPlayer, "last_killed_at");
		if(lastKilledAt == 0)
		{
			SetUserDataFloat(@cPlayer, "last_killed_at", g_Engine.time);
			lastKilledAt = g_Engine.time;
		}
		return lastKilledAt;
	}
	void SetLastKilledTime(CBasePlayer@ cPlayer, float time)
	{
		SetUserDataFloat(@cPlayer, "last_killed_at", time);
	}
}