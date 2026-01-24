---@diagnostic disable: inject-field, param-type-mismatch, undefined-field, undefined-global
---
--- Created by 4Lnx
---

require "Vehicles/ISUI/ISVehicleMenu"
require "luautils"

TheMechanic = TheMechanic or {}
TheMechanic.Dismantle = {}

local function findBestBlowTorch(inv)
    if not inv then return nil end

    local best = nil
    local bestUses = 0

    local allItems = inv:getAllTypeRecurse("Base.BlowTorch")
    for i = 0, allItems:size() - 1 do
        local item = allItems:get(i)
        if item and item.getCurrentUses then
            local uses = item:getCurrentUses()
            if uses > bestUses then
                bestUses = uses
                best = item
            end
        end
    end

    return best
end

function TheMechanic.Dismantle.getVehicleHealthPercent(vehicle)
    if not vehicle then
        return 100
    end

    if vehicle:isBurntOrSmashed() then
        return 0
    end

    local partCount = vehicle:getPartCount()
    if not partCount or partCount == 0 then
        return 100
    end

    local totalCondition = 0

    for i = 0, partCount - 1 do
        local part = vehicle:getPartByIndex(i)
        local cond = 0
        if part then
            if part:isInventoryItemUninstalled() then
                cond = 0
            else
                cond = part:getCondition()
                if not cond or cond < 0 then
                    cond = 0
                end
            end
        end
        totalCondition = totalCondition + cond
    end

    local percent = totalCondition / partCount
    return percent
end

function TheMechanic.Dismantle.onDismantle(playerObj, vehicle)
    if not playerObj or not vehicle then return end

    if not luautils.walkAdj(playerObj, vehicle:getSquare()) then
        return
    end

    ISWorldObjectContextMenu.equip(
        playerObj,
        playerObj:getPrimaryHandItem(),
        function(item)
            if not item then return false end
            if item:getFullType() ~= "Base.BlowTorch" then return false end
            return item:getCurrentUses() >= 10
        end,
        true,
        false
    )

    local playerNum = playerObj:getPlayerNum()
    local wornItems = playerObj:getWornItems()
    local hasMaskEquipped = false

    if wornItems then
        for i = 0, wornItems:size() - 1 do
            local wi = wornItems:get(i)
            local item = wi and wi:getItem()
            if item and item:getFullType() == "Base.WeldingMask" then
                hasMaskEquipped = true
                break
            end
        end
    end

    if not hasMaskEquipped then
        local mask = playerObj:getInventory():getFirstTypeRecurse("Base.WeldingMask")
        if mask then
            ISInventoryPaneContextMenu.wearItem(mask, playerNum)
        end
    end

    ISTimedActionQueue.add(
        TheMechanicDismantleVehicle:new(playerObj, vehicle)
    )
end


function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle)
    local playerObj = getSpecificPlayer(player)
    if not playerObj or not vehicle then return end

    local option = context:addOption(
        getText("ContextMenu_TheMechanic_Dismantle"),
        playerObj,
        TheMechanic.Dismantle.onDismantle,
        vehicle
    )

    local tooltip = ISToolTip:new()
    tooltip:initialise()
    tooltip:setVisible(false)
    tooltip:setName(getText("ContextMenu_Tooltip_Required_Items"))
    tooltip.description = ""
    option.toolTip = tooltip

    local inv = playerObj:getInventory()
    local notAvailable = false

    local torch = findBestBlowTorch(inv)
    if torch then
        local uses = torch:getCurrentUses()
        if uses >= 10 then
            tooltip.description = tooltip.description ..
                "<RGB:0,1,0>" .. getText("ContextMenu_Tooltip_Full_BlowTorch") .. "<LINE>"
        else
            tooltip.description = tooltip.description ..
                "<RGB:1,0,0>" .. getText("ContextMenu_Tooltip_Require_Full_BlowTorch") .. "<LINE>"
            notAvailable = true
        end
    else
        tooltip.description = tooltip.description ..
            "<RGB:1,0,0>" .. getText("ContextMenu_Tooltip_BlowTorch_Missing") .. "<LINE>"
        notAvailable = true
    end

    local mask = inv:getFirstTypeRecurse("Base.WeldingMask")
    if mask then
        tooltip.description = tooltip.description ..
            "<RGB:0,1,0>" .. getText("ContextMenu_Tooltip_Welding_Mask") .. "<LINE>"
    else
        tooltip.description = tooltip.description ..
            "<RGB:1,0,0>" .. getText("ContextMenu_Tooltip_Welding_Mask") .. "<LINE>"
        notAvailable = true
    end

    local healthPercent = TheMechanic.Dismantle.getVehicleHealthPercent(vehicle)

    local sandbox = SandboxVars.TheMechanic
    local threshold = sandbox and sandbox.DismantleHealthThreshold or 20.0
    if healthPercent > threshold then
        tooltip.description = tooltip.description ..
            "<RGB:1,0,0>" .. getText("ContextMenu_Tooltip_Vehicle_Low_Condition") .. "<LINE>"
        notAvailable = true
    end

    if notAvailable then
        option.notAvailable = true
    end
end