final class XPMurderGeneralData : XPPlayerDataBase
{
	float GetLastBlindTime(CBasePlayer@ cPlayer)
	{
		float lastblindTime = GetUserDataFloat(@cPlayer, "last_blind_at");
		return lastblindTime;
	}
	void SetLastBlindTime(CBasePlayer@ cPlayer, float time)
	{
		this.SetUserDataFloat(@cPlayer, "last_blind_at", time);
	}
}