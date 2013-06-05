--function print(...)
--    local printResult = ""
--    for i,v in ipairs(arg) do
--        printResult = printResult .. tostring(v) .. "\t"
--   end
--   CCNative:postNotification(0, printResult)
--end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

local function main()
	print("begin")
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
	StringManager.init(StringManager.LANGUAGE_CN)
	ATTACK_BUTTON_SIZE = 27
	MENU_BUTTON_SIZE = 20
	RETURN_BUTTON_SIZE = 25
	--ATTACK_BUTTON_SIZE = 20
	--MENU_BUTTON_SIZE = 18
	--RETURN_BUTTON_SIZE = 22
	
	--------------- program require
	require "data.StaticData"
	require "data.UserData"
	require "Scene.SceneChangeDelegate"
	require "Scene.CastleScene"
	require "Scene.PreBattleScene"
	require "Scene.LoadingScene"
	
	math.randomseed(os.time())
    
    CCUserDefault:sharedUserDefault():setStringForKey("username", "G:1621027083")
    --CCUserDefault:sharedUserDefault():setStringForKey("username", "liyong2")
    --CCUserDefault:sharedUserDefault():setStringForKey("nickname", "")
    
    --runLogoScene()
    --UserData.noPerson = true
    display.runScene(OperationScene.new(), LoadingScene)
    --require "Scene.TestScene"
    --display.runScene(TestScene.create())
    
    --require "General.Alipay"
    --print(Alipay.makeRequestInfo(23, "TEST2", "WHAT THE FUCK2", 0.01))
end

xpcall(main, __G__TRACKBACK__)
