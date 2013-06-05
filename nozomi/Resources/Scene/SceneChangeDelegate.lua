--��׼�л�����delegate
NormalChangeDelegate = class()

function NormalChangeDelegate:ctor(fromScene, toScene)
    local bg = CCTouchLayer:create(display.DIALOG_PRI, true)
    bg:setContentSize(General.winSize)
	self.view = bg
    simpleRegisterEvent(bg, {update={callback = self.update, inteval=0.1}}, self)
    self.loadState = 0
    --�ڲ�
    self.stepOver = true
    self.fromScene = fromScene
    self.toScene = toScene
    print("normal has view", self.view)
end

function NormalChangeDelegate:changeScene(fromScene, toScene)
    self.fromScene = fromScene
    self.toScene = toScene
end

function NormalChangeDelegate:checkStep()
    if self.loadState==0 or self.loadState==10 then
        self.stepOver = self.animateTime < timer.getTime()
    elseif self.loadState==4 then
        self.stepOver = self.toScene.isPrepared
    elseif self.loadState==7 then
        self.stepOver = (self.toScene.initInfo~=nil)
    elseif self.loadState==9 then
        self.stepOver = self.toScene:batchAddToScene()
    end
    if self.stepOver then
        self.loadState = self.loadState+1
    end
end

function NormalChangeDelegate:update(diff)
    if self.updateOthers then
        self:updateOthers()
    end
    if not self.stepOver then 
        return self:checkStep()
    end
        print("step", self.loadState)
    if self.loadState==0 then
        if self.exitAnimate then
            self.stepOver = false
            self:exitAnimate()
        else
            self.loadState=1
            return self:update(0)
        end
    elseif self.loadState==1 then
        self.loadState=2
        display.clearScene()
        if self.fromScene and self.fromScene.view and self.fromScene.sceneType~=self.toScene.sceneType then
            -- ���Ƴ�����ǰ�Ƴ�������Ϊ�˱��ⳡ������������
            CCTextureCache:sharedTextureCache():removeUnusedTextures()
        end
        if self.fromScene then
            self.fromScene:removeScene()
        end
        return self:update(0)
    elseif self.loadState==2 then
        self.loadState=3
        if self.fromScene and self.fromScene.sceneType~=self.toScene.sceneType then
            self.fromScene:unloadResource()
        end
        return self:update(0)
    elseif self.loadState==3 then
        self.toScene:initView()
        display.addScene(self.toScene)
        self.loadState=4
    elseif self.loadState==4 then
        if not self.fromScene or self.fromScene.sceneType~=self.toScene.sceneType then
            self.stepOver = false
            self.toScene:prepare()
        else
            self.loadState=5
            return self:update(0)
        end
    elseif self.loadState==5 then
        self.loadState=6
        self.toScene:initPreparedView()
    elseif self.loadState==6 then
        self.loadState=7
        self.toScene:initGround()
    elseif self.loadState==7 then
        -- ����״̬Ϊ�Ƴ���ʾ��ʵ�������걸�ģ�ֱ�ӽ������¼���
        -- ��������initInfo˵��������׼���ã�ֱ�ӽ��м���
        if self.toScene.removed then
            self.loadState=9
            self.toScene:reloadScene()
        elseif self.toScene.initInfo then
            self.loadState=8
            return self:update(0)
        else
            self.stepOver = false
            --ÿ������������Ӧ�����������ĵط���ֵ�����ģ���˵��žͺá�
        end
    elseif self.loadState==8 then
        self.loadState=9
        self.toScene:initData()
        self.toScene:initMenu()
    elseif self.loadState==9 then
        self.stepOver = false
        return self:checkStep()
    elseif self.loadState==10 then
        if self.enterAnimate then
            self.stepOver = false
            self:enterAnimate()
        else
            self.loadState=11
            return self:update(0)
        end
    elseif self.loadState==11 then
        self.view:removeFromParentAndCleanup(true)
        display.isSceneChange = false
        self.toScene.initOver = true
        music.playBackgroundMusic(self.toScene.music)
    end
end