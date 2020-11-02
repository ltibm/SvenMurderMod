#include "xp_access"
#include "xp_util_ent"
#include "xp_util_uv"
array<CTextMenu@> nPromptMenu(33);
array<CTextMenu@> nPromptMenuB(33);
array<CTextMenu@> nMenuA(33);
array<CTextMenu@> nMenuB(33);
array<CTextMenu@> nMenuC(33);
array<CTextMenu@> nLastMenu(33);
array<float> nLastMenuTime(33);
array<int> nMenuN(33);
array<int> nPromptMenuType(33);
array<string> nUserSessions(33);
const string config_path = "scripts/plugins/Config/maps/config/";
class EntityTraceClass
{
	TraceResult tr;
	TraceResult tr_end;
	CBaseEntity@ Entity;
	Vector TakedOrigin;
	EntityTraceClass(){}
	EntityTraceClass(CBaseEntity@ entity)
	{
		@Entity = entity;
	}
	EntityTraceClass(CBaseEntity@ entity, Vector takedOrigin)
	{
		@Entity = entity;
		TakedOrigin = takedOrigin;
	}
	EntityTraceClass(CBaseEntity@ entity, Vector takedOrigin, TraceResult _tr)
	{
		@Entity = entity;
		TakedOrigin = takedOrigin;
		tr = _tr;
	}
	EntityTraceClass(CBaseEntity@ entity, Vector takedOrigin, TraceResult _tr, TraceResult _tr_end)
	{
		@Entity = entity;
		TakedOrigin = takedOrigin;
		tr = _tr;
		tr_end = _tr_end;
	}
}
class TeleLoc
{
	Vector TeleLocation;
	float pitch, yaw;
	bool noData = false;
	float lasttime;
	string TeleName;
}
enum ANGLEVECTORSFLAG
{
	ANGLEVECTORS_FORWARD = 0,
	ANGLEVECTORS_RIGHT,
	ANGLEVECTORS_UP
}
class promptreturn
{
	int senderid;
	any@ aitems;
}
class MapConf
{
	string Name;
	string Value;
	bool isEmpty;
}
class MapInfo
{
	bool setTeamDefault;
	bool MapSetup;
	bool IsDeathmatch;
	bool TeamVsTeam;
	bool IsFunny;
	bool IsZombie;
	bool IsVoting;
	bool nobalancecontrol = false;
	bool teamvsteamspawnloc = false;
	int prev_mod = -1;
	int teamonelimit = 0;
	int teamtwolimit = 0;
	bool nodeathmatch = false;
	bool noteamvsteam = false;
	bool noteamvsteamdm = false;
	int timeoffwintype = 0; //0 Default, 1 Always blue win, 2 Always red win
	int RoundTime = 110;
	int RoundTimeMax = 110;
	bool unammo = false;
	int hardmode;
	bool adddefspawnpoints = false;
	float hardvalue;
	string lightoverride;
	dictionary all_vars;
	bool Loaded;
	bool is_survival;
}
class ApiInfo
{
	bool Success;
	string Response;
	array<string> Responses;
}
string GetInfoValue(int id, string key)
{
	CBasePlayer@ cPlayer = get_player(id);
	return GetInfoValue(cPlayer, key);
}
string GetInfoValue(CBasePlayer@ cPlayer, string key)
{
	if(cPlayer is null) return "";
	KeyValueBuffer@ nBuf = null;
	@nBuf = g_EngineFuncs.GetInfoKeyBuffer(cPlayer.edict());
	if(nBuf is null) return "";
	return nBuf.GetValue(key);
}
string GetInfoValue(edict_t@ cEdc, string key)
{
	if(cEdc is null) return "";
	KeyValueBuffer@ nBuf = null;
	@nBuf = g_EngineFuncs.GetInfoKeyBuffer(@cEdc);
	if(nBuf is null) return "";
	return nBuf.GetValue(key);
}
void SetInfoValue(int id, string key, string value)
{
	CBasePlayer@ cPlayer = get_player(id);
	SetInfoValue(cPlayer, key, value);
}
void SetInfoValue(CBasePlayer@ cPlayer, string key, string value)
{
	if(cPlayer is null) return;
	KeyValueBuffer@ nBuf = null;
	@nBuf = g_EngineFuncs.GetInfoKeyBuffer(cPlayer.edict());
	if(nBuf is null) return;
	nBuf.SetValue(key, value);
}
void RemoveValue(int id, string key)
{
	CBasePlayer@ cPlayer = get_player(id);
	RemoveValue(cPlayer, key);
}
void RemoveValue(CBasePlayer@ cPlayer, string key)
{
	if(cPlayer is null) return;
	KeyValueBuffer@ nBuf = null;
	@nBuf = g_EngineFuncs.GetInfoKeyBuffer(cPlayer.edict());
	nBuf.RemoveValue(key);
}
bool isNumeric(string text)
{
	int ilen = int(text.Length());
	if(ilen == 0) return false;
	int dotcount = 0;
	int minuscount = 0;
	for(int i = 0; i < ilen; i++)
	{
		char ntext = text[i];
		if(!isDigit(string(ntext)))
		{
			return false;
		}
		if(ntext == ".")
		{
			dotcount++;
		}
		if(ntext == "-" && i > 0)
		{
			return false;
		}
		if(dotcount > 1) return false;
	}
	return true;
}
bool isDigit(string txt)
{
	int ilen = int(txt.Length());
	if(ilen != 1) return false;
	string chr = txt.SubString(0, 1);
	for(int i = 0; i <= 9; i++)
	{
		if(chr == i) return true;
	}
	if(chr == ".") return true;
	if(chr == "-") return true;
	return false;
}
int clamp(int source, int min, int nmax)
{
	if(source < min) source = min;
	if(source > nmax) source = nmax;
	return source;
}
float clampf(float source, float min, float nmax)
{
	if(source < min) source = min;
	if(source > nmax) source = nmax;
	return source;
}
bool user_hasweapon(CBasePlayer@ cPlayer, string weaponname)
{
	if(cPlayer is null) return false;
	array<string> userWeapons = get_userweapons_str(@cPlayer);
	for(uint i = 0; i < userWeapons.length();i++)
	{
		if(userWeapons[i] == weaponname) return true;
	}
	return false;
}
int remove_usersweapon(string weaponname, CBasePlayer@ starter = null, bool exceptme = true, bool advancedcmd = true, bool canimm = true)
{
	int ncount = 0;
	for (uint i = 1; i < 32; ++i) 
	{
		CBasePlayer@ cPlayer = get_player( i );
		if(cPlayer is null) continue;
		if(!cPlayer.IsConnected()) continue;
		if(exceptme && cPlayer == starter) continue;
		if(canimm)
		{
			if(user_has_access(i, XP_ACC_IMM) && starter != cPlayer)
			{
				continue;
			}
		}
		if(remove_userweapon(@cPlayer, weaponname, advancedcmd))
		{
			ncount++;
		}
    }
	return ncount;
}
bool remove_userweapon(CBasePlayer@ cPlayer, string weaponname, bool advancedcmd = false)
{
	if(cPlayer is null) return false;
	array<CBasePlayerItem@> userWeapons = get_userweapons(@cPlayer);
	array<string> nWeaponsList;
	if(weaponname == "#")
	{
		strip_user_weapons(@cPlayer);
		return true;
	}
	if(advancedcmd)
	{
		bool exceptstart = false;
		if(weaponname.StartsWith("*"))
		{
			if(weaponname.Length() == 1) return false;
			weaponname = weaponname.SubString(1);
			exceptstart = true;
		}
		array<string> Splitted = xp_string::ExplodeStringEx(-1, -1, weaponname, ",");
		if(exceptstart)
		{
			for(uint g = 0; g < userWeapons.length(); g++)
			{
				bool canadd = true;
				for(uint i = 0; i < Splitted.length(); i++)
				{
					string wname = Splitted[i];
					if(!wname.StartsWith("weapon_"))
					{
						wname = "weapon_" + wname;
					}
					if(userWeapons[g].pev.classname == wname)
					{
						canadd = false;
						break;
					}
				}
				if(canadd)
				{
					nWeaponsList.insertLast(userWeapons[g].pev.classname);
				}
			}

		}
		else
		{
			for(uint i = 0; i < Splitted.length(); i++)
			{
				string wname = Splitted[i];
				if(!wname.StartsWith("weapon_"))
				{
					wname = "weapon_" + wname;
				}
				nWeaponsList.insertLast(wname);
			}			
		}
	}
	else
	{
		if(!weaponname.StartsWith("weapon_"))
		{
			weaponname = "weapon_" + weaponname;
		}
		nWeaponsList.insertLast(weaponname);
	}
	int totalrmvd = 0;
	for(uint i = 0; i < userWeapons.length();i++)
	{
		for(uint j = 0; j < nWeaponsList.length(); j++)
		{
			if(userWeapons[i].pev.classname == nWeaponsList[j]) 
			{
				cPlayer.RemovePlayerItem(@userWeapons[i]);
				nWeaponsList.removeAt(j);
				totalrmvd++;
				if(nWeaponsList.length() == 0)
				{
					return true;
				}
				break;
			}
		}
	}
	if(totalrmvd > 0) return true;
	return false;
}
CBasePlayerItem@ get_userweapons_byclass(CBasePlayer@ nPlayer, string wname)
{
	if(nPlayer is null) return null;
	for( size_t uiIndex = 0; uiIndex < MAX_ITEM_TYPES; ++uiIndex )
	{
		CBasePlayerItem@ pEnt = nPlayer.m_rgpPlayerItems(uiIndex);
		if( pEnt !is null )
		{
			do
			{
				if(pEnt.pev.classname == wname) return @pEnt;
			}
			while( ( @pEnt = cast<CBasePlayerItem@>(pEnt.m_hNextItem.GetEntity()) ) !is null );
		}

	}
	return null;
}
array<CBasePlayerItem@> get_userweapons(CBasePlayer@ nPlayer)
{
	array<CBasePlayerItem@> uWeapons;
	if(nPlayer is null) return uWeapons;
	for( size_t uiIndex = 0; uiIndex < MAX_ITEM_TYPES; ++uiIndex )
	{
		CBasePlayerItem@ pEnt = nPlayer.m_rgpPlayerItems(uiIndex);
		if( pEnt !is null )
		{
			do
			{
				uWeapons.insertLast(@pEnt);
			}
			while( ( @pEnt = cast<CBasePlayerItem@>(pEnt.m_hNextItem.GetEntity()) ) !is null );
		}

	}
	return uWeapons;
}
array<string> get_userweapons_str(CBasePlayer@ nPlayer)
{
	array<string> uWeapons;
	if(nPlayer is null) return uWeapons;
	for( size_t uiIndex = 0; uiIndex < MAX_ITEM_TYPES; ++uiIndex )
	{
		CBasePlayerItem@ pEnt = nPlayer.m_rgpPlayerItems(uiIndex);
		if( pEnt !is null )
		{
			do
			{
				uWeapons.insertLast(pEnt.GetClassname());
			}
			while( ( @pEnt = cast<CBasePlayerItem@>(pEnt.m_hNextItem.GetEntity()) ) !is null );
		}

	}
	return uWeapons;
}
uint BotCount(float idletime = 0)
{
	int ncount = 0;
	for (uint i = 1; i < 32; ++i) 
	{
		CBasePlayer@ cPlayer = get_player( i );
		if(cPlayer is null) continue;
		if(!is_user_bot(i)) continue;
		if(idletime > 0)
		{
			float uidletime = atof(get_keyvalue(@cPlayer, "idle"));
			if(uidletime > idletime) 
			{
				continue;
			}
		}
		ncount++;
    }
	return ncount;
}
uint ClientCountAlive(float idletime = 0, bool includebots = false)
{
	int ncount = 0;
	for (uint i = 1; i < 32; ++i) 
	{
		CBasePlayer@ cPlayer = get_player( i );
		if(cPlayer is null) continue;
		if(!cPlayer.IsConnected()) continue;
		if(is_user_bot(i) && !includebots) continue;
		if(!cPlayer.IsAlive()) continue;
		if(idletime > 0)
		{
			float uidletime = atof(get_keyvalue(@cPlayer, "idle"));
			if(uidletime > idletime) 
			{
				continue;
			}
		}
		ncount++;
    }
	return ncount;
}
uint ClientCount(float idletime = 0, bool includebots = false)
{
	int ncount = 0;
	for (uint i = 1; i < 32; ++i) 
	{
		CBasePlayer@ cPlayer = get_player( i );
		if(cPlayer is null) continue;
		if(!cPlayer.IsConnected()) continue;
		if(is_user_bot(i) && !includebots) continue;
		if(idletime > 0)
		{
			float uidletime = atof(get_keyvalue(@cPlayer, "idle"));
			if(uidletime > idletime) 
			{
				continue;
			}
		}
		ncount++;
    }
	return ncount;
}
uint MaxPage(int itempergae, int maxitems)
{
	int kalan = maxitems % itempergae;
	int sonuc = maxitems / itempergae;
	if(kalan == 0) sonuc--;
	return sonuc;
}
uint GetPage(int cid, int perpageitems = 7)
{
	float msonuc = floor(float(cid) / float(perpageitems));
	return uint(msonuc);
}
void ShowMotdAll(CBasePlayer@ sender, string Message, string Name = "")
{
	for (uint i = 1; i < 32; ++i) 
	{
		CBasePlayer@ cPlayer = get_player( i );
		if(cPlayer is null) continue;
		if(!cPlayer.IsConnected()) continue;
		if(!user_can_accessplayer(@cPlayer, @sender))
		{
			continue;
		}
		ShowMotd(@cPlayer, Message, Name);
    }
}
void ShowMotd(CBasePlayer@ cPlayer, string Message, string Name = "")
{
	string gname = g_EngineFuncs.CVarGetString("hostname");
	if(!Name.IsEmpty())
	{
		NetworkMessage message(MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, @cPlayer.edict());
		message.WriteString(Name);
		message.End();
	}
	if(Message.Length() <= 30)
	{
		NetworkMessage messageb(MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, @cPlayer.edict());
		messageb.WriteByte(1);
		messageb.WriteString(Message);
		messageb.End();
		return;
	}
	int nLimit = 30;
	int cLimit = nLimit;
	int totallength = int(Message.Length());
	int starti = 0;
	string wText = "";
	while(totallength > 0)
	{
		wText = Message.SubString(starti, cLimit); 
		totallength -= nLimit;
		starti += nLimit;
		if(totallength < 0)
		{
			starti += totallength;
			cLimit += totallength;
			starti -= cLimit;
		}
		NetworkMessage messagec(MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, @cPlayer.edict());
		messagec.WriteByte(0);
		messagec.WriteString(wText);
		messagec.End();
	}
	//wText = Message.SubString(starti, cLimit); 
	NetworkMessage messagec(MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, @cPlayer.edict());
	messagec.WriteByte(1);
	messagec.End();
	if(!Name.IsEmpty())
	{
		NetworkMessage messagef(MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, @cPlayer.edict());
		messagef.WriteString(gname);
		messagef.End();
	}
}
bool is_user_admin_all(int userid)
{
	return is_user_admin_all(@get_player(userid));
}
bool is_user_admin_all(CBasePlayer@ cPlayer)
{
	return is_user_admin(cPlayer) || user_is_admin(cPlayer);
}
bool is_user_admin(int userid)
{
	return is_user_admin(@get_player(userid));
}
bool is_user_admin(CBasePlayer@ cPlayer)
{
	if(cPlayer is null) return false;
	if(!cPlayer.IsConnected()) return false;
	if(g_PlayerFuncs.AdminLevel(@cPlayer) > 0) return true;
	return false;
}
CBasePlayer@ cmd_target_p(string Name)
{
	int id = cmd_target(Name);
	if(id < 0) return null;
	return @get_player(id);
}
int cmd_target(string Name)
{
	CBasePlayer@ cPlayer = null;
	int innum = -1;
	if(Name.StartsWith("#") && Name.Length() > 1 && Name.Length() < 4)
	{
		string nsbstr = Name.SubString(1);
		if(isNumeric(nsbstr))
		{
			innum = atoi(nsbstr);
			if(innum <= 0) innum = -1;
			if(innum > 32) innum = -1;
		}
	}
	for(int i = 1; i < 33; i++)
	{
		@cPlayer = @get_player(i);
		if(cPlayer is null) continue;
		if(!cPlayer.IsConnected()) continue;
		if(innum > 0)
		{
			if(i == innum) return i;
			continue;
		}
		string uname = cPlayer.pev.netname;
		uname = uname.ToLowercase();
		string tName = Name.ToLowercase();
		int dindex = uname.Find(tName);
		if(dindex >= 0)
		{ 
			return i;
			
		}
	}
	return -1;
}
void show_prompt(int target, int sender, string Message, TextMenuPlayerSlotCallback@ inputCB, string MsgYes = "Yes", string MsgNo = "No", any@ nitem = null)
{
	CBasePlayer@ cPlayer;
	@cPlayer = @get_player(target);
	if(cPlayer is null) return;
	if(!cPlayer.IsConnected()) return;
	CTextMenu@ CurMenu = null;
	promptreturn prtrn;
	prtrn.senderid = sender;
	@prtrn.aitems = @nitem;
	if(nPromptMenuType[target] == 0)
	{
		@nPromptMenu[target] = CTextMenu(@inputCB);
		@CurMenu = @nPromptMenu[target];
		nPromptMenuType[target] = 1;
	}
	else
	{
		@nPromptMenuB[target] = CTextMenu(@inputCB);
		@CurMenu = @nPromptMenuB[target];
		nPromptMenuType[target] = 0;
	}
	CurMenu.SetTitle(Message);
	CurMenu.AddItem(MsgYes, any(prtrn));
	CurMenu.AddItem(MsgNo, any(prtrn));
	CurMenu.Register();
	CurMenu.Open(0, 0, cPlayer);
}
string get_user_name(int id)
{
	CBasePlayer@ cPlayer;
	@cPlayer = @get_player(id);
	if(cPlayer is null) return "";
	if(!cPlayer.IsConnected()) return "";
	return cPlayer.pev.netname;
}
bool is_user_connected(int id)
{
	CBasePlayer@ cPlayer;
	@cPlayer = @get_player(id);
	if(cPlayer is null) return false;
	return cPlayer.IsConnected();
}
string say_merge(const CCommand@ sayparam, int starti = 1)
{
	if(sayparam is null) return "";
	if(starti < 0) starti = 0;
	if(starti > sayparam.ArgC()) starti = sayparam.ArgC() - 1;
	string cmds = "";
	int ttll = 0;
	for(int i = starti; i < sayparam.ArgC(); i++)
	{
		if(ttll == 0)
		{
			cmds = sayparam.Arg(i);
		}
		else
		{
			cmds += " " + sayparam.Arg(i);
		}
		ttll++;
	}
	return cmds;
}
array<string> say_to_array(const CCommand@ sayparam, int sindex = 0)
{
	array<string> temp_array;
	if(sayparam is null) return temp_array;
	if(sindex < 0) sindex = 0;
	if(sindex > sayparam.ArgC()) sindex = sayparam.ArgC() - 1;
	for(int i = sindex; i < sayparam.ArgC(); i++)
	{
		temp_array.insertLast(sayparam[i]);
	}
	return temp_array;
}
bool precacheitem(array<string> items)
{
	for(uint i = 0; i < items.length(); i++)
	{
		 g_Game.PrecacheModel(items[i]);
	}
	return true;
}
string current_map()
{
	return string(g_Engine.mapname);
}
bool isCurrentMap(string szMapName)
{
	if(szMapName.ToLowercase() == string(g_Engine.mapname).ToLowercase())
	{
		return true;
	}
	return false;
}
void precache_model(string nm)
{
	g_Game.PrecacheModel(nm);
}
bool xp_isprecached(string nm)
{
	return true;
}
Vector angle_vector(Vector flAngle, ANGLEVECTORSFLAG Aflag)
{
	Vector v_forward, v_right, v_up, v_return;
	g_EngineFuncs.AngleVectors(flAngle, v_forward, v_right, v_up);
	switch (Aflag)
	{
		case ANGLEVECTORS_FORWARD:
			v_return = v_forward;
			break;
		case ANGLEVECTORS_RIGHT:
			v_return = v_right;
			break;
		case ANGLEVECTORS_UP:
			v_return = v_up;
			break;
	}
	return v_return;
}
Vector xp_get_distancevec(CBaseEntity@ mEnt, float xoffset, float yoffset, float zoffset)
{
	Vector porigin = GetOrigin(mEnt);
	return xp_get_distancevec(@mEnt, porigin, xoffset, yoffset, zoffset);
}
Vector xp_get_distancevec(CBaseEntity@ mEnt, Vector origin, float xoffset, float yoffset, float zoffset)
{
	Vector NewVector;
	Vector flVecSrc, flViewOfs;
	Vector flAngles, flForward;
	flVecSrc = origin;
	flViewOfs = mEnt.pev.view_ofs;
    flVecSrc.x += flViewOfs.x;
    flVecSrc.y += flViewOfs.y;
	flAngles = mEnt.pev.v_angle;
    flForward = angle_vector(flAngles, ANGLEVECTORS_FORWARD);
    NewVector.x = flVecSrc.x + (flForward.x * xoffset);
	NewVector.y = flVecSrc.y + (flForward.y * yoffset);
	NewVector.z = flVecSrc.z + zoffset;
	return NewVector;
}
bool set_ammo(CBasePlayer@ nPlayer, int amount, int ctype = 0, bool checkmax = true, string eqname = "")
{
	int atotal = 0;
	array<CBasePlayerItem@> uitems = get_userweapons(@nPlayer);
	for(uint i = 0; i < uitems.length(); i++)
	{
		if(uitems[i].pev.classname != eqname && eqname != "") continue;
		if(set_ammo(@nPlayer, @uitems[i], amount, ctype, checkmax))
		{
			atotal++;
		}
	}
	if(atotal > 0) return true;
	return false;
}
bool set_ammo(CBasePlayer@ nPlayer, CBasePlayerItem@ plitem, int amount, int ctype = 0, bool checkmax = true) //0: set, 1: add, 2: sub
{
	if(amount < 0) amount = 0;
	if(!nPlayer.IsAlive())
	{
		return false;
	}
	if(plitem is null) return false;
	int prindex = plitem.PrimaryAmmoIndex();
	int secindex = plitem.SecondaryAmmoIndex();
	if(prindex < 0 && secindex < 0) return false;
	bool firstok = false;
	bool secondok = false;
	if(prindex >= 0)
	{
		int prmax = plitem.iMaxAmmo1();
		int primaryammocount = nPlayer.m_rgAmmo(prindex);
		int willadd = amount;
		switch(ctype)
		{
			case 0:
			{
				if(amount == primaryammocount) return false;
				if(checkmax)
				{
					if(amount >= prmax)
					{
						if(primaryammocount < amount)
						{
							return false;
						}
					}
				}
				break;
			}
			case 1:
			{
				if(amount == 0) return false;
				if(checkmax)
				{
					if(primaryammocount >= prmax)
					{
						return false;
					}
					int afark = prmax - primaryammocount;
					if(amount > afark) amount = afark;
				}
				willadd = primaryammocount + amount;
				break;
			}
			case 2:
			{
				if(amount == 0 || primaryammocount == 0) return false;
				willadd = primaryammocount - amount;
				if(willadd < 0) willadd = 0;
				break;
			}
		}
		nPlayer.m_rgAmmo(prindex,  willadd);
		firstok = true;
	}
	if(secindex >= 0)
	{
		int willadd = amount;
		int secmax = plitem.iMaxAmmo2();
		int secammocount = nPlayer.m_rgAmmo(secindex);
		switch(ctype)
		{
			case 0:
			{
				if(amount == secammocount) return false;
				if(checkmax)
				{
					if(amount >= secmax)
					{
						if(secammocount < amount)
						{
							return false;
						}
					}
				}
				break;
			}
			case 1:
			{
				if(amount == 0) return false;
				if(checkmax)
				{
					if(secammocount >= secmax)
					{
						return false;
					}
					int afark = secmax - secammocount;
					if(amount > afark) amount = afark;
				}
				willadd = secammocount + amount;
				break;
			}
			case 2:
			{
				if(amount == 0 || secammocount == 0) return false;
				willadd = secammocount - amount;
				if(willadd < 0) willadd = 0;
				break;
			}
		}			
		nPlayer.m_rgAmmo(secindex, willadd);
		secondok = true;
	}
	if(firstok) return true;
	if(secondok) return true;
	return false;
}
int give_maxammo(CBasePlayer@ cPlayer, float percent, string eqname, array<string> exceptitems)
{
	int atotal = 0;
	array<CBasePlayerItem@> uitems = get_userweapons(@cPlayer);
	for(uint i = 0; i < uitems.length(); i++)
	{
		if(exceptitems.find(uitems[i].pev.classname) >= 0) continue;
		if(eqname != "" && uitems[i].pev.classname != eqname) continue;
		atotal += give_maxammo(@cPlayer, @uitems[i], percent);
	}
	return atotal;
}
int give_maxammo(CBasePlayer@ cPlayer, float percent, string eqname = "")
{
	return give_maxammo(@cPlayer, percent, eqname, {});
}
int give_maxammo(CBasePlayer@ nPlayer, CBasePlayerItem@ plitem, float percent)
{
	if(percent < 0.25) percent = 0.25;
	if(percent > 1) percent = 1;
	if(!nPlayer.IsAlive())
	{
		return 0;
	}
	int totala = 0;
	if(plitem is null) return 0;
	int prindex = plitem.PrimaryAmmoIndex();
	int secindex = plitem.SecondaryAmmoIndex();
	if(prindex < 0 && secindex < 0) return 0;
	bool firstok = false;
	bool secondok = false;
	if(prindex >= 0)
	{
		int prmax = plitem.iMaxAmmo1();
		int primaryammocount = nPlayer.m_rgAmmo(prindex);
		if(primaryammocount > 10000) primaryammocount = 500;
		int willadd = int(float(prmax) * percent);
		int afark = prmax - primaryammocount;
		if(afark > 0)
		{
			if(willadd > afark) willadd = afark;
			nPlayer.m_rgAmmo(prindex, primaryammocount + willadd);
			totala += willadd;
			firstok = true;
		}
	}
	if(secindex >= 0)
	{
		int secmax = plitem.iMaxAmmo2();
		int secammocount = nPlayer.m_rgAmmo(secindex);
		if(secammocount > 10000) secammocount = 500;
		int willadd = int(float(secmax) * percent);
		int afark = secmax - secammocount;
		if(afark > 0)
		{
			if(willadd > afark) willadd = afark;
			nPlayer.m_rgAmmo(secindex, secammocount + willadd);
			totala += willadd;
			secondok = true;
		}
	}
	if(firstok) return totala;
	if(secondok) return totala;
	return 0;
}
Vector get_user_aimendvector(CBasePlayer@ pPlayer, float distance = 9999, bool ishull = false)
{
	Vector v;
	if(pPlayer is null) return v;
	if (pPlayer.IsConnected())
	{
		edict_t@ N_edict = @pPlayer.edict();
		Vector v_forward;
		Vector v_src = N_edict.vars.origin + N_edict.vars.view_ofs;
		v_forward = angle_vector(N_edict.vars.v_angle, ANGLEVECTORS_FORWARD);		
		TraceResult trEnd;
		Vector v_dest = v_src + v_forward * distance;
		if(ishull)
		{
			g_Utility.TraceHull(v_src, v_dest, dont_ignore_monsters, head_hull, @N_edict, trEnd);
		}
		else
		{
			g_Utility.TraceLine(v_src, v_dest, dont_ignore_monsters, @N_edict, trEnd);
		}
		
		return trEnd.vecEndPos;
	} 
	return v;
}
const array<string> u_pBPTextures = 
{
	"c2a2_dr",	//Blast Door
	"c2a5_dr"	//Secure Access
};
CBaseEntity@ get_user_aiming_wall_single_all(CBasePlayer@ cPlayer, float flDistance = 9999)
{
	array<EntityTraceClass> entities;
	get_user_aiming_wall(cPlayer, entities, flDistance, false);
	if(entities.length() == 0)
	{
		get_user_aiming_wall(cPlayer, entities, flDistance, true);
	}
	if(entities.length() == 0)
	{
		return null;
	}
	return @entities[0].Entity;
}
CBaseEntity@ get_user_aiming_wall_single(CBasePlayer@ cPlayer, float flDistance = 9999, bool ishull = false)
{
	array<EntityTraceClass> entities;
	get_user_aiming_wall(cPlayer, entities, flDistance, ishull);
	if(entities.length() == 0) return null;
	return @entities[0].Entity;
}
Vector get_user_aiming_wall(CBaseEntity@ cPlayer, float flDistance = 9999, bool ishull = false)
{
	array<EntityTraceClass> entities;
	return get_user_aiming_wall(cPlayer, entities, flDistance, ishull);
}
Vector get_user_aiming_wall(CBaseEntity@ cPlayer, array<EntityTraceClass>& out entities, float flDistance = 9999, bool ishull = false)
{
	array<EntityTraceClass> non_entities;
	return get_user_aiming_wall(cPlayer, entities, non_entities, flDistance, ishull);
}
Vector get_user_aiming_wall(CBaseEntity@ cPlayer, array<EntityTraceClass>& out entities, array<EntityTraceClass>& out non_entities, float flDistance = 9999.0, bool ishull = false,  float flRangeModifier = 1.0,  int iPenetration = 10)
{
	if (cPlayer is null)
	{
		return g_vecZero;
	}
	int iOriginalPenetration = iPenetration;
	float iPenetrationPower = 45;
	float flPenetrationDistance = flDistance;
	float flCurrentDistance;

	TraceResult tr;
	Vector vecRight, vecUp;
	Vector vecSrc = cPlayer.pev.origin + cPlayer.pev.view_ofs;
	
	//bool bHitMetal = false;

	vecRight = g_Engine.v_right;
	vecUp = g_Engine.v_up;


	float x, y, z;

	if (cPlayer.IsPlayer())
	{
		// Use player's random seed.
		// get circular gaussian spread
		x = 0;
		y = 0;
		//x = g_PlayerFuncs.SharedRandomFloat(shared_rand, -0.5, 0.5) + g_PlayerFuncs.SharedRandomFloat(shared_rand + 1, -0.5, 0.5);
		//y = g_PlayerFuncs.SharedRandomFloat(shared_rand + 2, -0.5, 0.5) + g_PlayerFuncs.SharedRandomFloat(shared_rand + 3, -0.5, 0.5);
	}
	else
	{
		do
		{
			x = Math.RandomFloat(-0.5, 0.5) + Math.RandomFloat(-0.5, 0.5);
			y = Math.RandomFloat(-0.5, 0.5) + Math.RandomFloat(-0.5, 0.5);
			z = x * x + y * y;
		}
		while (z > 1);
	}
	//x = 0;
	//y = 0;

	Vector vecDir, vecDirF, vecEnd;
	vecDir = angle_vector(cPlayer.pev.v_angle, ANGLEVECTORS_FORWARD);		
	//vecDir = vecDirShooting + x * vecSpread * vecRight + y * vecSpread * vecUp;
	vecEnd = get_look_vector(cPlayer, vecDirF, flDistance);
	
	//vecEnd = vecSrc + vecDir * flDistance;
	Vector endPos;
	while (iPenetration != 0)
	{
		if(ishull)
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, cPlayer.pev.pContainingEntity, tr );
		}
		else
		{
			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, cPlayer.pev.pContainingEntity, tr );
		}
		char cTextureType = UTIL_TextureHit(tr, vecSrc, vecEnd);
		//bool bSparks = false;
		if(cTextureType == CHAR_TEX_METAL)
		{
			//bHitMetal = true;
			//bSparks = true;
			iPenetrationPower *= 0.15;
		}
		else if(cTextureType == CHAR_TEX_CONCRETE)
		{
			iPenetrationPower *= 0.25;
		}
		else if(cTextureType == CHAR_TEX_GRATE)
		{
			//bHitMetal = true;
			//bSparks = true;
			iPenetrationPower *= 0.5;
		}
		else if(cTextureType == CHAR_TEX_VENT)
		{
			//bHitMetal = true;
			//bSparks = true;
			iPenetrationPower *= 0.5;
		}
		else if(cTextureType == CHAR_TEX_TILE)
		{
			iPenetrationPower *= 0.65;
		}
		else if(cTextureType == CHAR_TEX_COMPUTER)
		{
			//bHitMetal = true;
			//bSparks = true;
			iPenetrationPower *= 0.4;
		}
		else if(cTextureType == CHAR_TEX_WOOD)
		{
			
		}
		if (tr.flFraction != 1.0f)
		{
			endPos = tr.vecEndPos;
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
			if(pEntity !is null)
			{
				if(pEntity.entindex() > 0)
				{
					entities.insertLast(EntityTraceClass(pEntity, tr.vecEndPos, tr));
				}
				else
				{
					non_entities.insertLast(EntityTraceClass(pEntity, tr.vecEndPos, tr));
				}
			}
			else
			{
				non_entities.insertLast(EntityTraceClass(null, tr.vecEndPos, tr));
			}
			iPenetration--;

			flCurrentDistance = tr.flFraction * flDistance;

			if (flCurrentDistance > flPenetrationDistance)
			{
				iPenetration = 0;
			}
			float flDistanceModifier;
			if (pEntity.pev.solid != SOLID_BSP || iPenetration <= 0)
			{
				iPenetrationPower = 42;
				flDistanceModifier = 0.75;
			}
			else
				flDistanceModifier = 0.5;
			vecSrc = tr.vecEndPos + (vecDir * iPenetrationPower);
			flDistance = (flDistance - flCurrentDistance) * flDistanceModifier;
			vecEnd = vecSrc + (vecDir * flDistance);

		}
		else
		{
			non_entities.insertLast(EntityTraceClass(null, tr.vecEndPos, tr));
			iPenetration = 0;
		}

	}
	return endPos;
	//return Vector(x * vecSpread, y * vecSpread, 0);
}
Vector get_look_vector(CBaseEntity@ cEntity, float fldistance = 9999)
{
	Vector v_src;
	return get_look_vector(cEntity, v_src, fldistance);
}
Vector get_look_vector(CBaseEntity@ cEntity, Vector& out v_src, float fldistance = 9999)
{
	v_src = cEntity.pev.origin + cEntity.pev.view_ofs;
	Vector v_forward = angle_vector(cEntity.pev.v_angle, ANGLEVECTORS_FORWARD);		
	Vector v_dest = v_src + v_forward * fldistance;
	return v_dest;
}
CBaseEntity@ get_user_aiming(CBasePlayer@ pPlayer, int& out body = 0, float distance = 9999, bool ishull = false)
{
	if(pPlayer is null) return null;
	if (pPlayer.IsConnected())
	{
		Vector v_forward;
		Vector v_src = pPlayer.pev.origin + pPlayer.pev.view_ofs;
		v_forward = angle_vector(pPlayer.pev.v_angle, ANGLEVECTORS_FORWARD);		
		TraceResult trEnd;
		Vector v_dest = v_src + v_forward * distance;
		if(ishull)
		{
			g_Utility.TraceHull(v_src, v_dest, dont_ignore_monsters, head_hull, @pPlayer.pev.pContainingEntity, trEnd);
		}
		else
		{
			g_Utility.TraceLine(v_src, v_dest, dont_ignore_monsters, @pPlayer.pev.pContainingEntity, trEnd);
		}
		body = trEnd.iHitgroup;
		return g_EntityFuncs.Instance(@trEnd.pHit);
	} 
	else 
	{
		body = 0;
	}
	return null;
}
CBaseEntity@ get_user_aiming_h(CBasePlayer@ pPlayer, int& in body = 0, float distance = 9999)
{
	return get_user_aiming(@pPlayer, body, distance, true);
}
array<CBasePlayer@> get_users_bot()
{
	array<CBasePlayer@> uSers;
	for( int id = 1; id <= 32; id++)
	{
		CBasePlayer@ cPlayer = get_player(id);
		if(cPlayer is null) continue;
		if(!is_user_bot(id)) continue;
		uSers.insertLast(@cPlayer);
	}
	return uSers;
}
array<CBasePlayer@> get_users(CBasePlayer@ sender = null, CBasePlayer@ except = null, int alivetype = -1, bool includenc = false, bool immrule = false, int uaccess = -10)
{
	array<CBasePlayer@> uSers;
	for( int id = 1; id <= 32; id++)
	{
		CBasePlayer@ cPlayer = get_player(id);
		if(cPlayer is null) continue;
		if(except !is null)
		{
			if(cPlayer == except) continue;
		}
		if(!cPlayer.IsConnected() && !includenc) continue;
		if(uaccess != -10)
		{
			if(!user_has_access(id, uaccess, true))
			{
				continue;
			}
		}
		if(immrule)
		{
			if(!user_can_accessplayer(@cPlayer, @sender))
			{
				continue;
			}
		}
		bool errored = false;
		switch(alivetype)
		{
			case 1: //Only ALive users
				if(!cPlayer.IsAlive())
				{
					errored = true;
				}
				break;
			case 2: //Only Death users
				if(cPlayer.IsAlive())
				{
					errored = true;
				}
				break;
		}
		if(errored) continue;
		uSers.insertLast(@cPlayer);
	}
	return uSers;
}
string get_keyvalue(CBasePlayer@ cPlayer, string key)
{
	if(cPlayer is null) return "";
	return get_keyvalue(cPlayer.edict(), key);
}
string get_keyvalue(edict_t@ cEdict, string key)
{
	if(cEdict is null) return "";
	KeyValueBuffer@ nPysc = g_EngineFuncs.GetPhysicsKeyBuffer(cEdict);
	if(nPysc is null) return "";
	return nPysc.GetValue(key);
}
void set_keyvalue(CBasePlayer@ cPlayer, string key, string value)
{
	if(cPlayer is null) return;
	set_keyvalue(cPlayer.edict(), key, value);
}
void set_keyvalue(edict_t@ cEdict, string key, string value)
{
	if(cEdict is null) return;
	KeyValueBuffer@ nPysc = g_EngineFuncs.GetPhysicsKeyBuffer(cEdict);
	if(nPysc is null) return;
	nPysc.SetValue(key, value);
}
string Format(string Key, array<string> nctest)
{
	string NewKey = Key;
	for(int i = 0; i < int(nctest.length()); i++)
	{
		NewKey = NewKey.Replace("{" + i + "}", nctest[i]);
	}
	return NewKey;
}
string Join(const array<string> &in arr, const string &in delimiter)
{
	string nstr = "";
	for(uint i = 0; i < arr.length(); i++)
	{
		nstr += delimiter + arr[i];
	}
	return nstr.SubString(delimiter.Length());
}
void set_user_rendering(CBasePlayer@ cPlayer, int rfx = kRenderFxNone, float r = 255, float g = 255, float b = 255, int rmode = kRenderNormal, float namt = 16)
{
	if(cPlayer is null) return;
	cPlayer.pev.renderfx = rfx;
	Vector rClr;
	rClr.x = r;
	rClr.y = g;
	rClr.z = b;
	cPlayer.pev.rendermode = rmode;
	cPlayer.pev.renderamt = namt;
	cPlayer.pev.rendercolor = rClr;
}
bool TimerActive(CScheduledFunction@ n_target)
{
	if(n_target is null) return false;
	if(n_target.HasBeenRemoved()) return false;
	return true;
}
bool RemoveTimer(CScheduledFunction@ n_target)
{
	if(n_target is null) return false;
	if(n_target.HasBeenRemoved()) return false;
	g_Scheduler.RemoveTimer( n_target );
	return true;
}
void setNoreloadAll(int vtype = 0, CBasePlayer@ nplayer = null) //-1 toggle, 0 false, 1 true, if only player
{
	if(nplayer !is null)
	{
		KeyValueBuffer@ nPysc = g_EngineFuncs.GetPhysicsKeyBuffer(nplayer.edict());
		if(nPysc is null) return;
		if(vtype == -1)
		{
			bool isenabled = (nPysc.GetValue("snrld") == "1");
			if(isenabled)
			{
				nPysc.SetValue("snrld", "0");
			}
			else
			{
				nPysc.SetValue("snrld", "1");
			}
		}
		if(vtype == 0)
		{
			nPysc.SetValue("snrld", "0");
		}
		if(vtype == 1)
		{
			nPysc.SetValue("snrld", "1");
		}
		return;
	}
	for (uint i = 1; i < 32; ++i) 
	{
		CBasePlayer@ cPlayer = get_player( i );
		if(cPlayer is null) continue;
		if(!cPlayer.IsConnected()) continue;
		KeyValueBuffer@ nPysc = g_EngineFuncs.GetPhysicsKeyBuffer(cPlayer.edict());
		if(nPysc is null) continue;
		if(vtype == -1)
		{
			bool isenabled = (nPysc.GetValue("snrld") == "1");
			if(isenabled)
			{
				nPysc.SetValue("snrld", "0");
			}
			else
			{
				nPysc.SetValue("snrld", "1");
			}
		}
		if(vtype == 0)
		{
			nPysc.SetValue("snrld", "0");
		}
		if(vtype == 1)
		{
			nPysc.SetValue("snrld", "1");
		}
    }
}
MapInfo get_mapinformation(string mapname)
{
	MapInfo mp;

	string config_loc = "scripts/plugins/Config/xp_maps_conf.txt";
	::File@ pFile = g_FileSystem.OpenFile(config_loc, OpenFile::READ);
	string currentmap = mapname.ToLowercase();
	mp.prev_mod = -1;
	if(pFile is null || !pFile.IsOpen())
	{
		mp.Loaded = true;  
		return mp;
	}
	string cline;
	int linetype = 0;
	bool mapfound = false;
	while(!pFile.EOFReached())
	{
		pFile.ReadLine(cline);
		cline.Trim();
		if(cline.IsEmpty()) continue;
		if(cline.StartsWith(";")) continue;
		array<string> Splitted;
		if(mapfound && cline.StartsWith("["))
		{
			break;
		}
		if(cline.StartsWith("[") && cline.EndsWith("]"))
		{
			cline.Trim('[');
			cline.Trim(']');
			Splitted = xp_string::ExplodeStringEx(1, -1, cline, " ");
			if(Splitted.length() < 2) continue;
			if(Splitted[0].ToLowercase() != "mapset")
			{

				continue;
			}
			Splitted = xp_string::ExplodeStringEx(-1, -1, Splitted[1], ",");
			if(Splitted.length() <= 0) continue;
			for(uint i = 0; i < Splitted.length(); i++)
			{
				string inext = Splitted[i].ToLowercase();
				inext.Trim();
				if(inext == "*")
				{
					mapfound = true;
					break;
				}
				if(inext.StartsWith("*") && inext.EndsWith("*"))
				{
					inext.Trim('*');
					if(currentmap.Find(inext) != String::INVALID_INDEX)
					{
						mapfound = true;
						break;
					}
				}
				else if(inext.StartsWith("*"))
				{
					inext.Trim('*');
					if(currentmap.EndsWith(inext))
					{
						mapfound = true;
						break;
					}
				}
				else if(inext.EndsWith("*"))
				{
					inext.Trim('*');
					if(currentmap.StartsWith(inext))
					{
						mapfound = true;
						break;
					}
				}
				else
				{
					if(currentmap == inext)
					{
						mapfound = true;
						break;
					}
				}
			}
			continue;
		}
		if(!mapfound) continue;
		Splitted = xp_string::ExplodeStringEx(-1, -1, cline, "=");
		if(Splitted.length() <= 1) continue;
		string conf_text = Splitted[0].ToLowercase();
		string conf_value = Splitted[1].ToLowercase();
		conf_text.Trim();
		conf_value.Trim();
		if(conf_text == "isfunny")
		{
			if(conf_value == "1")
			{
				g_EngineFuncs.CVarSetFloat( "mp_observer_mode", 1 );
				g_EngineFuncs.CVarSetFloat( "mp_observer_cyclic", 1 );
				mp.IsDeathmatch = true;
				mp.IsFunny = true;
			}
			else
			{
				mp.setTeamDefault = true;
			}
		}
		if(conf_text == "iszombie")
		{
			if(conf_value == "1")
			{
				g_EngineFuncs.CVarSetFloat( "mp_observer_mode", 1 );
				g_EngineFuncs.CVarSetFloat( "mp_observer_cyclic", 1 );
				mp.IsDeathmatch = true;
				mp.nodeathmatch = true;
				mp.IsZombie = true;
				mp.IsFunny = true;
				mp.unammo = true;
				mp.nobalancecontrol = true;
				mp.teamtwolimit = 2;
			}
		}
		if(conf_text == "nobalance")
		{
			if(conf_value == "1")
			{
				mp.nobalancecontrol = true;
			}
		}
		if(conf_text == "teamvsteamspawndefault")
		{
			if(conf_value == "1")
			{
				mp.teamvsteamspawnloc = true;
			}
		}
		if(conf_text == "teamonelimit")
		{
			if(isNumeric(conf_value))
			{
				mp.teamonelimit = atoi(conf_value);
			}
			
		}
		if(conf_text == "teamtwolimit")
		{
			if(isNumeric(conf_value))
			{
				mp.teamtwolimit = atoi(conf_value);
			}
		}
		if(conf_text == "nodeathmatch")
		{
			if(conf_value == "1")
			{
				mp.nodeathmatch = true;
			}
		}
		if(conf_text == "noteamvsteam")
		{
			if(conf_value == "1")
			{
				mp.noteamvsteam = true;
			}
		}
		if(conf_text == "noteamvsteamdm")
		{
			if(conf_value == "1")
			{
				mp.noteamvsteamdm = true;
			}
		}
		if(conf_text == "adddefspawnpoints")
		{
			if(conf_value == "1")
			{
				mp.adddefspawnpoints = true;
			}
		}
		if(conf_text == "customroundtime")
		{
			if(isNumeric(conf_value))
			{
				int timeof = 0;
				timeof = atoi(conf_value);
				mp.RoundTimeMax = clamp(timeof, 45, 1000);
				mp.RoundTime = mp.RoundTimeMax;
			}
		}		
		if(conf_text == "timeoffwindraw")
		{
			if(isNumeric(conf_value))
			{
				int timeofwin = 0;
				timeofwin = atoi(conf_value);
				mp.timeoffwintype = clamp(timeofwin, 0, 2);
			}
		}			
		if(conf_text == "unammo")
		{
			if(conf_value == "1")
			{
				mp.unammo = true;
			}
		}	
		if(conf_text == "hardmode")
		{
			if(isNumeric(conf_value))
			{
				mp.hardmode = atoi(conf_value);
			}
		}
		if(conf_text == "hardvalue")
		{
			if(isNumeric(conf_value))
			{
				mp.hardvalue = atof(conf_value);
			}
		}		
		if(conf_text == "lightoverride")
		{
			mp.lightoverride = conf_value;
		}			
		if(conf_text == "is_survival")
		{
			if(conf_value == "1")
			{
				mp.is_survival = true;
			}
		}
		mp.all_vars.set(conf_text, conf_value);
	}		
	pFile.Close();
	mp.Loaded = true;  
	return mp;
}
void serverMsg(CBasePlayer@ nPlayer, string cmd, string iprefix)
{
	string netname_n = nPlayer.pev.netname;
	string tcmd ="\n" + iprefix + netname_n + ": used admin command: " + cmd + "\n";
	g_EngineFuncs.ServerPrint(tcmd);    
}
void strip_user_weapons(CBasePlayer@ nPlayer)
{
	CBaseEntity@ stripEnt = g_EntityFuncs.CreateEntity("player_weaponstrip");
	stripEnt.Use(@nPlayer, @nPlayer, USE_TOGGLE);
	g_EntityFuncs.Remove(@stripEnt);
}
array<CBasePlayer@> get_target_player(CBasePlayer@ nPlayer, string key)
{
	array<CBasePlayer@> tUsers;
	//if(!user_has_access(@nPlayer, XP_ACC_RCON))
	//{
		//return tUsers;
	//}
	if(key == "#ALL") //includeme
	{
		tUsers = get_users(@nPlayer, null, -1, false, true);
	}
	if(key == "@ALL") //not includeme
	{
		tUsers = get_users(@nPlayer, @nPlayer, -1, false, true);
	}
	if(key == "#BOT") //get bots
	{
		tUsers = get_users_bot();
	}
	if(key == "@ME" || key == "#ME")
	{
		tUsers.insertLast(@nPlayer);
	}
	return tUsers;
}
bool is_access_or_text(CBasePlayer@ nPlayer, string key)
{
	//if(!user_has_access(@nPlayer, XP_ACC_RCON))
	//{
		//return false;
	//}
	if(key == "#ALL") return true;
	if(key == "@ALL") return true;
	if(key == "#BOT") return true;
	if(key == "#ME") return true;
	if(key == "@ME") return true;
	return false;
}
array<MapConf> get_mapconfvalue(array<MapConf> mcarr, string confvalue)
{
	array<MapConf> mp;
	for(uint i = 0; i < mcarr.length(); i++)
	{
		array<string> Splitted = xp_string::ExplodeStringEx(-1, -1, confvalue, " ");
		for(uint j = 0; j < Splitted.length(); j++)
		{
			if(mcarr[i].Name == Splitted[j])
			{
				mp.insertLast(mcarr[i]);
				break;
			}
		}

	}
	return mp;
}
MapConf get_mapconfvalue_s(array<MapConf> mcarr, string confvalue, int findex = 0)
{
	MapConf MC;
	int fndi = 0;
	for(uint i = 0; i < mcarr.length(); i++)
	{
		if(mcarr[i].Name == confvalue)
		{
			if(findex == fndi)
			{
				return mcarr[i];
			}
			fndi++;
		}

	}
	MC.isEmpty = true;
	return MC;
}
array<MapConf> get_mapconf(string mapname, string startswith = "", bool fullpath = false)
{
	array<MapConf> mp;
	string path = config_path;
	string config_loc = path + mapname + ".cfg";
	if(fullpath){
		path = "";
		config_loc =  path + mapname;
	}

	::File@ pFile = g_FileSystem.OpenFile(config_loc, OpenFile::READ);
	if(pFile is null || !pFile.IsOpen())
	{
		int ilen = int(mapname.Length());
		for(int i = ilen - 1; i > 0; i--)
		{
			config_loc = Format("{0}{1}+.cfg", {path, mapname.SubString(0, i)});
			@pFile = @g_FileSystem.OpenFile(config_loc, OpenFile::READ);
			if(pFile is null || !pFile.IsOpen()) continue;
			break;
		}

	}
	if(pFile is null) return mp;  
	if(!pFile.IsOpen()) return mp;
	string cline;
	while(!pFile.EOFReached())
	{
		pFile.ReadLine(cline);
		cline.Trim();
		if(cline.IsEmpty()) continue;
		if(cline.StartsWith("##")) continue;
		array<string> Splitted = xp_string::ExplodeStringEx(2, -1, cline, " ");
		if(Splitted.length() == 0) continue;
		MapConf mconf;
		if(startswith != "")
		{
			if(!Splitted[0].StartsWith(startswith)) continue;
		}
		mconf.Name = Splitted[0];
		if(Splitted.length() > 1)
		{
			mconf.Value = Splitted[1];
		}
		mp.insertLast(mconf);
	}		
	pFile.Close();
	return mp;
}
Vector get_look_angles(Vector startOrigin, Vector vOfs, Vector origin2)
{
	Vector origin;
	origin = origin2;
	Vector fOfs = vOfs;
	Vector ent_origin = startOrigin + fOfs;
	origin.x -= ent_origin.x;
	origin.y -= ent_origin.y;
	origin.z -= ent_origin.z;
	float v_length = origin.Length();
	Vector aim_vector;
	aim_vector.x = origin.x / v_length;
	aim_vector.y = origin.y / v_length;
	aim_vector.z = origin.z / v_length;
	Vector new_angles;
	g_EngineFuncs.VecToAngles(aim_vector, new_angles);
	new_angles.x *= -1;
	if(new_angles.y >180.0) new_angles.y -= 360;
	if(new_angles.y <-180.0) new_angles.y += 360;
	if(new_angles.y ==180.0 || new_angles.y ==-180.0) new_angles.y = -179.999999;
	return new_angles;
}
Vector get_look_angles(CBaseEntity@ cEnt, Vector origin2)
{
	return get_look_angles(cEnt.pev.origin, cEnt.pev.view_ofs, origin2);
}
void entity_set_aim(CBasePlayer@ cPly, Vector origin)
{
	CBaseEntity@ cEnt = cast<CBaseEntity@>(@cPly);
	entity_set_aim(@cEnt, origin);
}
void entity_set_aim(CBaseEntity@ cEnt, Vector origin2)
{
	cEnt.pev.angles = get_look_angles(cEnt, origin2);
	cEnt.pev.fixangle = 1;
}
bool is_wallpoints(Vector start, Vector ent, edict_t@ ignore_ent)
{
	TraceResult ptr;
	g_Utility.TraceLine(start, ent, dont_ignore_monsters, @ignore_ent, ptr);
	return (1.0 - ptr.flFraction > 0.04);
}
string d_value(dictionary d, string key, string defkey = "")
{
	string returnval;
	if(!d.exists(key))
	{
		return defkey;
	}
	d.get(key, returnval);
	return returnval;
}
int d_valuei(dictionary d, string key, int defkey = 0)
{
	string returnval;
	if(!d.exists(key))
	{
		return defkey;
	}
	d.get(key, returnval);
	if(isNumeric(returnval))
	{
		return atoi(returnval);
	}
	return defkey;
}
float d_valuef(dictionary d, string key, float defkey = 1)
{
	string returnval;
	if(!d.exists(key))
	{
		return defkey;
	}
	d.get(key, returnval);
	if(isNumeric(returnval))
	{
		return atof(returnval);
	}
	return defkey;
}
void session_delete(CBasePlayer@ cPlayer)
{
	int iindex = cPlayer.entindex();
	nUserSessions[iindex] = "";
	//SetInfoValue(@cPlayer, "xp_session", "");
}
void session_create(CBasePlayer@ cPlayer)
{
	int iindex = cPlayer.entindex();
	nUserSessions[iindex] = session_generate(@cPlayer);
	//SetInfoValue(@cPlayer, "xp_session", nUserSessions[iindex]);
}
bool session_check(CBasePlayer@ cPlayer)
{
	int iindex = cPlayer.entindex();
	string userkey = nUserSessions[iindex];
	//string usersession = GetInfoValue(@cPlayer, "xp_session");
	string usersession = string(iindex) + "_" + g_EngineFuncs.GetPlayerAuthId(cPlayer.edict());
	if(userkey == usersession) return true;
	return false;
}
string session_generate(CBasePlayer@ cPlayer)
{
	string sessionkeyf = "{0}-{1}_{2}";
	string rkey = "";
	for(int i = 0; i < 5; i++)
	{
		rkey += string(Math.RandomLong(0, 9));
	}
	//sessionkeyf = Format(sessionkeyf, {cPlayer.entindex(), rkey, int(g_Engine.time)});
	sessionkeyf = string(cPlayer.entindex()) + "_" + g_EngineFuncs.GetPlayerAuthId(cPlayer.edict());
	return sessionkeyf;
}
CBasePlayer@ get_player(int index)
{
	if(index < 1 || index > 32) return null;
	CBaseEntity@ cEnt = g_EntityFuncs.Instance(index);
	if(cEnt is null) return null;
	CBasePlayer@ Cpl = cast<CBasePlayer@>(@cEnt);
	return Cpl;
}
CBasePlayer@ get_player_ip(string ip)
{
	if(ip != "")
	{
		array<string> minfo_ipaddr = xp_string::ExplodeStringEx(1, -1, ip, ":");
		ip =  minfo_ipaddr[0];
	}
 	for(uint i = 1; i < 33; i++)
	{
		CBasePlayer@ tPlayer = get_player(i);
		if(tPlayer is null) continue;
		string ipadr = get_keyvalue(@tPlayer, "ip");
		if(ipadr != "")
		{
			array<string> minfo_ipaddr = xp_string::ExplodeStringEx(1, -1, ipadr, ":");
			ipadr = minfo_ipaddr[0];
		}
		if(ip == ipadr)
		{
			return @tPlayer;
		}
	}
	return null;
}
CBasePlayer@ get_player_editc(edict_t@ mEdict)
{
	if(mEdict is null) return null;	
	if(!g_EntityFuncs.IsValidEntity(@mEdict)) return null;
	int eindex = g_EntityFuncs.EntIndex(@mEdict);
	return get_player(eindex);
}
CBasePlayer@ get_player_auth(string auth)
{
 	for(uint i = 1; i < 33; i++)
	{
		CBasePlayer@ tPlayer = get_player(i);
		if(tPlayer is null) continue;
		if( g_EngineFuncs.GetPlayerAuthId(tPlayer.edict()) == auth) return @tPlayer;
	}
	return null;
}
DateTime str_to_datetime(string instr)
{
	DateTime t;
	if(instr == "") return t;
	t.SetHour(0);
	t.SetMinutes(0);
	t.SetSeconds(0);
	t.SetYear(1990);
	t.SetMonth(1);
	t.SetDayOfMonth(1);
	array<string> SplittedStr = xp_string::ExplodeStringEx(-1, -1, instr, " ");
	if(SplittedStr.length() == 0) return t;
	array<string> SplittedStr2 = xp_string::ExplodeStringEx(-1, -1, SplittedStr[0], ".");
	if(SplittedStr2.length() != 3) return t;
	for(uint i = 0; i < SplittedStr2.length(); i++)
	{
		if(!isNumeric(SplittedStr2[i])) return t;
	}
	t.SetYear(atoi(SplittedStr2[2]));
	t.SetMonth(atoi(SplittedStr2[1]));
	t.SetDayOfMonth(atoi(SplittedStr2[0]));
	if(SplittedStr.length() == 1) return t;
	SplittedStr2 = xp_string::ExplodeStringEx(-1, -1, SplittedStr[1], ":");
	if(SplittedStr2.length() < 2) return t;
	for(uint i = 0; i < SplittedStr2.length(); i++)
	{
		if(!isNumeric(SplittedStr2[i])) return t;
	}
	t.SetHour(atoi(SplittedStr2[0]));
	t.SetMinutes(atoi(SplittedStr2[1]));
	if(SplittedStr2.length() > 2) t.SetSeconds(atoi(SplittedStr2[2]));
	return t;
}
string date_to_trformat(DateTime dt, bool showtime=false)
{
	string ntext = "";
	if(dt.GetDayOfMonth() < 10)
	{
		ntext += "0";
	}
	ntext += dt.GetDayOfMonth();
	ntext += ".";
	if(dt.GetMonth() < 10)
	{
		ntext += "0";
	}
	ntext += dt.GetMonth();
	ntext += ".";
	ntext += dt.GetYear();
	if(!showtime) return ntext;
	ntext += " ";
	if(dt.GetHour() < 10)
	{
		ntext += "0";
	}	
	ntext += dt.GetHour();
	ntext += ":";
	if(dt.GetMinutes() < 10)
	{
		ntext += "0";
	}	
	ntext +=  dt.GetMinutes();
	ntext += ":";
	if(dt.GetSeconds() < 10)
	{
		ntext += "0";
	}	
	ntext += dt.GetSeconds();
	return ntext;
}
string ReplaceOtherVar(string instr)
{
	string newstr = instr;
	newstr = newstr.Replace("*", "");
	newstr = newstr.Replace(".", "");
	newstr = newstr.Replace("-", "");
	newstr = newstr.Replace("+", "");
	newstr = newstr.Replace(":", "");
	newstr = newstr.Replace(";", "");
	newstr = newstr.Replace("/", "");
	newstr = newstr.Replace("@", "");
	newstr = newstr.Replace("$", "");
	newstr = newstr.Replace("#", "");
	newstr = newstr.Replace("_", "");
	newstr = newstr.Replace("{", "");
	newstr = newstr.Replace("}", "");
	newstr = newstr.Replace("[", "");
	newstr = newstr.Replace("]", "");
	newstr = newstr.Replace("!", "");
	newstr = newstr.Replace("%", "");
	newstr = newstr.Replace("\\", "");
	newstr = newstr.Replace("?", "");
	newstr = newstr.Replace("&", "");
	newstr = newstr.Replace("'", "");
	newstr = newstr.Replace("^", "");
	for(int i = 0; i <= 9; i++)
	{
		newstr = newstr.Replace(i, "");
	}
	return newstr;
}
string ToEnChars(string newstr)
{
	newstr = newstr.Replace("Ç", "C");
	newstr = newstr.Replace("Ğ", "P");
	newstr = newstr.Replace("İ", "I");
	newstr = newstr.Replace("Ö", "O");
	newstr = newstr.Replace("Ş", "S");
	newstr = newstr.Replace("Ü", "U");
	newstr = newstr.Replace("ç", "c");
	newstr = newstr.Replace("ğ", "g");
	newstr = newstr.Replace("ı", "i");
	newstr = newstr.Replace("ö", "o");
	newstr = newstr.Replace("ü", "u");
	newstr = newstr.Replace("ş", "s");
	return newstr;
}
string ToTrChars(string newstr)
{
	newstr = newstr.Replace("c", "ç");
	newstr = newstr.Replace("g", "ğ");
	newstr = newstr.Replace("i", "ı");
	newstr = newstr.Replace("s", "ş");
	newstr = newstr.Replace("o", "ö");
	newstr = newstr.Replace("u", "ü");
	return newstr;
}
string LowerCaseEN(string instr)
{
	string newstr = instr;
	newstr = newstr.Replace("Ç", "c");
	newstr = newstr.Replace("Ğ", "g");
	newstr = newstr.Replace("I", "i");
	newstr = newstr.Replace("İ", "i");
	newstr = newstr.Replace("Ö", "o");
	newstr = newstr.Replace("Ş", "s");
	newstr = newstr.Replace("ü", "u");
	newstr = newstr.Replace("ç", "c");
	newstr = newstr.Replace("ğ", "g");
	newstr = newstr.Replace("ı", "i");
	newstr = newstr.Replace("i", "i");
	newstr = newstr.Replace("ö", "o");
	newstr = newstr.Replace("ü", "u");
	newstr = newstr.Replace("ş", "s");
	return newstr.ToLowercase();
}
string LowerCaseTR(string instr, bool istrchar = false)
{
	string newstr = instr;
	newstr = newstr.Replace("Ç", "ç");
	newstr = newstr.Replace("Ğ", "ğ");
	newstr = newstr.Replace("I", "ı");
	newstr = newstr.Replace("İ", "i");
	newstr = newstr.Replace("Ö", "ö");
	newstr = newstr.Replace("ü", "ü");
	newstr = newstr.Replace("Ş", "ş");
	if(!istrchar)
	{	
		return newstr.ToLowercase();
	}
	newstr = newstr.ToLowercase();
	newstr = ToTrChars(newstr);
	return newstr;
}
string UpperCaseTR(string instr)
{
	string newstr = instr;
	newstr = newstr.Replace("ç", "Ç");
	newstr = newstr.Replace("ğ", "Ğ");
	newstr = newstr.Replace("ı", "I");
	newstr = newstr.Replace("i", "İ");
	newstr = newstr.Replace("ö", "Ö");
	newstr = newstr.Replace("ü", "Ü");
	newstr = newstr.Replace("ş", "Ş");
	return newstr.ToUppercase();
}
ApiInfo api_sendcommand(string target, string key, array<string> Strings)
{
	return api_sendcommand(target, key, merge_ArrayforApi(Strings));
}
ApiInfo api_sendcommand(string target, string key, array<dictionary> dicts)
{
	array<string> ntext;
	for(uint i = 0; i < dicts.length(); i++)
	{
		ntext.insertLast(xp_string::DictionaryToStr(dicts[i], false));
	}
	return api_sendcommand(target, key, ntext);
}
ApiInfo api_sendcommand(string target, string key, dictionary dict)
{
	string strdata = xp_string::DictionaryToStr(dict, false);
	return api_sendcommand(target, key, strdata);
}
ApiInfo api_sendcommand(string target, string key, string value)
{
	ApiInfo AInf;
	array<CBaseEntity@> ents = get_entity_byclassname(target);
	if(ents.length() == 0) return AInf;
	if(ents[0].KeyValue(key, value))
	{
		AInf.Success = true;
	}
	if(ents[0].pev.targetname == "")
	{
		AInf.Response = "";
		AInf.Responses.insertLast("");
	}
	else
	{
		AInf.Responses = split_ArrayforApi(ents[0].pev.targetname);
		AInf.Response = AInf.Responses[0];
	}
	ents[0].pev.targetname = "";
	return AInf;
}
array<string> split_ArrayforApi(string Allstring)
{
	string splitkey = "<-!xXxCNothingFFF_FF_cCxXx!->";
	array<string> ArrStr = Allstring.Split(splitkey);
	return ArrStr;
}
string merge_ArrayforApi(array<string> Strings)
{
	string totaltext = "";
	string splitkey = "<-!xXxCNothingFFF_FF_cCxXx!->";
	if(Strings.length() == 0) return "";
	if(Strings.length() == 1) return Strings[0];
	for(uint i = 0; i < Strings.length(); i++)
	{
		if(i == 0)
		{
			totaltext = Strings[i];
		}
		else
		{
			totaltext += splitkey + Strings[i];
		}
	}
	return totaltext;
}

void uv_setvalue(CBasePlayer@ cPlayer, string statname, string statvalue, string stattype = "set", bool addtodb = false)
{
	dictionary ndict;
	string steamid = g_EngineFuncs.GetPlayerAuthId(cPlayer.edict());
	ndict.set("steamid", steamid);
	ndict.set("userid", string(cPlayer.entindex()));
	ndict.set("keyname", statname);
	ndict.set("keyvalue", statvalue);
	ndict.set("settype", stattype);
	if(addtodb)
	{
		ndict.set("addtodb", "1");
	}
	api_sendcommand("item_userstats", "setvalue", ndict);
}
string uv_getvalue(CBasePlayer@ cPlayer, string statname)
{
	string steamid = g_EngineFuncs.GetPlayerAuthId(cPlayer.edict());
	dictionary ndict;
	ndict.set("steamid", steamid);
	ndict.set("keyname", statname);
	ApiInfo Ainfo;
	Ainfo = api_sendcommand("item_userstats", "getvalue", ndict);
	return Ainfo.Response;
}
void client_cmd(CBasePlayer@ cPlayer, string Cmd)
{
	client_cmd(cPlayer.edict(), Cmd);
}
void client_cmd(edict_t@ peditct, string Cmd)
{
	NetworkMessage m(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_STUFFTEXT, peditct);
		m.WriteString( Cmd );
	m.End();
}
void client_cmd(int id, string Cmd)
{
	client_cmd(get_player(id), Cmd);
}
CBaseEntity@ play_ambientmusic(string fileloc, float volume)
{
	CBaseEntity@ mTEnt = g_EntityFuncs.CreateEntity("ambient_music", null, false);
	if(mTEnt is null) return null;
	edict_t@ edict_mTEnt = @mTEnt.edict();
	g_EntityFuncs.DispatchKeyValue(@edict_mTEnt, "message", fileloc);
	g_EntityFuncs.DispatchKeyValue(@edict_mTEnt, "volume", volume);
	edict_mTEnt.vars.flags = 0;
	edict_mTEnt.vars.spawnflags = 0;
	g_EntityFuncs.DispatchSpawn(@edict_mTEnt);
	return @mTEnt;
}
void stop_ambientmusic(CBaseEntity@  Cent)
{
	g_EntityFuncs.Remove(@Cent);
}
bool user_can_accessplayer(CBasePlayer@ TargetUser, CBasePlayer@ SourceUser)
{
	if(TargetUser is null) return true;
	bool isimm = user_has_access(@TargetUser, XP_ACC_IMM);
	if(!isimm) return true;
	if(SourceUser is null) return false;
	if(TargetUser == SourceUser) return true;
	int sourcerank = user_superadmin_level(SourceUser);
	int targetrank = user_superadmin_level(TargetUser);
	if(sourcerank > targetrank)
	{
		return true;
	}
	else
	{
		if(sourcerank >= 3 && sourcerank == targetrank)
		{
			return true;
		}
	}
	return false;
}
bool is_user_bot(int iindex)
{
	return is_user_bot(get_player(iindex));
}
bool is_user_bot(CBasePlayer@ CPlayer)
{
	if(CPlayer is null) return false;
	if(!CPlayer.IsConnected()) return false;
	if(CPlayer.pev.flags & FL_FAKECLIENT != 0) return true;
	return false;
}
void menu_destroy(CTextMenu@ nMenu)
{
	if (@nMenu !is null)
	{
		if(nMenu.IsRegistered())
		{
			nMenu.Unregister();
		}
		@nMenu = null;
	}
}
CTextMenu@ getLastMenu(CBasePlayer@ cPlayer)
{	
	int uid = cPlayer.entindex();
	return @nLastMenu[uid];
}
TextMenuId_t getLastMenuId(CBasePlayer@ cPlayer)
{	
	CTextMenu@ menu = getLastMenu(cPlayer);
	if(menu is null) return -1;
	return menu.get_Id();
}
float getLastMenuTime(CBasePlayer@ cPlayer)
{
	int uid = cPlayer.entindex();
	return nLastMenuTime[uid];
}
CTextMenu@ getMHandle(CBasePlayer@ cPlayer, TextMenuPlayerSlotCallback@ inputCB)
{
	int uid = cPlayer.entindex();
	int cnum = nMenuN[uid];
	CTextMenu@ nMenu = null;
	if(cnum == 0)
	{
		@nMenuA[uid] = CTextMenu(@inputCB);
		nMenuN[uid] = 1;
		@nMenu = @nMenuA[uid];
	}
	else if(cnum == 1)
	{
		@nMenuB[uid] = CTextMenu(@inputCB);
		nMenuN[uid] = 2;
		@nMenu = @nMenuB[uid];
	}
	else
	{
		@nMenuC[uid] = CTextMenu(@inputCB);
		nMenuN[uid] = 0;
		@nMenu = @nMenuC[uid];
	}
	@nLastMenu[uid] = nMenu;
	nLastMenuTime[uid] = g_Engine.time;
	//int itotal = atoi(get_keyvalue(cPlayer, "tmcll")) + 1;
	//set_keyvalue(cPlayer, itotal);
	return nMenu;
}
array<EHandle> FindClosestEnemys(CBaseEntity@ cEntity, bool ivisble = false, float Distance = 9999, bool allowally = false, bool allowplayer = true, bool allowmonster = true )
{
	array<EHandle> AllEnts;
	if(cEntity is null) return AllEnts;
	CBaseEntity@ ent = null;
	float iNearest = Distance;
	CBaseEntity@ cEntOwner = null;
	if(cEntity.pev.owner !is null)
	{
		@cEntOwner = g_EntityFuncs.Instance(cEntity.pev.owner);
	}
	do
	{
		@ent = g_EntityFuncs.FindEntityInSphere( ent, cEntity.pev.origin, Distance, "*", "classname" ); 
		if ( ent is null || !ent.IsAlive() )
			continue;
		string clsname = ent.pev.classname;
		if ( !clsname.StartsWith ("monster") && !clsname.StartsWith ("player"))
		{
			continue;
		}
		if(cEntOwner !is null)
		{
			if(ent.entindex() == cEntOwner.entindex()) 
			{
				continue;
			}
			if(cEntOwner.pev.classname == "player" && ent.pev.classname == "player")
			{
				if(cEntOwner.m_iClassSelection == ent.m_iClassSelection)
				{
					 continue;
				}
			}

		}
		if ( ent.entindex() == cEntity.entindex() ) continue;
		if(clsname == "player" && allowplayer)
		{
			CBasePlayer@ hEnt = cast<CBasePlayer@>(@ent);
			if(cEntity.m_iClassSelection == hEnt.m_iClassSelection && !allowally)
			{
				continue;
			}
		}
		else if(clsname.StartsWith("monster") && allowmonster)
		{
			if(clsname == "monster_furniture") continue;
			if(clsname == "monster_generic") continue;
			CBaseMonster@ hEnt = cast<CBaseMonster@>(@ent);
			if(hEnt.m_fOverrideClass)
			{
				if(hEnt.m_iClassSelection == cEntity.m_iClassSelection && !allowally)
				{
					continue;
				}
				if(hEnt.m_iClassSelection == CLASS_PLAYER || hEnt.m_iClassSelection == CLASS_PLAYER_ALLY)
				{
					if(!allowally)
					{
						continue;
					}
				}
			}
			else
			{
				if(hEnt.IsPlayerAlly() && !allowally) //&& hEnt.m_iClassSelection == cEntity.m_iClassSelection)
				{
					continue;
				}
			}

		}
		else
		{
			continue;
		}
		float iDist = ( ent.pev.origin - cEntity.pev.origin ).Length();
		if(iDist > iNearest) continue;
		Vector ent_origin = ent.pev.origin;
		Vector fOfs = ent.pev.view_ofs;
		ent_origin.x += fOfs.x;
		ent_origin.y += fOfs.y;
		ent_origin.z += fOfs.z;
		Vector iOrigin = cEntity.EyePosition();
		if(ivisble)
		{
			if(!cEntity.FVisible(ent, true)) continue;
		}
		else
		{
			if(is_wallpoints(ent_origin, iOrigin, @ent.edict()))
			{
				continue;
			}
		}
		AllEnts.insertLast(ent);
	}
	while ( ent !is null );
	return AllEnts;	
	
	
}

bool pev_valid(int index)
{
	if(index == 0) return false;
	CBaseEntity@ cEntity = g_EntityFuncs.Instance(index);
	return pev_valid(@cEntity);
}
bool pev_valid(CBaseEntity@ cEntity)
{
	if(cEntity is null) return false;
	if(!g_EntityFuncs.IsValidEntity(cEntity.edict())) return false;
	if(cEntity.entindex() == 0) return false;
	return true;
}
CBaseEntity@ get_ent(EHandle entityHandle)
{
	if(!entityHandle) return null;
	return entityHandle.GetEntity();
}
CBaseEntity@ get_ent(int eindex)
{
	if(eindex <= 0) return null;
	return g_EntityFuncs.Instance(eindex);
}
bool IsPlayerHereEx(CBasePlayer@ player, Vector sVector, float radius)
{
	CBaseEntity@ cEnt = null;
	@cEnt = @g_EntityFuncs.FindEntityInSphere(@cEnt, sVector, radius, "*", "classname");
	if(cEnt !is null)
	{
		if(cEnt.entindex() == player.entindex())
		{
			return true;
		}
	}
	while(cEnt !is null)
	{
		@cEnt = @g_EntityFuncs.FindEntityInSphere(@cEnt, sVector, radius, "*", "classname");
		if(cEnt !is null)
		{
			if(cEnt.entindex() == player.entindex())
			{
				return true;
			}
		}
	}
	return false;
}
int GenerateNumber(int minlen = 4, int maxlen = 4)
{
	if(maxlen <= 0) return 0;
	if(minlen < 1) minlen = 1;
	if(minlen > maxlen) minlen = maxlen;
	int mlen = maxlen;
	if(minlen != maxlen)
	{
		mlen = Math.RandomLong(minlen, maxlen);
	}
	string generated = "";
	for(int i = 0; i < mlen; i++)
	{
		if(i == 0)
		{		
			generated += string(Math.RandomLong(1, 9));
		}
		else
		{	
			generated += string(Math.RandomLong(0, 9));
		}
	}
	return atoi(generated);
}
bool LastMenuMatch(CBasePlayer@ cPlayer, int menuidright, float maxtime = 0)
{
	int menuidleft = getLastMenuId(cPlayer);
	if(menuidleft == -1 || menuidright == -1) return false;
	if(menuidleft == menuidright)
	{
		if(maxtime <= 0)
		{
			return true;
		}
		else
		{
			if((g_Engine.time - getLastMenuTime(cPlayer)) < maxtime)
			{
				return true;
			}
		}
	}
	return false;
}
//For rcbot
Vector GetOrigin ( CBaseEntity@ entity )
{
	return entity.Center();
	//return (entity.pev.absmin + entity.pev.absmax) / 2;
}
Vector velocity_by_aim( CBaseEntity@ entity, float velocity)
{
    //Math.MakeVectors(entity.pev.v_angle);
	g_EngineFuncs.MakeVectors(entity.pev.v_angle);
    return g_Engine.v_forward * velocity;
}
void set_Velocity(CBasePlayer@ cPlayer, CBaseEntity@ cEntity, float distance, float speed)
{
	Vector vecOrigin = cPlayer.GetGunPosition();
	Vector eOrigin = cEntity.Center();
	Vector fVel = velocity_by_aim(@cPlayer, distance);
	Vector aOrigin;
	aOrigin = ((vecOrigin + fVel) - eOrigin) * speed;
	cEntity.pev.velocity = aOrigin;
}
int StringToTime(string timestr)
{
	int mul = 1;
	int oneday = 86400;
	string newstr = timestr.ToLowercase();
	if(newstr.EndsWith("w"))
	{
		mul = oneday * 7;
	}
	else if(newstr.EndsWith("d"))
	{
		mul = oneday;
	}
	else if(newstr.EndsWith("h"))
	{
		mul = 60 * 60;
	}
	else if(newstr.EndsWith("m"))
	{
		mul = 60 * 60;
	}
	else if(newstr.EndsWith("s"))
	{
		newstr = newstr.SubString(0, newstr.Length() - 1);
	}
	if(mul != 1)
	{
		newstr = newstr.SubString(0, newstr.Length() - 1);
	}
	int val = atoi(newstr);
	return val * mul;
}
bool Array_Find(string item, array<string> list)
{
	string nitem = item;
	nitem = nitem.ToLowercase();
	for(uint i = 0; i < list.length(); i++)
	{
		string cur = list[i].ToLowercase();
		if(cur.EndsWith("*") && cur.StartsWith("*"))
		{
			cur = cur.SubString(1, cur.Length() - 2);
			if(nitem.Find(cur) != String::INVALID_INDEX)
			{
				return true;
			}
		}
		else if(cur.StartsWith("*"))
		{
			cur = cur.SubString(1);
			if(nitem.EndsWith(cur))
			{
				return true;
			}
		}
		else if(cur.EndsWith("*"))
		{
			cur = cur.SubString(0, cur.Length() - 1);
			if(nitem.StartsWith(cur))
			{
				return true;
			}
		}
		else
		{
			if(nitem == cur)
			{
				return true;
			}
		}
	}
	return false;
}