--复用一下建筑VIEW,测试性能
ReuseNodeCache = class()

function ReuseNodeCache:ctor()
    self.cache = {}
end

function ReuseNodeCache:removeAndCache(key, node)
    node:retain()
    node:removeFromParentAndCleanup(false)
    local items = self.cache[key]
    if not items then
        items = {}
        self.cache[key] = items
    end
    table.insert(items, node)
end

function ReuseNodeCache:getReuseNode(key)
    local items = self.cache[key]
    if items and #items>0 then
        local node = table.remove(items)
        node:autorelease()
        return node
    end
end