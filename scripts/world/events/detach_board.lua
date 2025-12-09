local Trigger, super = Class(Event, "detach_board")

function Trigger:updateTrigger()
    if self.triggered then
        self:setFlag("triggered", true)
    end
end

function Trigger:detach(detach)
    if detach == nil then detach = true end
    if self.triggered == true then return end
    if self.once == true then
        self.triggered = true
    end

    if self.setflag then
        Game:setFlag(self.setflag, self.setflagvalue)
    end

    -- The actual detachment
    local world = Game.world
    local board = world.board
    if not board then return end
    local player = board.player or world.boardPlayer
    local followers = board.followers or world.boardFollowers
    local actors = {player}
    for _,f in ipairs(followers) do
        table.insert(actors, f)
    end

    if detach then
        if player.world ~= world then
            -- print("detached!")
            board.player = nil
            board.followers = nil
            for _,actor in ipairs(actors) do
                local screenx, screeny = actor:getScreenPos()
                board:removeChild(actor)
                actor.world = world
                actor.layer = world.map.object_layer
                actor.x = screenx
                actor.y = screeny
                world:addChild(actor)
            end
            world.boardPlayer = player
            world.boardFollowers = followers
        end
    else
        if player.world ~= board then
            -- print("attached!")
            board.player = player
            board.followers = followers
            for _,actor in ipairs(actors) do
                world:removeChild(actor)
                actor.world = board
                actor.layer = board.map.object_layer
                actor.x = self.x
                actor.y = self.y
                board:addChild(actor)
            end
            world.boardPlayer = nil
            world.boardFollowers = nil
        end
    end
end

function Trigger:init(data)
    super.init(self, data)

    local properties = data.properties or {}
    self.properties = properties or {}
    self.triggered = properties["triggered"] or false
    self.once = properties["once"] or false
    self.dtach = properties["detach"]
    self.setflag = properties["setflag"]
    self.setflagvalue = properties["setflagvalue"] or true

    self:setScale(1)
end

function Trigger:onCollide(plr, dt)
    if self.triggered == true then return end
    self:detach(self.dtach)
end

function Trigger:onAdd(parent)
    super.onAdd(self, parent)
    
    if self:getFlag("triggered") then
        self.triggered = true
    end
end

function Trigger:update()
    super.update(self)

end

function Trigger:draw()
    super.draw(self)
end

return Trigger