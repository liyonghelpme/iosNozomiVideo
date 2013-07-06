ZombieLogic = {}

function ZombieLogic.delayNext()
    --local tid = squeeze(ZombieLogic.zombieDefends, 0, 4)
    --ZombieLogic.zombieDefends = ZombieLogic.zombieDefends+1
    UserData.zombieShieldTime = timer.getTime()+getParam("zombieDelayTime" .. (UserData.level), 28800)
end

function ZombieLogic.init()
	ZombieLogic.max=0
	ZombieLogic.num=0
	ZombieLogic.person = math.floor(ResourceLogic.getResource("person") * 19/100)
	ZombieLogic.personMax = ZombieLogic.person
	ZombieLogic.losePerson = 0
	ZombieLogic.personNum = 0
	ZombieLogic.losePersonNum = 0
	ZombieLogic.initZombies()
	ZombieLogic.buildNum = 0
	ZombieLogic.destroyNum = 0
	ZombieLogic.percent = 100
	ZombieLogic.stars = 3
	ZombieLogic.killZombies = {0,0,0,0,0,0,0,0}
	ZombieLogic.battleEnd = false
	BattleLogic.costTraps = {}
end

local ZOMBIE_SETTINGS = {{{3,0,0,0,0,0,0,0}},{{10,10,0,0,0,0,0,0}},{{30,30,10,0,0,0,0,0}},{{40,40,30,0,10,0,0,0}},{{40,40,40,15,15,0,0,0}},{{40,45,45,30,15,5,0,0}},{{40,40,50,40,20,5,5,0}},{{40,40,40,40,25,5,5,5}},{{30,30,40,40,30,10,10,10}}}

function ZombieLogic.getAttackZombies()
    local data = copyData(getParam("attackWaves", ZOMBIE_SETTINGS)[UserData.level][1])
    if not ZombieLogic.isGuide then
        for i=1, #data do
            data[i] = math.floor(0.5 + (math.random()*0.4+0.8)*data[i])
        end
    end
    ZombieLogic.zombies = data
    return data
end

local ZOMBIE_PRI = {1, 1, 3, 3, 2, 4, 4, 4}

function ZombieLogic.initZombies()
    local num = 0
    local zombies = ZombieLogic.zombies --getAttackZombies()
    local zombieIds = {}
    local waveList = {{}, {}, {}, {}}
    for i=1, #zombies do
        if zombies[i]>0 then
            num = num + zombies[i]
            local pri = ZOMBIE_PRI[i]
            table.insert(waveList[pri], i)
        end
    end
    ZombieLogic.waves = waveList
    ZombieLogic.zombieIds = waveList[1]
    ZombieLogic.zombie = num
    ZombieLogic.zombieMax = num
    --ZombieLogic.areas = {1, 2, 3, 4, 5, 6}
end

function ZombieLogic.getOneZombie()
    while #(ZombieLogic.zombieIds)==0 do
        table.remove(ZombieLogic.waves, 1)
        if ZombieLogic.waves[1] then
            ZombieLogic.zombieIds = ZombieLogic.waves[1]
        else
            return nil
        end
    end
    local rid = math.random(#(ZombieLogic.zombieIds))
    ZombieLogic.zombie = ZombieLogic.zombie-1
    local zid = ZombieLogic.zombieIds[rid]
    ZombieLogic.zombies[zid] = ZombieLogic.zombies[zid] - 1
    if ZombieLogic.zombies[zid]==0 then
        table.remove(ZombieLogic.zombieIds, rid)
    end
    return zid
end
--[[
function ZombieLogic.getOneZombieArea()
    return ZombieLogic.areas[math.random(#(ZombieLogic.areas))]
end
--]]
function ZombieLogic.destroyBuild(bid)
    local destroyNum = ZombieLogic.destroyNum + 1
    if ZombieLogic.destroyNum*2<ZombieLogic.buildNum and destroyNum*2>=ZombieLogic.buildNum then
        ZombieLogic.stars = ZombieLogic.stars - 1
    end
    if bid==TOWN_BID then
        ZombieLogic.stars = ZombieLogic.stars - 1
    end
    if destroyNum==ZombieLogic.buildNum then
        ZombieLogic.stars = ZombieLogic.stars - 1
        ZombieLogic.battleEnd = true
    end
    ZombieLogic.destroyNum = destroyNum
    ZombieLogic.percent = 100-math.floor(100*destroyNum/ZombieLogic.buildNum)
end

function ZombieLogic.changeBuilderMax(value)
	ZombieLogic.max=ZombieLogic.max+value
end

function ZombieLogic.changeBuilder(value)
	ZombieLogic.num=ZombieLogic.num+value
end

function ZombieLogic.getBuilderMax()
	return ZombieLogic.max
end

function ZombieLogic.getBuilder()
	return ZombieLogic.num
end

function ZombieLogic.changePerson(value)
	if value<0 then
		ZombieLogic.losePersonNum = ZombieLogic.losePersonNum - value
		ZombieLogic.losePerson = math.floor((ZombieLogic.losePersonNum/ZombieLogic.personNum)*ZombieLogic.personMax)
		ZombieLogic.person = ZombieLogic.personMax - ZombieLogic.losePerson
	else
	    ZombieLogic.personNum = ZombieLogic.personNum+value
	end
end

function ZombieLogic.getPerson()
	return ZombieLogic.person
end

function ZombieLogic.getZombie()
	return ZombieLogic.zombie
end

function ZombieLogic.incZombieNumber(zid)
    ZombieLogic.killZombies[zid] = ZombieLogic.killZombies[zid]+1
end

function ZombieLogic.getBattleResult()
	local result = {stars = ZombieLogic.stars, percent=ZombieLogic.percent, losePerson=ZombieLogic.losePerson, killZombies=ZombieLogic.killZombies}
	return result
end