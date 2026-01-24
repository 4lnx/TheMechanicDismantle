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
    if perks.blacksmith  then traitCount = traitCount + 1 end
    if perks.crafty      then traitCount = traitCount + 1 end
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
    -- Para som
    if self.sound and self.sound ~= 0 then
        self.character:getEmitter():stopSound(self.sound)
    end

    local sandbox = SandboxVars.TheMechanic
    local totalXp = sandbox and sandbox.DismantleXpReward or 10

    self:chanceAddItem("MetalBar")
    self:chanceAddItem("MetalBar")
    self:chanceAddItem("ElectricWire")
    self:chanceAddItem("Wire")
    self:chanceAddItem("MetalPipe")
    self:chanceAddItem("MetalPipe")
    self:chanceAddItem("ElectronicsScrap")
    self:chanceAddItem("SheetMetal")
    self:chanceAddItem("SheetMetal")
    self:chanceAddItem("SheetMetal")
    self:chanceAddItem("SmallSheetMetal")
    self:chanceAddItem("SmallSheetMetal")
    self:chanceAddItem("SmallSheetMetal")
    self:chanceAddItem("ScrapMetal")
    self:chanceAddItem("ScrapMetal")
    self:chanceAddItem("ScrapMetal")
    self:chanceAddItem("Screws")
    self:chanceAddItem("Screws")
    self:chanceAddItem("ElectronicsScrap")
    self:chanceAddItem("LeatherStripsDirty")
    self:chanceAddItem("RippedSheetsDirty")
    self:chanceAddItem("LightBulb")
    self:chanceAddItem("Amplifier")
    self:chanceAddItem("EngineParts")
    self:chanceAddItem("UnusableMetal")

    -- Build 42
    self:chanceAddItem("CopperScrap")
    self:chanceAddItem("AluminumScrap")
    self:chanceAddItem("AluminumScrap")
    self:chanceAddItem("SteelScrap")
    self:chanceAddItem("SteelScrap")
    self:chanceAddItem("SteelScrap")
    self:chanceAddItem("IronScrap")
    self:chanceAddItem("IronBand")
    self:chanceAddItem("IronBandSmall")
    self:chanceAddItem("SteelBar")
    self:chanceAddItem("SteelBarHalf")
    self:chanceAddItem("SteelBarQuarter")
    self:chanceAddItem("NutsBolts")
    self:chanceAddItem("NutsBolts")
    self:chanceAddItem("NutsBolts")

    for i = 1, 10 do
        self.item:Use()
    end

    local sumSkills = self:getPlayerPerks().sumSkills
    local damageChance = 40 - (sumSkills - 2) * (35 / 18)
    damageChance = math.max(5, math.min(40, damageChance))
    if ZombRand(100) < damageChance then
        local wornItems = self.character:getWornItems()
        if wornItems then
            for i = 0, wornItems:size() - 1 do
                local wi = wornItems:get(i)
                local item = wi and wi:getItem()
                if item and item:getFullType() == "Base.WeldingMask" then
                    local currentCondition = item:getCondition()
                    if currentCondition > 0 then
                        item:setCondition(currentCondition - 1)
                    end
                    break
                end
            end
        end
    end

    sendAddXp(self.character, Perks.MetalWelding, totalXp, true)

    if isClient() then
        sendClientCommand(
            self.character,
            "vehicle",
            "remove",
            { vehicle = self.vehicle:getId() }
        )
    else
        self.vehicle:permanentlyRemove()
    end

    self.item:setJobDelta(0);

    ISBaseTimedAction.perform(self)
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