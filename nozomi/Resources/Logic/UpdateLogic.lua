UpdateLogic = {}

function UpdateLogic.init()
	UpdateLogic.list = {}
end

function UpdateLogic.addUpdate(target, handler)
	table.insert(UpdateLogic.list, {target, handler})
end
