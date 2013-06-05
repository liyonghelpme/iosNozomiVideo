UserSetting = {musicOn = false, soundOn=false, nightMode = false}

function UserSetting.init()
    UserSetting.musicOn = CCUserDefault:sharedUserDefault():getBoolForKey("musicOn", true)
    UserSetting.soundOn = CCUserDefault:sharedUserDefault():getBoolForKey("soundOn", true)
    UserSetting.nightMode = CCUserDefault:sharedUserDefault():getBoolForKey("nightMode", false)
    music.changeMusicState(UserSetting.musicOn)
    music.changeSoundState(UserSetting.soundOn)
end
UserSetting.init()

function UserSetting.changeMusicState(state)
    if state~=UserSetting.musicOn then
        UserSetting.musicOn = state
        music.changeMusicState(UserSetting.musicOn)
        CCUserDefault:sharedUserDefault():setBoolForKey("musicOn", UserSetting.musicOn)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function UserSetting.changeSoundState(state)
    if state~=UserSetting.soundOn then
        UserSetting.soundOn = state
        music.changeSoundState(UserSetting.soundOn)
        CCUserDefault:sharedUserDefault():setBoolForKey("soundOn", UserSetting.soundOn)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function UserSetting.changeNightMode(state)
    if state~=UserSetting.nightMode then
        UserSetting.nightMode = state
        CCUserDefault:sharedUserDefault():setBoolForKey("nightMode", UserSetting.nightMode)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function UserSetting.getValue(key)
    if UserSetting[key] then return UserSetting[key] end
    local value = CCUserDefault:sharedUserDefault():getIntegerForKey(key)
    UserSetting[key] = value
    return value
end

function UserSetting.setValue(key, value)
    UserSetting[key] = value
    CCUserDefault:sharedUserDefault():setIntegerForKey(key, value)
    CCUserDefault:sharedUserDefault():flush()
end

UserData = {isNight=false, researchLevel={[1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1}}

SceneTypes = {Operation=1, Battle=2, Zombie=3, Stage=4, Visit=5}
BuildStates = {STATE_FREE="free", STATE_BUILDING="building", STATE_DESTROY="destroy"}
GridKeys = {Build=1, SET_SOLDIER=2}

TAG_SPECIAL=101
TAG_LIGHT=1000
TAG_ACTION=2000
TAG_VISIT=3000

TOWN_BID=1
LOST_PERCENT=20

NEXT_COST={10, 50, 75, 110, 170, 250, 380, 580, 750}
TIME_SCALE = {1, 2, 4}
RANK_COLOR = {{255, 212, 88}, {166, 186, 188}, {191, 148, 118}}
STORAGE_IMG_SETTING={food="images/storeItemFood1.png", oil="images/storeItemOil2.png", person="images/storeItemPerson2.png"}
RESOURCE_COLOR={food=ccc3(222,178,0), oil=ccc3(3,88,178), person=ccc3(21,1,34), exp=ccc3(1,175,128)} 
RESOURCE_BUILD_BIDS={food=2003, oil=2001, person=2005}
do
	function UserData.changeValue(key, value)
		UserData[key] = (UserData[key] or 0) + value
		--[[
		if key == "exp" then
			while UserData.exp >= UserData.nextExp do
				UserData.ulevel = UserData.ulevel + 1
				UserData.exp = UserData.exp - UserData.nextExp
				UserData.nextExp = UserData.ulevel*50 - 50
				isLevelUp = true
			end
		end
		--]]
	end
	
		--[[
	function UserData.initLevel(level, exp)
	    UserData.ulevel = level
	    UserData.exp = exp
	    if level==1 then
    	    UserData.nextExp = 30
    	else
    	    UserData.nextExp = UserData.ulevel*50 - 50
    	end
		while UserData.exp >= UserData.nextExp do
			UserData.ulevel = UserData.ulevel + 1
			UserData.exp = UserData.exp - UserData.nextExp
			UserData.nextExp = UserData.ulevel*50 - 50
		end
	end
		--]]
end

UserStat = {crystalLogs = {}}
UserStatType = Enum("ZOMBIE", "ZOMBIE_DEFEND", "ZOMBIE_SKIP", "ATTACK", "BATTLE_END", "BATTLE_END_VIDEO", "HISTORY_VIDEO", 
        "VIDEO_DOWNLOAD", "DOWNLOAD", "SHARE", "NIGHT")
CrystalStatType = Enum("ACC_BUILD", "ACC_SOLDIER", "BUY_BUILDER", "BUY_RESOURCE", "BUY_SHIELD", "BUY_ZOMBIE_SHIELD")
        
function UserStat.stat(type)
    if type~=nil then
        UserStat[type] = (UserStat[type] or 0)+1
    end
end

function UserStat.addCrystalLog(type, t, cost, ext)
    table.insert(UserStat.crystalLogs, {type, timer.getServerTime(t), cost, ext})
end

function UserStat.dump()
    local result = {}
    local isEmpty = true
    for k, i in pairs(UserStatType) do
        if UserStat[i] then
            isEmpty = false
            result[i] = UserStat[i]
            UserStat[i] = nil
        else
            result[i] = 0
        end
    end
    if not isEmpty then
        return result
    end
end

function UserStat.dumpCrystal()
    local crystalLog = UserStat.crystalLogs
    if crystalLog[1] then
        UserStat.crystalLogs = {}
        return crystalLog
    end
end