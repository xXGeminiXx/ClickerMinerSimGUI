-- GeminisClickerMinerSim Version 13 --
-- Introduced new gui using Uwuware.lua --
-- All credits to that GUI lib go to the original developer --
-- Created by xXGeminiXx --
print('Library Initialization Started...')
local isChestTeleporting = false
local lastTeleportTime = 0
local isGemTeleporting = false
local camera = game.Workspace.CurrentCamera
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xXGeminiXx/ClickerMinerSimGUI/main/Uwuware.lua", true))()
local window = Library:CreateWindow("CMS-PMS by xXGeminiXx")
local Player = game:GetService("Players") and game:GetService("Players").LocalPlayer or nil
if not Player then
    warn("LocalPlayer not found!")
    return
end
local Character = Player and Player:WaitForChild("Character", 1)
local RunService = game:GetService("RunService")
if not RunService then
    warn("RunService not found!")
    return
end
local Workspace = game:GetService("Workspace")
if not Workspace then
    warn("Workspace not found!")
    return
end
local TeleportService = game:GetService("TeleportService")
if not TeleportService then
    warn("TeleportService not found!")
    return
end
local originalTeleport = TeleportService.Teleport
-- Now use 'TeleportService' in places where you'd use 'game:GetService("TeleportService")'
local UserInputService = game:GetService("UserInputService")
if not UserInputService then
    warn("UserInputService not found!")
    return
end
local mineSizes = {
    ["Starter Mine"] = 100,
    ["Gem Mine"] = 101,
    ["Frozen Mine"] = 102,
    ["Lava Mine"] = 103,
    ["Desert Mine"] = 104,
    ["Poisonous Mine"] = 105,
    ["Sakura Mine"] = 106,
    ["Bamboo Mine"] = 107,
    ["Sea Mine"] = 108,
    ["Savannah Mine"] = 109,
    -- ... add additional mines as you discover them
}
local blockTypes = {
    "Air", "Boundary", "TransparentBoundary", "Dirt", "Chest", "TimeTrialDoor_1", "TimeTrialDoor_2", "TimeTrialDoor_3",
    "Dirt1_1", "Dirt1_2", "Dirt1_3", "Dirt1_4", "Dirt2_1", "Dirt2_2", "Dirt2_3", "Dirt2_4", "Dirt3_1", "Dirt3_2",
    "Dirt3_3", "Dirt3_4", "Dirt4_1", "Dirt4_2", "Dirt4_3", "Dirt4_4", "Dirt5_1", "Dirt5_2", "Dirt5_3", "Dirt5_4",
    "Dirt6_1", "Dirt6_2", "Dirt6_3", "Dirt6_4", "Chest1_1", "Chest1_2", "Chest1_3", "Chest1_4", "Chest2_1", "Chest2_2",
    "Chest2_3", "Chest2_4", "Chest3_1", "Chest3_2", "Chest3_3", "Chest3_4", "Chest4_1", "Chest4_2", "Chest4_3", "Chest4_4",
    "Chest5_1", "Chest5_2", "Chest5_3", "Chest5_4", "Chest6_1", "Chest6_2", "Chest6_3", "Chest6_4", "M1_1", "M1_2",
    "M1_3", "M1_4", "M2_1", "M2_2", "M2_3", "M2_4", "M3_1", "M3_2", "M3_3", "M3_4", "M4_1", "M4_2", "M4_3", "M4_4",
    "M5_1", "M5_2", "M5_3", "M5_4", "M6_1", "M6_2", "M6_3", "M6_4", "M7_1", "M7_2", "script", "M7_4", "M8_1", "M8_2",
    "script", "M8_4", "M9_1", "M9_2", "M9_3", "M9_4", "Gem1_3", "Gem1_4", "Gem2_1", "Gem2_2", "Gem2_3", "Gem2_4",
    "Gem3_1", "Gem3_2", "Gem3_3", "Gem3_4", "Gem4_1", "Gem4_2", "Gem4_3", "Gem4_4", "Gem5_1", "Gem5_2", "Gem5_3",
    "Gem5_4", "Gem6_1", "Gem6_2", "Gem6_3", "Gem6_4", "Copper2_1", "Copper2_2", "Copper2_3", "Copper2_4", "Copper3_1",
    "Copper3_2", "Copper3_3", "Copper3_4", "Copper4_1", "Copper4_2", "Copper4_3", "Copper4_4", "Copper5_1", "Copper5_2",
    "Copper5_3", "Copper5_4", "Copper6_1", "Copper6_2", "Copper6_3", "Copper6_4", "Iron2_1", "Iron2_2", "Iron2_3", "Iron2_4",
    "Iron3_1", "Iron3_2", "Iron3_3", "Iron3_4", "Iron4_1", "Iron4_2", "Iron4_3", "Iron4_4", "Iron5_1", "Iron5_2", "Iron5_3",
    "Iron5_4", "Iron6_1", "Iron6_2", "Iron6_3", "Iron6_4", "Coal2_1", "Coal2_2", "Coal2_3", "Coal2_4", "Coal3_1", "Coal3_2",
    "Coal3_3", "Coal3_4", "Coal4_1", "Coal4_2", "Coal4_3", "Coal4_4", "Coal5_1", "Coal5_2", "Coal5_3", "Coal5_4", "Coal6_1",
    "Coal6_2", "Coal6_3", "Coal6_4", "EasterEgg1_1", "EasterEgg1_2", "EasterEgg1_3", "EasterEgg1_4", "EasterEgg1_5", "EasterEgg2_1",
    "EasterEgg2_2", "EasterEgg2_3", "EasterEgg2_4", "EasterEgg2_5", "EasterEgg3_1", "EasterEgg3_2", "EasterEgg3_3", "EasterEgg3_4",
    "EasterEgg3_5", "EasterEgg4_1", "EasterEgg4_2", "EasterEgg4_3", "EasterEgg4_4", "EasterEgg4_5", "EasterEgg5_1", "EasterEgg5_2",
    "EasterEgg5_3", "EasterEgg5_4", "EasterEgg5_5", "EasterEgg6_1", "EasterEgg6_2", "EasterEgg6_3", "EasterEgg6_4", "EasterEgg6_5",
    "EasterEgg7_1", "EasterEgg7_2", "EasterEgg7_3", "EasterEgg7_4", "EasterEgg7_5", "Dirt8_1", "Dirt8_2", "Dirt8_3", "Dirt8_4",
    "Chest8_1", "Chest8_2", "Chest8_3", "Chest8_4", "Gem8_1", "Gem8_2", "Gem8_3", "Gem8_4", "Copper8_1", "Copper8_2", "Copper8_3",
    "Copper8_4", "Iron8_1", "Iron8_2", "Iron8_3", "Iron8_4", "Coal8_1", "Coal8_2", "Coal8_3", "Coal8_4", "EasterEgg8_1", "EasterEgg8_2",
    "EasterEgg8_3", "EasterEgg8_4", "EasterEgg8_5", "Empty"
}
local blockPattern = "^(?:Chest\\d+_\\d+|Copper\\d+_\\d+|Iron\\d+_\\d+|Coal\\d+_\\d+|Gem\\d+_\\d+|Mystery\\d+_\\d+|M\\d+_\\d+|EasterEgg\\d+_\\d+)$"
cameraCFrame = cameraCFrame or game.Workspace.CurrentCamera.CFrame
local regionCenter = cameraCFrame.Position
local region3 = Region3.new(regionCenter - Vector3.new(50, 75, 50), regionCenter + Vector3.new(50, 25, 50))
local prop = Player:FindFirstChild("FriendAmount")
local Clip = false -- Or true, based on the default state you want
local userInputService = game:GetService("UserInputService")
local awaitingCpsInput = false
local removeObjectsToggle = false
local snipeModeToggle = false
local toggleFriendAmountToggle = false
local serverHopToggle = false
local gemTeleportToggle = false
local destroyGUIToggle = false
local teleportCopperToggle = false
-- Add Toggle Buttons
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
local bestBlock = nil
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")  -- Retrieve the Players service
local mainSection = window:AddFolder("Main")
local movementSection = window:AddFolder("Movement")
local teleportSection = window:AddFolder("Teleports")
local testingSection = window:AddFolder("Testing")
local exitSection = window:AddFolder("Exit")
local mainFrame = Instance.new("Frame") 
local cpsInputValue = 7  -- Default value
local cpsInputButton = testingSection:AddButton({
    text = "Set CPS (Click and type a number)",
    callback = function()
        if not awaitingCpsInput then
            cpsInputButton.text = "Enter a number (1-9) for CPS..."
            awaitingCpsInput = true
        end
    end
})
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
print("Script initialization started.")  
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
            customNotifyUser("Gemini Mode", "Removed " .. removedCount .. " instances of '" .. name .. "'.", .3)
        else
            customNotifyUser("Gemini Mode", "No instances of '" .. name .. "' found to remove.", .1)
        end
        --wait(0.2)  -- Reducing wait time to speed up the function
    end
end
local lastTeleportTime = 0 -- Initialize with a default value
function canTeleportAgain()
    local currentTime = tick()
    if currentTime - lastTeleportTime < teleportCooldown then
        notifyUser("Teleport Check", "Teleport cooldown not yet passed. Wait for " .. tostring(teleportCooldown - (currentTime - lastTeleportTime)) .. " seconds.", 3)
        return false
    end
    return true
end
local function isStuck(current, previous)
    if current and previous then
        return (current - previous).magnitude < deltaThreshold
    else
        return false  -- Handle the case where either current or previous is nil
    end
end
function getSafeNearbyBlock(currentPos)
    local Camera = workspace.CurrentCamera
    if not currentPos then
        currentPos = Camera.CFrame.Position
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
            notifyUser("Info", "Found a safe nearby block.", 3)
            return part.Position + Vector3.new(0, part.Size.Y/2 + 1, 0)
        end
    end
    notifyUser("Info", "No safe nearby blocks found.", 3)
    return nil
end
local Player = game.Players.LocalPlayer
-- Enhanced checkIfStuck function
-- This function checks if the player's position has remained unchanged over a period of time.
-- If unchanged, it assumes the player is stuck and attempts a recovery by moving the player vertically.
local lastCheckedPosition = nil
local stuckThreshold = 5  -- Time in seconds to consider the player as stuck
local lastCheckTime = nil
function checkIfStuck()
    local currentTime = tick()
    
    -- If this is the first check, initialize the lastCheckedPosition and lastCheckTime
    if not lastCheckedPosition or not lastCheckTime then
        lastCheckedPosition = Player.Character.HumanoidRootPart.Position
        lastCheckTime = currentTime
        return false
    end
    
    -- Calculate the distance moved since the last check
    local distanceMoved = (Player.Character.HumanoidRootPart.Position - lastCheckedPosition).Magnitude
    
    -- If the player hasn't moved significantly and the time exceeds the threshold, they are considered stuck
    if distanceMoved < 1 and (currentTime - lastCheckTime) > stuckThreshold then
        notifyUser("Warning", "Player seems to be stuck. Attempting recovery.", 3)
        
        -- Attempt to recover by moving the player up
        Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
        
        -- Reset the lastCheckedPosition and lastCheckTime
        lastCheckedPosition = Player.Character.HumanoidRootPart.Position
        lastCheckTime = currentTime
        return true
    end
    
    -- Update the lastCheckedPosition and lastCheckTime for the next check
    lastCheckedPosition = Player.Character.HumanoidRootPart.Position
    lastCheckTime = currentTime
    
    return false
end

local function toggleFlyJump()
    if flyjumpActive then
        if flyjump then
            flyjump:Disconnect()
            flyjump = nil
        end
        flyjumpActive = false
        customNotifyUser("Gemini Mode", "Fly Jump Disabled!", 2)
    else
        flyjump = game:GetService("UserInputService").JumpRequest:Connect(function()
            Player.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        flyjumpActive = true
        customNotifyUser("Gemini Mode", "Fly Jump Enabled!", 2)
    end
end
local teleportOffset = Vector3.new(0, 6, 0)  -- Example offset, adjust as needed


-- Function to check if a block has been mined
local function checkBlockMined(block)
    -- If the block doesn't exist or doesn't have a parent (indicating it's been removed from the game.Workspace or its original parent)
    if not block or not block.Parent then
        return true  -- The block is considered mined
    end
    return false  -- The block is not mined
end
-- Returns the nearest iron to the camera's position with an open space above
local function findNearestIron()
    local camera = game.Workspace.CurrentCamera
    local closestDistance = math.huge
    local closestIron = nil
    local regionCenter = camera.CFrame.Position
    local region3 = Region3.new(regionCenter - Vector3.new(1000, 1500, 1000), regionCenter + Vector3.new(1000, 500, 1000))
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    local ironBlocksFound = 0
    local rejectedBlocks = 0

    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Iron%d+_%d+") then
            ironBlocksFound = ironBlocksFound + 1
            if obj.Position.Y <= Player.Character.HumanoidRootPart.Position.Y + 10 and isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y, 0)) then
                local distance = (obj.Position - camera.CFrame.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestIron = obj
                end
            else
                rejectedBlocks = rejectedBlocks + 1
            end
        end
    end
    
    if not closestIron then
        if ironBlocksFound == 0 then
            notifyUser("Info", "No iron blocks found in the search region.", 3)
        else
            notifyUser("Info", "Found " .. ironBlocksFound .. " iron blocks, but " .. rejectedBlocks .. " were rejected due to checks.", 3)
        end
    else
        notifyUser("Success", "Teleporting to a valid iron block.", 3)
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
local function isSpaceAboveEmpty(Position)
    local rayLength = 3
    local ray = Ray.new(Position, Vector3.new(0, 1, 0) * rayLength)  -- Pointing the ray upwards for 3 units
    local block, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character})
    return not block
end

-- Returns the nearest copper to the camera's position with an open space above
local function findNearestCopper()
    local camera = game.Workspace.CurrentCamera
    local closestDistance = math.huge
    local closestCopper = nil
    local regionCenter = camera.CFrame.Position
    local region3 = Region3.new(regionCenter - Vector3.new(1000, 1500, 1000), regionCenter + Vector3.new(1000, 500, 1000))
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    local copperBlocksFound = 0
    local rejectedBlocks = 0

    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Copper%d+_%d+") then
            copperBlocksFound = copperBlocksFound + 1
            if obj.Position.Y <= Player.Character.HumanoidRootPart.Position.Y + 10 and isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y, 0)) then
                local distance = (obj.Position - camera.CFrame.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestCopper = obj
                end
            else
                rejectedBlocks = rejectedBlocks + 1
            end
        end
    end
    
    if not closestCopper then
        if copperBlocksFound == 0 then
            notifyUser("Info", "No copper blocks found in the search region.", 3)
        else
            notifyUser("Info", "Found " .. copperBlocksFound .. " copper blocks, but " .. rejectedBlocks .. " were rejected due to checks.", 3)
        end
    else
        notifyUser("Success", "Teleporting to a valid copper block.", 3)
    end

    return closestCopper
end

-- Returns the nearest gem to the camera's position with an open space above
local function findNearestGem()
    local camera = game.Workspace.CurrentCamera
    local closestDistance = math.huge
    local closestGem = nil
    local regionCenter = camera.CFrame.Position
    local region3 = Region3.new(regionCenter - Vector3.new(1000, 1500, 1000), regionCenter + Vector3.new(1000, 500, 1000))
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    local gemBlocksFound = 0
    local rejectedBlocks = 0

    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Gem%d+_%d+") then
            gemBlocksFound = gemBlocksFound + 1
            if obj.Position.Y <= Player.Character.HumanoidRootPart.Position.Y + 10 and isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y, 0)) then
                local distance = (obj.Position - camera.CFrame.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestGem = obj
                end
            else
                rejectedBlocks = rejectedBlocks + 1
            end
        end
    end
    
    if not closestGem then
        if gemBlocksFound == 0 then
            notifyUser("Info", "No gem blocks found in the search region.", 3)
        else
            notifyUser("Info", "Found " .. gemBlocksFound .. " gem blocks, but " .. rejectedBlocks .. " were rejected due to checks.", 3)
        end
    else
        notifyUser("Success", "Teleporting to a valid gem block.", 3)
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
function isMysteryBlock(block)
    if not block or not block.Name then
        return false
    end
    -- Check if the block name follows the pattern Mx_y
    local mine_num, layer_num = block.Name:match("M(%d+)_(%d+)")
    if mine_num and layer_num then
        return true
    end
    -- The previous check for "Mystery" can be retained if there are blocks with just that name
    if block.Name == "Mystery" then
        return true
    end
    return false
end
-- Enhanced findNearestMystery function
-- This function prioritizes mystery blocks based on the available open space above them.
-- Blocks with direct open space above are prioritized, followed by blocks with open space 2 or 3 units above.
local function findNearestMystery()
    local camera = game.Workspace.CurrentCamera
    local closestDistance = math.huge
    local closestMystery = nil
    local regionCenter = camera.CFrame.Position
    local region3 = Region3.new(regionCenter - Vector3.new(1000, 1500, 1000), regionCenter + Vector3.new(1000, 500, 1000))
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    local mysteryBlocksFound = 0
    local rejectedBlocks = 0
    
    -- Tables to hold blocks based on priority
    local priority1Blocks = {}  -- Blocks with direct open space above
    local priority2Blocks = {}  -- Blocks with open space 2 units above
    local priority3Blocks = {}  -- Blocks with open space 3 units above
    
    for _, obj in ipairs(partsInRegion) do
        if isMysteryBlock(obj) then
            mysteryBlocksFound = mysteryBlocksFound + 1
            if obj.Position.Y <= Player.Character.HumanoidRootPart.Position.Y + 10 then
                if isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y, 0)) then
                    table.insert(priority1Blocks, obj)
                elseif isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y*2, 0)) then
                    table.insert(priority2Blocks, obj)
                elseif isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y*3, 0)) then
                    table.insert(priority3Blocks, obj)
                else
                    rejectedBlocks = rejectedBlocks + 1
                end
            end
        end
    end
    
    -- Find the closest block based on priority
    local function findClosest(blocks)
        for _, block in ipairs(blocks) do
            local distance = (block.Position - camera.CFrame.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestMystery = block
            end
        end
    end
    
    findClosest(priority1Blocks)
    if not closestMystery then
        findClosest(priority2Blocks)
    end
    if not closestMystery then
        findClosest(priority3Blocks)
    end
    
    if not closestMystery then
        if mysteryBlocksFound == 0 then
            --notifyUser("Info", "No mystery blocks found in the search region.", .3)
			--print("Info: No mystery blocks found in the search region.")

        else
            --notifyUser("Info", "Found " .. mysteryBlocksFound .. " mystery blocks, but " .. rejectedBlocks .. " were rejected due to checks.", .3)
			--print("Info: Found " .. mysteryBlocksFound .. " mystery blocks, but " .. rejectedBlocks .. " were rejected due to checks.")

        end
    else
        notifyUser("Success", "Teleporting to a valid mystery block.", .1)
		--print("Success: Teleporting to a valid mystery block.")

    end
    return closestMystery
end

-- Returns the nearest chest to the camera's position with an open space above
local function findNearestChest()
    local camera = game.Workspace.CurrentCamera
    local closestDistance = math.huge
    local closestChest = nil
    local regionCenter = camera.CFrame.Position
    local region3 = Region3.new(regionCenter - Vector3.new(1000, 1500, 1000), regionCenter + Vector3.new(1000, 500, 1000))
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    local chestBlocksFound = 0
    local rejectedBlocks = 0

    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Chest%d+_%d+") then
            chestBlocksFound = chestBlocksFound + 1
            if obj.Position.Y <= Player.Character.HumanoidRootPart.Position.Y + 10 and isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y, 0)) then
                local distance = (obj.Position - camera.CFrame.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestChest = obj
                end
            else
                rejectedBlocks = rejectedBlocks + 1
            end
        end
    end
    
    if not closestChest then
        if chestBlocksFound == 0 then
            notifyUser("Info", "No chest blocks found in the search region.", 3)
        else
            notifyUser("Info", "Found " .. chestBlocksFound .. " chest blocks, but " .. rejectedBlocks .. " were rejected due to checks.", 3)
        end
    else
        notifyUser("Success", "Teleporting to a valid chest block.", 3)
    end

    return closestChest
end
-- Returns the nearest coal to the camera's position with an open space above
local function findNearestCoal()
    local camera = game.Workspace.CurrentCamera
    local cameraCFrame = game.Workspace.CurrentCamera.CFrame
    local closestDistance = 50
    local closestCoal = nil
    local teleportPosition = nil
    local regionSize = Vector3.new(1000, 1000, 1000)
    local regionCenter = cameraCFrame.Position
    local region3 = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    for _, obj in ipairs(partsInRegion) do
        if string.match(obj.Name, "Coal%d+_%d+") and obj.Position.Y <= Player.Character.HumanoidRootPart.Position.Y + 10 then
            local distance = (obj.Position - cameraCFrame.Position).Magnitude
            -- Check space above up to 3 blocks high
            for i = 1, 3 do
                if isSpaceAboveEmpty(obj.Position + Vector3.new(0, obj.Size.Y + i, 0)) then
                    teleportPosition = obj.Position + Vector3.new(0, obj.Size.Y + i, 0)
                    break
                end
            end
            if distance < closestDistance and teleportPosition then
                closestDistance = distance
                closestCoal = obj
            end
        end
    end
    if not closestCoal then
        notifyUser("Error", "No accessible coal found nearby.", 3)
    end
    return closestCoal, teleportPosition
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
-- Returns the best block matching the itemPattern near the camera's position
function getBestBlock(itemPattern)
    local camera = game.Workspace.CurrentCamera
    local centerPoint = camera.CFrame.Position
    local halfExtents = Vector3.new(750, 750, 750)
    local searchRegion = Region3.new(centerPoint - halfExtents, centerPoint + halfExtents)
    local blocks = game.Workspace:FindPartsInRegion3(searchRegion, nil, 1000)
    local bestBlock = nil
    local closestDistance = math.huge
    local PlayerPosition = camera.CFrame.Position
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
        notifyUser("Snipe Mode", "No block found for pattern: " .. itemPattern, 3)
    else
        notifyUser("Success", "Best block found for pattern: " .. itemPattern, 3)
    end
    return bestBlock or nil
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

-- Enhanced isBlockSurrounded function
-- This function checks if a block is surrounded on all sides using raycasting.
function isBlockSurrounded(block)
    local directions = {
        Vector3.new(1, 0, 0),  -- right
        Vector3.new(-1, 0, 0),  -- left
        Vector3.new(0, 0, 1),  -- forward
        Vector3.new(0, 0, -1),  -- backward
        Vector3.new(0, 1, 0),  -- up
        Vector3.new(0, -1, 0)  -- down
    }
    
    for _, direction in ipairs(directions) do
        local ray = Ray.new(block.Position, direction * block.Size)
        local hit, _ = workspace:FindPartOnRay(ray)
        if not hit then
            return false  -- If any side is open, the block isn't surrounded
        end
    end
    
    return true  -- If all sides have a hit, the block is surrounded
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

local Noclipping = nil
local Clip = true
local originalCollideStates = {}

function noclip()
    Clip = false
    wait(0.1)
    local function NoclipLoop()
        if not Clip and Players.LocalPlayer.Character then
            for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide and child.Name ~= floatName then
                    if not originalCollideStates[child] then 
                        originalCollideStates[child] = child.CanCollide
                    end
                    child.CanCollide = false
                end
            end
        end
    end
    Noclipping = game:GetService("RunService").Stepped:Connect(NoclipLoop)
end

function deactivateNoClip()
    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
    end
    Clip = true
    wait(0.1)  -- Add a small delay to ensure the noclip loop has ceased
    if Players.LocalPlayer.Character then
        for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") then
                if originalCollideStates[child] then
                    child.CanCollide = originalCollideStates[child]
                    originalCollideStates[child] = nil  -- Clear the stored state
                else
                    child.CanCollide = true  -- Default to true if we don't have an original state
                end
            end
        end
    end
end

function getSafestBlock()
    -- Define the camera position as the region center
    local regionCenter = workspace.CurrentCamera.CFrame.Position
    -- Define the search region based on the camera position
    local region3 = Region3.new(regionCenter - Vector3.new(1000, 1500, 1000), regionCenter + Vector3.new(1000, 500, 1000))
    -- Find all parts within the defined region
    local partsInRegion = workspace:FindPartsInRegion3(region3, nil, math.huge)
    -- Filter out only the mystery blocks
    local mysteryBlocks = {}
    for _, part in pairs(partsInRegion) do
        if part and part.Name and string.match(part.Name, "M%d+_") then -- Adjusted to the new naming pattern
            table.insert(mysteryBlocks, part)
        end
    end
    -- Sort the mystery blocks based on distance to the camera position
    table.sort(mysteryBlocks, function(a, b)
        return (a.Position - regionCenter).Magnitude < (b.Position - regionCenter).Magnitude
    end)
    -- Check each mystery block for safety and return the first safe one found
    for _, mysteryBlock in pairs(mysteryBlocks) do
        if isSafeToTeleport(mysteryBlock) then
            notifyUser("Success", "Found a safe mystery block to teleport.", 3)
            return mysteryBlock
        end
    end
    notifyUser("Info", "No safe mystery blocks found in the region.", 3)
    return nil
end
function deactivateFullbright()
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = 1
    Lighting.ClockTime = 14  -- This remains unchanged as it's set to 14 in the fullbright function
    Lighting.FogEnd = 10000  -- This is a default value, adjust if your game uses a different value
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)  -- Default value, adjust if needed
end
-- clientantiteleport: Prevent client from being teleported by the server (basic implementation) 
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
function autoMine()
    local cpsValue = tonumber(cpsInputBox:GetValue()) or 7 -- Get value from the textbox, default to 7 if invalid
    local isAutoMining = true  -- Refined auto-mining logic based on server-side mechanics
    NotifyUser("AutoMine Activated!", "Why do miners never tell secrets? They can't keep things under rock!")
    task.spawn(
        function()
            while isAutoMining do  -- Check the flag in the loop
                game:GetService("ReplicatedStorage").Remotes.Click:InvokeServer()
                task.wait(1/cpsValue) -- Adjust the wait time based on CPS value
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
    if Player and Player.Character and Player.Character.Humanoid then
        Player.Character.Humanoid.WalkSpeed = normalSpeed
    end
    -- 3. Flare Effect
    removeFlare()
    if flareUpdateConnection then
        flareUpdateConnection:Disconnect()
        flareUpdateConnection = nil
    end
    -- 4. Friend Amount
    if Player and Player.FriendAmount and originalFriendAmount then
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

-- Enhanced findAlternativePosition function
-- This function attempts to find an alternative teleport position close to the original one.
function findAlternativePosition(originalPosition)
    local safeRadius = 10  -- a radius in which we consider an alternative position
    local bestAlternative = nil
    local shortestDistance = math.huge
    
    for angle = 0, 360, 10 do  -- checking every 10 degrees
        local xOffset = safeRadius * math.cos(math.rad(angle))
        local zOffset = safeRadius * math.sin(math.rad(angle))
        local potentialPosition = originalPosition + Vector3.new(xOffset, 0, zOffset)
        
        -- Calculate distance to the original position
        local distance = (potentialPosition - originalPosition).Magnitude
        
        if distance < shortestDistance then
            bestAlternative = potentialPosition
            shortestDistance = distance
        end
    end
    
    return bestAlternative
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
    local camera = game.Workspace.CurrentCamera
    local cameraPosition = camera.CFrame.Position
    local searchRadius = 1000
    local region = Region3.new(
        cameraPosition - Vector3.new(searchRadius, searchRadius, searchRadius),
        cameraPosition + Vector3.new(searchRadius, searchRadius, searchRadius)
    )
    local partsInRadius = game.Workspace:FindPartsInRegion3(region, nil, math.huge)
    local nearestSpecialBlock = nil
    local shortestDistance = math.huge
    for _, part in ipairs(partsInRadius) do
        if not string.match(part.Name, "^Dirt%d+_%d+$") and part.Position.Y <= Player.Character.HumanoidRootPart.Position.Y + 10 then
            local distance = (cameraPosition - part.Position).magnitude
            if distance < shortestDistance and isSpaceAboveEmpty(part.Position + Vector3.new(0, part.Size.Y, 0)) then
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

function isSafeToTeleport(mysteryBlock)
    -- Check the space above
    if not isSpaceAboveEmpty(mysteryBlock.Position + Vector3.new(0, mysteryBlock.Size.Y, 0)) then
        notifyUser("Info", "Space above mystery block is not empty.", 3)
        return false
    end
    
    -- Any other checks can be added here
    return true
end
function comprehensiveSafetyCheck(position)
    -- Check if position exists and is of type Vector3
    if not position or typeof(position) ~= "Vector3" then
        notifyUser("Safety Check", "Invalid position provided.", 3)
        return false
    end
    -- Check if player would be stuck at the target position
    if isStuck(position) then
        notifyUser("Safety Check", "Player would be stuck at target position.", 3)
        return false
    end
    -- Any other checks can be added here with corresponding notifications
    notifyUser("Safety Check", "Position is safe for teleport.", 3)
    return true -- If all checks pass, return true
end
-- Define variables to track toggle states
local serverHopToggle = false
local gemTeleportToggle = false
local destroyGUIToggle = false
local teleportCopperToggle = false
local teleGemToggle = false
local teleMysteryToggle = false
local teleCoalToggle = false
local teleCopperToggle = false
local teleChestToggle = false
local autoTeleportToggle = false
local cpsLabelToggle = false
-- NoClip Button
-- Server Hop Button
-- Toggle Friend Amount Button
local toggleFriendAmountToggle = mainSection:AddToggle({
    text = "Toggle Friend Amount",
    callback = function(state)
        local prop = Player:FindFirstChild("FriendAmount")
        if prop then
            if state then
                prop.Value = 777
                notifyUser("WTF", "OMG YOU'RE SO POPULAR!", 1)
                notifyUser("Info", "Friend Amount Set to 777!", 2)
            else
                prop.Value = originalFriendAmount
                notifyUser("Info", "Friend Amount Reset", 2)
            end
        end
    end
})

-- Snipe Mode Button
local snipeModeToggle = mainSection:AddToggle({
    text = "Snipe Mode",
	textColor = Color3.new(0, 128, 255),       -- Text Color
    callback = function(state)
        executeSnipeMode()
    end
})
-- Gemini Mode Button
local geminiModeToggle = mainSection:AddToggle({
    text = "Gemini Mode",
    tooltip = "Enable Gemini Mode for advanced features.",
    textSize = 25,                               -- Custom text size
    textColor = Color3.new(255, 50, 50),       -- Text Color
    callback = function(state)
        if state then
            EnableGeminiMode()
            notifyUser("Gemini Mode Enabled", "You now have access to advanced features.", 2)
        else
            DisableGeminiMode()
            notifyUser("Gemini Mode Disabled", "Advanced features are now turned off.", 2)
        end
    end,
})
-- Remove Objects Button
local removeObjectBtn = mainSection:AddButton({ 
    text = "Remove Objects", 
    callback = function()
        print("Button Callback Triggered...")
        -- Ensure removeObjectBtn is initialized
        if not removeObjectBtn then return end
        if not removeObjectsToggle then
            removeObjectsByName(namesList)
        end
        removeObjectsToggle = not removeObjectsToggle
        removeObjectBtn.text = removeObjectsToggle and "Stop Removing Objects" or "Remove Objects"
    end 
})
local serverHopBtn = mainSection:AddButton({ 
    text = "Server Hop", 
    callback = function()
        print("Button Callback Triggered...")
        -- Ensure the serverHopBtn is initialized
        -- if not serverHopBtn then return end
        if not serverHopToggle then
            serverhop()
        end
        serverHopToggle = not serverHopToggle
        serverHopBtn.text = serverHopToggle and "Stop Server Hop" or "Server Hop"
    end 
})
-- Fly Jump Button
local flyJumpToggle = movementSection:AddToggle({
    text = "Fly Jump",
    callback = function(state)
        if state then
            if not flyJumpActive then
                flyJumpActive = true
				callback = toggleFlyJump
                customNotifyUser("Gemini Mode", "Fly Jump Enabled!", 2)
            end
        else
            if flyJumpActive then
                if flyjump then  
                    flyjump:Disconnect()
                    flyjump = nil
                end 
                flyJumpActive = false
                customNotifyUser("Gemini Mode", "Fly Jump Disabled!", 2)
            end
        end
    end
})
-- Super Speed Button
local superSpeedToggle = movementSection:AddToggle({
    text = "Super Speed",
    callback = function(state)
        if state then
            Player.Character.Humanoid.WalkSpeed = 55
            customNotifyUser("Info", "Super Speed Enabled!", 3)
        else
            Player.Character.Humanoid.WalkSpeed = normalSpeed
            customNotifyUser("Info", "Super Speed Disabled!", 3)
        end
    end
})
local noClipToggle = movementSection:AddToggle({
    text = "NoClip",
    callback = function(state)
        if state then
            noclip()
            notifyUser("Info", "NoClip Enabled!", 2)
        else
            deactivateNoClip()
            notifyUser("Info", "NoClip Disabled!", 2)
        end
    end
})
local function getSafeTeleportPosition(targetPosition)
    local possible_offsets = {Vector3.new(0, 1, 0), Vector3.new(0, 2, 0), Vector3.new(0, 3, 0)}
    for _, offset in ipairs(possible_offsets) do
        local checkPosition = targetPosition + offset
        if isSpaceAboveEmpty(checkPosition) then
            return checkPosition
        end
    end
    return nil  -- Return nil if no suitable position is found
end
-- Enhanced Teleport to Mystery Block Toggle function
-- This function uses the enhanced findNearestMystery for improved block selection.
-- After each teleport, the function checks if the player is stuck using the enhanced checkIfStuck function.
-- It introduces regular up and down movements to ensure the player is constantly moving while mining.
-- The waiting time between teleports has been reduced for a faster operation.

local teleMysteryToggle = teleportSection:AddToggle({
    text = "Tele Mystery",
    callback = function(state)
        if state then
            isMysteryTeleporting = true
            while isMysteryTeleporting do
                if canTeleportAgain() then
                    local mysteryBlock = findNearestMystery()
                    if mysteryBlock then
                        local safePosition = getSafeTeleportPosition(mysteryBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                            
                            -- Check if the player is stuck after teleporting
                            if checkIfStuck() then
                                notifyUser("Warning", "Player seems to be stuck. Trying to recover.", 3)
                                -- Recovery logic can be added here
                            end
                            
                            -- Introduce regular up and down movements for continuous motion
                            --Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                            --wait(0.5)  -- Reduced waiting time
                            --Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
                            
                        else
                            --notifyUser("Error", "Couldn't find a safe teleport Position.", .3)
							--print("Error: Couldn't find a safe teleport Position.")

                        end
                    else
                        --notifyUser("Error", "No safe mystery block found.", .3)
						--print("Error: No safe mystery block found.")
                    end
                end
            end
        else
            isMysteryTeleporting = false
        end
    end 
})

-- Enhanced Teleport to Coal Block Button
local teleCoalToggle = teleportSection:AddToggle({
    text = "Tele Coal",
    callback = function(state)
        if state then
            isCoalTeleporting = true
            while isCoalTeleporting do
                if canTeleportAgain() then
                    local coalBlock = findNearestCoal()
                    if coalBlock then
                        local safePosition = getSafeTeleportPosition(coalBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                        else
                            print("Error: Couldn't find a safe teleport Position.")
                        end
                    else
                        print("Error: No safe coal block found.")
                    end
                end
                wait(1)  -- Reduced delay
            end
        else
            isCoalTeleporting = false
        end
    end
})


-- Enhanced Teleport to Iron Block Button
local teleIronToggle = teleportSection:AddToggle({
    text = "Tele Iron",
    callback = function(state)
        if state then
            isIronTeleporting = true
            while isIronTeleporting do
                if canTeleportAgain() then
                    local ironBlock = findNearestIron()
                    if ironBlock then
                        local safePosition = getSafeTeleportPosition(ironBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                        else
                            print("Error: Couldn't find a safe teleport Position.")
                        end
                    else
                        print("Error: No safe iron block found.")
                    end
                end
                wait(1)
            end
        else
            isIronTeleporting = false
        end
    end
})
-- Enhanced Teleport to Gem Block Button
local teleGemToggle = teleportSection:AddToggle({
    text = "Tele Gem",
    callback = function(state)
        if state then
            isGemTeleporting = true
            while isGemTeleporting do
                if canTeleportAgain() then
                    local gemBlock = findNearestGem()
                    if gemBlock then
                        local safePosition = getSafeTeleportPosition(gemBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                        else
                            print("Error: Couldn't find a safe teleport Position.")
                        end
                    else
                        print("Error: No safe gem block found.")
                    end
                end
                wait(1)
            end
        else
            isGemTeleporting = false
        end
    end
})
-- Enhanced Teleport to Chest Block Button
local teleChestToggle = teleportSection:AddToggle({
    text = "Tele Chest",
    callback = function(state)
        if state then
            isChestTeleporting = true
            while isChestTeleporting do
                if canTeleportAgain() then
                    local chestBlock = findNearestChest()
                    if chestBlock then
                        local safePosition = getSafeTeleportPosition(chestBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                        else
                            print("Error: Couldn't find a safe teleport Position.")
                        end
                    else
                        print("Error: No safe chest block found.")
                    end
                end
                wait(1)
            end
        else
            isChestTeleporting = false
        end
    end
})
-- Enhanced Teleport to Copper Block Button
local teleCopperToggle = teleportSection:AddToggle({
    text = "Tele Copper",
    callback = function(state)
        if state then
            isCopperTeleporting = true
            while isCopperTeleporting do
                if canTeleportAgain() then
                    local copperBlock = findNearestCopper()
                    if copperBlock then
                        local safePosition = getSafeTeleportPosition(copperBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                        else
                            print("Error: Couldn't find a safe teleport Position.")
                        end
                    else
                        print("Error: No safe copper block found.")
                    end
                end
                wait(1)
            end
        else
            isCopperTeleporting = false
        end
    end
})
-- Auto-Mine Gems Toggle Button
local autoMineGemsToggle = teleportSection:AddToggle({
    text = "Auto Mine Gems",
    callback = function(state)
        if state then
            autoMineGemsConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not lastTeleportedBlock or checkBlockMined(lastTeleportedBlock) then
                    wait(teleportCooldown)
                    local gemBlock = findNearestGem()
                    if gemBlock then
                        local safePosition = getSafeTeleportPosition(gemBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                            lastTeleportedBlock = gemBlock
                            notifyUser("Auto Mine Gems", "Teleported to Gem: " .. gemBlock.Name, 2)
                        else
                            notifyUser("Error", "Couldn't find a safe teleport Position for auto-mine.", 3)
                        end
                    else
                        notifyUser("Error", "No safe gem block found for auto-mine.", 3)
                    end
                end
            end)
            notifyUser("Info", "Auto-Mining Gems Enabled!", 3)
        else
            if autoMineGemsConnection then
                autoMineGemsConnection:Disconnect()
                autoMineGemsConnection = nil
            end
            notifyUser("Info", "Auto-Mining Gems Disabled!", 3)
        end
    end
})
-- Enhanced Teleport to Special Block Button
local teleSpecialBlockToggle = teleportSection:AddToggle({
    text = "Tele Special Block",
    callback = function(state)
        if state then
            isSpecialBlockTeleporting = true
            while isSpecialBlockTeleporting do
                if canTeleportAgain() then
                    local specialBlock = findNearestSpecialBlock()
                    if specialBlock then
                        local safePosition = getSafeTeleportPosition(specialBlock.Position)
                        if safePosition then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
                            lastTeleportTime = tick()
                        else
                            print("Error: Couldn't find a safe teleport Position.")
                        end
                    else
                        print("Error: No safe special block found.")
                    end
                end
                wait(1)
            end
        else
            isSpecialBlockTeleporting = false
        end
    end
})
local cpsLabelToggle = false
local cpsLabelToggle = testingSection:AddToggle({
    text = "CPS Label",
    callback = function(state)
        if state then
            cps = tonumber(cpsInputBox.text) or 7  -- Fetch CPS rate from input box; default to 7 if invalid
            autoMine(cps)
            cpsLabel.Text = "CPS: " .. cps
        else
            cpsLabel.Text = "Stop CPS"
        end
    end
})
-- Destroy GUI Button
exitSection:AddButton({text = "Destroy GUI", callback = function()
    print("Button Callback Triggered...")
        resetAllChanges()
    -- This will destroy the entire Uwuware GUI
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChild("Hello, how are you today?") then
            v:Destroy()
        end
    end
end})
-- Teleport to Nearest Door Button
teleportSection:AddButton({ 
    text = "Teleport to Nearest Door", 
    callback = function()
        print("Button Callback Triggered...")
        teleportToNearestDoor()
    end 
})
local resetCollisionToggle = mainSection:AddButton({
    text = "Reset Collision",
    callback = function()
        local Character = Player.Character
        if Character then
            -- Iterate over each part in the character
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            notifyUser("Info", "Collision values reset to default.", 2)
        end
    end
})
userInputService.InputBegan:Connect(function(input, isProcessed)
    if awaitingCpsInput and not isProcessed then
        if input.KeyCode.Name:match("Number%d") then
            local enteredNumber = tonumber(input.KeyCode.Name:match("Number(%d)"))
            if enteredNumber and enteredNumber >= 1 and enteredNumber <= 9 then  -- Restricting to single digits for simplicity
                cps = enteredNumber
                if cpsInputButton then
                    cpsInputButton.text = "Set CPS (Currently: " .. cps .. ")"
                end
                notifyUser("Info", "CPS value set to " .. tostring(cps), 3)
                awaitingCpsInput = false
            end
        end
    end
end)
function EnableGeminiMode()
    -- Activate Gemini Mode logic here
    isGeminiModeOn = true
    notifyUser("#WINNING", "Gemini Mode Enabled. Hang in there while we toggle...", 3)
    -- Store original FriendAmount
    originalFriendAmount = Player.FriendAmount.Value
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
		flyJumpToggle.state = true
		flyJumpToggle:UpdateState()
	end
    -- Toggle Super Speed on when Gemini Mode is activated
    if not superSpeedEnabled then
        Player.Character.Humanoid.WalkSpeed = 80
        notifyUser("Info", "Super Speed Enabled!", 2)
        superSpeedEnabled = true
		superSpeedToggle.state = true
		superSpeedToggle:UpdateState()
    end
    clientantikick()
    notifyUser("Info", "Anti-Kick Enabled!", 2)
    notifyUser("Info", "Turning on Anti-Lag... it'll cause some lag first... lol", 2)
    antilag()
    notifyUser("xXGeminiXx", "Okay bud, trees and shit going away now.", 2)
    removeObjectsByName(namesList)
    notifyUser("Info", "Anti-Lag Enabled! Lag over.", 2)
    addFlare(Player.Character)
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
        noclipActivatedInGeminiMode = true
        -- Update noClipToggle text
        noClipToggle.text = "NoClip (Activated)"
		noClipToggle.state = true
		noClipToggle:UpdateState()
	end
    removeterrain()
    notifyUser("Info", "Some bad Terrain Removed!", 2)
    -- Fullbright
    fullbright()
    notifyUser("Info", "Fullbright Enabled!", 2)
    notifyUser("xXGeminiXx", "Welcome to my world. Gemini Mode on.", 2)
    geminiModeToggle.Text = "Deactivate Gemini Mode"
end
-- Function to disable Gemini Mode features
function DisableGeminiMode()
    -- Deactivate Infinite Jumps
    if flyjump then
        flyjump:Disconnect()
        flyjump = nil
        notifyUser("Info", "Flying Jump Disabled!", 2)
		flyJumpToggle.text = "Fly Jump (Deactivated)"
		flyJumpToggle.state = false
		flyJumpToggle:UpdateState()
    end
    -- Reset WalkSpeed
    Player.Character.Humanoid.WalkSpeed = normalSpeed
    notifyUser("Info", "WalkSpeed reset to normal!", 2)
	superSpeedToggle.text = "Super Speed (Deactivated)"
	superSpeedToggle.state = false
	superSpeedToggle:UpdateState()
    -- Remove flare effect
    removeFlare()
    notifyUser("Info", "Flare effect removed!", 2)
    -- Disconnect flare update connection
    if flareUpdateConnection then
        flareUpdateConnection:Disconnect()
        flareUpdateConnection = nil
    end
    -- Restore original FriendAmount
    if originalFriendAmount then
        Player.FriendAmount.Value = originalFriendAmount
        originalFriendAmount = nil
        notifyUser("Info", "Friend Amount Restored!", 2)
    end
    -- Deactivate NoClip
    if noclipActivatedInGeminiMode then
        deactivateNoClip()
        noclipActivatedInGeminiMode = false
        --Update noClipToggle text
        noClipToggle.text = "NoClip (Deactivated)"
		noClipToggle.state = false
		noClipToggle:UpdateState()
	end
    notifyUser("We're good.", "Back to fully normal, all changes reversed.", 5)
    geminiModeToggle.Text = "Activate Gemini Mode"
end

-- Snipe Mode variables -- Snipe Mode variables
local isSnipeModeActive = false 
local snipeModeConnection = nil 
local failedAttempts = 0  -- Counter to track failed attempts 
local maxFailedAttempts = 500  -- Maximum allowed failed attempts before Snipe Mode is deactivated 
local snipeCooldown = 1  -- Cooldown duration in seconds 
local priorityOrder = {"Mystery", "Gem", "Chest", "Coal", "Iron", "Copper"}
function executeSnipeMode()
    isSnipeModeActive = not isSnipeModeActive
    if isSnipeModeActive then 
        snipeModeToggle.text = "Stop Snipe Mode"
        notifyUser("Snipe Mode", "Snipe Mode Activated!", 3)
        notifyUser("Snipe Mode", "Starting snipe loop...", 2)
        snipeModeConnection = game:GetService("RunService").Heartbeat:Connect(function()
            wait(0.3)  -- This will make it try approximately 3 times a second

            local foundBlock = false 
            local PlayerPosition = game.Workspace.CurrentCamera.CFrame.Position
            local targetBlock = nil
            local shortestDistance = math.huge

            for _, blockType in ipairs(priorityOrder) do
                local functionFinder = "findNearest" .. blockType
                if _G[functionFinder] then
                    local block = _G[functionFinder]()
                    if block then
                        local distance = (block.Position - PlayerPosition).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            targetBlock = block
                        end
                    end
                end
            end

            if targetBlock then
                local teleportPosition = getSafeTeleportPosition(targetBlock.Position)
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
                foundBlock = true
                failedAttempts = 0  -- Reset failed attempts counter
                notifyUser("Snipe Mode", "Teleported to block: " .. targetBlock.Name, 2)
                wait(0.05)
            else 
                failedAttempts = failedAttempts + 1
                if failedAttempts >= maxFailedAttempts then 
                    snipeModeToggle.text = "Snipe Mode"
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
        snipeModeToggle.text = "Snipe Mode"
        notifyUser("Snipe Mode", "Snipe Mode Deactivated!", 3)
    end 
end

--spawn(checkIfStuck)
Library:Init()
print("Script initialization completed.")  -- Added print statement
