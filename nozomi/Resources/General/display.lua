require "General.EventManager"

display = {}

do
	local SCENE_PRI = 0
	local MENU_PRI = -10000
	local MENU_BUTTON_PRI = -10001
	local DARK_PRI = -19999
	local DIALOG_PRI = -20000
	local DIALOG_BUTTON_PRI = -20001
	local NOTICE_PRI = -30000
	local NOTICE_BUTTON_PRI = -30001
	
	local SCENE_ZORDER = 0
	local DIALOG_ZORDER = 1
	local NOTICE_ZORDER = 2
	
	local director = CCDirector:sharedDirector()
	--��Ϸ�Ǻܼ򵥵ĳ���������ʹ��Director��Scene
	local baseScene = CCScene:create()
	director:runWithScene(baseScene)
	
	-- LUA�����Ķ�ջ��һ������ֻ��������Σ���������ǰ����������ʱ�����������������ݣ���Ҳ��ĳɲ�������ֻ����������ʵ�����ʣ���
	local sceneStack = {}
	
	-- �Ի���ֻ����һ������Ŀǰ�������һ���Ի����һ��ALERT���͵ĶԻ���ͬʱ���ڣ�
	local curDialog = nil
	
	-- ��ʾ�������֣��������г���
	local notices = {}
	
	local function closeDialog(isAlert)
		if curDialog then
		    local pDialog = curDialog.parentDialog
		    if pDialog and not pDialog.deleted then
		        if isAlert then
		            local s = getParam("scaleMinDialogClose", 0)/100
    		        curDialog.view:runAction(CCEaseBackIn:create(CCScaleTo:create(0.25, s*curDialog.view:getScaleX(), s*curDialog.view:getScaleY())))
        			delayRemove(0.25, curDialog.dialog)
        			curDialog = pDialog
        			return true
        		else
        		    closeDialog(true)
        		end
        	end
    		EventManager.sendMessage("EVENT_DIALOG_CLOSE", curDialog)
    		local size = curDialog.view:getContentSize()
    		curDialog.deleted = true
    		
    		-- �����͸�����һ������ĻС���Ƿ�ȫ���Ի���
    		if (size.width>0 and size.width<General.winSize.width) or (size.height>0 and size.height<General.winSize.height) then
		        local s = getParam("scaleMinDialogClose", 0)/100
    			curDialog.view:runAction(CCEaseBackIn:create(CCScaleTo:create(0.25, s*curDialog.view:getScaleX(), s*curDialog.view:getScaleY())))
    			delayRemove(0.25, curDialog.dialog)
    		else
    			curDialog.dialog:removeFromParentAndCleanup(true)
    		end
    		curDialog = nil
		end
	end
	display.closeDialog = closeDialog
	
	function display.showDialog(dialog, autoPop)
	    if autoPop==nil then autoPop=true end
	    if autoPop and display.isSceneChange then return end
		if type(dialog) == "table" and (not dialog.view) then
			if dialog.create then
				dialog = dialog.create()
			elseif dialog.new then
				dialog = dialog.new()
			end
		end
		if type(dialog) == "userdata" then
			dialog = {view = dialog}
		end
		if curDialog then
		    -- test
		    if dialog.isAlert then
		        if curDialog.isAlert then
		            closeDialog(true)
		        end
		        dialog.parentDialog = curDialog
		    else
    			closeDialog()
    		end
		end
		local function darkCallback()
			if autoPop then
				closeDialog(true)
			end
		end
		local pri = DARK_PRI
		if dialog.isAlert then pri = pri-3 end
		local node = UI.createButton(General.winSize, darkCallback, {priority = pri, nodeChangeHandler = doNothing})
		
		node:setContentSize(General.winSize)
		node:setAnchorPoint(General.anchorLeftBottom)
		local dark = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
		screen.autoSuitable(dark)
		node:addChild(dark)
		
		node:addChild(dialog.view)
		dialog.dialog = node
		curDialog = dialog
		if not curDialog.parentDialog then
		    EventManager.sendMessage("EVENT_DIALOG_OPEN", curDialog)
		end
		-- ����Ի�����Ҫָ�����صĸ��ڵ㣨��ʵֻ��REPLAYʱ�������Ҫ,�������ֵ��
		local scene = dialog.scene or baseScene
		if not scene then scene = baseScene end
		scene:addChild(node, DIALOG_ZORDER)
	end
	
	local function popNotice(node)
	    local rmId = nil
	    for i, notice in pairs(notices) do
	        if node==notice then
        		rmId = i
        		node:removeFromParentAndCleanup(true)
	        end
	    end
	    if rmId then notices[rmId] = nil end
	end
	
	function display.pushNotice(node)
		local delayTime = 3
		local outTime = 1
		
		local my = node:getContentSize().height
		
		local sactions = CCArray:create()
		sactions:addObject(CCDelayTime:create(delayTime))
		sactions:addObject(CCFadeOut:create(outTime))
		sactions:addObject(CCCallFuncN:create(popNotice))
		node:runAction(CCSequence:create(sactions))
		baseScene:addChild(node, NOTICE_ZORDER)
		for id, node in pairs(notices) do
			node:setPositionY(node:getPositionY()+1.1*my)
		end
		table.insert(notices,node)
	end
	
	function display.clearScene()
	    for i, notice in pairs(notices) do
	        notice:removeFromParentAndCleanup(true)
	    end
		notices = {}
		
		closeDialog()
	end
	
	-- �л�����Ӧ����һ������ʽ�Ĳ��������л�������ɾ��ԭ���ĳ����������³��������л�����
	-- Ϊʵ��������̣����ڼ���ĳ�����һ��Ҫ��
	
	-- �л���������Ҫ�У�ԭ������Ŀ�곡���������л�����
	-- ԭ����������Ϊ�ձ�ʾ��ʼ���أ���Ŀ�곡��������һ��LUA���󣨲���Ҫ��VIEW�����������ࣩ
	-- �л�������Ҫ�����ڼ��ص���������֮���Զ���ʼ���г����л�
	local function changeScene(fromScene, toScene, delegate)
	    display.isSceneChange = true
	    if not delegate.view then
	        delegate = delegate.new(fromScene, toScene)
	        baseScene:addChild(delegate.view, DIALOG_ZORDER)
	    else
	        -- ˵���Ѿ����л��������ˣ����õ�ǰ
	        delegate:changeScene(fromScene, toScene)
	    end
	    CCDirector:sharedDirector():getScheduler():setTimeScale(1)
	end
	    
	function display.runScene(scene, delegate)
	    if display.isSceneChange then return end
		local depth = #sceneStack
		local fromScene = nil
		if depth == 0 then
			sceneStack[1] = scene
		else
		    fromScene = sceneStack[depth]
			sceneStack[depth] = scene
		end
		changeScene(fromScene, scene, delegate)
	end
	
	function display.pushScene(scene, delegate)
	    if display.isSceneChange then return end
	    changeScene(sceneStack[#sceneStack], scene, delegate)
	    sceneStack[1 + #sceneStack] = scene
	end
	
	function display.popScene(delegate)
	    if display.isSceneChange then return end
	    local fromScene = sceneStack[#sceneStack]
		sceneStack[#sceneStack] = nil
		changeScene(fromScene, sceneStack[#sceneStack], delegate)
	end
	
	function display.addScene(scene)
	    baseScene:addChild(scene.view, SCENE_ZORDER)
	end
	
	function display.getCurrentScene(index)
		return sceneStack[index or #sceneStack]
	end
	
	function display.isDialogShow()
		return curDialog
	end
	
	-- �������棬�����ز����¼���
	function display.restartWithScene(scene, delegate)
	    --local fromScene = sceneStack[#sceneStack]
	    local fromScene = nil
		baseScene:removeAllChildrenWithCleanup(false)
	    sceneStack = {scene}
	    curDialog = nil
	    notices = {}
	    changeScene(fromScene, scene, delegate)
	end
	
	display.SCENE_PRI = SCENE_PRI
	display.MENU_PRI=MENU_PRI
	display.MENU_BUTTON_PRI=MENU_BUTTON_PRI
	display.DARK_PRI=DARK_PRI
	display.DIALOG_PRI=DIALOG_PRI
	display.DIALOG_BUTTON_PRI=DIALOG_BUTTON_PRI
	display.NOTICE_PRI=NOTICE_PRI
	display.NOTICE_BUTTON_PRI = NOTICE_BUTTON_PRI
end