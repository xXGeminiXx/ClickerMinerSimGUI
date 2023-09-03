-- GeminisClickerMinerSim Version 11.5 --
-- Created by xXGeminiXx --
local Player = game.Players.LocalPlayer 
local prop = Player:FindFirstChild("FriendAmount")
local Clip = false -- Or true, based on the default state you want
while not Player.Character do wait() end
while not Player.PlayerGui do wait() end
local Players = game:GetService("Players")  -- Retrieve the Players service
local yPos = 0.8 -- Or any other default value you want
local superSpeedEnabled = false 
local normalSpeed = Player.Character.Humanoid.WalkSpeed 
local flyJumpActive = false -- flag to check if flyjump is on or off 
local lastTeleportedBlock = nil 
local teleportOffset = Vector3.new(0, 6, 0)  -- Adjust the vertical offset as needed 
local flyjump 
local previousPosition = Vector3.new(0,0,0)  -- Initial position, it will be updated in the function
local deltaThreshold = 0.5  -- Threshold for considering the player as having moved
local isGeminiModeOn = false 
local isAutoTeleporting = false 
local autoTeleportConnection = nil 
		local teleportCooldown = 1.5  -- Adjusted teleportation logic with server-side configurations
		local blockMinedCheckCooldown = 3  -- Reduced cooldown for better mining efficiency
local consecutiveFailures = 0 -- -- Counter for tracking consecutive failures. Stopped the spam from snipemode debugging.
local allDescendants = game.Workspace:GetDescendants() -- Cache the descendants once
local mainFrame = Instance.new("Frame") 
local titleLabel = Instance.new("TextLabel") 
local teleportBtn = Instance.new("TextButton") 
local autoTeleportToggleBtn = Instance.new("TextButton") 
local destroyGuiBtn = Instance.new("TextButton") 
local flyJumpBtn = Instance.new("TextButton") 
local superSpeedBtn = Instance.new("TextButton") 
local friendAmountBtn = Instance.new("TextButton") 
local teleportDoorBtn = Instance.new("TextButton")
local geminiModeBtn = Instance.new("TextButton") 
--local pickaxeModule = require(game:GetService("ReplicatedStorage").Modules.pickaxesModule)
local allBlocks = game.Workspace:GetChildren()
local blocksList = {}  -- Table to store all the blocks
for _, block in ipairs(allBlocks) do
    if block:IsA("Part") or block:IsA("MeshPart") then  -- Assuming blocks are of type Part or MeshPart
        table.insert(blocksList, block)  -- Add the block to the blocksList
    end
end
local geminiModeActive = false -- flag to check if Gemini Mode is on or off 
local stuckThreshold = 0.5 -- Change based on how sensitive you want the detection to be
local checkInterval = 3 -- Duration in seconds between checks
local isIronTeleporting = false
local isCopperTeleporting = false
local originalKick = kick
local originalTeleport = game.TeleportService.Teleport
local isCpsToggling = false  -- Debounce variable
local cpsConnection
local cps = 60  -- Initialize cps with a default value
local isAutoMining = true  -- Flag to indicate if auto mining is active
local originalCollideStates = {}
local namesList = {
    "Ad_AdBoard",
	"black", "cake", "candy", "Meshes/Donut (1)", 
    "Cliff09", "Cliff10", "Cliff11", "Cliff12",
    "dazhiwu", "ding", "door_light",
    "Entrance", "fire",
    "Flower", "green", "Grass", "hill", "grass001", "grass", "grasss",
    "hillda", "jshitou", "shanh", 
	"king", "lz01", "lz02", "houba", "pingzi01", 
    "kongdong", "kuangche", "Icing", "shetou", "suizhuan",
    "light004", "light2", "louti",
    "MeshPart", "mu", "Minecart",
	"naiyouxia",
    "peng", "pingzi02", 
    "quan", "qiaokeli",
    "Rock", "Road2", "Road1",
    "shenzi", "sanjiao", 
    "shugan", "shuzhi", "shuijing", "snow", "shideng", "sha01", "sweet", "weilan",
    "stree", "stone", "stoen", "small_light", "stones", "Stones",
	"tree", "xiaotree", "TopL", "totally not a stolen mesh",
    --"UGC-13", "xiaodi", "y", "Union", "ice"
    "Wall", "wall"
}
-- Global variables to track the notifications
local currentYPosition = 0.8  -- Starting from 80% of the screen height.
local activeNotifications = {}
local MAX_ACTIVE_NOTIFICATIONS = 10
local MAX_NOTIFICATION_QUEUE = 100
local notificationQueue = {}

-- Ensure the game is fully loaded before proceeding
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- == FUNCTIONS == -- 

local function processNotificationQueue()
    while #activeNotifications < MAX_ACTIVE_NOTIFICATIONS and #notificationQueue > 0 do
        local notification = table.remove(notificationQueue, 1)
        local notifyObj = notifyUser(notification.title, notification.text, notification.duration, notification.verticalOffset)
        table.insert(activeNotifications, notifyObj)
    end
end

local function notifyUser(title, text, duration)
    if #activeNotifications >= MAX_ACTIVE_NOTIFICATIONS then
        return
    end

    local notify = Instance.new("ScreenGui")
    local main = Instance.new("Frame")  -- Define the main GUI element
    local titleBar = Instance.new("TextLabel")
    local body = Instance.new("TextLabel")

    -- Parent the elements
    main.Parent = notify
    titleBar.Parent = main
    body.Parent = main
	notify.Parent = Player:WaitForChild("PlayerGui")

    -- Adjust properties of the main frame
    main.Name = "Main"
    main.BackgroundColor3 = Color3.new(0, 0, 0)
    main.BackgroundTransparency = 0.5
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.8, 0, 0.8, 0)  -- For now, using a static position
    main.Size = UDim2.new(0.2, 0, 0.1, 0)

    -- Adjust properties of the title bar
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = Color3.new(0, 0.2, 0.6)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0.2, 0)
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.Text = title
    titleBar.TextColor3 = Color3.new(1, 1, 1)
    titleBar.TextScaled = true

    -- Adjust properties of the body
    body.Name = "Body"
    body.BackgroundColor3 = Color3.new(0, 0, 0)
    body.BackgroundTransparency = 0.5
    body.BorderSizePixel = 0
	body.Position = UDim2.new(0, 0, 0.2, 0)  -- Positioned just below the titleBar
	body.Size = UDim2.new(1, 0, 0.8, 0)  -- Adjusted size to take up the remaining space

    body.Font = Enum.Font.SourceSans
    body.Text = text
    body.TextColor3 = Color3.new(1, 1, 1)
    body.TextScaled = true
    body.TextWrapped = true

    -- Add the notification to the activeNotifications table
    table.insert(activeNotifications, notify)

    -- Display the notification for the given duration
    wait(duration or 5)
    for index, activeNotify in ipairs(activeNotifications) do
        if activeNotify == notify then
            table.remove(activeNotifications, index)
            activeNotify:Destroy()
            break
        end
    end

    -- If a function named processNotificationQueue exists, call it
    if processNotificationQueue then
        processNotificationQueue()
    end
end


local function customNotifyUser(title, text, duration, verticalOffset)
    if #activeNotifications < MAX_ACTIVE_NOTIFICATIONS then
        local notifyObj = notifyUser(title, text, duration, verticalOffset)
        table.insert(activeNotifications, notifyObj)
    else
        table.insert(notificationQueue, {title=title, text=text, duration=duration, verticalOffset=verticalOffset})
        if #notificationQueue > MAX_NOTIFICATION_QUEUE then
            table.remove(notificationQueue, 1)  -- Remove the oldest notification
        end
    end
end

local function removeObjectsByName(namesToRemove, startingPoint)
    local startingPoint = startingPoint or game.Workspace 
    local descendants = startingPoint:GetDescendants()
    for _, name in ipairs(namesToRemove) do
        local removedCount = 0
        for _, object in ipairs(descendants) do
            if string.match(object.Name, name) then
                object:Destroy()
                removedCount = removedCount + 1
            end
        end
        if removedCount > 0 then
            --customNotifyUser("Gemini Mode", "Removed " .. removedCount .. " instances of '" .. name .. "'.", 2)
        else
           -- customNotifyUser("Gemini Mode", "No instances of '" .. name .. "' found to remove.", 2)
        end
        --wait(0.2)  -- Reducing wait time to speed up the function
    end
end
local function canTeleportAgain() 
    return tick() - lastTeleportTime >= 2 
end 
local function isStuck(current, previous)
    return (current - previous).magnitude < deltaThreshold
end
local searchRadius = 2 -- Define how far you want to search for safe blocks
local function getSafeNearbyBlock(currentPos)
    -- Define a bounding box around the current position based on searchRadius
    local region = Region3.new(
        currentPos - Vector3.new(searchRadius, searchRadius, searchRadius),
        currentPos + Vector3.new(searchRadius, searchRadius, searchRadius)
    )
    local partsInRadius = game.Workspace:FindPartsInRegion3(region, nil, math.huge)

    for _, part in ipairs(partsInRadius) do
        local _, _, isTopOpen, _ = checkSurroundings(part)
        if isTopOpen and isEmptyConsideringDepth(part.Position + Vector3.new(0, part.Size.Y, 0)) then
            -- Return the top position of the block as the safe position
            return part.Position + Vector3.new(0, part.Size.Y/2 + 1, 0) -- adding half the size + 1 to get the top position
        end
    end
    return nil
end

local function checkIfStuck()
    local previousPosition = Player.Character.HumanoidRootPart.Position
    while wait(checkInterval) do
        local currentPosition = Player.Character.HumanoidRootPart.Position
        if isStuck(currentPosition, previousPosition) then
            local safePosition = getSafeNearbyBlock(currentPosition)
            if safePosition then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
            else
                notifyUser("Stuck Check", "Couldn't find a safe position!", 3)
            end
        end
        previousPosition = currentPosition
    end
end
function enableAllGuiButtons()
    for _, element in pairs(mainFrame:GetChildren()) do
        if element:IsA("TextButton") then
            element.Active = true
            element.Selectable = true
        end
    end
end
local teleportOffset = Vector3.new(0, 6, 0)  -- Example offset, adjust as needed
local function getSafeTeleportPosition(targetPosition)
    if not targetPosition or typeof(targetPosition) ~= "Vector3" then
        notifyUser("Error", "Invalid target position provided for teleportation.", 3)
        return nil
    end
    local potentialTeleportPosition = targetPosition + teleportOffset
    -- Check if the block at potentialTeleportPosition is empty
    if isEmpty(potentialTeleportPosition) then
        return potentialTeleportPosition
    else
        local alternativePosition = findAlternativeOpenBlockAbovePlayer()
        if not alternativePosition then
            notifyUser("Error", "Couldn't find an alternative safe position.", 3)
        end
        return alternativePosition
    end
end
-- Function to check if a block has been mined
local function checkBlockMined(block)
    -- If the block doesn't exist or doesn't have a parent (indicating it's been removed from the game.Workspace or its original parent)
    if not block or not block.Parent then
        return true  -- The block is considered mined
    end
    return false  -- The block is not mined
end
-- Returns the nearest iron to the Player with an open space above 
local function findNearestIron() 
    local closestDistance = 50
    local closestIron = nil 
    -- Ensuring Player and necessary parts exist
    if not (Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
        notifyUser("Error", "Player or necessary parts missing.", 3)
        return nil
    end
    local playerPosition = Player.Character.HumanoidRootPart.Position
    for _, obj in pairs(allDescendants) do
        if obj:IsA("BasePart") and string.match(obj.Name, "Iron%d+_%d+") then 
            local distance = (obj.Position - playerPosition).Magnitude
            if distance < closestDistance 
               and isEmpty(obj.Position + Vector3.new(0, obj.Size.Y, 0))
               and not checkBlockMined(obj) then 
                closestDistance = distance
                closestIron = obj
            end 
        end 
    end 
    if not closestIron then
        notifyUser("Error", "No accessible iron found nearby.", 3)
    end
    return closestIron 
end
local function getAutoTargets()
    local searchRadius = 10  -- Define an appropriate radius based on the game mechanics
    local currentPos = Player.Character.HumanoidRootPart.Position
    local partsInRadius = game.Workspace:FindPartsInRegion3(
        currentPos - Vector3.new(searchRadius, searchRadius, searchRadius),
        currentPos + Vector3.new(searchRadius, searchRadius, searchRadius),
        nil,
        math.huge
    )
    local targetBlocks = {}
    for _, part in ipairs(partsInRadius) do
        if (string.match(part.Name, "^Mystery%d+_%d+$") or string.match(part.Name, "^M%d+_%d+$")) and part.Name ~= "Unminable" then
            table.insert(targetBlocks, part)
        end
    end
    return targetBlocks
end
local function isEmptyConsideringDepth(position)
    local rayLength = 1
    local ray = Ray.new(position, Vector3.new(0, -1, 0) * rayLength)  -- Pointing the ray downwards
    local block, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character})
    if block and block:IsA('BasePart') then
        rayLength = block.Size.Y + Player.Character.HumanoidRootPart.Size.Y + 1
    end
    return not block
end

-- Returns the nearest copper to the Player with an open space above 
local function findNearestCopper() 
    local closestDistance = 50
    local closestCopper = nil 
    local playerPosition = Player.Character.HumanoidRootPart.Position
    
    local potentialTargets = getAutoTargets()
    
    for _, obj in pairs(potentialTargets) do
        if obj:IsA("BasePart") and string.match(obj.Name, "Copper%d+_%d+") then 
            local distance = (obj.Position - playerPosition).Magnitude
            if distance < closestDistance 
               and isEmptyConsideringDepth(obj.Position + Vector3.new(0, obj.Size.Y, 0))
               and not checkBlockMined(obj) then 
                closestDistance = distance
                closestCopper = obj
            end 
        end 
    end 
    if not closestCopper then
        notifyUser("Error", "No accessible copper found nearby.", 3)
    end
    return closestCopper 
end


local function findNearestGem() 
    local closestDistance = 50
    local closestGem = nil 
    local playerPosition = Player.Character.HumanoidRootPart.Position
    
    local potentialTargets = getAutoTargets()
    
    for _, obj in pairs(potentialTargets) do
        if obj and obj:IsA("BasePart") and string.match(obj.Name, "Gem%d+_") then
            local distance = (obj.Position - playerPosition).Magnitude
            if distance < closestDistance 
               and isEmptyConsideringDepth(obj.Position + Vector3.new(0, obj.Size.Y, 0))
               and not checkBlockMined(obj) then 
                closestDistance = distance
                closestGem = obj
            end 
        end 
    end 
    if not closestGem then
        notifyUser("Error", "No accessible gem found nearby.", 3)
    end
    return closestGem 
end

-- Function to find the nearest door and teleport the player to it
function teleportToNearestDoor()
    local doors = game.Workspace:FindChildren(function(item)
        return item.Name == "TimeTrialDoor_1" or item.Name == "TimeTrialDoor_2" or item.Name == "TimeTrialDoor_3"
    end)
    local closestDoor = nil
    local shortestDistance = math.huge
    for _, door in ipairs(doors) do
        local distance = (Player.Character.HumanoidRootPart.Position - door.Position).Magnitude
        if distance < shortestDistance then
            closestDoor = door
            shortestDistance = distance
        end
    end
    if closestDoor then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(closestDoor.Position)
    end
end
local function findNearestMystery() 
    local closestDistance = math.huge
    local closestMystery = nil 
    if not (Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
        notifyUser("Error", "Player or necessary parts missing.", 3)
        return nil
    end
    local playerPosition = Player.Character.HumanoidRootPart.Position
    
    local potentialTargets = getAutoTargets()  -- Use the new getAutoTargets function
    
    for _, obj in pairs(potentialTargets) do
        if obj:IsA("BasePart") and (string.match(obj.Name, "^Mystery%d+_%d+$") or string.match(obj.Name, "^M%d+_%d+$")) then 
            local distance = (obj.Position - playerPosition).Magnitude
            if distance < closestDistance 
               and isEmptyConsideringDepth(obj.Position + Vector3.new(0, obj.Size.Y, 0))
               and not checkBlockMined(obj) 
               and obj.Name ~= "Unminable" then
                closestDistance = distance
                closestMystery = obj
            end 
        end 
    end 
    if not closestMystery then
        notifyUser("Error", "No accessible mystery block found nearby.", 3)
    end
    return closestMystery 
end

local function findNearestChest() 
    local closestDistance = math.huge
    local closestChest = nil 
    local playerPosition = Player.Character.HumanoidRootPart.Position
    
    local potentialTargets = getAutoTargets()
    
    for _, obj in pairs(potentialTargets) do
        if obj:IsA("BasePart") and string.match(obj.Name, "Chest%d+_%d+") then 
            local distance = (obj.Position - playerPosition).Magnitude
            if distance < closestDistance 
               and isEmptyConsideringDepth(obj.Position + Vector3.new(0, obj.Size.Y, 0))
               and not checkBlockMined(obj) then 
                closestDistance = distance
                closestChest = obj
            end 
        end 
    end 
    if not closestChest then
        notifyUser("Error", "No accessible chest found nearby.", 3)
    end
    return closestChest 
end

-- Returns the nearest coal to the Player with an open space above 
local function findNearestCoal() 
    local closestDistance = 50
    local closestCoal = nil 
    local playerPosition = Player.Character.HumanoidRootPart.Position
    
    local potentialTargets = getAutoTargets()
    
    for _, obj in pairs(potentialTargets) do
        if obj:IsA("BasePart") and string.match(obj.Name, "Coal%d+_%d+") then 
            local distance = (obj.Position - playerPosition).Magnitude
            if distance < closestDistance 
               and isEmptyConsideringDepth(obj.Position + Vector3.new(0, obj.Size.Y, 0))
               and not checkBlockMined(obj) then 
                closestDistance = distance
                closestCoal = obj
            end 
        end 
    end 
    if not closestCoal then
        notifyUser("Error", "No accessible coal found nearby.", 3)
    end
    return closestCoal 
end

function checkSurroundings(block)
    print("Workspace value at checkSurroundings start:", game.Workspace)
    local Vector3_new = Vector3.new
    local Ray_new = Ray.new
    local directions = {
        Vector3_new(0,1,0),   -- up
        Vector3_new(0,-1,0),  -- down
        Vector3_new(1,0,0),   -- left
        Vector3_new(-1,0,0),  -- right
        Vector3_new(0,0,1),   -- front
        Vector3_new(0,0,-1)   -- back
    }
    local exposedSides = 0 
    local touchingUnminable = false 
    local isTopOpen = false 
    local isOnlyBottomOpen = true 

    -- Check top direction
    if isEmptyConsideringDepth(block.Position + (directions[1] * block.Size.Y)) then
        exposedSides = exposedSides + 1
        isTopOpen = true
    end

    -- Check bottom direction
    if not isEmptyConsideringDepth(block.Position + (directions[2] * block.Size.Y)) then
        isOnlyBottomOpen = false
    end

    -- Check other directions
    for index = 3, #directions do
        local posToCheck = block.Position + (directions[index] * block.Size)
        local hit = not isEmptyConsideringDepth(posToCheck)
        if not hit then 
            exposedSides = exposedSides + 1
        else
            if not string.sub(hit.Name, 1, 4) == "Dirt" then
                touchingUnminable = true
                break
            end
        end
    end

    return exposedSides, touchingUnminable, isTopOpen, isOnlyBottomOpen
end

function getAllBlocks()
    local allChildren = game.Workspace:GetChildren()
    local blocks = {}
    for _, child in ipairs(allChildren) do
        if child:IsA("Part") or child:IsA("MeshPart") then
            table.insert(blocks, child)
        end
    end
    return blocks
end
function getBestBlock(itemPattern)
    -- Ensure that Player and necessary parts exist
    if not (Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
        notifyUser("Error", "Player character not found.", 3)
        return nil
    end
    -- Define search region around the camera
    local centerPoint = game.Workspace.CurrentCamera.CFrame.Position
    local halfExtents = Vector3.new(750, 750, 750)  -- This gives a 150x150x150 region around the center point
    local searchRegion = Region3.new(centerPoint - halfExtents, centerPoint + halfExtents)
    local blocks = game.Workspace:FindPartsInRegion3(searchRegion, nil, 1000)
    local bestBlock = nil 
    local closestDistance = math.huge
    local playerPosition = Player.Character.HumanoidRootPart.Position 
    for _, block in ipairs(blocks) do
        if string.match(block.Name, itemPattern) then 
            local distance = (block.Position - playerPosition).Magnitude 
			local _, _, isTopOpen, _ = checkSurroundings(block)
            if distance < closestDistance and isTopOpen and isEmptyConsideringDepth(block.Position + Vector3.new(0, block.Size.Y, 0)) then
                closestDistance = distance
                bestBlock = block
            end 
        end 
    end 
    if not bestBlock then 
        notifyUser("Snipe Mode", "No block found for pattern: " .. itemPattern, 1)
    end 
    return bestBlock 
end

local flareParts = {}
local function addFlare(character) 
    for i = 1, 24 do -- Create 24 parts for the flare effect (12 for each circle)
        local part = Instance.new("Part") 
        part.Size = Vector3.new(0.5, 0.5, 0.5)
        part.Anchored = true
        part.BrickColor = BrickColor.new("Bright yellow")
        part.Material = Enum.Material.Neon
        part.CanCollide = false
        part.Parent = game.Workspace
        table.insert(flareParts, part)
    end 
end 
local function updateFlare(character) 
    local hrp = character and character:FindFirstChild("HumanoidRootPart") 
    if hrp then 
        for i = 1, 12 do
            local part = flareParts[i]
            if part and part:IsA('BasePart') then
                part.Position = hrp.Position + Vector3.new(math.sin(tick() + i), math.sin(tick() * 2 + i), math.cos(tick() + i)) * 3
            end
        end 
        for i = 13, 24 do
            local part = flareParts[i]
            if part and part:IsA('BasePart') then
                part.Position = hrp.Position + Vector3.new(math.cos(tick() + i), math.sin(tick() * 2 + i), math.sin(tick() + i)) * 3
            end
        end 
    end 
end 
local function removeFlare() 
    for _, part in ipairs(flareParts) do
        if part and part:IsA('BasePart') then
            part:Destroy()
        end
    end 
    flareParts = {} -- Reset the table
end 
local function removeterrain() 
    game.Workspace:FindFirstChildOfClass('Terrain'):Clear()
end
local function removeterrain() 
    game.Workspace:FindFirstChildOfClass('Terrain'):Clear()
end 
-- clientantikick: Prevent client from being kicked by the server 
local function clientantikick()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local args = {...}
        if not checkcaller() and self.ClassName == "RemoteEvent" and self.Name == "Kick" then
            return
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
end
-- antilag: Reduce the graphics quality to reduce game lag (enhanced implementation)
local function antilag()
    local Terrain = game.Workspace:FindFirstChildOfClass('Terrain')
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = 1
    for i,v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        end
    end
    for i,v in pairs(Lighting:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
    game.Workspace.DescendantAdded:Connect(function(child)
        task.spawn(function()
            if child:IsA('ForceField') then
                game:GetService("RunService").Heartbeat:Wait()
                child:Destroy()
            elseif child:IsA('Sparkles') then
                game:GetService("RunService").Heartbeat:Wait()
                child:Destroy()
            elseif child:IsA('Smoke') or child:IsA('Fire') then
                game:GetService("RunService").Heartbeat:Wait()
                child:Destroy()
            end
        end)
    end)
end
local function fullbright()
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end
-- serverhop: Move to a different server (basic implementation) -- serverhop: Move to a different server (basic implementation)
local function serverhop() 
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end 
-- freecam: Free the camera movement -- freecam: Free the camera movement
local function freecam() 
    game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end 
-- unfreecam: Restore original camera behavior -- unfreecam: Restore original camera behavior
local function unfreecam() 
    game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
end 
local Noclipping = nil
local Clip = true
function noclip()
    Clip = false
    wait(0.1)
    local function NoclipLoop()
        if not Clip and Players.LocalPlayer.Character then
            for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide and child.Name ~= floatName then
                    originalCollideStates[child] = child.CanCollide  -- Store original state
                    child.CanCollide = false
                end
            end
        end
    end
    Noclipping = game:GetService("RunService").Stepped:Connect(NoclipLoop)
end
-- Function: deactivateNoClip
function deactivateNoClip()
    if Noclipping then
        Noclipping:Disconnect()
    end
    Clip = true
    if Players.LocalPlayer.Character then
        for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") and not child.CanCollide and child.Name ~= floatName then
                if originalCollideStates[child] ~= nil then  -- Check if we have an original state stored
                    child.CanCollide = originalCollideStates[child]
                end
            end
        end
    end
end
function deactivateFullbright()
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = 1
    Lighting.ClockTime = 14  -- This remains unchanged as it's set to 14 in the fullbright function
    Lighting.FogEnd = 10000  -- This is a default value, adjust if your game uses a different value
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)  -- Default value, adjust if needed
end
-- clientantiteleport: Prevent client from being teleported by the server (basic implementation) -- clientantiteleport: Prevent client from being teleported by the server (basic implementation)
local function clientantiteleport() 
    local mt = getrawmetatable(game) 
    local oldNamecall = mt.__namecall 
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local args = {...} 
        if not checkcaller() and self.ClassName == "RemoteEvent" and self.Name == "Teleport" then 
            return 
        end 
        return oldNamecall(self, ...) 
    end 
    setreadonly(mt, true)
end 
function toShortString(number)
    local shorts = {"k", "M", "B", "T", "qd", "Qn"}
    local pow = #shorts * 3

    for i = #shorts, 1, -1 do
        if number >= 10 ^ pow then
            return string.format("%.2f" .. shorts[i], number / 10 ^ pow)
        end
    end
end

function split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
end
function autoMine(cpsValue)
local isAutoMining = true  -- Refined auto-mining logic based on server-side mechanics
	NotifyUser("AutoMine Activated!", "Why do miners never tell secrets? They can't keep things under rock!")
    task.spawn(
        function()
            while isAutoMining do  -- Check the flag in the loop
                game:GetService("ReplicatedStorage").Remotes.Click:InvokeServer()
                task.wait(.1)
            end
        end
    )
end

    

function getCurrentPickaxe()
    return game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool").Name
end

function getNextPickaxe()
    local current = pickaxeModule.picks[getCurrentPickaxe()]
    local next
    for i, v in pairs(pickaxeModule.picks) do
        if v.Index == current.Index + 1 then
            next = i
        end
    end
    return next
end

function autoBuyPickaxe()
    task.spawn(
        function()
            while true do
                local nextPick = getNextPickaxe()
                if nextPick then
                    game:GetService("ReplicatedStorage").Remotes.BuyPickaxe:InvokeServer(nextPick)
                end
                task.wait(1)
            end
        end
    )
end


-- removeterrain: Remove the game's terrain -- removeterrain: Remove the game's terrain
local function removeterrain() 
    game.Workspace.Terrain:Clear()
end 
function antiidle()
    local GC = getconnections or get_signal_cons
    local Player = Players.LocalPlayer
    if Player and Player.Idled then
        if GC then
            for i,v in pairs(GC(Player.Idled)) do
                if v["Disable"] then
                    v["Disable"](v)
                elseif v["Disconnect"] then
                    v["Disconnect"](v)
                end
            end
        else
            Player.Idled:Connect(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end
function enhancedSnipeMode()
    local targetBlock = findNearestSpecialBlock()
    if targetBlock and targetBlock:IsA('BasePart') then
        local teleportPosition = getSafeTeleportPosition(targetBlock.Position)
        if teleportPosition then
            teleportToPosition(teleportPosition)
            mineBlock(targetBlock)
        else
            notifyUser("Error", "No safe position found for teleportation.", 3)
        end
    else
        notifyUser("Error", "No valid special block found.", 3)
    end
end
-- == END - FUNCTIONS == --
-- GUI Creation --
local screenGui = Instance.new("ScreenGui") 
-- GUI Properties --
screenGui.Name = "GemTeleporter"
screenGui.Parent = Player:WaitForChild("PlayerGui")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 350)  -- Adjusted for the new buttons
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)  -- Adjusted for the new buttons
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0.5)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "CMS-PMS by xXGeminiXx"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundColor3 = Color3.new(0, 0, 0.8)
titleLabel.BorderSizePixel = 0
titleLabel.Parent = mainFrame
local minimizeBtn = Instance.new("TextButton") 
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0.1, 0, 1, 0)
minimizeBtn.Position = UDim2.new(0.9, 0, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.TextSize = 24
minimizeBtn.Parent = titleLabel
local isMinimized = false 
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then 
        mainFrame.Size = UDim2.new(0, 250, 0.1, 0)
    else 
        mainFrame.Size = UDim2.new(0, 250, 0, 350)
    end 
end) 
-- TeleportBtn properties (for teleporting to Gem) -- TeleportBtn properties (for teleporting to Gem)
teleportBtn.Name = "TeleportBtn"
teleportBtn.Size = UDim2.new(0.5, 0, 0.1, 0)  
teleportBtn.Position = UDim2.new(0, 0, 0.1, 0)  
teleportBtn.Text = "Tele Gem"
teleportBtn.Parent = mainFrame
local RemoveObjectsButton = Instance.new("TextButton")
RemoveObjectsButton.Name = "removeObjects"
RemoveObjectsButton.Size = UDim2.new(1, 0, 0.1, 0)
RemoveObjectsButton.Position = UDim2.new(0, 0, 1.3, 0)  -- Adjust the position as needed
RemoveObjectsButton.Text = "Remove Objects"
RemoveObjectsButton.Parent = mainFrame
-- TeleportToMysteryBtn properties (for teleporting to Mystery Box) -- TeleportToMysteryBtn properties (for teleporting to Mystery Box)
local teleportToMysteryBtn = Instance.new("TextButton") 
teleportToMysteryBtn.Name = "TeleportToMysteryBtn"
teleportToMysteryBtn.Size = UDim2.new(0.5, 0, 0.1, 0)  
teleportToMysteryBtn.Position = UDim2.new(0.5, 0, 0.1, 0)  
teleportToMysteryBtn.Text = "Tele Mystery"
teleportToMysteryBtn.Parent = mainFrame
autoTeleportToggleBtn.Name = "AutoTeleportToggleBtn"
autoTeleportToggleBtn.Size = UDim2.new(1, 0, 0.1, 0)
autoTeleportToggleBtn.Position = UDim2.new(0, 0, 0.4, 0)
autoTeleportToggleBtn.Text = "Toggle Auto-Teleport On/Off"
autoTeleportToggleBtn.Parent = mainFrame
-- FlyJumpBtn properties -- FlyJumpBtn properties
flyJumpBtn.Name = "FlyJumpBtn"
flyJumpBtn.Size = UDim2.new(0.5, 0, 0.1, 0)  
flyJumpBtn.Position = UDim2.new(0, 0, 0.5, 0)  -- Adjusted the position
flyJumpBtn.Text = "Fly Jump"
flyJumpBtn.Parent = mainFrame
-- SuperSpeedBtn properties -- SuperSpeedBtn properties
superSpeedBtn.Name = "SuperSpeedBtn"
superSpeedBtn.Size = UDim2.new(0.5, 0, 0.1, 0)  
superSpeedBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
superSpeedBtn.Text = "Super Speed"
superSpeedBtn.Parent = mainFrame
-- Snipe Mode Button Properties -- Snipe Mode Button Properties
local snipeModeBtn = Instance.new("TextButton") 
snipeModeBtn.Name = "SnipeModeBtn"
snipeModeBtn.Parent = mainFrame
snipeModeBtn.Size = UDim2.new(1, 0, 0.1, 0)
snipeModeBtn.Position = UDim2.new(0, 0, 0.6, 0)
snipeModeBtn.BackgroundColor3 = Color3.new(0, 0, 0.5)  -- Made it consistent with other buttons
snipeModeBtn.Font = Enum.Font.SourceSansBold
snipeModeBtn.Text = "Snipe Mode"
snipeModeBtn.TextColor3 = Color3.new(1, 1, 1)  -- Adjusted to white text
snipeModeBtn.TextScaled = true
-- Friend Amount Button Properties
friendAmountBtn.Name = "FriendAmountBtn"
friendAmountBtn.Size = UDim2.new(1, 0, 0.1, 0)
friendAmountBtn.Position = UDim2.new(0, 0, 0.7, 0)
friendAmountBtn.Text = "Toggle Friend Amount"
friendAmountBtn.Parent = mainFrame
-- Gemini Amount Button Properties. -- Gemini Amount Button Properties.
geminiModeBtn.Name = "GeminiModeBtn"
geminiModeBtn.Size = UDim2.new(1, 0, 0.1, 0)
geminiModeBtn.Position = UDim2.new(0, 0, 0.8, 0)
geminiModeBtn.Text = "Gemini Mode"
geminiModeBtn.Parent = mainFrame
-- TeleportToCoalBtn properties (for teleporting to Coal) -- TeleportToCoalBtn properties (for teleporting to Coal)
local teleportToCoalBtn = Instance.new("TextButton") 
teleportToCoalBtn.Name = "TeleportToCoalBtn"
teleportToCoalBtn.Size = UDim2.new(0.5, 0, 0.1, 0)
teleportToCoalBtn.Position = UDim2.new(0, 0, 0.2, 0)  -- Adjusted the position
teleportToCoalBtn.Text = "Tele Coal"
teleportToCoalBtn.Parent = mainFrame
-- Add a blank GUI line for spacing -- Add a blank GUI line for spacing
local blankSpace = Instance.new("Frame") 
blankSpace.Name = "BlankSpace"
blankSpace.Size = UDim2.new(1, 0, 0.1, 0)
blankSpace.Position = UDim2.new(0, 0, 1.0, 0)
blankSpace.BackgroundColor3 = Color3.new(0, 0, 0.5)
blankSpace.BorderSizePixel = 0
blankSpace.Parent = mainFrame
-- DestroyGuiBtn properties -- DestroyGuiBtn properties
destroyGuiBtn.Name = "DestroyGuiBtn"
destroyGuiBtn.Size = UDim2.new(1, 0, 0.1, 0)
destroyGuiBtn.Position = UDim2.new(0, 0, 1.5, 0)  -- Adjusted position for destroyGuiBtn
destroyGuiBtn.Text = "Destroy GUI"
destroyGuiBtn.Parent = mainFrame
-- TeleportToChestBtn properties (for teleporting to Chest) -- TeleportToChestBtn properties (for teleporting to Chest)
local teleportToChestBtn = Instance.new("TextButton") 
teleportToChestBtn.Name = "TeleportToChestBtn"
teleportToChestBtn.Size = UDim2.new(0.5, 0, 0.1, 0)
teleportToChestBtn.Position = UDim2.new(0.5, 0, 0.2, 0)  -- Adjusted the position
teleportToChestBtn.Text = "Tele Chest"
teleportToChestBtn.Parent = mainFrame
local serverhopBtn = Instance.new("TextButton") 
serverhopBtn.Parent = mainFrame
local rejoinServerBtn = Instance.new("TextButton") 
rejoinServerBtn.Name = "RejoinServerBtn"
rejoinServerBtn.Size = UDim2.new(.5, 0, 0.1, 0)
rejoinServerBtn.Position = UDim2.new(0.5, 0, 1.0, 0)
rejoinServerBtn.Text = "Rejoin Server"
rejoinServerBtn.Parent = mainFrame
-- Rejoin Server Button Click Event -- Rejoin Server Button Click Event
rejoinServerBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end) 
-- For serverhop -- For serverhop
serverhopBtn.Name = "ServerhopBtn"
serverhopBtn.Size = UDim2.new(.5, 0, 0.1, 0)
serverhopBtn.Position = UDim2.new(0, 0, 1.0, 0)
serverhopBtn.Text = "Server Hop"
-- Rejoin Server Button properties -- Rejoin Server Button properties
serverhopBtn.MouseButton1Click:Connect(serverhop)
local noclipBtn = Instance.new("TextButton")
noclipBtn.Name = "NoclipBtn"
noclipBtn.Size = UDim2.new(1, 0, 0.1, 0)
noclipBtn.Position = UDim2.new(0, 0, 1.1, 0)
noclipBtn.Text = "NoClip"
noclipBtn.Parent = mainFrame
-- Add a button for teleporting to relic doors
local teleportToDoorBtn = Instance.new("TextButton")
teleportToDoorBtn.Name = "TeleportToDoorBtn"
teleportToDoorBtn.Size = UDim2.new(1, 0, 0.1, 0)
teleportToDoorBtn.Position = UDim2.new(0, 0, 1.2, 0)
teleportToDoorBtn.Text = "Tele Relic Door"
teleportToDoorBtn.Parent = mainFrame
-- Exploit Testing Button Creation
local exploitTestBtn = Instance.new("TextButton")
exploitTestBtn.Parent = mainFrame
exploitTestBtn.Size = UDim2.new(1, 0, 0.1, 0)
exploitTestBtn.Position = UDim2.new(0, 0, 1.4, 0)
exploitTestBtn.Text = "Test Exploits"
exploitTestBtn.BackgroundColor3 = Color3.new(1, 0, 0) -- Red color for visibility
exploitTestBtn.TextColor3 = Color3.new(1, 1, 1) -- White text
exploitTestBtn.Visible = false
local isNoclipEnabled = false 
noclipBtn.MouseButton1Click:Connect(function()
    if Clip then
        noclip()
        noclipBtn.Text = "Deactivate NoClip"  -- Update the GUI text for active state
        notifyUser("Info", "NoClip Enabled!", 2)
    else
        deactivateNoClip()
        noclipBtn.Text = "Activate NoClip"  -- Update the GUI text for inactive state
        notifyUser("Info", "NoClip Disabled!", 2)
    end
end)
-- Create the CPS label (acting as a button but looking like a label)
local cpsLabel = Instance.new("TextButton")
cpsLabel.Name = "CPSLabel"
cpsLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
cpsLabel.Position = UDim2.new(0, 0, 1.4, 0)
cpsLabel.Text = "CPS: " .. tostring(cps)  -- Display the current CPS value
cpsLabel.TextColor3 = Color3.new(1, 1, 1)
cpsLabel.BackgroundColor3 = Color3.new(0, 0, 0.5)
cpsLabel.BorderSizePixel = 0  -- Removes the default border to make it look like a label
cpsLabel.Parent = mainFrame
-- Make the cpsLabel interactive (act like a button)
cpsLabel.MouseButton1Click:Connect(function()
    -- Toggle CPS logic here (e.g., using the autoMine function and a flag)
    if isCpsToggling then return end  -- Check debounce
    isCpsToggling = true

    isCpsOn = not isCpsOn
    if isCpsOn then
        cpsLabel.Text = "Stop CPS"
        autoMine(cps)  -- Activate the autoMine function with the specified CPS rate
    else
local isAutoMining = true  -- Refined auto-mining logic based on server-side mechanics
        cpsLabel.Text = "CPS: " .. cps
    end
    task.wait(0.5)  -- Debounce duration
    isCpsToggling = false
end)
-- TeleportToIronBtn properties
local teleportToIronBtn = Instance.new("TextButton")
teleportToIronBtn.Name = "TeleportToIronBtn"
teleportToIronBtn.Size = UDim2.new(0.5, 0, 0.1, 0)
teleportToIronBtn.Position = UDim2.new(0, 0, 0.3, 0)
teleportToIronBtn.Text = "Tele Iron"
teleportToIronBtn.Parent = mainFrame

-- TeleportToCopperBtn properties
local teleportToCopperBtn = Instance.new("TextButton")
teleportToCopperBtn.Name = "TeleportToCopperBtn"
teleportToCopperBtn.Size = UDim2.new(0.5, 0, 0.1, 0)
teleportToCopperBtn.Position = UDim2.new(0.5, 0, 0.3, 0)
teleportToCopperBtn.Text = "Tele Copper"
teleportToCopperBtn.Parent = mainFrame


-- Create the CPS input box
local cpsInputBox = Instance.new("TextBox")
cpsInputBox.Name = "CPSInputBox"
cpsInputBox.Size = UDim2.new(0.5, 0, 0.1, 0)
cpsInputBox.Position = UDim2.new(0.5, 0, 1.4, 0)
cpsInputBox.Text = tostring(CPS)  -- Initialize with the current CPS value
cpsInputBox.TextColor3 = Color3.new(1, 1, 1)
cpsInputBox.BackgroundColor3 = Color3.new(0, 0, 0.8)
cpsInputBox.Parent = mainFrame
-- Update the CPS value when the user finishes editing the input box
cpsInputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newCPS = tonumber(cpsInputBox.Text)
        if newCPS and newCPS > 0 then
            CPS = newCPS
            cpsLabel.Text = "CPS: " .. tostring(CPS)
        else
            cpsInputBox.Text = tostring(CPS)  -- Reset to the original value if the input is invalid
        end
    end
end)
-- Teleport Buttons -- Teleport Buttons
-- Toggle variables -- Toggle variables
local isGemTeleporting = false 
local isMysteryTeleporting = false 
local isCoalTeleporting = false 
local isChestTeleporting = false 
-- Exploit Testing Button Action
--exploitTestBtn.MouseButton1Click:Connect(testAllExploits)
-- Teleport to Gem -- Teleport to Gem
teleportBtn.MouseButton1Click:Connect(function()
    isGemTeleporting = not isGemTeleporting
    if isGemTeleporting then 
        teleportBtn.Text = "Stop Tele Gem"
        while isGemTeleporting do 
            if canTeleportAgain() then 
                local gem = findNearestGem() 
                if gem then 
                    local safePosition = getSafeTeleportPosition(gem.Position) 
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                    lastTeleportTime = tick()
                end 
            end 
            wait(1)  -- Check every second
        end 
    else 
        teleportBtn.Text = "Tele Gem"
    end 
end) 
function resetAllChanges()
    -- 1. Fly Jump
    if flyjump then
        flyjump:Disconnect()
        flyjump = nil
    end
    -- 2. Super Speed
    Player.Character.Humanoid.WalkSpeed = normalSpeed
    -- 3. Flare Effect
    removeFlare()
    if flareUpdateConnection then
        flareUpdateConnection:Disconnect()
        flareUpdateConnection = nil
    end
    -- 4. Friend Amount
    if originalFriendAmount then
        Player.FriendAmount.Value = originalFriendAmount
    end
    -- 5. NoClip
    if noclipActivatedInGeminiMode then
        deactivateNoClip() -- Make sure this function exists in your script
    end
    -- 6. Anti-Kick
    kick = originalKick
    -- 7. Anti-Idle
    if antiIdleConnection then
        antiIdleConnection:Disconnect()
        antiIdleConnection = nil
    end
    -- 8. Fullbright
    deactivateFullbright()  -- Placeholder, add the logic to deactivate Fullbright
end
-- Connect the above function to the Destroy GUI button's MouseButton1Click event
destroyGuiBtn.MouseButton1Click:Connect(function()
    resetAllChanges()
    screenGui:Destroy()
end)
-- Teleport to Mystery Block -- 
teleportToMysteryBtn.MouseButton1Click:Connect(function()
    isMysteryTeleporting = not isMysteryTeleporting
    if isMysteryTeleporting then 
        teleportToMysteryBtn.Text = "Stop Tele Mystery"
        while isMysteryTeleporting do 
            if canTeleportAgain() then 
                local mysteryBlock = findNearestMystery() 
                if mysteryBlock then 
                    local safePosition = getSafeTeleportPosition(mysteryBlock.Position) 
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                    lastTeleportTime = tick()
                end 
            end 
            wait(2)  -- Check every 2 seconds
        end 
    else 
        teleportToMysteryBtn.Text = "Tele Mystery"
    end 
end)
-- Teleport to Coal --
teleportToCoalBtn.MouseButton1Click:Connect(function()
    isCoalTeleporting = not isCoalTeleporting
    if isCoalTeleporting then 
        teleportToCoalBtn.Text = "Stop Tele Coal"
        while isCoalTeleporting do 
            if canTeleportAgain() then 
                local coal = findNearestCoal() 
                if coal then 
                    local safePosition = getSafeTeleportPosition(coal.Position) 
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                    lastTeleportTime = tick()
                end 
            end 
            wait(1)  -- Check every second
        end 
    else 
        teleportToCoalBtn.Text = "Tele Coal"
    end 
end) 
teleportToIronBtn.MouseButton1Click:Connect(function()
    local iron = findNearestIron()
    if iron then
        local safePosition = getSafeTeleportPosition(iron.Position)
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
    end
end)

teleportToCopperBtn.MouseButton1Click:Connect(function()
    local copper = findNearestCopper()
    if copper then
        local safePosition = getSafeTeleportPosition(copper.Position)
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
    end
end)

-- Teleport to Chest --
teleportToChestBtn.MouseButton1Click:Connect(function()
    isChestTeleporting = not isChestTeleporting
    if isChestTeleporting then 
        teleportToChestBtn.Text = "Stop Tele Chest"
        while isChestTeleporting do 
            if canTeleportAgain() then 
                local chest = findNearestChest() 
                if chest then 
                    local safePosition = getSafeTeleportPosition(chest.Position) 
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                    lastTeleportTime = tick()
                end 
            end 
            wait(1)  -- Check every second
        end 
    else 
        teleportToChestBtn.Text = "Tele Chest"
    end 
end) 
autoTeleportToggleBtn.MouseButton1Click:Connect(function()
    isAutoTeleporting = not isAutoTeleporting
    if isAutoTeleporting then 
        autoTeleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not lastTeleportedBlock or checkBlockMined(lastTeleportedBlock) then 
                wait(teleportCooldown)
                local gem = findNearestGem() 
                if gem then 
                    local gemPosition = gem.Position 
                    local teleportOffset = Vector3.new(0, 6, 0)  -- Adjust the vertical offset as needed 
                    local teleportPosition = gemPosition + teleportOffset 
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
                    lastTeleportedBlock = gem
		    local blockMinedCheckCooldown = 3  -- Reduced cooldown for better mining efficiency
                end 
            end 
        end) 
        notifyUser("Info", "Auto-Teleport Enabled!", 3)
    else 
        if autoTeleportConnection then 
            autoTeleportConnection:Disconnect()
            autoTeleportConnection = nil
        end 
        notifyUser("Info", "Auto-Teleport Disabled!", 3)
    end 
end) 
flyJumpBtn.MouseButton1Click:Connect(function()
    if flyJumpActive then 
        -- If flyjump is active, deactivate it         -- If flyjump is active, deactivate it
        if flyjump then  
            flyjump:Disconnect() 
            flyjump = nil
        end 
        notifyUser("Info", "Fly Jump Disabled!", 3)
        flyJumpBtn.Text = "Activate Fly Jump"
        flyJumpActive = false
    else 
        -- If flyjump is inactive, activate it         -- If flyjump is inactive, activate it
        if not flyjump then  
            flyjump = game:GetService("UserInputService").JumpRequest:Connect(function()
                Player.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end) 
        end 
        notifyUser("Info", "Fly Jump Enabled!", 3)
        flyJumpBtn.Text = "Deactivate Fly Jump"
        flyJumpActive = true
    end 
end) 
superSpeedBtn.MouseButton1Click:Connect(function()
    if not superSpeedEnabled then 
        Player.Character.Humanoid.WalkSpeed = 80
        notifyUser("Info", "Super Speed Enabled!", 3)
        superSpeedBtn.Text = "Disable Super Speed"
        superSpeedEnabled = true
    else 
        Player.Character.Humanoid.WalkSpeed = normalSpeed
        notifyUser("Info", "Super Speed Disabled!", 3)
        superSpeedBtn.Text = "Super Speed"
        superSpeedEnabled = false
    end 
end) 
friendAmountBtn.MouseButton1Click:Connect(function()
    -- Toggle FriendAmount for the local Player
    local prop = Player:FindFirstChild("FriendAmount") 
    if prop then 
        if prop.Value == 888 then
            prop.Value = 0
            notifyUser("Info", "You have no friends, LOSER!", 3)
        else
            prop.Value = 888
            notifyUser("Info", "Friend Amount Set to 888!", 3)
        end
    else 
        notifyUser("Error", "FriendAmount property not found!", 3)
    end 
end)
-- GEMINI MODE! --
geminiModeBtn.MouseButton1Click:Connect(function()
    isGeminiModeOn = not isGeminiModeOn
    if isGeminiModeOn then
        --disableAllGuiButtons() 
        notifyUser("#WINNING", "Gemini Mode Enabled. Hang in there while we toggle...", 5)
        -- Store original FriendAmount
        originalFriendAmount = Player.FriendAmount.Value
        -- New addition: Set FriendAmount to 777
        local prop = Player:FindFirstChild("FriendAmount")
        if prop then
            prop.Value = 777
            notifyUser("WTF", "OMG YOU'RE SO POPULAR!", 1)
            notifyUser("Info", "Friend Amount Set to 777!", 2)
        end
        if not flyjump then
            flyjump = game:GetService("UserInputService").JumpRequest:Connect(function()
                Player.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end)
            notifyUser("Info", "Infinite Jumps Enabled!", 2)
        end
        -- Toggle Super Speed on when Gemini Mode is activated
        if not superSpeedEnabled then
            Player.Character.Humanoid.WalkSpeed = 80
            notifyUser("Info", "Super Speed Enabled!", 3)
            superSpeedBtn.Text = "Disable Super Speed"
            superSpeedEnabled = true
        end
        clientantikick()
        notifyUser("Info", "Anti-Kick Enabled!", 2)
        notifyUser("Info", "Turning on Anti-Lag... it'll cause some lag first... lol", 2)
        antilag()
        notifyUser("xXGeminiXx", "Okay bud, trees and shit going away now.", 2)
		removeObjectsByName(namesList)
        notifyUser("Info", "Anti-Lag Enabled! Lag over.", 2)
		addFlare(Player.Character)
        -- Store the heartbeat connection to be disconnected later
        flareUpdateConnection = game:GetService("RunService").Heartbeat:Connect(function()
            updateFlare(Player.Character)
        end)
        notifyUser("Look what I can do!", "Gemini's badass Flare effect added!", 2)
        clientantiteleport()
        notifyUser("Info", "Anti-Teleport Enabled!", 2)
        antiidle()
        notifyUser("Info", "Anti-Idle Enabled!", 2)
        -- Toggle NoClip on when Gemini Mode is activated
        if Clip then
            noclip()
            noclipBtn.Text = "Deactivate NoClip"  -- Update the GUI text
            notifyUser("Info", "NoClip Enabled!", 2)
            noclipActivatedInGeminiMode = true  -- Set a flag to remember that NoClip was activated during Gemini Mode
        end
        removeterrain()
        notifyUser("Info", "Some bad Terrain Removed!", 2)
        -- Fullbright
        fullbright()
        notifyUser("Info", "Fullbright Enabled!", 2)
        geminiModeBtn.Text = "Deactivate Gemini Mode"
		notifyUser("xXGeminiXx", "Welcome to my world. Gemini Mode on.", 2)
		enableAllGuiButtons() 
    else
		disableAllGuiButtons() 
        notifyUser("Stupid Idea...", "Gemini Mode Disabled. Hang in there while we toggle...", 4)
        if flyjump then
            flyjump:Disconnect() 
            flyjump = nil
            notifyUser("Info", "Flying Jump Disabled!", 2)
        end
        Player.Character.Humanoid.WalkSpeed = normalSpeed
        notifyUser("Info", "WalkSpeed reset to normal!", 2)
        removeFlare()
        notifyUser("Info", "Flare effect removed!", 2)
        -- Disconnect the heartbeat connection for flare update
        if flareUpdateConnection then
            flareUpdateConnection:Disconnect()
            flareUpdateConnection = nil
        end
        -- Restore original FriendAmount
        if originalFriendAmount then
            Player.FriendAmount.Value = originalFriendAmount
            originalFriendAmount = nil
        end
        -- Deactivate NoClip if it was activated during Gemini Mode
        if noclipActivatedInGeminiMode then
            deactivateNoClip()  -- Assuming you have a function to deactivate NoClip. If not, you'll need to implement the logic here.
            noclipActivatedInGeminiMode = false
        end
		enableAllGuiButtons() 
		notifyUser("We're good.", "Back to fully normal, all changes reversed.", 5)
		geminiModeBtn.Text = "Activate Gemini Mode"
    end
end)
cpsLabel.MouseButton1Click:Connect(function()
    if isCpsToggling then return end  -- Check debounce
    isCpsToggling = true

 if isCpsOn then
        cpsLabel.Text = "Stop CPS"
        cps = tonumber(cpsInputBox.Text) or 7  -- Fetch CPS rate from input box; default to 7 if invalid
        
        -- Activate the autoMine function with the specified CPS rate
        autoMine(cps)
    else
	local isAutoMining = true  -- Refined auto-mining logic based on server-side mechanics
        cpsLabel.Text = "CPS: " .. cps
    end
    task.wait(0.5)  -- Debounce duration
    isCpsToggling = false
end)
-- Connect to the Idled event
Player.Idled:Connect(antiidle)
-- Snipe Mode variables -- Snipe Mode variables
local isSnipeModeActive = false 
local snipeModeConnection = nil 
local failedAttempts = 0  -- Counter to track failed attempts 
local maxFailedAttempts = 500  -- Maximum allowed failed attempts before Snipe Mode is deactivated 
local snipeCooldown = 1  -- Cooldown duration in seconds 
-- Improved function to check if top block is actually empty -- Improved function to check if top block is actually empty
local priorityOrder = {"M%d+_", "Mystery%d+_%d+", "Gem%d+_", "Chest%d+_%d+", "Coal%d+_%d+"}
function executeSnipeMode() -- Defining a function.
    isSnipeModeActive = not isSnipeModeActive
    if isSnipeModeActive then 
        snipeModeBtn.Text = "Stop Snipe Mode"
        notifyUser("Snipe Mode", "Snipe Mode Activated!", 3)
        notifyUser("Snipe Mode", "Starting snipe loop...", 2)
        snipeModeConnection = game:GetService("RunService").Heartbeat:Connect(function()
            --wait(snipeCooldown)  -- Apply cooldown
            --local priorityOrder = {"M%d+_", "Gem%d+_", "Chest%d+_%d+", "Coal%d+_%d+"} 
            local foundBlock = false 
			wait(0.3)  -- This will make it try approximately 3 times a second
            for _, pattern in ipairs(priorityOrder) do -- Starting a for loop.
                _, _, isTopOpen, _ = checkSurroundings(block)
                if bestBlock then 
				notifyUser("Snipe Mode", "Best block identified: " .. bestBlock.Name, 2)
                    _, _, isTopOpen, _ = checkSurroundings(block)
					notifyUser("Snipe Mode", "Top of block " .. bestBlock.Name .. " is obstructed. Skipping...", 2)
                    if isTopOpen and isTopSpaceEmpty(bestBlock) then  -- Check if top space is empty 
                        --notifyUser("Snipe Mode", "Top of block " .. bestBlock.Name .. " is open.", 1)
						if bestBlock and bestBlock:IsDescendantOf(game.Workspace) then
							local teleportPosition = getSafeTeleportPosition(bestBlock.Position) 
							Player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
							foundBlock = true
							failedAttempts = 0  -- Reset failed attempts counter
							notifyUser("Snipe Mode", "Teleported to block: " .. bestBlock.Name, 2)
							wait(0.05)
						break
						end
                    else 
                       -- notifyUser("Snipe Mode", "Top of block " .. bestBlock.Name .. " is not open.", 1)
                    end 
                end 
            end 
            if not foundBlock then 
                failedAttempts = failedAttempts + 1
                if failedAttempts >= maxFailedAttempts then 
                    snipeModeBtn.Text = "Snipe Mode"
                    notifyUser("Snipe Mode", "Maximum failed attempts reached. Stopping Snipe Mode.", 3)
                    isSnipeModeActive = false
                    if snipeModeConnection then 
                        snipeModeConnection:Disconnect()
                        snipeModeConnection = nil
                    end 
                end 
            end 
        end) 
    else 
        if snipeModeConnection then 
            snipeModeConnection:Disconnect()
            snipeModeConnection = nil
        end 
        snipeModeBtn.Text = "Snipe Mode"
        notifyUser("Snipe Mode", "Snipe Mode Deactivated!", 3)
    end 
end 
function isTopSpaceEmpty(block)
    if block and block:IsA('BasePart') then
        return isEmptyConsideringDepth(block.Position + Vector3.new(0, block.Size.Y, 0))
    end
    return false
end

function isEmpty(position, checkAboveBlock)
    local rayLength = 1
    local ray = Ray.new(position, Vector3.new(0, -1, 0) * rayLength)  -- Pointing the ray downwards
    local block, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character})
    if checkAboveBlock and block and block:IsA('BasePart') then
        rayLength = block.Size.Y + Player.Character.HumanoidRootPart.Size.Y + 1
    end
    return not block
end

function findAlternativeOpenBlockAbovePlayer()
    local currentPos = Player.Character.HumanoidRootPart.Position
    local searchRadius = 10
	local region = Region3.new(
		currentPos - Vector3.new(searchRadius, searchRadius, searchRadius),
		currentPos + Vector3.new(searchRadius, searchRadius, searchRadius)
	)
	local partsInRadius = game.Workspace:FindPartsInRegion3(region, nil, math.huge)

    for _, part in ipairs(partsInRadius) do
        if isEmptyConsideringDepth(part.Position) then
            return part.Position + Vector3.new(0, part.Size.Y/2 + 1, 0)
        end
    end
    return nil
end

function teleportToPosition(position)
    if position and typeof(position) == "Vector3" and Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    else
        notifyUser("Teleportation Error", "Invalid position provided.", 3)
    end
end
local function mineBlock(block)
    if not block then
        notifyUser("Mining Error", "Block does not exist.", 3)
        return
    end
    local _, _, isTopOpen, _ = checkSurroundings(block)
    if isTopOpen then
        block:Destroy()
    else
        notifyUser("Mining Error", "Cannot mine this block.", 3)
    end
end
local function findNearestSpecialBlock()
    local currentPos = Player.Character.HumanoidRootPart.Position
    local searchRadius = 10  -- adjustable based on your game's grid size or requirements
    -- Define a bounding box around the current position based on searchRadius
	local region = Region3.new(
		currentPos - Vector3.new(searchRadius, searchRadius, searchRadius),
		currentPos + Vector3.new(searchRadius, searchRadius, searchRadius)
	)
	local partsInRadius = game.Workspace:FindPartsInRegion3(region, nil, math.huge)

    local nearestSpecialBlock = nil
    local shortestDistance = math.huge
    for _, part in ipairs(partsInRadius) do
        if not string.match(part.Name, "^Dirt%d+_%d+$") then  
            local distance = (currentPos - part.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestSpecialBlock = part
            end
        end
    end
    if not nearestSpecialBlock then
        notifyUser("Error", "No special block found nearby.", 3)
    end
    return nearestSpecialBlock
end
-- Directly use the destroyGuiBtn variable
if not destroyGuiBtn then
    warn("DestroyGUI button not found!")
    return
end
snipeModeBtn.MouseButton1Click:Connect(executeSnipeMode)
--snipeMode.MouseButton1Click:Connect(executeSnipeMode)
-- Connect the button click event to the function
teleportDoorBtn.MouseButton1Click:Connect(teleportToNearestDoor)
RemoveObjectsButton.MouseButton1Click:Connect(function()
    removeObjectsByName(namesList)
end)
-- Connect the event to destroyGuiBtn
destroyGuiBtn.MouseButton1Click:Connect(function()
    -- Disconnect snipeModeConnection if it exists
	notifyUser("Reversing everything", "Killing all functions then closing script.", 5)
    if snipeModeConnection then
        snipeModeConnection:Disconnect()
        snipeModeConnection = nil
    end
    -- Deactivate snipe mode (or any other modes)
    isSnipeModeActive = false
		if flyjump then
            flyjump:Disconnect() 
            flyjump = nil
            notifyUser("Info", "Flying Jump Disabled!", 2)
        end
        Player.Character.Humanoid.WalkSpeed = normalSpeed
        notifyUser("Info", "WalkSpeed reset to normal!", 2)
        removeFlare()
        -- Disconnect the heartbeat connection for flare update
        if flareUpdateConnection then
            flareUpdateConnection:Disconnect()
            flareUpdateConnection = nil
        end
        notifyUser("Info", "Flare effect removed!", 2)
        -- Restore original FriendAmount
        if originalFriendAmount then
            Player.FriendAmount.Value = originalFriendAmount
            originalFriendAmount = nil
        end
        notifyUser("Info", "You have no friends... RIP. Goodbye.", 5)
        -- Deactivate NoClip if it was activated during Gemini Mode
        if noclipActivatedInGeminiMode then
            deactivateNoClip()  -- Assuming you have a function to deactivate NoClip. If not, you'll need to implement the logic here.
            noclipActivatedInGeminiMode = false
        end
    -- Destroy the GUI
    screenGui:Destroy()
end)
spawn(checkIfStuck)
