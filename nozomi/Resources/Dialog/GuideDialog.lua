-- 引导流程在程序中作为一种全屏式的对话框处理

GuideDialog = class()

function GuideDialog:ctor(gid)
	self.view = CCNode:create()
	self.view:setContentSize(General.winSize)
	
	self.guideInfo = {"TEST1", "TEST2"; isLeft = true}
	
	
end