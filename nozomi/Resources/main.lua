
local oldPrint = print
function print(...)
    local printResult = ""
    for i=1,arg.n do
        printResult = printResult .. tostring(arg[i]) .. "\t"
    end
    oldPrint(printResult)
    local logFile = io.open(CCFileUtils:sharedFileUtils():getWriteablePath() .. "error.log", "a")
	logFile:write(printResult .. "\n")
    logFile:close()
end
--[[
function print(...)
end
--]]

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

local function main()
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	
	local cclog = function(...)
	    print(string.format(...))
	end
	
	--------------- test require
	require "param"
	
	--------------- must require
	require "Util.Util"
	require "General.General"
	require "UI.UI"
	require "UI.Effect"
	
	local language = StringManager.LANGUAGE_EN
    StringManager.init(language)
	if language==StringManager.LANGUAGE_CN then
    	ATTACK_BUTTON_SIZE = 27
    	CHILD_MENU_OFF=16
    	NEWSPAPER_TITLE_SIZE = 26
    	NORMAL_SIZE_OFF=2
    	BIGGER_SIZE_OFF=3
    	CRYSTAL_PREFIX = "xicrystal"
	    network.baseUrl = "http://121.199.3.147:9000/"
	    network.scoreUrl = "http://121.199.3.147:9002/"
	    network.chatUrl = "http://121.199.3.147:8004/"
    else
	    ATTACK_BUTTON_SIZE = 20
    	CHILD_MENU_OFF=20
    	NEWSPAPER_TITLE_SIZE = 22
    	NORMAL_SIZE_OFF=0
    	BIGGER_SIZE_OFF=0
	    General.font1="fonts/font1.fnt"
	    General.font2="fonts/font2.fnt"
	    General.font3="fonts/font3.fnt"
	    network.baseUrl = "http://23.21.135.42:8999/"
	    network.scoreUrl = "http://23.21.135.42:8998/"
	    network.chatUrl = "http://23.21.135.42:8005/"
	    CRYSTAL_PREFIX = "crystal"
	end
	--network.baseUrl = "http://192.168.3.101:5000/"
	--network.scoreUrl = "http://192.168.3.101:5001/"
	--------------- program require
	require "data.StaticData"
	require "data.UserData"
	require "Scene.SceneChangeDelegate"
	require "Scene.CastleScene"
	require "Scene.PreBattleScene"
	require "Scene.LoadingScene"
	
	math.randomseed(os.time())
    
    --CCUserDefault:sharedUserDefault():setStringForKey("username", "AD8E5567-F108-4B4E-9353-3635261EC1FE-del")
    print("nozomi main.lua test")
    display.runScene(OperationScene.new(), LoadingScene)
    
    --require "Scene.TestScene"
    --display.addScene(TestScene.create())
end

xpcall(main, __G__TRACKBACK__)
