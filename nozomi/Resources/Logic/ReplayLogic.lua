ReplayLogic = {}

function ReplayLogic.initWriteReplay(seed)
    ReplayLogic.randomSeed = seed
    ReplayLogic.buildData = nil
    ReplayLogic.cmdList = {}
    print("inited?")
end

function ReplayLogic.makeReplayResult(fileName)
    local replayFile = io.open(CCFileUtils:sharedFileUtils():getWriteablePath() .. fileName, "w")
	replayFile:write(json.encode(ReplayLogic.buildData) .. "\n")
	replayFile:write(ReplayLogic.randomSeed .. "\n")
	for _, cmd in ipairs(ReplayLogic.cmdList) do
	    replayFile:write(json.encode(cmd) .. "\n")
	end
    replayFile:close()
end

function ReplayLogic.loadReplayResult(fileName)
    local replayFile = io.open(CCFileUtils:sharedFileUtils():getWriteablePath() .. fileName)
	ReplayLogic.buildData = json.decode(replayFile:read())
	ReplayLogic.randomSeed = tonumber(replayFile:read())
    local cmdList = {}
    while true do
        local cmd = json.decode(replayFile:read())
        table.insert(cmdList, cmd)
        if cmd[2]=="e" then
            ReplayLogic.battleTime = cmd[1]
            break
        end
    end
    ReplayLogic.cmdList = cmdList
    replayFile:close()
end
