namespace XP_Phrases
{
	class PhraseItem
	{
		private string n_Name;
		private string n_LangName;
		private string n_LangText;
		string Name
		{
			get const 
			{
				 return n_Name; 
			}
			set 
			{
				 n_Name = value; 
			}
		}
		string LangName
		{
			get const 
			{
				 return n_LangName; 
			}
			set 
			{
				 n_LangName = value; 
			}
		}
		string LangText
		{
			get const 
			{
				 return n_LangText; 
			}
			set 
			{
				 n_LangText = value; 
			}
		}
	}
	class PhraseList
	{
		private dictionary n_phraselist;
		int GetIndexByName(array<PhraseItem@> n_phrases, string Lang, string Key, string dLang = "")
		{
			PhraseItem@ nitem = null;
			int dindex = -1;
			for( uint i = 0; i < n_phrases.length(); i++ ) 
			{
				@nitem = n_phrases[i];
				if(nitem.Name == Key)
				{
					if(nitem.LangName == Lang)
					{
						return i;
					}
					else
					{
						if(nitem.LangName == dLang && dLang.Length() > 0)
						{
							dindex = i;
						}
					}
				}
			}
			return dindex;	
		}
		int AddItem(string name, string lang, string ntext)
		{
			PhraseItem@ nItem;
			name.Trim();
			lang.Trim();
			ntext.Trim();
			@nItem = PhraseItem();
			nItem.Name = name;
			nItem.LangName = lang;
			nItem.LangText = ntext;
			return AddItem(nItem);
		}
		int AddItem(PhraseItem@ nitem)
		{
			if(nitem is null) return -1;
			if(nitem.Name == "") return -1;
			if(nitem.LangText == "") return -1;
			if(nitem.LangName == "") return -1;
			//array<PhraseItem@> n_phrases;
			dictionary n_phrases;
			if(n_phraselist.exists(nitem.Name))
			{
				n_phraselist.get(nitem.Name, n_phrases);
			}
			n_phrases.set(nitem.LangName, nitem);
			//n_phrases.insertLast(nitem);
			n_phraselist.set(nitem.Name, n_phrases);
			return 1;
		}
		void Clear()
		{
			n_phraselist.deleteAll();
		}
		PhraseItem@ GetItem(string Lang, string n_Key, string n_Def = "")
		{
			if(!n_phraselist.exists(n_Key))
			{
				return null;
			}
			dictionary n_phrases;
			n_phraselist.get(n_Key, n_phrases);
			PhraseItem@ ptarget = null;
			if(n_phrases.exists(Lang) && Lang != "")
			{
				n_phrases.get(Lang, @ptarget);
			}						
			if(ptarget !is null) return ptarget;
			PhraseItem@ pdefault = null;
			if(n_phrases.exists(n_Def) && n_Def != "")
			{
				n_phrases.get(n_Def, @pdefault);
			}
			//int index = GetIndexByName(n_phrases ,Lang, n_Key, n_Def);
			//if(index < 0) return null;
			//return n_phrases[index];
			return @pdefault;
		}
	}
	class PhraseClass
	{
		string default_lang = "EN";
		string lang_loc = "scripts/plugins/Lang/";
		PhraseList@ nPhrases;
		PhraseClass()
		{
			@nPhrases = PhraseList(); 
		}
		void register_language(string name)
		{
			register_language_direct(lang_loc + name);
		}
		void register_language_direct(string name)
		{
			g_EngineFuncs.ServerPrint("Added language file: " + name + "\n" );  
			::File@ nFile = g_FileSystem.OpenFile(name, OpenFile::READ);
			register_language(nFile);
		}
		void register_language(::File@ pFile)
		{
			if(pFile is null || !pFile.IsOpen()) return;  

			string cline;
			string langkey;
			int totaladded = 0;
			while(!pFile.EOFReached())
			{
				pFile.ReadLine(cline);
				cline.Trim();
				if(cline.IsEmpty() || cline.StartsWith(";")) continue;
					  
				if(cline.StartsWith("[") && cline.EndsWith("]"))
				{
					cline = cline.SubString(1, cline.Length() - 2);
					langkey = cline;
					langkey.Trim();
					continue;
				}

				if(langkey.IsEmpty()) continue;
							
				uint eqindex = cline.Find("=");
				if(eqindex == String::INVALID_INDEX || eqindex == 0) continue;
				string name = cline.SubString(0, eqindex);
				name.Trim();
				string value = cline.SubString(eqindex + 1);
				value.Trim();
				value = value.Replace("^n", "\n");
				value = value.Replace("^r", "\r");
				value = value.Replace("^t", "\t");
					
				if(nPhrases.AddItem(name, langkey, value) >= 0)
				{
					totaladded++;
				}
			}			
			pFile.Close();
		}
		string phrase(string name, string lang)
		{
			array<string> ntest;
			return phrase(name, lang, ntest);
		}
		string phrase(string name, string lang, array<string> nctest)
		{
			PhraseItem@ pitem = @nPhrases.GetItem(lang, name, default_lang);
			if(pitem is null) return name;//"ML_NF: " + name;
			string ltext = pitem.LangText;
			for(int i = 0; i < int(nctest.length()); i++)
			{
				ltext = ltext.Replace("{" + i + "}", nctest[i]);
			}
			return ltext;
		}
		string phrase(CBasePlayer@ pPlayer, string name)
		{
			if(pPlayer is null) return name;
			string langtx = GetInfoValueA(@pPlayer, "lang").ToUppercase();

			return phrase(name, langtx);
		}
		string phrase(CBasePlayer@ pPlayer, string name, array<string> nctest)
		{
			if(pPlayer is null) return name;
			string langtx = GetInfoValueA(@pPlayer, "lang").ToUppercase();
			return phrase(name, langtx, nctest);
		}
	}
}
string GetInfoValueA(CBasePlayer@ cPlayer, string key)
{
	if(cPlayer is null) return "";
	KeyValueBuffer@ nBuf = null;
	@nBuf = g_EngineFuncs.GetInfoKeyBuffer(cPlayer.edict());
	if(nBuf is null) return "";
	return nBuf.GetValue(key);
}
XP_Phrases::PhraseClass@ n_Phrases = XP_Phrases::PhraseClass();
string MLText(CBasePlayer@ player, string mlName)
{
	return MLText(player, mlName, {});
}
string MLText(CBasePlayer@ player, string mlName, array<string> mparams)
{
	return n_Phrases.phrase(player, mlName, mparams);
}
void RegisterML(string filelocation)
{
	n_Phrases.register_language(filelocation);
}
void RegisterMLDirect(string filelocation)
{
	n_Phrases.register_language_direct(filelocation);
}
void SetMLFolder(string folder)
{
	if(!folder.EndsWith("/") && !folder.IsEmpty()) folder += "/";
	n_Phrases.lang_loc = folder;
}
void SetMLDefaultLang(string name)
{
	n_Phrases.default_lang = name;
}