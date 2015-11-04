-- Unteleporter
-- Automatically swaps back to normal gear after using teleportation items.

local teleportFrame = CreateFrame("FRAME", "UnteleporterFrame");
--teleportFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

-- Teleportation items taken from 
-- http://www.wowhead.com/item=65360/cloak-of-coordination#comments:id=1478188
local teleportationItems = {
		--trinkets
		103678, --timeless isle trinket

		--neck
		32757,	--black temple neck

		--tabards
		63379,	--tol barad ally
		63378,	--tol barad horde
		46874,	--argent tournament 

		--boots
		50287, --booty bay

		--Cloaks
		63353, --green cloak horde
		63352, --green cloak ally
		63206, --rare cloak ally
		63207, --rare cloak horde
		65274, --epic cloak ally
		65360, --epic cloak horde

		--Rings
		95051, --brawler ring ally
		95050, --brawler ring horde
		40585, --dalaran ring  
		40586, --dalaran ring  
		44934, --dalaran ring  
		44935, --dalaran ring 
		45688, --dalaran ring 
		45689, --dalaran ring 
		45690, --dalaran ring 
		45691, --dalaran ring 
		48954, --dalaran ring 
		48955, --dalaran ring 
		48956, --dalaran ring 
		48957, --dalaran ring 
		51557, --dalaran ring 
		51558, --dalaran ring 
		51559, --dalaran ring 
		51560, --dalaran ring  
}
-- all gear slots that can contain a teleportation item.
local gearSlots = {
	"NeckSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"BackSlot"
}
-- table containing the players gear.
-- key 	 = inventoryID.
-- value = itemID.
local currentGear = {}

-- prints a message to player. 
-- @param message			-	string, the message to display.
-- @param isWarning			-	boolean, treat message as a warning message or normal message.
-- @param displayWarnings	-	boolean, telling function to display messages or not.
local function informPlayer(message, isWarning, displayMessage)
	if not displayMessage then return end
	isWarning = isWarning or false
	textColor = isWarning and "|cffff0000"	--red in 100% alpha
						  or "|cffffffff"	--white  100% alpha
	print(textColor .. message)
end

-- adds a given item to the "currentGear"-table by given ID.
-- @param inventoryID	-	the inventoryID to used by the given item.
-- @param itemID 		-	the itemID to add to the table.
local function addEquippedItem(inventoryID, itemID)
	currentGear[inventoryID] = itemID
end

-- checks if given item is a teleportation item by comparing it to the teleporation-table.
-- @param itemID 		-	the item to check for.
local function isItemTeleportationItem(itemID)
	for key, teleportItemID in pairs(teleportationItems) do
		if itemID == teleportItemID then
			return true
		end
	end
	return false
end

-- saves the players current gear in the "currentGear"-table.
-- condition: item may not be a teleportation item.
local function saveCurrentGear()
	for key, inventoryName in pairs(gearSlots) do
		local inventoryID = GetInventorySlotInfo(inventoryName)
		local equippedItemID = GetInventoryItemID("player", inventoryID)

		if equippedItemID ~= nil and not isItemTeleportationItem(equippedItemID) then
			addEquippedItem(inventoryID, equippedItemID)
		end
	end	
end

-- restores (equips) the players last-used gear pieces.
-- also warns the user if slot is empty or a teleportation item is equipped.
-- @param displayWarnings	-	boolean, telling function to display messages or not.
local function restoreGear(displayWarnings)
	if InCombatLockdown() then return end
	for key, inventoryName in pairs(gearSlots) do
		local inventoryID = GetInventorySlotInfo(inventoryName)
		local equippedItemID = GetInventoryItemID("player", inventoryID)

		if equippedItemID ~= nil then 
			local isTeleItem = isItemTeleportationItem(equippedItemID)
			if isTeleItem and currentGear[inventoryID] ~= nil then
				EquipItemByName(currentGear[inventoryID], inventoryID)
			elseif isTeleItem and currentGear[inventoryID] == nil then
				informPlayer(GetInventoryItemLink("player", inventoryID) .. " is equipped.", true, true)
			end
		else
			informPlayer("Nothing equipped in " .. inventoryName .. "!", true, true)
		end
	end
end

-- handles all registered events and call the appropriate method.
local function eventHandler(self, event, ...)
	if event == "ZONE_CHANGED" then restoreGear()
	elseif event == "ZONE_CHANGED_INDOORS" then restoreGear(true)
	elseif event == "ZONE_CHANGED_INDOORS" then restoreGear(true)
	elseif event == "ZONE_CHANGED_NEW_AREA" then restoreGear(true)
	elseif event == "PLAYER_ENTERING_WORLD" then saveCurrentGear()
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then saveCurrentGear()
	end
end

teleportFrame:RegisterEvent("ZONE_CHANGED")
teleportFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
teleportFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

teleportFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
teleportFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

teleportFrame:SetScript("OnEvent", eventHandler)