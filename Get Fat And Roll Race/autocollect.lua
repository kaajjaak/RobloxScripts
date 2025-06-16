local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Get the EatFood remote function
local eatRemote = ReplicatedStorage.Packages.Knit.Services.EatService.RF.EatFood

-- Configuration
local REFRESH_INTERVAL = 5 -- Refresh food list every 5 attempts
local TELEPORT_HEIGHT_OFFSET = 5
local DELAY_BETWEEN_FOODS = 0.3
local POSITION_REGISTER_DELAY = 0.1

-- Function to get all available foods with distances
local function getFoodsByDistance()
    local foodsFolder = Workspace.GameObjects.Foods
    local playerPosition = humanoidRootPart.Position
    local foodsWithDistance = {}

    for _, foodObject in pairs(foodsFolder:GetChildren()) do
        if foodObject:IsA("Model") or foodObject:IsA("BasePart") then
            local foodPosition

            -- Handle WorldPivot for models, Position for parts
            if foodObject:IsA("Model") then
                foodPosition = foodObject:GetPivot().Position
            else
                foodPosition = foodObject.Position
            end

            local distance = (playerPosition - foodPosition).Magnitude

            table.insert(foodsWithDistance, {
                object = foodObject,
                distance = distance,
                position = foodPosition,
                name = foodObject.Name
            })
        end
    end

    -- Sort by distance (closest first)
    table.sort(foodsWithDistance, function(a, b)
        return a.distance < b.distance
    end)

    return foodsWithDistance
end

-- Function to teleport and eat food
local function teleportAndEatFood(foodData)
    local originalPosition = humanoidRootPart.CFrame

    -- Teleport to food
    local targetCFrame = CFrame.new(foodData.position + Vector3.new(0, TELEPORT_HEIGHT_OFFSET, 0))
    humanoidRootPart.CFrame = targetCFrame

    task.wait(POSITION_REGISTER_DELAY)

    -- Eat the food
    local success, error = pcall(function()
        eatRemote:InvokeServer(foodData.name)
    end)

    if success then
        print(string.format("✓ Ate: %s (Distance: %.2f)", foodData.name, foodData.distance))
    else
        warn("✗ Failed to eat:", foodData.name, error)
    end

    -- Return to original position
    humanoidRootPart.CFrame = originalPosition
    task.wait(DELAY_BETWEEN_FOODS)

    return success
end

-- Main farming function with auto-refresh
local function autoRefreshFoodFarm()
    local originalPosition = humanoidRootPart.CFrame
    local totalEaten = 0
    local attemptCount = 0
    local sortedFoods = {}
    local currentIndex = 1

    print("Starting auto-refreshing food farm...")

    while true do
        -- Refresh food list every REFRESH_INTERVAL attempts
        if attemptCount % REFRESH_INTERVAL == 0 then
            print(string.format("🔄 Refreshing food list... (Attempt %d)", attemptCount + 1))
            sortedFoods = getFoodsByDistance()
            currentIndex = 1

            if #sortedFoods == 0 then
                print("No foods found! Waiting for respawn...")
                task.wait(2)
                continue
            end

            print(string.format("Found %d foods available", #sortedFoods))
        end

        -- Check if we have foods to eat
        if currentIndex > #sortedFoods then
            print("All foods in current list consumed, refreshing...")
            attemptCount = attemptCount + REFRESH_INTERVAL -- Force refresh
            continue
        end

        local foodData = sortedFoods[currentIndex]

        -- Check if food still exists (might have been eaten by others)
        if not foodData.object.Parent then
            print(string.format("Food %s no longer exists, skipping...", foodData.name))
            currentIndex = currentIndex + 1
            continue
        end

        print(string.format("[%d] Targeting: %s (Distance: %.2f studs)",
                attemptCount + 1, foodData.name, foodData.distance))

        local success = teleportAndEatFood(foodData)
        if success then
            totalEaten = totalEaten + 1
        end

        attemptCount = attemptCount + 1
        currentIndex = currentIndex + 1

        -- Optional: Add a break condition
        -- if totalEaten >= 100 then break end
    end

    print(string.format("Food farm completed! Total eaten: %d", totalEaten))
end

-- Execute the farm
autoRefreshFoodFarm()
