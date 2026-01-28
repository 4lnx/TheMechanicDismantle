---@diagnostic disable: duplicate-set-field, undefined-field, param-type-mismatch, undefined-global
---
--- Created by 4Lnx
---

require "TimedActions/ISBaseTimedAction"

TheMechanicDismantleVehicle = ISBaseTimedAction:derive("TheMechanicDismantleVehicle");

function TheMechanicDismantleVehicle:getPlayerPerks()
    local perks       = {}

    local metalLevel  = self.character:getPerkLevel(Perks.MetalWelding)
    local mechLevel   = self.character:getPerkLevel(Perks.Mechanics)
    perks.sumSkills   = metalLevel + mechLevel

    perks.blacksmith  = self.character:hasTrait(CharacterTrait.BLACKSMITH)
    perks.blacksmith2 = self.character:hasTrait(CharacterTrait.BLACKSMITH2)
    perks.crafty      = self.character:hasTrait(CharacterTrait.CRAFTY)

    return perks
end

function TheMechanicDismantleVehicle:getDuration()
    -- verifica se esta ativo o instant time(debug)
    if self.character:isTimedActionInstant() then
        return 10;
    end

    local sumSkills = self:getPlayerPerks().sumSkills

    local duration = 2000 - (sumSkills * 70)

    return math.max(500, duration)
end

function TheMechanicDismantleVehicle:chanceAddItem(item)
    local perks = self:getPlayerPerks()

    local sandbox = SandboxVars.TheMechanic
    local baseChance = sandbox and sandbox.DismantleItemDropChance or 10

    local skillBonus = perks.sumSkills * 2

    local traitCount = 0
    if perks.blacksmith2 then traitCount = traitCount + 1 end
    if perks.blacksmith then traitCount = traitCount + 1 end
    if perks.crafty then traitCount = traitCount + 1 end
    local handyBonus = traitCount * 5

    local finalChance = baseChance + skillBonus + handyBonus

    finalChance = math.max(0, math.min(100, finalChance))

    if ZombRand(100) < finalChance then
        self.vehicle:getSquare():AddWorldInventoryItem(
            item,
            ZombRandFloat(0, 0.9),
            ZombRandFloat(0, 0.9),
            0
        )
        return true
    end

    return false
end

function TheMechanicDismantleVehicle:isValid()
    local player = self.character
    if not player then return false end

    -- Verificar se BlowTorch válido está equipado na mão primária
    local primaryItem = player:getPrimaryHandItem()
    if not primaryItem or primaryItem:getFullType() ~= "Base.BlowTorch" or primaryItem:getCurrentUses() < 10 then
        return false
    end

    return self.vehicle and not self.vehicle:isRemovedFromWorld()
end

function TheMechanicDismantleVehicle:update()
    self.character:faceThisObject(self.vehicle)
    self.item:setJobDelta(self:getJobDelta())
    self.item:setJobType("Dismantle Vehicle")

    if self.sound ~= 0 and not self.character:getEmitter():isPlaying(self.sound) then
        self.sound = self.character:playSound("BlowTorch")
    end

    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function TheMechanicDismantleVehicle:start()
    self.item = self.character:getPrimaryHandItem()
    self:setActionAnim("BlowTorch")
    self:setOverrideHandModels(self.item, nil)
    self.sound = self.character:playSound("BlowTorch")

    if self.sound ~= 0 then
        local radius = 20
        local volume = 30

        if self.character.getWeldingSoundMod then
            local mod = self.character:getWeldingSoundMod()
            radius = math.floor(radius * mod + 0.5)
            volume = math.floor(volume * mod + 0.5)
        end

        addSound(
            self.character,
            self.character:getX(),
            self.character:getY(),
            self.character:getZ(),
            radius,
            volume
        )
    end
end

function TheMechanicDismantleVehicle:stop()
    if self.item then
        self.item:setJobDelta(0)
    end

    if self.sound ~= 0 then
        self.character:getEmitter():stopSound(self.sound);
    end

    ISBaseTimedAction.stop(self);
end

function TheMechanicDismantleVehicle:perform()
    if self.sound and self.sound ~= 0 then
        self.character:getEmitter():stopSound(self.sound)
    end

    self.item:setJobDelta(0)

    ISBaseTimedAction.perform(self)
end

function TheMechanicDismantleVehicle:complete()
    if isClient() then
        sendClientCommand(
            self.character,
            "TheMechanic",
            "DismantleVehicle",
            { vehicleId = self.vehicle:getId() }
        )
    else
        TheMechanic.ServerDismantleVehicle(self.character, self.vehicle)
    end

    return true
end

function TheMechanicDismantleVehicle:new(character, vehicle)
    local o = ISBaseTimedAction.new(self, character)

    setmetatable(o, self)
    o.character  = character
    o.vehicle    = vehicle

    o.maxTime    = o:getDuration()

    o.stopOnWalk = true
    o.stopOnRun  = true

    return o
end
