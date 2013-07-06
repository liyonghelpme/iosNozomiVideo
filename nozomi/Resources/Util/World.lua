-- 参考实现 http://www.policyalmanac.org/games/aStarTutorial.htm
-- https://github.com/liyonghelpme/PathFinder

require "Util.Class"
require "Util.heapq"
local simpleJson =  require "Util.SimpleJson"

World = class()

--[[
startPoint 搜索起点
endPoint 搜索终点
cellNum 地图cellNum*cellNum 大小   内部表示会在地图边界加上一圈墙体 因此实际大小是(cellNum+2)*(cellNum+2) 有效坐标范围1-cellNum 
cells 记录地图每个网格的状态 nil 空白区域 Wall 障碍物 Start 开始位置 End 结束位置 

coff 将x y 坐标转化成 单一的key的系数 x*coff+y = key 默认1000


w = World()
w:initCell()
w:putStart(x, y)
w:putEnd(x, y)
w:putWall(x, y)
path = w:search()

]]--
function World:ctor(cellNum, coff)
    self.calGrid = nil
    self.startPoint = nil
    self.endPoint = nil
    self.cellNum = cellNum
    self.cellSize = 100
    if coff == nil then
        self.coff = 100000
    else
        self.coff = coff
    end
    self.allBuilds = {}
    self.prevGrids = {}
    self.typeNum = {}

    
    --当前只在攻击的时候使用该方法
    --当前帧是否已经搜索过路径
    self.searchYet = false
    --根据性能设定最大允许的每帧搜索士兵数量
    self.maxSearchNum = 1
    self.searchNum = 0
    self.passTime = 0
    self.frameRate = 0.016

    --经营场景
    self.scene = nil

    --是否显示调试块
    self.debug = false
    self.performance = false

    --通过大网格记录最近的建筑物 来帮助searchAttack 计算HScore
    --80*80 = 20*20
    self.bigCoff = 8

    self.benchmark = nil
    --攻击目标类型
    self.searchTargetType = nil
    self.bigStartPoint = nil
    self.bigPath = nil
    self.bigEndPoint = nil
    self.tempBigTarget = nil 
    self.worldBigCursor = nil

    self.totalBig = 0
    self.totalSmall = 0
    self.totalBetween = 0
    self.totalPathCount = 0
    self.searchCount = 0
    self.searchBigGridCount = 0
    self.searchSmallCount = 0
    self.searchBigCount = 0
    --obj 建筑物信息 x y size
    self.buildInfo = {}
    self.unitType = 1 --默认地面单位

    --大网格攻击目标
    self.bigTargetPoint = nil

    self.maxBigCount = 0
    self.maxSmallCount = 0
    self.maxBetweenCount = 0
end
function World:setUnitType(t)
    self.unitType = t
end
function World:setSearchNormal()
    self.searchTargetType = nil
end
--战斗页面设定攻击士兵类型
--设定当前寻路士兵是喜欢攻击防御建筑
--参照建筑物类型 设定搜索目标类型
--0 普通
--1 陷阱
--2 资源
--3 防御
--4 城墙
--5 障碍
--6 装饰
--7 人口
function World:setSearchTarget(target)
    --print("setSearchTarget", target)
    self.searchTargetType = target
end

function World:setScene(s)
    self.scene = s
end
--更新搜索状态 每固定时间 限制寻路的士兵数量
function World:update(dt)
    --print("update World State")
    self.searchNum = self.searchNum - 1
    if self.searchNum <= 0 then
        self.searchYet = false
        self.searchNum = 0
    end
end
--showGrid 显示每个网格的值
--只用于测试
--坐标变换  
--笛卡尔坐标 ---- 正则网格坐标 ---- 仿射网格坐标
--      nx = rount(x/46)  ny = round(y/34.5)            dx = RoundInt((nx+ny)/2) dy = RoundInt((ny-nx)/2) 
--      x = nx*46  y = ny*34.5            nx = dx-dy  ny = dx+dy

--得到最近的整数
function round(x)
    return math.floor(x+0.5)
end
--实际坐标 转化成 网格编号 
function cartesianToNormal(x, y)
    return round(x/23), round(y/17.25)
end
function normalToAffine(nx, ny)
    return round((nx+ny)/2), round((ny-nx)/2)
end

--用于计算当前位置和攻击范围的关系
--返回浮点normal 网格坐标
function cartesianToNormalFloat(x, y)
    return (x/23), (y/17.25)
end

--返回浮点affine 网格坐标  
function normalToAffineFloat(nx, ny)
    return (nx+ny)/2, (ny-nx)/2
end

function normalToCartesian(nx, ny)
    return nx*23, ny*17.25
end
function affineToNormal(dx, dy)
    return dx-dy, dx+dy
end
--我的affine坐标和梁浩然游戏内部的坐标的 x y 方向相反了 

function World:showGrid(param)
    if param == nil then
        if not self.debug then
            return
        end
    end
    -- 0 0 坐标点位置
    local zx = 2080
    local zy = 195

    if self.calGrid ~= nil then
        self.calGrid:removeFromParentAndCleanup(true)
        self.calGrid = nil
    end
    self.calGrid = CCNode:create()--"block.png", 200
    --self.calGrid = CCSpriteBatchNode:create("block.png", 1000)
    self.calGrid:setPosition(0, 0)

    --显示大网格的最近建筑物
    --为什么我的affine坐标系的 x y 和 游戏内的 x y 
                --[[
                local word = CCLabelTTF:create(""..dx.." "..dy.." "..angle.." "..dist, "Arial", 30)
                word:setColor(ccc3(255, 0, 255))
                word:setPosition(px+zx, py+zy+17.25)
                word:setAnchorPoint(ccp(0.5, 0.5))
                
                self.calGrid:addChild(word)
                ]]--

    local totalX = math.ceil(self.cellNum/self.bigCoff)
    local totalY = math.ceil(self.cellNum/self.bigCoff)
    for x = 1, totalX, 1 do
        for y = 1, totalY, 1 do
            local key = self:getKey(x, y)
            if self.bigCells[key]['isPath'] ~= nil then
                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46*self.bigCoff/cs.width)
                temp:setScaleY(34.5*self.bigCoff/cs.height)
                temp:setAnchorPoint(ccp(0.5, 0.5))
                self.calGrid:addChild(temp)

                local sx, sy = self:getBigCenter(x, y)
                local nx, ny = affineToNormal(sy, sx)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)

                temp:setColor(ccc3(0, 255, 0))
            
            end
            --[[
            if self.bigCells[key]['gScore'] ~= nil then
                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46*self.bigCoff/cs.width)
                temp:setScaleY(34.5*self.bigCoff/cs.height)
                temp:setAnchorPoint(ccp(0.5, 0.5))
                self.calGrid:addChild(temp)

                local sx, sy = self:getBigCenter(x, y)
                local nx, ny = affineToNormal(sy, sx)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)

                --temp:setColor(ccc3(0, 255, 0))
                local bc = self.bigCells[key]
                local word = CCLabelTTF:create(""..bc["gScore"].." "..bc["hScore"].." "..bc['fScore'], "Arial", 20)
                word:setColor(ccc3(255, 0, 255))
                word:setPosition(px+zx, py+zy+17.25)
                word:setAnchorPoint(ccp(0.5, 0.5))
                
                self.calGrid:addChild(word)
            end
            --]]
            --最后一个建筑物
            --大网格 对应的小建筑物
            local builds = self.bigBuildings[key]
            for i=1, #builds do
                local bx = builds[i][1]
                local by = builds[i][2]

                local nx, ny = affineToNormal(bx, by)
                local px, py = normalToCartesian(nx, ny)
            
                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                temp:setPosition(-px+zx, py+zy+17.25)
                self.calGrid:addChild(temp)

                --grid distance
                --x, y, 
                local word = CCLabelTTF:create(string.format("%.0f", builds[i][6]), "Arial", 20)
                word:setColor(ccc3(255, 0, 255))
                word:setPosition(-px+zx, py+zy+17.25)
                word:setAnchorPoint(ccp(0.5, 0.5))
                
                self.calGrid:addChild(word)
            end
        end
    end

    local totalX = math.ceil(self.cellNum/self.bigCoff)
    local totalY = math.ceil(self.cellNum/self.bigCoff)
    for x = 1, totalX, 1 do
        for y = 1, totalY, 1 do
            local key = self:getKey(x, y)
            if self.bigGrid[key]['nearObj'] ~= nil then
                local cx, cy = self:getBigCenter(x, y)
                local nx, ny = affineToNormal(cx, cy)
                local px, py = normalToCartesian(nx, ny)

                local nearX, nearY = self.bigGrid[key]['nearX'], self.bigGrid[key]['nearY'] 
                nearX, nearY = affineToNormal(nearX, nearY)
                nearX, nearY = normalToCartesian(nearX, nearY)

                local dx, dy = nearX-px, nearY-py
                local dist = math.sqrt(dx*dx+dy*dy)
                local angle = math.atan2(dy, dx)*180/math.pi

                local temp = CCSprite:create("myLine.png")
                local cs = temp:getContentSize()


                temp:setOpacity(128)
                temp:setAnchorPoint(ccp(0, 0.5))
                temp:setScaleX(dist/cs.width)
                temp:setScaleY(10/cs.height)
                temp:setRotation(angle+180)


                temp:setPosition(-px+zx, py+zy+17.25)

                self.calGrid:addChild(temp)
            end
        end
    end
    --[[

                    local word = CCLabelTTF:create(""..pg[1][1], "Arial", 30)
                    word:setColor(ccc3(255, 0, 255))
                    word:setPosition(23, 17.5)
                    word:setAnchorPoint(ccp(0.5, 0.5))
                    temp:addChild(word)
    --]]

    for x = 1, self.cellNum, 1 do
        for y = 1, self.cellNum, 1 do
            local key = self:getKey(x, y)
            --[[
            local pg = self.prevGrids[key]
            if pg ~= nil then
                if #pg > 0  and pg[1][1] < 3 then
                    local temp = CCSprite:create("block.png")
                    temp:setOpacity(128)
                    local cs = temp:getContentSize()
                    temp:setScaleX(46/cs.width)
                    temp:setScaleY(34.5/cs.height)
                    self.calGrid:addChild(temp)

                    local nx, ny = affineToNormal(y, x)
                    local px, py = normalToCartesian(nx, ny)
                    temp:setPosition(px+zx, py+zy+17.25)
                    temp:setColor(ccc3(255/3*(3-pg[1][1]), 0, 0))
                end

            end
            --]]
                
            --[[
            if self.cells[key]['state'] == 'Wall' then
                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                self.calGrid:addChild(temp)

                local nx, ny = affineToNormal(y, x)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)


                local word = CCLabelTTF:create(""..x.." "..y, "Arial", 20)
                word:setColor(ccc3(255, 0, 255))
                word:setPosition(23, 17.5)
                word:setAnchorPoint(ccp(0.5, 0.5))
                temp:addChild(word)
            end
            --]]
            if self.cells[key]['isTurn'] then
                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                self.calGrid:addChild(temp)

                local nx, ny = affineToNormal(y, x)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)

                temp:setColor(ccc3(255, 0, 0))

                
                local word = CCLabelTTF:create(""..(self.cells[key]['pathCount'] or 0), "Arial", 30)
                word:setColor(ccc3(255, 255, 0))
                word:setPosition(23, 17.5)
                word:setAnchorPoint(ccp(0.5, 0.5))
                temp:addChild(word)

            elseif self.cells[key]['isReal'] then
                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                self.calGrid:addChild(temp)

                local nx, ny = affineToNormal(y, x)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)

                temp:setColor(ccc3(0, 0, 255))

                local word = CCLabelTTF:create(""..self.cells[key]['pathCount'], "Arial", 20)
                word:setColor(ccc3(255, 255, 255))
                word:setPosition(23, 17.5)
                word:setAnchorPoint(ccp(0.5, 0.5))
                temp:addChild(word)

            elseif self.cells[key]['isPath'] then

                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                self.calGrid:addChild(temp)

                local nx, ny = affineToNormal(y, x)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)

                temp:setColor(ccc3(0, 255, 0))
                
                --[[
                local word = CCLabelTTF:create(""..self.cells[key]['gScore'].." "..self.cells[key]['hScore'].." "..self.cells[key]['fScore'], "Arial", 40)
                word:setColor(ccc3(255, 255, 255))
                word:setPosition(23, 17.5)
                word:setAnchorPoint(ccp(0.5, 0.5))
                temp:addChild(word)
                --]]

            elseif self.cells[key]['gScore'] then

                local temp = CCSprite:create("block.png")
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                self.calGrid:addChild(temp)

                local nx, ny = affineToNormal(y, x)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)

                

            end
            --[[
            if self.cells[key]['hScore'] ~= nil then
                --local temp = CCLabelTTF:create(self.cells[key]['fScore'].."", "Arial", 10)
                local temp = CCSprite:create("block.png")
                local hasPathCount = false
                if self.cells[key]['pathCount'] ~= nil and self.cells[key]['pathCount'] > 0 then
                    hasPathCount = true
                    temp:setColor(ccc3(255, 255, 0)) 
                    local word = CCLabelTTF:create(""..self.cells[key]['pathCount'], "Arial", 30)
                    word:setColor(ccc3(255, 0, 255))
                    word:setPosition(23, 17.5)
                    word:setAnchorPoint(ccp(0.5, 0.5))
                    temp:addChild(word)
                elseif self.cells[key]['isPath'] and not self.cells[key]['isReal'] then
                    temp:setColor(ccc3(0, 255, 0))
                elseif self.cells[key]['isReal'] then
                    temp:setColor(ccc3(0, 0, 255))
                elseif self.cells[key]['state'] ~= nil then
                    temp:setColor(ccc3(0, 255, 255))
                end
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                self.calGrid:addChild(temp)
                
                --显示每个路径点预测的值
                if not hasPathCount then
                    local word = CCLabelTTF:create(""..self.cells[key]['hScore'], "Arial", 20)
                    word:setColor(ccc3(255, 0, 0))
                    word:setPosition(23, 17.5)
                    word:setAnchorPoint(ccp(0.5, 0.5))
                    temp:addChild(word)
                end
                --我的坐标x y 轴 和 游戏中的 x y 轴相反
                local nx, ny = affineToNormal(y, x)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)
            end
            --]]
        end
    end
    self.scene.ground:addChild(self.calGrid, 10000)
end
function World:getKey(x, y)
    return x*self.coff+y
end
-- 初始化cells 
-- 每次生成路径都会修改cells的属性
-- 因此在下次搜索结束之前应该清空cells状态 
-- g 从start位置到当前的位置的开销
-- h 启发从当前位置到目标位置的开
-- f = g+h
-- isPath 是否路径 isReal 是否光线最短路径
function World:initCell()
    self.cells = {}
    self.walls = {}
    self.path = {}
    self.bigGrid = {}--x/4 y/4 --->bigId
    self.bigBuildings = {} --每个大网格中的建筑物 {{obj}}
    self.bigCells = {}
    self.buildToBig = {} --每个建筑物作为 某个大网格的最近建筑物 对应的这些大网格的列表

    --nearest --> building
    local totalX = math.ceil(self.cellNum/self.bigCoff)
    local totalY = math.ceil(self.cellNum/self.bigCoff)
    for i=1, totalX, 1 do
        for j=1, totalY, 1 do
            local key = self:getKey(i, j)
            self.bigGrid[key] = {}
            self.bigBuildings[key] = {}
            self.bigCells[key] = {}
        end
    end
    for i=0, totalX+1 do
        local key
        key = self:getKey(0, i)
        self.bigCells[key] = {state='Solid'}
        key = self:getKey(i, 0)
        self.bigCells[key] = {state='Solid'}
        key = self:getKey(totalX+1, i)
        self.bigCells[key] = {state='Solid'}
        key = self:getKey(i, totalX+1)
        self.bigCells[key] = {state='Solid'}
    end

    

    for x = 1, self.cellNum, 1 do
        for y = 1, self.cellNum, 1 do
            self.cells[x*self.coff+y] = {state=nil, fScore=nil, gScore=nil, hScore=nil, parent=nil, isPath=nil, isReal=nil}
        end
    end

    for i = 0, self.cellNum+1, 1 do
        self.cells[0*self.coff+i] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
        self.cells[i*self.coff+0] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
        self.cells[(self.cellNum+1)*self.coff+i] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
        self.cells[i*self.coff+(self.cellNum+1)] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
    end
end
function World:putStart(x, y)
    self.startPoint = {x, y}
end
function World:putEnd(x, y)
    self.endPoint = {x, y}
end
function World:putWall(x, y)
    --print("putWall", x, y)
    self.cells[self:getKey(x, y)]['state'] = 'Wall'
end

--设定Grid
function World:clearGrids(x, y, size)
	for i=1, size do
		for j=1, size do
            local key = self:getKey(x-1+i, y-1+j)
			self.cells[key]['state'] = nil
            self.cells[key]['obj'] = nil
		end
	end
end

--清除经营页面障碍物
function World:clearObstacle(x, y, size)
	for i=1, size do
		for j=1, size do
            local key = self:getKey(x-1+i, y-1+j)
			self.cells[key]['state'] = nil
            self.cells[key]['obj'] = nil
		end
	end
end
--经营页面障碍物
--经营障碍物 不能 像城墙一样堵死路线
--否则使用setGrids 方法
function World:setObstacle(x, y, size, obj)
	for i=1, size do
		for j=1, size do
            local key = self:getKey(x-1+i, y-1+j)
			self.cells[key]['state'] = 'Solid'
            self.cells[key]['obj'] = obj
		end
	end
end

--陷阱 城墙 装饰
function World:setGrids(x, y, size, obj)
	for i=1, size do
		for j=1, size do
            local key = self:getKey(x-1+i, y-1+j)
			self.cells[key]['state'] = 'Wall'
            self.cells[key]['obj'] = obj
		end
	end
end

local function compareDis(a, b)
	return a[1] < b[1]
end
--1 2 3 4 ---> 1
function World:smallToBig(x, y)
    return math.floor((x-1)/self.bigCoff)+1, math.floor((y-1)/self.bigCoff)+1
end
--得到大网格的中心位置 对应的小网格编号 浮点数 affine坐标
function World:getBigCenter(x, y)
    return (x-1)*self.bigCoff+1+self.bigCoff/2, (y-1)*self.bigCoff+1+self.bigCoff/2
end

local function compareBigDistance(a, b)
    --print("compareBigDistance", a, b)
    return a[6] < b[6]
end

--某个建筑可能影响多个大网格
--判定每个小网格属于哪个大网格
--大网格中的某个小网格有对象
function World:setBigGridBuildings(x, y, size, btype, obj)
    local halfSize = size/2
	local cp = {x+halfSize, y+halfSize, obj} --建筑物中点 和 建筑物

    for i = x, x+size-1 do
        for j = y, y+size-1 do
            local bx, by = self:smallToBig(i, j)
            local bKey = self:getKey(bx, by)
            --print("insert inner")
            table.insert(self.bigBuildings[bKey], {i, j, size, btype, obj, 0})--range 攻击距离
            table.sort(self.bigBuildings[bKey], compareBigDistance)
        end
    end

    for i = x-6, x+size+5 do
        for j = y-6, y+size+5 do
            if i >= x and i < x+size and j >= y and j < y+size then
            elseif i < 1 or j < 1 or i > self.cellNum or j > self.cellNum then 
            else
                --print("inser outer")
                local dx = math.abs(cp[1]-(i+0.5))
                local dy = math.abs(cp[2]-(j+0.5))
                local dis = 0
                if dx <= halfSize then
                    dis = math.max(dy-halfSize-0.5, 0)
                elseif dy <= halfSize then
                    dis = math.max(dx-halfSize-0.5, 0)
                else
                    local ex = dx-halfSize
                    local ey = dy-halfSize
                    dis = math.max(math.sqrt(ex*ex+ey*ey)-0.5, 0)
                end

                local bx, by = self:smallToBig(i, j)
                local bKey = self:getKey(bx, by)
                table.insert(self.bigBuildings[bKey], {i, j, size, btype, obj, dis}) --攻击距离
                table.sort(self.bigBuildings[bKey], compareBigDistance)
            end
        end
    end
end
function World:clearBigGridBuildings(x, y, size, btype, obj)
    local halfSize = size/2
	local cp = {x+halfSize, y+halfSize, obj} --建筑物中点 和 建筑物

    for i = x, x+size-1 do
        for j = y, y+size-1 do
            local bx, by = self:smallToBig(i, j)
            local bKey = self:getKey(bx, by)
            for b=1, #self.bigBuildings[bKey] do
                if self.bigBuildings[bKey][b][5] == obj then
                    table.remove(self.bigBuildings[bKey], b)
                    break
                end
            end
        end
    end

    for i = x-6, x+size+5 do
        for j = y-6, y+size+5 do
            if i >= x and i < x+size and j >= y and j < y+size then
            elseif i < 1 or j < 1 or i > self.cellNum or j > self.cellNum then 
            else
                local dx = math.abs(cp[1]-(i+0.5))
                local dy = math.abs(cp[2]-(j+0.5))
                local dis = 0
                if dx <= halfSize then
                    dis = math.max(dy-halfSize-0.5, 0)
                elseif dy <= halfSize then
                    dis = math.max(dx-halfSize-0.5, 0)
                else
                    local ex = dx-halfSize
                    local ey = dy-halfSize
                    dis = math.max(math.sqrt(ex*ex+ey*ey)-0.5, 0)
                end

                local bx, by = self:smallToBig(i, j)
                local bKey = self:getKey(bx, by)

                for b=1, #self.bigBuildings[bKey] do
                    if self.bigBuildings[bKey][b][5] == obj then
                        table.remove(self.bigBuildings[bKey], b)
                        break
                    end
                end
            end
        end
    end
end
--普通 建筑物 
--x y  建筑物 左下角坐标类型 0 0
--size 建筑物2*2 的大小
--btype 建筑物类型
--obj 建筑物本身

--设定bigGrid 大网格中 最近的建筑物
--设定smallGrid 每个小网格状态 建筑物， 建筑物附近可以攻击到建筑物的范围  affectRange 根据士兵最大的范围决定
--塔攻击最近的 最近的士兵
--所有的塔都在 时刻遍历所有的士兵进行攻击
function World:setBigGrid(x, y, size, btype, obj)
    local halfSize = size/2
    local cx = x+halfSize
    local cy = y+halfSize
    local totalX = math.ceil(self.cellNum/self.bigCoff)
    local totalY = math.ceil(self.cellNum/self.bigCoff)
    for i=1, totalX, 1 do
        for j=1, totalY, 1 do
            local key = self:getKey(i, j)
            local data = self.bigGrid[key]
            local bx, by = self:getBigCenter(i, j) 
            local dx = bx-cx
            local dy = by-cy
            if data['nearDist'] == nil then
                data['nearDist'] = dx*dx+dy*dy
                data['nearObj'] = obj
                data['nearX'] = cx
                data['nearY'] = cy
                if self.buildToBig[obj] == nil then
                    self.buildToBig[obj] = {}
                end
                table.insert(self.buildToBig[obj], {i, j})
            else
                local newDist = dx*dx+dy*dy
                if newDist < data['nearDist'] then
                    data['nearDist'] = newDist
                    data['nearObj'] = obj
                     data['nearX'] = cx
                    data['nearY'] = cy

                    if self.buildToBig[obj] == nil then
                        self.buildToBig[obj] = {}
                    end
                    table.insert(self.buildToBig[obj], {i, j})
                end
            end
        end
    end
end
--prevGrid 包含建筑物类型 用于寻路特定类型建筑物 
function World:setSmallGrid(x, y, size, btype, obj)
    local halfSize = size/2
	local cp = {x+halfSize, y+halfSize, obj} --建筑物中点 和 建筑物
    for i = x, x+size-1 do
        for j = y, y+size-1 do
			self.cells[self:getKey(i, j)]['state'] = 'Building'
        end
    end
    --[[
    --普通建筑物中心距离 = 0
    for i = x-6, x+size+5 do
        for j = y-6, y+size+5 do
            local key = self:getKey(i, j)
            local prevGrid = self.prevGrids[key]
            if not prevGrid then
                prevGrid = {}
                self.prevGrids[key] = prevGrid
            end
            if i >= x and i < x+size and j >= y and j < y+size then
                table.insert(prevGrid, {0, cp, halfSize, obj, btype})
                table.sort(prevGrid, compareDis)
            else
                local dx = math.abs(cp[1]-(i+0.5))
                local dy = math.abs(cp[2]-(j+0.5))
                local dis = 0
                if dx <= halfSize then
                    dis = math.max(dy-halfSize-0.5, 0)
                elseif dy <= halfSize then
                    dis = math.max(dx-halfSize-0.5, 0)
                else
                    local ex = dx-halfSize
                    local ey = dy-halfSize
                    dis = math.max(math.sqrt(ex*ex+ey*ey)-0.5, 0)
                end

                table.insert(prevGrid, {dis, cp, halfSize, obj, btype})
                table.sort(prevGrid, compareDis)
            end
        end
    end
    --]]
end

function World:setBuild(x, y, size, btype, obj)
    local halfSize = size/2
	--local fsize = (size-1)/2
	local cp = {x+halfSize, y+halfSize, obj} --建筑物中点 和 建筑物
    self.buildInfo[obj] = {x, y, size, btype}
    --所有建筑物类型 
    --建筑物初始位置
	self.typeNum[btype] = (self.typeNum[btype] or 0) + 1
	self.allBuilds[self:getKey(x, y)] = cp
    --for k, v in pairs(self.allBuilds) do
    --    print("allBuilding "..self:getXY(k))
    --end
    --1 2 3 4 / 4 =  math.floor((x-1)/4)+1
    --设定大网格的最近距离的建筑物
    --居中位置
    --大网格对应的最近建筑
    --每个建筑 作为最近建筑 对应的若干个大网格 
    
    --self:setBigGrid(x, y, size, btype, obj)
    --self:setBigGridBuildings(x, y, size, btype, obj)
    self:setSmallGrid(x, y, size, btype, obj)

    --self:showGrid("setBuild")
end

--当大网格最近的建筑物被摧毁后 寻找新的最近的建筑物
--压力转移到 建筑物销毁 和 游戏初始化阶段
function World:findNearBuild(x, y)
    local bx, by = self:getBigCenter(x, y) 
    local data = self.bigGrid[self:getKey(x, y)]

    local minDist = 9999999;
    --遍历所有建筑物 寻找最近的建筑物
    --建筑物太多怎么办？
    for k, v in pairs(self.allBuilds) do
        local dx = bx-v[1]
        local dy = by-v[2]
        local obj = v[3]
        local newDist = dx*dx+dy*dy
        if newDist < minDist then
            data['nearDist'] = newDist
            data['nearObj'] = obj
            data['nearX'] = v[1]
            data['nearY'] = v[2]
            minDist = newDist
        end
    end
end

--清理大网格 最近建筑物
function World:clearBigGrid(x, y, size, btype, obj)
    if self.buildToBig[obj] ~= nil then
        local grids = self.buildToBig[obj]
        self.buildToBig[obj] = nil
        for k, v in ipairs(grids) do
            self:findNearBuild(v[1], v[2])
        end

    end
end
--避免根据key 反过来求x y 值是不对的 因为x y 可能有负数值
function World:clearSmallGrid(x, y, size, btype, obj)
    for i=x, x+size-1 do
        for j=y, y+size-1 do
			self.cells[self:getKey(i, j)]['state'] = nil
        end
    end
    --[[
    for i=x-6, x+size+5 do
        for j=y-6, y+size+5 do
            --if i >= x and i < x+size and j >= y and j < y+size then
            --else
                local key = self:getKey(i, j)
                local prevGrid = self.prevGrids[key]
                if prevGrid then
                    self.prevGrids[key] = prevGrid
                    for k=1, #prevGrid do
                        if prevGrid[k][4] == obj then
                            table.remove(prevGrid, k)
                            break
                        end
                    end
                    if #prevGrid == 0 then
                        self.prevGrids[key] = nil
                    end
                end
            --end
        end
    end
    --]]
end

--清理建筑物的网格
function World:clearBuild(x, y, size, btype, obj)
	local fsize = (size-1)/2
	local cp = {x+fsize, y+fsize}
	self.typeNum[btype] = self.typeNum[btype] - 1
	self.allBuilds[self:getKey(x, y)] = nil
    self.buildInfo[obj] = nil

    --清理当前建筑的最近的大网格
    --为大网格重新寻找最近的建筑
    
    --self:clearBigGrid(x, y, size, btype, obj)
    self:clearSmallGrid(x, y, size, btype, obj)    
    --self:clearBigGridBuildings(x, y, size, btype, obj)
    
    --self:showGrid()
    --self:showGrid("bigGridSearch")
end

-- 临边10 斜边 14
function World:calcG(x, y)
    local data = self.cells[self:getKey(x, y)]
    local parent = data['parent']
    local difX = math.abs(math.floor(parent/self.coff)-x)
    local difY = math.abs(parent%self.coff-y)
    local dist = 10
    if self.searchType == "attack" then
        -- 经营页面绕不过去城墙的时候 士兵可以穿过城墙
        --当前可以绕过5个城墙
        if self.unitType == 1 then
            if data['state'] == 'Wall' then --不是空军
                if data['wallPath'] then --为什么去打破城墙呢
                    dist = 1
                else
                    dist = 50
                end
            elseif data['state'] == 'Building' then
                dist = 500
            elseif difX > 0 and difY > 0 then
                dist = 14
            end
        else --空军不考虑城墙和建筑物
            if difX > 0 and difY > 0 then
                dist = 14
            end
        end
        --经营页面不需要
        --已经有人在这个上面找过路径了 且不是最终点
        --这条路径 在最近的5s内还是有人走过的  and (now-data['pathTime']) < 5 
        --但是初始路径就没有意义
        --local now = os.time()
        --不是最终路径

        --路径拥挤程度
        --忽略路径拥挤
        if data['pathCount'] ~= nil then
            dist = dist + math.min(data['pathCount']*5, 40)--路径消耗小于城墙消耗
        end

        --print("calG "..dist)

    else
        if data['state'] == 'Wall' then
            if data['wallPath'] then
                dist = 1
            else
                dist = 50
            end
        elseif data['state'] == 'Building' then
            dist = 500
        elseif difX > 0 and difY > 0 then
            dist = 14
        end
    end
    data['gScore'] = self.cells[parent]['gScore']+dist
end

--士兵攻击的时候 首先寻找攻击目标
--bx by 是parent点的位置
--检查所有calcH 都有bx by 传入
--当没有建筑之后 可能存在bug
function World:calcH(x, y, bx, by)
    local data = self.cells[self:getKey(x, y)]
	if self.searchType=="attack" then
        --大网格路径存在 且长度大于当前网格位置
        if self.endPoint ~= nil then
            local dx, dy = math.abs(self.endPoint[1]-x), math.abs(self.endPoint[2]-y)
            data['hScore'] = (dx+dy)*10
        else
            data["hScore"] = 1
        end

        --[[
        local bigCx, bigCy = self:smallToBig(x, y)
        local bigData = self.bigGrid[self:getKey(bigCx, bigCy)]
        if bigData['nearObj'] ~= nil then
            local nearX, nearY = bigData['nearX'], bigData['nearY']
            local dx, dy = math.abs(nearX-x), math.abs(nearY-y)
            data['hScore'] = (dx+dy)*10
        else
		    data['hScore'] = 99999 --没有最近的建筑则是无穷远
        end
        --]]
	else
		local dx, dy = math.abs(self.endPoint[1]-x), math.abs(self.endPoint[2]-y)
		local score = (dx+dy)*10
		data['hScore'] = score
	end
end

function World:calcF(x, y)
    local data = self.cells[self:getKey(x, y)]
    data['fScore'] = data['gScore']+data['hScore']
end

function World:pushBigQueue(x, y)
    local fScore = self.bigCells[self:getKey(x, y)]['fScore']
    heapq.heappush(self.openList, fScore)
    local fDict = self.pqDict[fScore]
    if fDict == nil then
        fDict = {}
    end
    table.insert(fDict, self:getKey(x, y))
    self.pqDict[fScore] = fDict
end

function World:pushQueue(x, y)
    local fScore = self.cells[self:getKey(x, y)]['fScore']
    heapq.heappush(self.openList, fScore)
    local fDict = self.pqDict[fScore]
    if fDict == nil then
        fDict = {}
    end
    table.insert(fDict, self:getKey(x, y))
    self.pqDict[fScore] = fDict
end

--检测大网格邻居
--两个相邻大网格需要存在路径才可以
function World:checkBigNeibor(x, y)
    local neibors = {
        {x-1, y-1},
        {x, y-1},
        {x+1, y-1},
        {x+1, y},
        {x+1, y+1},
        {x, y+1},
        {x-1, y+1},
        {x-1, y}
    }

    for n, nv in ipairs(neibors) do
        local key = self:getKey(nv[1], nv[2]) 
        if self.closedList[key] == nil and self.bigCells[key]['state'] ~= 'Solid'  then  
            -- 检测是否已经在 openList 里面了
            local nS = self.bigCells[key]['fScore']
            local inOpen = false
            if nS ~= nil then
                local newPossible = self.pqDict[nS]
                if newPossible ~= nil then
                    for k, v in ipairs(newPossible) do
                        if v == key then
                            inOpen = true
                            break
                        end
                    end
                end
            end
            -- 已经在开放列表里面 检查是否更新
            if inOpen then
                local oldParent = self.bigCells[key]['parent']
                local oldGScore = self.bigCells[key]['gScore']
                local oldHScore = self.bigCells[key]['hScore']
                local oldFScore = self.bigCells[key]['fScore']

                self.bigCells[key]['parent'] = self:getKey(x, y)
                self:calcBigG(nv[1], nv[2])

                -- 新路径比原路径花费高 gScore  
                if self.bigCells[key]['gScore'] > oldGScore then
                    self.bigCells[key]['parent'] = oldParent
                    self.bigCells[key]['gScore'] = oldGScore
                    self.bigCells[key]['hScore'] = oldHScore
                    self.bigCells[key]['fScore'] = oldFScore
                else -- 删除旧的自己的优先级队列 重新压入优先级队列
                    self:calcBigH(nv[1], nv[2], x, y)
                    self:calcBigF(nv[1], nv[2])

                    local oldPossible = self.pqDict[oldFScore]
                    for k, v in ipairs(oldPossible) do
                        if v == key then
                            table.remove(oldPossible, k)
                            break
                        end
                    end
                    self:pushBigQueue(nv[1], nv[2])
                end
                    
            else --不在开放列表中 直接插入
                self.bigCells[key]['parent'] = self:getKey(x, y)
                self:calcBigG(nv[1], nv[2])
                self:calcBigH(nv[1], nv[2], x, y)
                self:calcBigF(nv[1], nv[2])

                self:pushBigQueue(nv[1], nv[2])
            end
        end
    end
    self.closedList[self:getKey(x, y)] = true
    --self:showGrid()
end


--检测邻居节点 城墙可以穿过去 普通建筑不可以
function World:checkNeibor(x, y)
    local neibors = {
        {x-1, y-1},
        {x, y-1},
        {x+1, y-1},
        {x+1, y},
        {x+1, y+1},
        {x, y+1},
        {x-1, y+1},
        {x-1, y}
    }

    for n, nv in ipairs(neibors) do
        local key = self:getKey(nv[1], nv[2]) 
        --对于城墙value+5

        --如果邻居点 是 终点则不用考虑 该点是否是Building 或者solid
        --(self.closedList[key] == nil and self.cells[key]['state'] ~= 'SOLID' and self.cells[key]['state'] ~= 'Building')  then
        --and nv[1] == self.endPoint[1] and nv[2] == self.endPoint[2]
        if self.closedList[key] == nil and self.cells[key]['state'] ~= 'Solid'  then  
            -- 检测是否已经在 openList 里面了
            local nS = self.cells[key]['fScore']
            local inOpen = false
            if nS ~= nil then
                local newPossible = self.pqDict[nS]
                if newPossible ~= nil then
                    for k, v in ipairs(newPossible) do
                        if v == key then
                            inOpen = true
                            break
                        end
                    end
                end
            end
            -- 已经在开放列表里面 检查是否更新
            if inOpen then
                local oldParent = self.cells[key]['parent']
                local oldGScore = self.cells[key]['gScore']
                local oldHScore = self.cells[key]['hScore']
                local oldFScore = self.cells[key]['fScore']

                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcG(nv[1], nv[2])

                -- 新路径比原路径花费高 gScore  
                if self.cells[key]['gScore'] > oldGScore then
                    self.cells[key]['parent'] = oldParent
                    self.cells[key]['gScore'] = oldGScore
                    self.cells[key]['hScore'] = oldHScore
                    self.cells[key]['fScore'] = oldFScore
                else -- 删除旧的自己的优先级队列 重新压入优先级队列
                    self:calcH(nv[1], nv[2], x, y)
                    self:calcF(nv[1], nv[2])

                    local oldPossible = self.pqDict[oldFScore]
                    for k, v in ipairs(oldPossible) do
                        if v == key then
                            table.remove(oldPossible, k)
                            break
                        end
                    end
                    self:pushQueue(nv[1], nv[2])
                end
                    
            else --不在开放列表中 直接插入
                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcG(nv[1], nv[2])
                self:calcH(nv[1], nv[2], x, y)
                self:calcF(nv[1], nv[2])

                self:pushQueue(nv[1], nv[2])
            end
        end
    end
    self.closedList[self:getKey(x, y)] = true
    --self:showGrid()
end
function World:getXY(pos)
    return math.floor(pos/self.coff), pos%self.coff
end


function World:search()
    local timeBegin = os.clock()

    self.searchType = "business"
    self.searchNum = self.searchNum + 1 --两帧搜索一次路径
    if self.searchNum >= self.maxSearchNum then
        self.searchYet = true
    end

    self.openList = {}
    self.pqDict = {}
    self.closedList = {}

	local tempStart = {}
	if self.startPoint[1]<1 then
		tempStart[1] = 1
	elseif self.startPoint[1]>self.cellNum then
		tempStart[1] = self.cellNum
	end
	if self.startPoint[2]<1 then
		tempStart[2] = 1
	elseif self.startPoint[2]>self.cellNum then
		tempStart[2] = self.cellNum
	end
	if tempStart[1] then
		self.startPoint[1], tempStart[1] = tempStart[1], self.startPoint[1]
	end
	if tempStart[2] then
		self.startPoint[2], tempStart[2] = tempStart[2], self.startPoint[2]
	end

    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcH(self.startPoint[1], self.startPoint[2])
    self:calcF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])

    local startData = self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]
    local endData = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]
    --print("start search " .. self.startPoint[1] .. " " .. self.startPoint[2] .." "..self.endPoint[1].." "..self.endPoint[2])
    --[[
    if startData['state'] == nil then
        print("startState nil")
    else
        print("startState"..startData['state'])
    end
    if endData['state'] == nil then
        print('endState nil')
    else
        print("endState "..endData['state'])
    end
    ]]--

    --获取openList 中第一个fScore
    while #(self.openList) > 0 do

        local fScore = heapq.heappop(self.openList)
        --print("listLen", #self.openList, fScore)
        local possible = self.pqDict[fScore]
        if #(possible) > 0 then
            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            if x == self.endPoint[1] and y == self.endPoint[2] then
                break
            end
            self:checkNeibor(x, y)
        end
    end

    --包含从start到end的所有点
    local path = {self.endPoint}
    local parent = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]['parent']
    --print("getPath", parent)
    while parent ~= nil do
        local x, y = self:getXY(parent)
        table.insert(path, {x, y})
        --路径到开始位置则结束
        if x == self.startPoint[1] and y == self.startPoint[2] then
            break
        end
        --[[
        	if tempStart[1] or tempStart[2] then
        		table.insert(self.path, {tempStart[1] or self.startPoint[1], tempStart[2] or self.startPoint[2]})
        	end
            break    
        else
            self.cells[parent]['isPath'] = true
            table.insert(self.path, {x, y})
        end
        ]]--
        parent = self.cells[parent]["parent"]
    end
    
    local temp = {}
    for i = #path, 1, -1 do
        table.insert(temp, path[i])
        --print(path[i][1], path[i][2])
    end
    
    self.searchType = nil
    --local costTime = os.clock()-timeBegin


    if self.debug then 
        local costTime = os.clock()-timeBegin
        if self.benchmark then
            self.benchmark:removeFromParentAndCleanup(false)
        end

        if self.scene.view ~= nil then
            self.benchmark = CCLabelTTF:create(string.format("%.2f", costTime), "Arial", 50)
            self.benchmark:setPosition(ccp(200, 200))
            self.scene.view:addChild(self.benchmark, 10000)
        end
    end
    return temp
end

function World:minusPathCount(x, y)
    local key = self:getKey(x, y)
    local old = self.cells[key]['pathCount'] or 0
    if old > 0 then
        self.cells[key]['pathCount'] = old - 1
        self.totalPathCount = self.totalPathCount-1
    else
        print("PathError PathCount-1 < 0") 
    end

end
function World:addPathCount(x, y)
    local key = self:getKey(x, y)
    local old = self.cells[key]['pathCount'] or 0
    self.cells[key]['pathCount'] = old+1
    self.totalPathCount = self.totalPathCount + 1
end
function World:adjustStartPoint()
	local tempStart = {}
	if self.startPoint[1]<1 then
		tempStart[1] = 1
	elseif self.startPoint[1]>self.cellNum then
		tempStart[1] = self.cellNum
	end
	if self.startPoint[2]<1 then
		tempStart[2] = 1
	elseif self.startPoint[2]>self.cellNum then
		tempStart[2] = self.cellNum
	end
	if tempStart[1] then
		self.startPoint[1], tempStart[1] = tempStart[1], self.startPoint[1]
	end
	if tempStart[2] then
		self.startPoint[2], tempStart[2] = tempStart[2], self.startPoint[2]
	end
    return tempStart
end

--searchAttack 如果有特定类型的建筑物 则调用该函数
--if self.searchTargetType ~= nil and self.typeNum[self.searchTargetType] ~= nil and self.typeNum[self.searchTargetType] > 0 then

function World:findCertainTypeBuilding(range)
    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcH(self.startPoint[1], self.startPoint[2])
    self:calcF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])

    --获取openList 中第一个fScore
    local parent, lastPoint, target
    while #(self.openList) > 0 do
        local fScore = heapq.heappop(self.openList)
        --print("listLen", #self.openList, fScore)
        local possible = self.pqDict[fScore]
        if #(possible) > 0 then
            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            --当前点到建筑物距离 小于 士兵的射程
            local prevGrid = self.prevGrids[point]
            --距离 建筑物中心 建筑物大小 建筑物
			--table.insert(prevGrid, {dis, cp, fsize, obj, btype})
            if prevGrid and #prevGrid > 0 and prevGrid[1][1]<=range and prevGrid[1][5] == self.searchTargetType then
                prevGrid = prevGrid[1]
                parent = point 
                lastPoint = {x, y}
                target = prevGrid[4]
                --end
                break
            end
            self:checkNeibor(x, y)
        end
    end
    return parent, lastPoint, target 
end

--搜索初始攻击目标
function World:findInitPath(range)
    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcH(self.startPoint[1], self.startPoint[2])
    self:calcF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])

    --获取openList 中第一个fScore
    local parent, lastPoint, target
    while #(self.openList) > 0 do
        local fScore = heapq.heappop(self.openList)
        --print("listLen", #self.openList, fScore)
        local possible = self.pqDict[fScore]
        if #(possible) > 0 then
            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            --当前点到建筑物距离 小于 士兵的射程
            local prevGrid = self.prevGrids[point]
            --距离 建筑物中心 建筑物大小 建筑物
			--table.insert(prevGrid, {dis, cp, fsize, obj})
            --一个网格多个prevGrid 寻找最近的距离
            if prevGrid and #prevGrid > 0 and prevGrid[1][1] <= range then
                parent = point 
                lastPoint = {x, y}
                target = prevGrid[1][4]
                break
            end
            self:checkNeibor(x, y)
        end
    end
    --print("findInitPath", parent, simpleJson:encode(lastPoint), target)
    return parent, lastPoint, target 
end

function World:calcBigG(x, y)
    local data = self.bigCells[self:getKey(x, y)]
    local parent = data['parent']
    local difX = math.abs(math.floor(parent/self.coff)-x)
    local difY = math.abs(parent%self.coff-y)
    local dist = 10
    if difX > 0 and difY > 0 then
            dist = 14
    end
    data['gScore'] = self.bigCells[parent]['gScore']+dist
end

function World:calcBigH(x, y, bx, by)
    local data = self.bigCells[self:getKey(x, y)]
    data['hScore'] = 0
end
function World:calcBigF(x, y)
    local data = self.bigCells[self:getKey(x, y)]
    data['fScore'] = data['gScore']+data['hScore']
end

--cells
--pushQueue
function World:calcBetweenG(x, y)
    local data = self.cells[self:getKey(x, y)]
    local parent = data['parent']
    local difX = math.abs(math.floor(parent/self.coff)-x)
    local difY = math.abs(parent%self.coff-y)
    local dist = 10

    if data['state'] == 'Wall' then
        if data['wallPath'] then
            dist = 1
        else
            dist = 100
        end
    elseif data['state'] == 'Building' then
        dist = 500
    elseif difX > 0 and difY > 0 then
        dist = 14
    end
    --只有在最后的路径才考虑pathCount 之前不用考虑
    --路径拥挤程度 开始士兵散开
    if data['pathCount'] ~= nil then
        dist = dist + math.min(data['pathCount']*10, 40)
    end

    data['gScore'] = self.cells[parent]['gScore']+dist
end
function World:calcBetweenH(x, y, bx, by)
    local data = self.cells[self:getKey(x, y)]
    if self.bigTargetPoint ~= nil then
        local dx, dy = math.abs(self.endPoint[1]-x), math.abs(self.endPoint[2]-y)
        local score = (dx+dy)*10
        data['hScore'] = score
    else
        data['hScore'] = 1
    end
end
function World:calcBetweenF(x, y)
    local data = self.cells[self:getKey(x, y)]
    data['fScore'] = data['gScore']+data['hScore']
end

--cells
--calcG H F
--pushQueue
function World:checkBetweenNeibor(x, y)
    local neibors = {
        {x-1, y-1},
        {x, y-1},
        {x+1, y-1},
        {x+1, y},
        {x+1, y+1},
        {x, y+1},
        {x-1, y+1},
        {x-1, y}
    }

    for n, nv in ipairs(neibors) do
        local key = self:getKey(nv[1], nv[2]) 
        if self.closedList[key] == nil and self.cells[key]['state'] ~= 'Solid'  then  
            -- 检测是否已经在 openList 里面了
            local nS = self.cells[key]['fScore']
            local inOpen = false
            if nS ~= nil then
                local newPossible = self.pqDict[nS]
                if newPossible ~= nil then
                    for k, v in ipairs(newPossible) do
                        if v == key then
                            inOpen = true
                            break
                        end
                    end
                end
            end
            -- 已经在开放列表里面 检查是否更新
            if inOpen then
                local oldParent = self.cells[key]['parent']
                local oldGScore = self.cells[key]['gScore']
                local oldHScore = self.cells[key]['hScore']
                local oldFScore = self.cells[key]['fScore']

                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcBetweenG(nv[1], nv[2])

                -- 新路径比原路径花费高 gScore  
                if self.cells[key]['gScore'] > oldGScore then
                    self.cells[key]['parent'] = oldParent
                    self.cells[key]['gScore'] = oldGScore
                    self.cells[key]['hScore'] = oldHScore
                    self.cells[key]['fScore'] = oldFScore
                else -- 删除旧的自己的优先级队列 重新压入优先级队列
                    self:calcBetweenH(nv[1], nv[2], x, y)
                    self:calcBetweenF(nv[1], nv[2])

                    local oldPossible = self.pqDict[oldFScore]
                    for k, v in ipairs(oldPossible) do
                        if v == key then
                            table.remove(oldPossible, k)
                            break
                        end
                    end
                    self:pushQueue(nv[1], nv[2])
                end
                    
            else --不在开放列表中 直接插入
                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcBetweenG(nv[1], nv[2])
                self:calcBetweenH(nv[1], nv[2], x, y)
                self:calcBetweenF(nv[1], nv[2])

                self:pushQueue(nv[1], nv[2])
            end
        end
    end
    self.closedList[self:getKey(x, y)] = true
    --self:showGrid()
end
--寻找两个大网格之间的小路径 使用cells
--根据startPoint 和 endPoint bigStartPoint, bigEndPoint寻找目标
--local parent, lastPoint, target
--只返回最后的路径lastPoint 但是没有目标因为目标不明确 还未找到呢
function World:findBetweenInitPath()
    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcBetweenH(self.startPoint[1], self.startPoint[2])
    self:calcBetweenF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])
    local target
    while #(self.openList) > 0 do
        local fScore = heapq.heappop(self.openList)
        local possible = self.pqDict[fScore]
        if #(possible) > 0 then
            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            local bigX, bigY = self:smallToBig(x, y)
            if bigX == self.bigEndPoint[1] and bigY == self.bigEndPoint[2] then
                target = point
                break
            end
            self:checkBetweenNeibor(x, y)
        end
    end
    return target 
end
--寻找大的初始路径
--判定网格内建筑物的攻击范围
function World:findBigInitPath(bx, by, range)
    range = range or 0

    self.bigCells[self:getKey(bx, by)]['gScore'] = 0
    self:calcBigH(bx, by)
    self:calcBigF(bx, by)
    self:pushBigQueue(bx, by)

    local target
    local tempTarget 
    --当网格中当前的临时攻击对象 足够靠近的时候 使用searchAttack 来明确攻击对象
    while #(self.openList) > 0 do
        local fScore = heapq.heappop(self.openList)
        local possible = self.pqDict[fScore]
        if #(possible) > 0 then
            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            local builds = self.bigBuildings[point]
            --大网格存在建筑物 且是当前士兵最喜欢的建筑物
--if self.searchTargetType ~= nil and self.typeNum[self.searchTargetType] ~= nil and self.typeNum[self.searchTargetType] > 0 then
            if #builds > 0 then
                --favorite and in range
                if self.searchTargetType ~= nil and (self.typeNum[self.searchTargetType] or 0) > 0 then
                    local findFavorite = false
                    for bk, bv in ipairs(builds) do
                        --table.insert(self.bigBuildings[bKey], {i, j, size, btype, obj})
                        if bv[4] == self.searchTargetType and bv[6] <= range then
                            findFavorite = true
                            tempTarget = bv[5]
                            target = point
                            break
                        end
                    end
                    if findFavorite then
                        break
                    end
                else
                --inRange
                --大建筑的网格已经排好了顺序
                    local findRangeBuild = false
                    --寻找在攻击范围内的建筑物
                    --x y size btype obj distance
                    for k, v in ipairs(builds) do
                        if v[6] <= range then
                            findRangeBuild = true
                            target = point
                            tempTarget = v[5]
                            break
                        else
                            break
                        end
                    end
                    --target = point
                    --tempTarget = builds[1][5]
                    if findRangeBuild then
                        break
                    end
                end
            end
            self:checkBigNeibor(x, y)
        end
    end
    return target, tempTarget 
end

--寻找到大网格路径
--逆向成从起点到终点的路径
function World:getBigPath(parent)
    local path = {}
    while parent ~= nil do
        local x, y = self:getXY(parent)
        table.insert(path, {x, y})
        self.bigCells[parent]['isPath'] = true
        self.bigCells[parent]['pathTime'] = os.time()
        if x == self.bigStartPoint[1] and y == self.bigStartPoint[2] then
            break
        end
        parent = self.bigCells[parent]["parent"]
    end
    local temp = {}
    for i=#path, 1, -1 do
        table.insert(temp, path[i])
    end
    --print("bigPath", simpleJson:encode(temp))
    return temp
end

--得到当前路径
--从终点到起点的路径
function World:getPath(parent)
    local path = {}
    
    while parent ~= nil do
        local x, y = self:getXY(parent)
        table.insert(path, {x, y})
        self.cells[parent]['isPath'] = true
        self.cells[parent]['pathTime'] = os.time()
        if x == self.startPoint[1] and y == self.startPoint[2] then
            break
        end
        parent = self.cells[parent]["parent"]
    end
    return path
end
--检测路径中是否包含城墙
function World:checkWall(path)
    local temp = {}
    local findWall = false
    local wallX = 0
    local wallY = 0
    local wallObj = nil
    --空中单位不用考虑城墙
    if self.unitType == 2 then
        --reverse path
        for i = #path, 1, -1 do
            table.insert(temp, path[i])
            local key = self:getKey(path[i][1], path[i][2])
            local data = self.cells[key]
        end
        return temp, findWall, wallX, wallY, wallObj
    end
    --local wallData = nil
    --当前状态是城墙 且 有士兵路径 则降低该城墙的权值
    --没有考虑本身如果是墙体的话
    for i = #path, 1, -1 do
        table.insert(temp, path[i])
        local key = self:getKey(path[i][1], path[i][2])
        local data = self.cells[key]
        --如果路径上面有城墙 则 停止
        --如果士兵本身陷入到城墙里面则不考虑起点的城墙 and i ~= #path 验证方法 searchAttack 返回的路径没有随机值
        if data['state'] == 'Wall' and i ~= #path  then
            if self.debug then
                print("findWall Here")
                print(data["obj"])
            end
            findWall = true
            wallX = path[i][1]
            wallY = path[i][2]
            wallObj = data['obj']
            --wallData = data
            data['wallPath'] = true
            break
        end
    end
    return temp, findWall, wallX, wallY, wallObj
end

--到攻击目标之间存在城墙 首先攻击城墙
--solX solY 笛卡尔坐标
function World:findWallPath(solX, solY, wallX, wallY, wallObj, temp, range)
    local key = self:getKey(wallX, wallY)
    local wpx, wpy = wallX, wallY
    
    local solAffX, solAffY = cartesianToNormalFloat(solX, solY)
    solAffX, solAffY = normalToAffineFloat(solAffX, solAffY)

    --起点在攻击范围圆内
    local dx = solAffX - wpx 
    local dy = solAffY - wpy
    local target = wallObj
    local lastPoint 
    --只有两个以下的顶点
    --至少保持路径有一个顶点
    if dx*dx+dy*dy <= range*range or #temp <= 2 then
        temp = {temp[1]}
        target = wallObj 
        lastPoint = {solAffX, solAffY} 
    else
        --2个以上的顶点
        local stopGrid = math.max(#temp-1, 1)
        for i = #temp-1, 1, -1 do
            local x, y = temp[i][1], temp[i][2]
            local dx = x - wpx
            local dy = y - wpy
            if dx*dx+dy*dy > range*range then
                stopGrid = math.min(i + 1, stopGrid)
                break
            end
        end
        --移除后面的顶点
        for i = #temp, stopGrid+1, -1 do
            table.remove(temp, i)
        end
        target = wallObj
        local x, y = affineToNormal(temp[stopGrid][1], temp[stopGrid][2])
        x, y = normalToCartesian(x, y)
        --网格内随机一定位置
        lastPoint = {temp[stopGrid][1], temp[stopGrid][2]}
    end
    return temp, target, lastPoint 
end

function World:clearData()
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
end





function World:extendTable(t1, t2)
    for k,v in ipairs(t2) do 
        table.insert(t1, v)
    end
    return t1
end

--使用大网格搜索士兵攻击目标
--接着使用大网格间寻路 
function World:bigGridSearchPath(range, fx, fy)
    local timeBegin = os.clock()
    self:searchBigGrid(range)
    local path, target, lastPoint = self:searchPathToTarget(range, fx, fy)
    
    if self.performance then
        local costTime = os.clock()-timeBegin
        if self.benchmark then
            self.benchmark:removeFromParentAndCleanup(false)
        end

        if self.scene.view ~= nil then
            self.benchmark = CCLabelTTF:create(string.format("%.2f", costTime), "Arial", 50)
            self.benchmark:setPosition(ccp(200, 200))
            self.scene.view:addChild(self.benchmark, 10000)
        end
    end

    --self:showGrid("bigGridSearch")


    return path, target, lastPoint
end

--根据大网格的提示寻找到目标路径
function World:searchPathToTarget(range, fx, fy)
    local totalPath = {}
    local leftPath = #self.bigPath
    local sx, sy = self.startPoint[1], self.startPoint[2]
    local cursor = 1
    local findWall = false
    local curPath, target, lastPoint
    --如果到目标有超过2个的大网格 使用大网格提示路径
    --print("searchPathToTarget",  leftPath)
    while leftPath > 2 do
        local start = self.bigPath[cursor]
        local finish = self.bigPath[cursor+1]
        --返回路径 和 进入邻居网格的点
        findWall, curPath, target, lastPoint = self:searchBetweenBigGrid(start[1], start[2], finish[1], finish[2], sx, sy, range)
        self:extendTable(totalPath, curPath)
        if findWall then
            break
        end
        
        sx, sy = lastPoint[1], lastPoint[2]
        cursor = cursor + 1
        leftPath = leftPath - 1
    end
    if findWall then
        return totalPath, target, lastPoint
    end
    --开始在两个相邻块内寻找路径
    self.startPoint = {sx, sy}
    curPath, target, lastPoint = self:searchAttack(range, fx, fy, nil, nil, "init")
    self:extendTable(totalPath, curPath)
    return totalPath, target, lastPoint
end


--寻找大网格之间的细节路径
--0 - 1 大网格编号
--sx sy 起始大网格中小网格的编号
--返回路径 可能的目标城墙 如果是城墙则返回到城墙的点
function World:searchBetweenBigGrid(x0, y0, x1, y1, sx, sy, range)
    self.searchType = "between"
    self:clearData()
    self.bigStartPoint = {x0, y0}
    self.startPoint = {sx, sy} 
    local cx, cy = self:getBigCenter(x1, y1)
    self.endPoint = {cx, cy}
    self.bigEndPoint = {x1, y1}
    
    local startKey = self:getKey(sx, sy)
    self.cells[startKey]["isTurn"] = true

    local parent = self:findBetweenInitPath()
    local path = self:getPath(parent)
    local temp, findWall, wallX, wallY, wallObj = self:checkWall(path)
    local ex, ey = self:getXY(parent)
    local lastPoint = {ex, ey}
    local target = nil

    local solX, solY = affineToNormal(sx, sy)
    solX, solY = normalToCartesian(solX, solY)
    if findWall then
        temp, target, lastPoint = self:findWallPath(solX, solY, wallX, wallY, wallObj, temp, range)
    end

    self.searchType = nil
    self.cells[self:getKey(lastPoint[1], lastPoint[2])]["isTurn"] = true
    return findWall, temp, target, lastPoint
end


--寻找大网格到附近建筑物
--设定bigPath
--搜索特定攻击范围的士兵 大网格路径
function World:searchBigGrid(range)
    self.searchType = "searchBig"
    self:adjustStartPoint()
    local bx, by = self:smallToBig(self.startPoint[1], self.startPoint[2])
    self.bigStartPoint = {bx, by}

    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    local target, tempTarget = self:findBigInitPath(bx, by, range) 
    self.bigPath = self:getBigPath(target) 
    self.tempBigTarget = tempTarget
    self.searchType = nil

    --self:showGrid("searchBigGrid")
end

function getLen(t)
    local i = 0
    for k, v in pairs(t) do
        i = i+1
    end
    return i
end
function checkHas(t)
    local find = false
    for k, v in pairs(t) do
        find = true
        break
    end
    return find
end

--检测sx sy 网格位置士兵 是否可以攻击到自己的攻击目标
--target目标建筑物以及对应的一些数据
--build---> x y size btype 信息
function World:checkNearTarget(sx, sy, target, range)
    local data = self.buildInfo[target]
    local x, y, size = data[1], data[2], data[3]
    local halfSize = size/2
    local cp = {x+halfSize, y+halfSize}

    local dx = math.abs(cp[1]-(sx+0.5))
    local dy = math.abs(cp[2]-(sy+0.5))
    local dis = 0
    if dx <= halfSize then
        dis = math.max(dy-halfSize-0.5, 0)
    elseif dy <= halfSize then
        dis = math.max(dx-halfSize-0.5, 0)
    else
        local ex = dx-halfSize
        local ey = dy-halfSize
        dis = math.max(math.sqrt(ex*ex+ey*ey)-0.5, 0)
    end
    if dis <= range then
        return true
    end
    return false
end

function World:testSearchAttack(range, fx, fy, oldBigPath, bigCursor, currentTarget)
    local timeBegin = os.clock()
    if not checkHas(self.allBuilds) then
        return nil, nil, nil
    end

    local bigCount = 0
    if oldBigPath == nil then
        self:searchBigGrid(range)
        oldBigPath = self.bigPath
        self.worldBigCursor = 1
        bigCursor = 1
        currentTarget = self.tempBigTarget
    --已经寻过路 恢复状态信息
        bigCount = getLen(self.closedList)
        self.searchBigGridCount = self.searchBigGridCount+1
    else
        self.bigPath = oldBigPath
        self.tempBigTarget = currentTarget
        self.worldBigCursor = bigCursor
    end

    self.bigTargetPoint = self:getTempTargetPos()
    local curPath, target, lastPoint

    local smallCount = 0
    curPath, target, lastPoint = self:searchAttack(range, fx, fy)
    --bigPath 在返回值之前被清空
    self.bigPath = nil
    bigCursor = nil
    smallCount = getLen(self.closedList)

    if self.performance then
        local costTime = os.clock()-timeBegin
        if self.benchmark then
            self.benchmark:removeFromParentAndCleanup(false)
        end
        if self.scene.view ~= nil then
            self.benchmark = CCNode:create()
            local t = CCLabelTTF:create(string.format("%.4f %d %d", costTime, bigCount, smallCount), "Arial", 20)
            self.benchmark:addChild(t)

            self.maxSmallCount = math.max(self.maxSmallCount, smallCount)
            t = CCLabelTTF:create(string.format("%d", self.maxSmallCount), "Arial", 20)
            self.benchmark:addChild(t)
            t:setPosition(ccp(0, 100))

            self.benchmark:setPosition(ccp(200, 200))
            self.scene.view:addChild(self.benchmark, 10000)
        end
    end

    --self:showGrid("testSearchAttack")
    return curPath, target, lastPoint, nil, nil
end
--oldBig 当前士兵的大网格路径
--bigCursor 当网格路径的编号
--当前目标从一个大网格移动到另外一个大网格目标
--putStartPoint 是士兵当前的位置
--返回值
--path target lastPoint bigPath bigCursor
function World:searchFromBig(range, fx, fy, oldBigPath, bigCursor, currentTarget)
    self.searchCount = self.searchCount+1
    --没有建筑了
    if not checkHas(self.allBuilds) then
        return nil, nil, nil
    end

    local timeBegin = os.clock()
    local bigCount = 0
    --没有寻过路
    if oldBigPath == nil then
        self:searchBigGrid(range)
        oldBigPath = self.bigPath
        self.worldBigCursor = 1
        bigCursor = 1
        currentTarget = self.tempBigTarget
    --已经寻过路 恢复状态信息
        bigCount = getLen(self.closedList)
        self.searchBigGridCount = self.searchBigGridCount+1
    else
        self.bigPath = oldBigPath
        self.tempBigTarget = currentTarget
        self.worldBigCursor = bigCursor
    end

    --self.endPoint = nil
    --self.bigEndPoint = nil
    --[[
    self.bigTargetPoint = nil
    if #self.bigPath > bigCursor then
        local ex, ey = self.bigPath[bigCursor+1][1], self.bigPath[bigCursor+1][2]
        ex, ey = self:getBigCenter(ex, ey)
        --self.endPoint = {ex, ey}
        self.bigTargetPoint = {ex, ey}
    end
    --]]

    self.bigTargetPoint = self:getTempTargetPos()

    local smallCount = 0
    local betweenCount = 0
    local curPath, target, lastPoint
    --print("bigPath, bigCursor", #self.bigPath, bigCursor)
    --如果士兵当前位置 和 目标建筑物距离足够近 则直接攻击即可
    --if currentTarget and self:checkNearTarget(self.startPoint[1], self.startPoint[2], currentTarget, range) then 
    --    curPath = {}
    --    target = currentTarget
    --可能发现另外一个更近的建筑物 所以临时target 不能奏效 看一下range是多少

    --当前大网格位置 和 目标位置 足够接近 直接小距离寻路
    --远程士兵需要更大的寻路范围
    --应该是建筑物影响范围 而不是建筑物所在范围的网格
    --如果建筑物影响了该大网格 记录了大网格range 来判定是否寻路士兵 需要考虑这个range 因素
    --or (range > 2 and #self.bigPath-bigCursor < 3)
    --setBuild 中设定阴影位置
    --两个大网格寻路
    if #self.bigPath-bigCursor < 2 then
        curPath, target, lastPoint = self:searchAttack(range, fx, fy)
        --bigPath 在返回值之前被清空
        self.bigPath = nil
        bigCursor = nil
        --return curPath, target, lastPoint, nil, nil
        smallCount = getLen(self.closedList)
        self.searchSmallCount = self.searchSmallCount+1
    else
        --距离较远大网格之间寻路
        local sx, sy = self.startPoint[1], self.startPoint[2]
        local findWall = false

        local start = self.bigPath[bigCursor]
        local finish = self.bigPath[bigCursor+1]
        --返回路径 和 进入邻居网格的点
        findWall, curPath, target, lastPoint = self:searchBetweenBigGrid(start[1], start[2], finish[1], finish[2], sx, sy, range)
        bigCursor = bigCursor+1 
        betweenCount = getLen(self.closedList)
        self.searchBigCount = self.searchBigCount+1
        --大网格之间存在城墙移动被中断了
        if findWall then
            self.bigPath = nil
            bigCursor = nil
            --return curPath, target, lastPoint, nil, nil
        else
        --维持临时攻击目标
            target = currentTarget
        end

    end


    if self.performance then
        local costTime = os.clock()-timeBegin
        if self.benchmark then
            self.benchmark:removeFromParentAndCleanup(false)
        end

        if self.scene.view ~= nil then
            self.benchmark = CCNode:create()
            local t = CCLabelTTF:create(string.format("%.4f %d %d %d", costTime, bigCount, smallCount, betweenCount), "Arial", 20)
            self.benchmark:addChild(t)


            self.totalBig = self.totalBig+bigCount
            self.totalSmall = self.totalSmall+smallCount
            self.totalBetween = self.totalBetween+betweenCount

            t = CCLabelTTF:create(string.format("%d %d %d %d %d", self.totalBig, self.totalSmall, self.totalBetween, self.totalPathCount, self.searchCount), "Arial", 20)
            t:setPosition(ccp(0, 50))
            self.benchmark:addChild(t)

            t = CCLabelTTF:create(string.format("%.1f %.1f %.1f ", self.totalBig/self.searchBigGridCount, self.totalSmall/self.searchSmallCount, self.totalBetween/self.searchBigCount), "Arial", 20)
            t:setPosition(ccp(0, 150))
            self.benchmark:addChild(t)

            if smallCount > self.maxSmallCount then
                t = CCLabelTTF:create(simpleJson:encode(curPath), "Arial", 20)
                t:setPosition(ccp(0, 200))
                self.benchmark:addChild(t)
            end

            self.maxBigCount = math.max(self.maxBigCount, bigCount)
            self.maxSmallCount = math.max(self.maxSmallCount, smallCount)
            self.maxBetweenCount = math.max(self.maxBetweenCount, betweenCount)

            t = CCLabelTTF:create(string.format("%d %d %d", self.maxBigCount, self.maxSmallCount, self.maxBetweenCount), "Arial", 20)
            t:setPosition(ccp(0, 250))
            self.benchmark:addChild(t)

            self.benchmark:setPosition(ccp(200, 200))
            self.scene.view:addChild(self.benchmark, 10000)
        end
    end

    --self:showGrid("bigGridSearch")

    --返回大网格之间的路径 使用大网格临时目标
    return curPath, target, lastPoint, self.bigPath, bigCursor 
end

function World:getTempTargetPos()
    local tempPos
    if self.tempBigTarget then
        local info = self.buildInfo[self.tempBigTarget]
        tempPos = {info[1]+info[3]/2, info[2]+info[3]/2}
    end
    return tempPos
end
--searchAttack 中得到当前大网格最近的建筑物
function World:getBigGridTarget()
    local x, y = self.startPoint[1], self.startPoint[2]
    local bigCx, bigCy = self:smallToBig(x, y)
    local bigData = self.bigGrid[self:getKey(bigCx, bigCy)]
    if bigData['nearObj'] ~= nil then
        return {bigData['nearX'], bigData['nearY']}
    end
    return nil
end

--士兵当前的位置坐标 solX solY
function World:searchAttack(range, fx, fy, solX, solY, param)
    if self.debug then
        print("start search Attack")
    end
    --local timeBegin = os.clock()
    self.searchType = "attack"

    --设定搜索次数    
    self.searchNum = self.searchNum + 1
    if self.searchNum >= self.maxSearchNum then
        self.searchYet = true
    end

    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    self.endPoint = nil
    --[[
    if self.tempBigTarget then
        local info = self.buildInfo[self.tempBigTarget]
        self.endPoint = {info[1]+info[3]/2, info[2]+info[3]/2}
    end
    --]]
    --根据大网格最近建筑物设定 攻击目标
    --self.endPoint = self:getTempTargetPos()
    self.endPoint = self:getBigGridTarget()

    
    local tempStart = self:adjustStartPoint()
    if self.debug then
        print("adjustStartPoint", simpleJson:encode(self.startPoint), simpleJson:encode(tempStart))
    end

    local bx, by = self.startPoint[1]+fx, self.startPoint[2]+fy
    --当前位置根据 startPoint 和 偏移位置来计算
    solX = bx
    solY = by


    local parent, lastPoint, target

	--self.typeNum[btype] = (self.typeNum[btype] or 0) + 1
    --print("typeNum", (self.typeNum[self.searchTargetType] or 0))
    if self.searchTargetType ~= nil and self.typeNum[self.searchTargetType] ~= nil and self.typeNum[self.searchTargetType] > 0 then
        parent, lastPoint, target = self:findCertainTypeBuilding(range)
    else
        parent, lastPoint, target = self:findInitPath(range)
    end

    if self.debug then
        print("findInitPath", parent, target)
        print(target.buildMould.buildData.bid)
        print(simpleJson:encode(lastPoint))
        print("len closed", #self.closedList)
    end
    --包含从start到end的所有点
    local path = self:getPath(parent)
    if self.debug then
        print("getPath")
        print(simpleJson:encode(path))
    end

    local temp, findWall, wallX, wallY, wallObj = self:checkWall(path)
    --使用affine 坐标计算位置差值
    --攻击范围是一个椭圆
    if findWall then
        temp, target, lastPoint = self:findWallPath(solX, solY, wallX, wallY, wallObj, temp, range)
    end

    --反向路径 temp 判定是否有
    self.endPoint = nil
    self.searchType = nil

    if self.debug then
        print("world searchAttack target ")
        print(simpleJson:encode(temp))
        print(target)
        print(simpleJson:encode(lastPoint))
    end
    --路径 攻击目标 路径最后的位置点
    --local costTime = os.clock()-timeBegin


    if self.debug then
        if param == nil then
            --self:showGrid()
        end

        print("end search Attack")
    end


    --如果士兵和建筑物重叠 则路径为nil 
    --如果士兵目标没有
    if temp == nil or #temp <= 1 then
        temp = {}
        lastPoint = nil
    end
    
    if lastPoint ~= nil then
        lastPoint = {lastPoint[1]+math.random()*0.6-0.3, lastPoint[2]+math.random()*0.6-0.3}
    end
    return temp, target, lastPoint
end

function World:printCell()
    print("cur Board")
    local d
    for j = 0, self.cellNum+1, 1 do 
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['state'] == nil then
                d['state'] = 'None'
            end
            io.write(string.format("%4s ", d['state'])) 
        end
        print() 
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['gScore'] == nil then
                d['gScore'] = 0
            end
            io.write(string.format("%4d ", d['gScore'])) 
        end
        print()
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['hScore'] == nil then
                d['hScore'] = 0
            end
            io.write(string.format("%4d ", d['hScore'])) 
        end
        print()

        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['fScore'] == nil then
                d['fScore'] = 0
            end
            io.write(string.format("%4d ", d['fScore'])) 
        end
        print()

        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['parent'] == nil then
                io.write(string.format("%4s ", "Pare"))
            else
                io.write(string.format("%d,%d ", self:getXY(d['parent']))) 
            end
        end
        print()
    end
end
--不用清理世界
function World:clearWorld()
    if true then
        return
    end

	local cell
    if self.startPoint ~= nil then
    	cell = self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    if self.endPoint ~= nil then
        cell = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    --[[
    for k, v in ipairs(self.walls) do
        cell = self.cells[self:getKey(v[1], v[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    ]]--

    for k, v in ipairs(self.path) do
        cell = self.cells[self:getKey(v[1], v[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    self.startPoint = nil
    self.endPoint = nil
    --self.walls = {}
    self.path = {}
end

--各个大网格中心遍历生成最近敌人路径
--range = 1
--function World:searchAttack(range, fx, fy, solX, solY)
--进入战斗场景 初始化完建筑之后生成 路径信息
function World:initPath()
    if true then
        return
    end
    local range = 0.5
    local fx = 0
    local fy = 0
    local totalX = math.ceil(self.cellNum/self.bigCoff)
    local totalY = math.ceil(self.cellNum/self.bigCoff)
    for i=1, totalX, 1 do
        for j=1, totalY, 1 do
            local bx, by = self:getBigCenter(i, j) 
            self:putStart(math.floor(bx), math.floor(by))
            self:searchAttack(range, fx, fy, nil, nil, "init")
        end
    end
    --调试路径
    --self:showGrid("initPath")
end


--[[Test Case
MAP = {
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 1, 0, 0, 0,  
0, 2, 0, 1, 0, 3, 0,  
0, 0, 0, 1, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
}

world = World.new(7)
world:initCell()
for k, v in ipairs(MAP) do
    if v == 1 then
        world:putWall((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    elseif v == 2 then
        world:putStart((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    elseif v == 3 then
        world:putEnd((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    end
end
world:search()
world:printCell()
]]--

