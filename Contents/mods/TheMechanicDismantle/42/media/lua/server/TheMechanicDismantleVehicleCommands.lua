---@diagnostic disable: undefined-global, param-type-mismatch
---
--- The Mechanic - Server Logic
--- Author: 4Lnx
---

TheMechanic = TheMechanic or {}


local function getPlayerPerks(player)
    local perks       = {}

    local metal       = player:getPerkLevel(Perks.MetalWelding)
    local mech        = player:getPerkLevel(Perks.Mechanics)

    perks.sumSkills   = metal + mech

    perks.blacksmith  = player:hasTrait(CharacterTrait.BLACKSMITH)
    perks.blacksmith2 = player:hasTrait(CharacterTrait.BLACKSMITH2)
    perks.crafty      = player:hasTrait(CharacterTrait.CRAFTY)

    return perks
end


local function chanceAddItem(player, vehicle, itemType)
    if not player or not vehicle then return end

    local perks      = getPlayerPerks(player)
    local sandbox    = SandboxVars.TheMechanic

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
        vehicle:getSquare():AddWorldInventoryItem(
            itemType,
            ZombRandFloat(0, 0.9),
            ZombRandFloat(0, 0.9),
            0
        )
    end
end


function TheMechanic.ServerDismantleVehicle(player, vehicle)
    if not player or not vehicle then return end
    if vehicle:isRemovedFromWorld() then return end

    vehicle:permanentlyRemove()

    local lootTable = {
        "MetalBar", "MetalBar",
        "ElectricWire", "Wire",
        "MetalPipe", "MetalPipe",
        "ElectronicsScrap", "SheetMetal",
        "SheetMetal", "SheetMetal",
        "SmallSheetMetal", "SmallSheetMetal", "SmallSheetMetal",
        "ScrapMetal", "ScrapMetal", "ScrapMetal",
        "Screws", "Screws",
        "LeatherStripsDirty",
        "RippedSheetsDirty",
        "LightBulb",
        "Amplifier",
        "EngineParts",
        "UnusableMetal",
        "CopperScrap",
        "AluminumScrap", "AluminumScrap",
        "SteelScrap", "SteelScrap", "SteelScrap",
        "IronScrap",
        "IronBand",
        "IronBandSmall",
        "SteelBar",
        "SteelBarHalf",
        "SteelBarQuarter",
        "NutsBolts", "NutsBolts", "NutsBolts"
    }

    for _, item in ipairs(lootTable) do
        chanceAddItem(player, vehicle, item)
    end

    local sandbox = SandboxVars.TheMechanic
    local xp = sandbox and sandbox.DismantleXpReward * 4 or 10.0

    local xpSys = player:getXp()
    if xpSys then
        xpSys:AddXP(Perks.MetalWelding, xp, true, true, true, true)
    end

    local torch = player:getPrimaryHandItem()
    if torch
        and torch:getFullType() == "Base.BlowTorch"
        and torch:getCurrentUses() >= 10
    then
        for i = 1, 10 do
            torch:UseAndSync()
        end
    end


    local perks = getPlayerPerks(player)
    local sumSkills = perks.sumSkills

    local damageChance = 40 - (sumSkills - 2) * (35 / 18)

    damageChance = math.max(5, math.min(40, damageChance))

    if ZombRand(100) < damageChance then
        local wornItems = player:getWornItems()
        if wornItems then
            for i = 0, wornItems:size() - 1 do
                local wi = wornItems:get(i)
                local item = wi and wi:getItem()
                if item and item:getFullType() == "Base.WeldingMask" then
                    local currentCondition = item:getCondition()
                    if currentCondition > 0 then
                        item:setCondition(currentCondition - 1)
                        item:syncItemFields()
                    end
                    break
                end
            end
        end
    end

end


function TheMechanic.onClientCommand(module, command, player, args)
    if module ~= "TheMechanic" then return end
    if not player or not args then return end

    if command == "DismantleVehicle" then
        local vehicle = getVehicleById(args.vehicleId)
        if not vehicle then return end

        TheMechanic.ServerDismantleVehicle(player, vehicle)
    end
end

Events.OnClientCommand.Add(TheMechanic.onClientCommand)
