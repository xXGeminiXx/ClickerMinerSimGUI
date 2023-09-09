local isChestTeleporting = false
local lastTeleportTime = 0
local isGemTeleporting = false
-- GeminisClickerMinerSim Version 12 --
-- Introduced new gui using Uwuware.lua --
-- All credits to that GUI lib go to the original developer --
-- Created by xXGeminiXx --
print('Library Initialization Started...')
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xXGeminiXx/ClickerMinerSimGUI/main/Uwuware.lua", true))()
local window = Library:CreateWindow("CMS-PMS by xXGeminiXx")
local Player = game.Players.LocalPlayer
local Character = Player and Player:WaitForChild("Character", 5)
local prop = Player:FindFirstChild("FriendAmount")
local Clip = false -- Or true, based on the default state you want
local namesList = {
    "Ad_AdBoard",
	"black", "cake", "candy", "Meshes/Donut (1)", 
    "Cliff09", "Cliff10", "Cliff11", "Cliff12",
    "dazhiwu", "ding", "door_light",
    "fire",
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
    "Wall", "wall"
}
while not Player.Character do wait() end
while not Player.PlayerGui do wait() end
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")  -- Retrieve the Players service
local mainSection = window:AddFolder("Main")
local movementSection = window:AddFolder("Movement")
local teleportSection = window:AddFolder("Teleports")
local testingSection = window:AddFolder("Testing")
local exitSection = window:AddFolder("Exit")
local mainFrame = Instance.new("Frame") 
local yPos = 0.8 -- Or any other default value you want
local superSpeedEnabled = false 
local normalSpeed = Player.Character.Humanoid.WalkSpeed 
local flyJumpActive = false -- flag to check if flyjump is on or off 
local lastTeleportedBlock = nil 
local teleportOffset = Vector3.new(0, 6, 0)  -- Adjust the vertical offset as needed 
local flyjump 
local previousPosition = Vector3.new(0,0,0)  -- Initial Position, it will be updated in the function
local deltaThreshold = 0.5  -- Threshold for considering the Player as having moved
local isGeminiModeOn = false 
local isAutoTeleporting = false 
local currentPos = nil
local autoTeleportConnection = nil 
local teleportCooldown = 1.5  -- Adjusted teleportation logic with server-side configurations
local blockMinedCheckCooldown = 3  -- Reduced cooldown for better mining efficiency
local consecutiveFailures = 0 -- -- Counter for tracking consecutive failures. Stopped the spam from snipemode debugging.
local allDescendants = game.Workspace:GetDescendants() -- Cache the descendants once
--local pickaxeModule = require(game:GetService("ReplicatedStorage").Modules.pickaxesModule)
local allBlocks = game.Workspace:GetChildren()
local blocksList = {}  -- Table to store all the blocks
for _, block in ipairs(allBlocks) do
    if block:IsA("Part") or block:IsA("MeshPart") then  -- Assuming blocks are of type Part or MeshPart
        table.insert(blocksList, block)  -- Add the block to the blocksList
    end
end
local Position = Camera.CFrame.Position
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
-- == CONSTANTS == --
local MAX_ACTIVE_NOTIFICATIONS = 5
local MAX_NOTIFICATION_QUEUE = 10
-- == VARIABLES == --
local activeNotifications = {}
local notificationQueue = {}
-- == FUNCTIONS == --
local function processNotificationQueue()
    while #activeNotifications < MAX_ACTIVE_NOTIFICATIONS and #notificationQueue > 0 do
        local notification = table.remove(notificationQueue, 1)
        local notifyObj = notifyUser(notification.title, notification.text, notification.duration, notification.verticalOffset)
        table.insert(activeNotifications, notifyObj)
    end
end
local function notifyUser(title, text, duration, verticalOffset)
    if #activeNotifications >= MAX_ACTIVE_NOTIFICATIONS then
        return
    end
    local notification = Instance.new("ScreenGui")
    notification.Name = "NotificationGui"
    notification.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local frame = Instance.new("Frame")
    frame.Parent = notification
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black Background
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0.25, 0, 0.15, 0)
    frame.Position = UDim2.new(0.75, 0, verticalOffset or 0.8, 0)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = frame
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24 -- Larger text
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0) -- Adjust height
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0) -- Black outline
    titleLabel.TextStrokeTransparency = 0.5
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = frame
    textLabel.Text = text
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 20 -- Larger text
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Size = UDim2.new(1, 0, 0.6, 0) -- Adjust height
    textLabel.Position = UDim2.new(0, 0, 0.4, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0) -- Black outline
    textLabel.TextStrokeTransparency = 0.5
    table.insert(activeNotifications, notification)
    wait(duration or 5)
    for index, activeNotify in ipairs(activeNotifications) do
        if activeNotify == notification then
            table.remove(activeNotifications, index)
            activeNotify:Destroy()
            break
        end
    end
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
            customNotifyUser("Gemini Mode", "Removed " .. removedCount .. " instances of '" .. name .. "'.", .2)
        else
            customNotifyUser("Gemini Mode", "No instances of '" .. name .. "' found to remove.", .2)
        end
        --wait(0.2)  -- Reducing wait time to speed up the function
    end
end
local lastTeleportTime = 0 -- Initialize with a default value
local function canTeleportAgain()
    return tick() - lastTeleportTime >= 2
end
local function isStuck(current, previous)
    return (current - previous).magnitude < deltaThreshold
end
local function getSafeNearbyBlock(currentPos)
    local Character = Player:WaitForChild("Character", 3)
    if not Character then
        notifyUser("Error", "Player Character not found.", 3)
        return
    end
    local searchRadius = 10
    local partsInRadius = workspace:FindPartsInRegion3(
        currentPos - Vector3.new(searchRadius, searchRadius, searchRadius),
        currentPos + Vector3.new(searchRadius, searchRadius, searchRadius),
        nil,
        math.huge
    )
    for _, part in ipairs(partsInRadius) do
        local _, _, isTopOpen, _ = checkSurroundings(part)
        if isTopOpen then
            return part.Position + Vector3.new(0, part.Size.Y/2 + 1, 0)
        end
    end
    return nil
end
-- Assuming you have a way to get the Player object
local Player = game.Players.LocalPlayer
-- Define a reasonable value for checkInterval (in seconds)
local checkInterval = 1
local function notifyUserDebug(message)
    -- This function will refresh the message every 0.1 seconds
    while true do
        notifyUser(message)
        wait(0.1)
    end
end
local function checkIfStuck()
    while wait(checkInterval) do
        if not Player then
            notifyUser("Error", "checkIfStuck() - Player missing.", 3)
            return
        end
        local Character = Player:WaitForChild("Character", 3)
        if not Character then
            notifyUser("Error", "checkIfStuck() - Character missing.", 3)
            return
        end
        if not Character:FindFirstChild("HumanoidRootPart") then
            notifyUser("Error", "checkIfStuck() - HumanoidRootPart missing.", 3)
            return
        end
        local previousPosition = Character.HumanoidRootPart.Position
        local currentPosition = Character.HumanoidRootPart.Position
        if previousPosition and currentPosition and isStuck(currentPosition, previousPosition) then
            local safePosition = getSafeNearbyBlock(currentPosition)
            if safePosition then
                Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
            else
                notifyUser("Stuck Check", "Couldn't find a safe Position!", 3)
            end
        end
        previousPosition = currentPosition
    end
end
local function flyJumpActive()
    if flyJumpActive then
        if flyjump then
            flyjump:Disconnect()
            flyjump = nil
        end
        flyJumpActive = false
    else
        flyjump = game:GetService("UserInputService").JumpRequest:Connect(function()
            Player.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        flyJumpActive = true
    end
end
local teleportOffset = Vector3.new(0, 6, 0)  -- Example offset, adjust as needed
local function getSafeTeleportPosition(targetPosition)
    if not targetPosition or typeof(targetPosition) ~= "Vector3" then
        notifyUser("Error", "Invalid target Position provided for teleportation.", 3)
        return nil
    end
    local potentialTeleportPosition = targetPosition + teleportOffset
    -- Check if the block at potentialTeleportPosition is empty
    if isEmpty(potentialTeleportPosition) then
        return potentialTeleportPosition
    else
        local alternativePosition = findAlternativeOpenBlockAbovePlayer()
        if not alternativePosition then
            notifyUser("Error", "Couldn't find an alternative safe Position.", 3)
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
-- Returns the nearest iron to the camera's position with an open space above
local function findNearestIron(cameraCFrame)
    local closestDistance = 50
    local closestIron = nil
    local regionSize = Vector3.new(10, 10, 10) -- Adjust the size of the search region as needed
    local regionCenter = cameraCFrame.Position
    local region3 = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Iron%d+_%d+") then
            local distance = (obj.Position - cameraCFrame.Position).Magnitude
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
local function getAutoTargets(Player)
    if not Player then
        notifyUser("Error", "getAutoTargets() - Player missing.", 3)
        return {}  -- Return an empty table
    end
    local Character = Player:WaitForChild("Character", 3)
    if not Character then
        notifyUser("Error", "getAutoTargets() - Character missing.", 3)
        return {}  -- Return an empty table
    end
    if not Character:FindFirstChild("HumanoidRootPart") then
        notifyUser("Error", "getAutoTargets() - HumanoidRootPart missing.", 3)
        return {}  -- Return an empty table
    end
    local currentPos = Character.HumanoidRootPart.Position
    local searchRadius = 10  -- Define an appropriate radius based on the game mechanics
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
local function isEmptyConsideringDepth(Position)
    local rayLength = 1
    local ray = Ray.new(Position, Vector3.new(0, -1, 0) * rayLength)  -- Pointing the ray downwards
    local block, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character})
    if block and block:IsA('BasePart') then
        rayLength = block.Size.Y + Player.Character.HumanoidRootPart.Size.Y + 1
    end
    return not block
end
-- Returns the nearest copper to the Player with an open space above 
-- Returns the nearest copper to the camera's position with an open space above
local function findNearestCopper()
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraCFrame = camera.CFrame
    local closestDistance = 50
    local closestCopper = nil
    local regionSize = Vector3.new(10, 10, 10) -- Adjust the size of the search region as needed
    local regionCenter = cameraCFrame.Position
    local region3 = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Copper%d+_%d+") then
            local distance = (obj.Position - cameraCFrame.Position).Magnitude
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
-- Returns the nearest gem to the camera's position with an open space above
local function findNearestGem()
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraCFrame = camera.CFrame
    local closestDistance = 50
    local closestGem = nil
    local regionSize = Vector3.new(10, 10, 10) -- Adjust the size of the search region as needed
    local regionCenter = cameraCFrame.Position
    local region3 = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Gem%d+_") then
            local distance = (obj.Position - cameraCFrame.Position).Magnitude
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
-- Function to find the nearest door and teleport the Player to it
function teleportToNearestDoor()
    local Character = Player:WaitForChild("Character", 3)
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        notifyUser("Error", "Player Character not found.", 3)
        return
    end
    local doors = game.Workspace:FindChildren(function(item)
        return item.Name == "TimeTrialDoor_1" or item.Name == "TimeTrialDoor_2" or item.Name == "TimeTrialDoor_3"
    end)
    local closestDoor = nil
    local shortestDistance = math.huge
    for _, door in ipairs(doors) do
        local distance = (Character.HumanoidRootPart.Position - door.Position).Magnitude
        if distance < shortestDistance then
            closestDoor = door
            shortestDistance = distance
        end
    end
    if closestDoor then
        Character.HumanoidRootPart.CFrame = CFrame.new(closestDoor.Position)
    end
end
-- Returns the nearest mystery block to the camera's position with an open space above
local function findNearestMystery()
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraCFrame = camera.CFrame
    local closestDistance = math.huge
    local closestMystery = nil
    local regionSize = Vector3.new(10, 10, 10) -- Adjust the size of the search region as needed
    local regionCenter = cameraCFrame.Position
    local region3 = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    for _, obj in ipairs(partsInRegion) do
        if (string.match(obj.Name, "^Mystery%d+_%d+$") or string.match(obj.Name, "^M%d+_%d+$")) then
            local distance = (obj.Position - cameraCFrame.Position).Magnitude
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
-- Returns the nearest chest to the camera's position with an open space above
local function findNearestChest()
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraCFrame = camera.CFrame
    local closestDistance = math.huge
    local closestChest = nil
    local regionSize = Vector3.new(10, 10, 10) -- Adjust the size of the search region as needed
    local regionCenter = cameraCFrame.Position
    local region3 = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Chest%d+_%d+") then
            local distance = (obj.Position - cameraCFrame.Position).Magnitude
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
-- Returns the nearest coal to the camera's position with an open space above
local function findNearestCoal()
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraCFrame = camera.CFrame
    local closestDistance = 50
    local closestCoal = nil
    local regionSize = Vector3.new(10, 10, 10) -- Adjust the size of the search region as needed
    local regionCenter = cameraCFrame.Position
    local region3 = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Coal%d+_%d+") then
            local distance = (obj.Position - cameraCFrame.Position).Magnitude
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
-- Returns the best block matching the itemPattern near the camera's position
function getBestBlock(itemPattern)
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraCFrame = camera.CFrame
    local Character = Player:WaitForChild("Character", 3)
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        notifyUser("Error", "Player Character not found.", 3)
        return nil
    end
    -- Define search region around the camera
    local centerPoint = cameraCFrame.Position
    local halfExtents = Vector3.new(750, 750, 750)  -- This gives a 150x150x150 region around the center point
    local searchRegion = Region3.new(centerPoint - halfExtents, centerPoint + halfExtents)
    local blocks = game.Workspace:FindPartsInRegion3(searchRegion, nil, 1000)
    local bestBlock = nil
    local closestDistance = math.huge
    local PlayerPosition = Character.HumanoidRootPart.Position
    for _, block in ipairs(blocks) do
        if string.match(block.Name, itemPattern) then
            local distance = (block.Position - PlayerPosition).Magnitude
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
local function updateCurrentPos(Player)
    currentPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position
end
local flareParts = {}
local function addFlare(Character) 
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
local function updateFlare(Character) 
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart") 
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
-- Function to disable Gemini Mode features
function DisableGeminiMode()
    -- Deactivate Gemini Mode logic here
    -- Example: Assuming you want to reset variables, you can do it here
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
        deactivateNoClip() -- Assuming you have a function to deactivate NoClip. If not, you'll need to implement the logic here.
        noclipActivatedInGeminiMode = false
    end
    enableAllGuiButtons()
    notifyUser("We're good.", "Back to fully normal, all changes reversed.", 5)
    geminiModeBtn.text = "Activate Gemini Mode"
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
            notifyUser("Error", "No safe Position found for teleportation.", 3)
        end
    else
        notifyUser("Error", "No valid special block found.", 3)
    end
end
local isGemTeleporting = false 
local isMysteryTeleporting = false 
local isCoalTeleporting = false 
local isChestTeleporting = false 
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
-- Connect to the Idled event
Player.Idled:Connect(antiidle)

function isTopSpaceEmpty(block)
    if block and block:IsA('BasePart') then
        local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
        local cameraPosition = camera.CFrame.Position
        local topPosition = block.Position + Vector3.new(0, block.Size.Y, 0)
        return isEmptyConsideringDepth(topPosition)
    end
    return false
end
function isEmpty(Position, checkAboveBlock)
    local rayLength = 1
    local ray = Ray.new(Position, Vector3.new(0, -1, 0) * rayLength)  -- Pointing the ray downwards
    local block, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character})
    if checkAboveBlock and block and block:IsA('BasePart') then
        rayLength = block.Size.Y + Player.Character.HumanoidRootPart.Size.Y + 1
    end
    return not block
end
function findAlternativeOpenBlockAbovePlayer()
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraPosition = camera.CFrame.Position
    local currentPos = cameraPosition -- Use the camera's position as the starting point
    local searchRadius = 10
    local region = Region3.new(
        currentPos - Vector3.new(searchRadius, searchRadius, searchRadius),
        currentPos + Vector3.new(searchRadius, searchRadius, searchRadius)
    )
    local partsInRadius = game.Workspace:FindPartsInRegion3(region, nil, math.huge)
    for _, part in ipairs(partsInRadius) do
        if isEmptyConsideringDepth(part.Position) then
            return part.Position + Vector3.new(0, part.Size.Y / 2 + 1, 0)
        end
    end
    return nil
end
function teleportToPosition(Position)
    if not Player then
        notifyUser("Error", "teleportToPosition() - Player missing.", 3)
        return
    end
    local Character = Player:WaitForChild("Character", 3)
    if not Character then
        notifyUser("Error", "teleportToPosition() - Character missing.", 3)
        return
    end
    if not Character:FindFirstChild("HumanoidRootPart") then
        notifyUser("Error", "teleportToPosition() - HumanoidRootPart missing.", 3)
        return
    end
    if Position and typeof(Position) == "Vector3" then
        Character.HumanoidRootPart.CFrame = CFrame.new(Position)
    else
        notifyUser("Teleportation Error", "Invalid Position provided.", 3)
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
function findNearestSpecialBlock()
    local camera = game.Workspace.CurrentCamera -- Replace with how you access your game's camera
    local cameraPosition = camera.CFrame.Position
    local currentPos = cameraPosition -- Use the camera's position as the starting point
    local searchRadius = 10
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

-- Function to enable Gemini Mode features
function EnableGeminiMode()
    -- Activate Gemini Mode logic here
    -- Example: Assuming you want to enable features
    isGeminiModeOn = true
    notifyUser("#WINNING", "Gemini Mode Enabled. Hang in there while we toggle...", 5)
    -- Store original FriendAmount
    originalFriendAmount = Player.FriendAmount.Value
    -- Set FriendAmount to 777
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
        
        notifyUser("Info", "NoClip Enabled!", 2)
        noclipActivatedInGeminiMode = true -- Set a flag to remember that NoClip was activated during Gemini Mode
    end
    removeterrain()
    notifyUser("Info", "Some bad Terrain Removed!", 2)
    -- Fullbright
    fullbright()
    notifyUser("Info", "Fullbright Enabled!", 2)
    
    notifyUser("xXGeminiXx", "Welcome to my world. Gemini Mode on.", 2)
--    enableAllGuiButtons()
end
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
-- Define variables to track toggle states
local removeObjectsToggle = false
local snipeModeToggle = false
local toggleFriendAmountToggle = false
local geminiModeToggle = false
local serverHopToggle = false
local gemTeleportToggle = false
local destroyGUIToggle = false
local teleportCopperToggle = false
-- Add Toggle Buttons
testingSection:AddButton({ text = "Remove Objects", callback = function()
    print("Button Callback Triggered...")
    if not removeObjectsToggle then
        removeObjectsByName(namesList)
    end
    -- Toggle the state
    removeObjectsToggle = not removeObjectsToggle
    -- Update the button text
    testingSection:GetButton("Remove Objects").text = removeObjectsToggle and "Stop Removing Objects" or "Remove Objects"
end })
mainSection:AddButton({ text = "Snipe Mode", callback = function()
    print("Button Callback Triggered...")
    if not snipeModeToggle then
        executeSnipeMode()
    end
    -- Toggle the state
    snipeModeToggle = not snipeModeToggle
    -- Update the button text
    mainSection:GetButton("Snipe Mode").text = snipeModeToggle and "Disable Snipe Mode" or "Snipe Mode"
end })
mainSection:AddButton({ text = "Toggle Friend Amount", callback = function()
    print("Button Callback Triggered...")
    local prop = Player:FindFirstChild("FriendAmount")
    if prop then
        if not toggleFriendAmountToggle then
            prop.Value = 777
            notifyUser("WTF", "OMG YOU'RE SO POPULAR!", 1)
            notifyUser("Info", "Friend Amount Set to 777!", 2)
        else
            -- Reset the FriendAmount to its original value
            prop.Value = originalFriendAmount
            notifyUser("Info", "Friend Amount Reset", 2)
        end
        -- Toggle the state
        toggleFriendAmountToggle = not toggleFriendAmountToggle
        -- Update the button text
        mainSection:GetButton("Toggle Friend Amount").text = toggleFriendAmountToggle and "Reset Friend Amount" or "Toggle Friend Amount"
    end
end })
-- Define variables to track toggle states
local geminiModeToggle = false
local serverHopToggle = false
local gemTeleportToggle = false
local destroyGUIToggle = false
local teleportCopperToggle = false

mainSection:AddButton({ text = "Gemini Mode", callback = function()
    print("Button Callback Triggered...")
    if not geminiModeToggle then
        EnableGeminiMode()
    end
    -- Toggle the state
    geminiModeToggle = not geminiModeToggle
    -- Update the button text
    --mainSection:GetButton("Gemini Mode").text = geminiModeToggle and "Deactivate Gemini Mode" or "Gemini Mode"
end })

mainSection:AddButton({ text = "Server Hop", callback = function()
    print("Button Callback Triggered...")
    if not serverHopToggle then
        serverhop()
    end
    -- Toggle the state
    serverHopToggle = not serverHopToggle
    -- Update the button text
    --mainSection:GetButton("Server Hop").text = serverHopToggle and "Stop Server Hop" or "Server Hop"
end })

teleportBtn = teleportSection:AddButton("Gem Teleport", function()
    print("Button Callback Triggered...")
    if not gemTeleportToggle then
        -- Add logic for Gem Teleport here
        local Character = Player:WaitForChild("Character", 3)
        if not Character then
            notifyUser("Error", "Player Character not found.", 3)
            return
        end
        isGemTeleporting = not isGemTeleporting
        if isGemTeleporting then 
            teleportSection:GetButton("Gem Teleport").text = "Stop Tele Gem"
            while isGemTeleporting do 
                if canTeleportAgain() then 
                    local gem = findNearestGem() 
                    if gem then 
                        local safePosition = getSafeTeleportPosition(gem.Position) 
                        Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                        lastTeleportTime = tick()
                    end 
                end 
                wait(1)  -- Check every second
            end 
        else 
            teleportSection:GetButton("Gem Teleport").text = "Gem Teleport"
        end
    end
    -- Toggle the state
    gemTeleportToggle = not gemTeleportToggle
    -- Update the button text
    teleportSection:GetButton("Gem Teleport").text = gemTeleportToggle and "Disable Gem Teleport" or "Gem Teleport"
end, true)

-- Destroy GUI Button
exitSection:AddButton({text = "Destroy GUI", callback = function()
    print("Button Callback Triggered...")
    -- resetAllChanges()
    -- This will destroy the entire Uwuware GUI
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChild("Hello, how are you today?") then
            v:Destroy()
        end
    end
end})

teleportSection:AddButton("Tele Copper", function()
    print("Button Callback Triggered...")
    if not teleportCopperToggle then
        -- Add logic for Teleport Copper here
        local Character = Player:WaitForChild("Character", 3)
        if not Character then
            notifyUser("Error", "Player Character not found.", 3)
            return
        end
        local copper = findNearestCopper()
        if copper then
            local safePosition = getSafeTeleportPosition(copper.Position)
            Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
        end
    end
    -- Toggle the state
    teleportCopperToggle = not teleportCopperToggle
    -- Update the button text
    teleportSection:GetButton("Tele Copper").text = teleportCopperToggle and "Disable Teleport Copper" or "Tele Copper"
end, true)


-- Define the buttons
local flyJumpButton = movementSection:AddButton({ text = "Fly Jump", callback = function()
    print("Button Callback Triggered...")
    if flyJumpActive then 
        if flyjump then  
            flyjump:Disconnect() 
            flyjump = nil
        end 
        flyJumpActive = false
    else
        -- Logic to activate fly jump here
        flyJumpActive = true
    end
    -- Update the button text when Fly Jump status changes
    flyJumpButton.text = flyJumpActive and "Disable Fly Jump" or "Fly Jump"
end })
local superSpeedButton -- Declare a variable to store the button reference

superSpeedButton = movementSection:AddButton({ text = "Super Speed", callback = function()
    print("Button Callback Triggered...")
    if not superSpeedEnabled then 
        Player.Character.Humanoid.WalkSpeed = 70
        notifyUser("Info", "Super Speed Enabled!", 3)
        superSpeedEnabled = true
    else 
        Player.Character.Humanoid.WalkSpeed = normalSpeed  -- Assuming normalSpeed is predefined
        notifyUser("Info", "Super Speed Disabled!", 3)
        superSpeedEnabled = false
    end
    -- Update the button text when Super Speed status changes
    superSpeedButton.text = superSpeedEnabled and "Disable Super Speed" or "Super Speed"
end })


-- Define variables to track toggle states
local noClipToggle = false
local teleGemToggle = false
local teleMysteryToggle = false
local teleCoalToggle = false
local teleCopperToggle = false
local teleChestToggle = false
local autoTeleportToggle = false
local cpsLabelToggle = false
-- Teleport to Nearest Door Button
teleportSection:AddButton({ text = "Teleport to Nearest Door", callback = function()
    print("Button Callback Triggered...")
    teleportToNearestDoor()
end })
-- NoClip Button
local noClipButton = movementSection:AddButton({ text = "NoClip", callback = function()
    print("Button Callback Triggered...")
    if noClipToggle then
        deactivateNoClip()
        noClipButton.text = "Activate NoClip"
        notifyUser("Info", "NoClip Disabled!", 2)
    else
        noclip()
        noClipButton.text = "Deactivate NoClip"
        notifyUser("Info", "NoClip Enabled!", 2)
    end
    -- Toggle the state
    noClipToggle = not noClipToggle
end })

-- Initialize the toggle state
local noClipToggle = false

-- Teleport to Gem Button
teleportSection:AddButton({ text = "Tele Gem", callback = function()
    print("Button Callback Triggered...")
    local Character = Player:WaitForChild("Character", 3)
    if not Character then
        notifyUser("Error", "Player Character not found.", 3)
        return
    end
    if teleGemToggle then
        teleportSection:GetButton("Tele Gem").text = "Tele Gem"
    else
        isGemTeleporting = true
        teleportSection:GetButton("Tele Gem").text = "Stop Tele Gem"
        while isGemTeleporting do
            if canTeleportAgain() then
                local gem = findNearestGem()
                if gem then
                    local safePosition = getSafeTeleportPosition(gem.Position)
                    Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                    lastTeleportTime = tick()
                end
            end
            wait(1)  -- Check every second
        end
    end
    -- Toggle the state
    teleGemToggle = not teleGemToggle
end })
-- Teleport to Mystery Block Button
teleportSection:AddButton({ text = "Tele Mystery", callback = function()
    print("Button Callback Triggered...")
    local Character = Player:WaitForChild("Character", 100)
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        notifyUser("Error", "Player or necessary parts missing.", 3)
        return
    end
    if teleMysteryToggle then
        teleportSection:GetButton("Tele Mystery").text = "Tele Mystery"
    else
        isMysteryTeleporting = true
        teleportSection:GetButton("Tele Mystery").text = "Stop Tele Mystery"
        while isMysteryTeleporting do
            if canTeleportAgain() then
                local mysteryBlock = findNearestMystery()
                if mysteryBlock then
                    local safePosition = getSafeTeleportPosition(mysteryBlock.Position)
                    if safePosition then
                        Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                        lastTeleportTime = tick()
                    else
                        notifyUser("Error", "Couldn't find a safe teleport Position.", 3)
                    end
                end
            end
            wait(2)  -- Check every 2 seconds
        end
    end
    -- Toggle the state
    teleMysteryToggle = not teleMysteryToggle
end })
-- Teleport to Coal Button
teleportSection:AddButton({ text = "Tele Coal", callback = function()
    print("Button Callback Triggered...")
    local Character = Player:WaitForChild("Character", 3)
    if not Character then
        notifyUser("Error", "Player Character not found.", 3)
        return
    end
    if teleCoalToggle then
        teleportSection:GetButton("Tele Coal").text = "Tele Coal"
    else
        isCoalTeleporting = true
        teleportSection:GetButton("Tele Coal").text = "Stop Tele Coal"
        while isCoalTeleporting do
            if canTeleportAgain() then
                local coal = findNearestCoal()  -- Assuming you have a function to find the nearest coal
                if coal then
                    local safePosition = getSafeTeleportPosition(coal.Position)
                    Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                end
            end
            wait(2)  -- Check every 2 seconds
        end
    end
    -- Toggle the state
    teleCoalToggle = not teleCoalToggle
end })
-- Teleport to Copper Button
teleportSection:AddButton({ text = "Tele Copper", callback = function()
    print("Button Callback Triggered...")
    local Character = Player:WaitForChild("Character", 3)
    if not Character then
        notifyUser("Error", "Player Character not found.", 3)
        return
    end
    if teleCopperToggle then
        teleportSection:GetButton("Tele Copper").text = "Tele Copper"
    else
        isCopperTeleporting = true
        teleportSection:GetButton("Tele Copper").text = "Stop Tele Copper"
        while isCopperTeleporting do
            if canTeleportAgain() then
                local copper = findNearestCopper()
                if copper then
                    local safePosition = getSafeTeleportPosition(copper.Position)
                    Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                end
            end
            wait(2)  -- Check every 2 seconds
        end
    end
    -- Toggle the state
    teleCopperToggle = not teleCopperToggle
end })
-- Teleport to Chest Button
teleportSection:AddButton({ text = "Tele Chest", callback = function()
    print("Button Callback Triggered...")
    local Character = Player:WaitForChild("Character", 3)
    if not Character then
        notifyUser("Error", "Player Character not found.", 3)
        return
    end
    if teleChestToggle then
        teleportSection:GetButton("Tele Chest").text = "Tele Chest"
    else
        isChestTeleporting = true
        teleportSection:GetButton("Tele Chest").text = "Stop Tele Chest"
        while isChestTeleporting do
            if canTeleportAgain() then
                local chest = findNearestChest()
                if chest then
                    local safePosition = getSafeTeleportPosition(chest.Position)
                    Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                    lastTeleportTime = tick()
                end
            end
            wait(1)  -- Check every second
        end
    end
    -- Toggle the state
    teleChestToggle = not teleChestToggle
end })
-- Auto-Teleport Toggle Button
teleportSection:AddButton({ text = "Auto Teleport", callback = function()
    print("Button Callback Triggered...")
    local Character = Player:WaitForChild("Character", 3)
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        notifyUser("Error", "Player Character not found.", 3)
        return
    end
    if autoTeleportToggle then
        if autoTeleportConnection then
            autoTeleportConnection:Disconnect()
            autoTeleportConnection = nil
        end
        teleportSection:GetButton("Auto Teleport").text = "Auto Teleport"
        notifyUser("Info", "Auto-Teleport Disabled!", 3)
    else
        autoTeleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not lastTeleportedBlock or checkBlockMined(lastTeleportedBlock) then
                wait(teleportCooldown)
                local gem = findNearestGem()
                if gem then
                    local gemPosition = gem.Position
                    local teleportOffset = Vector3.new(0, 6, 0)
                    local teleportPosition = gemPosition + teleportOffset
                    Character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
                    lastTeleportedBlock = gem
                end
            end
        end)
        teleportSection:GetButton("Auto Teleport").text = "Disable Auto Teleport"
        notifyUser("Info", "Auto-Teleport Enabled!", 3)
    end
    -- Toggle the state
    autoTeleportToggle = not autoTeleportToggle
end })
-- Initialize cpsLabelToggle and cpsLabel
local cpsLabelToggle = false
local cpsLabel = Instance.new("TextLabel") -- Create the Label

testingSection:AddButton({ text = "CPS Label", callback = function()
    print("Button Callback Triggered...")
    if cpsLabelToggle then
        cpsLabel.Text = "CPS: " .. cps
    else
        if isCpsToggling then return end  -- Check debounce
        isCpsToggling = true
        if isCpsOn then
            cpsLabel.Text = "Stop CPS"
            cps = tonumber(cpsInputBox.text) or 7  -- Fetch CPS rate from input box; default to 7 if invalid
            autoMine(cps)
        else
            cpsLabel.Text = "CPS: " .. cps
        end
        task.wait(0.5)  -- Debounce duration
        isCpsToggling = false
    end
    -- Toggle the state
    cpsLabelToggle = not cpsLabelToggle
end })

--spawn(checkIfStuck)
Library:Init()
