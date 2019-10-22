Set = {}
Set.__index = Set

function Set.New()
    local o = {}
    setmetatable(o,Set)
    o.tab = {}
    return o
end

function Set:Insert(val)
    if self:Contain(val) then
        return
    end
    self.tab[val] = true
end

function Set:Remove(val)
    self.tab[val] = nil
end

function Set:Contain(val)
    return self.tab[val] and true or false
end