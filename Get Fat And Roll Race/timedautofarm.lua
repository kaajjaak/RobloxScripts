local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Get the EatFood remote function
local eatRemote = ReplicatedStorage.Packages.Knit.Services.EatService.RF.EatFood

-- Configuration
local REFRESH_INTERVAL = 2 -- Refresh food list every 5 attempts
local TELEPORT_HEIGHT_OFFSET = 5
local DELAY_BETWEEN_FOODS = 0.05
local POSITION_REGISTER_DELAY = 0.1
local FARM_DURATION = 30 -- Run for 30 seconds

-- Timer variables
local startTime = tick()
local isRunning = true

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

-- Function to find closest track start
local function findClosestTrackStart()
    local tracksFolder = Workspace.Tracks
    local playerPosition = humanoidRootPart.Position
    local closestStart = nil
    local closestDistance = math.huge

    print("🔍 Searching for track starts...")

    for _, track in pairs(tracksFolder:GetChildren()) do
        if track:IsA("Model") or track:IsA("Folder") then
            local startObject = track:FindFirstChild("Start")

            if startObject then
                local startPosition

                -- Handle different start object types
                if startObject:IsA("Model") then
                    startPosition = startObject:GetPivot().Position
                elseif startObject:IsA("BasePart") then
                    startPosition = startObject.Position
                else
                    -- If it's a folder, find the first part inside
                    local firstPart = startObject:FindFirstChildOfClass("BasePart")
                    if firstPart then
                        startPosition = firstPart.Position
                    end
                end

                if startPosition then
                    local distance = (playerPosition - startPosition).Magnitude
                    print(string.format("Found track: %s - Start distance: %.2f studs", track.Name, distance))

                    if distance < closestDistance then
                        closestDistance = distance
                        closestStart = {
                            object = startObject,
                            position = startPosition,
                            distance = distance,
                            trackName = track.Name
                        }
                    end
                end
            else
                print(string.format("Track %s has no Start object", track.Name))
            end
        end
    end

    return closestStart
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

    task.wait(DELAY_BETWEEN_FOODS)

    return success
end

-- Main farming function with 30-second timer
local function timedFoodFarm()
    local totalEaten = 0
    local attemptCount = 0
    local sortedFoods = {}
    local currentIndex = 1

    print("Starting 30-second auto-refreshing food farm...")

    while isRunning do
        -- Check if 30 seconds have passed
        if tick() - startTime >= FARM_DURATION then
            print("⏰ 30 seconds completed! Stopping farm...")
            isRunning = false
            break
        end

        -- Refresh food list every REFRESH_INTERVAL attempts
        if attemptCount % REFRESH_INTERVAL == 0 then
            local timeRemaining = FARM_DURATION - (tick() - startTime)
            print(string.format("🔄 Refreshing food list... (Time remaining: %.1fs)", timeRemaining))
            sortedFoods = getFoodsByDistance()
            currentIndex = 1

            if #sortedFoods == 0 then
                print("No foods found! Waiting for respawn...")
                task.wait(1)
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

        local timeRemaining = FARM_DURATION - (tick() - startTime)
        print(string.format("[%d] Targeting: %s (Distance: %.2f studs) - Time left: %.1fs",
                attemptCount + 1, foodData.name, foodData.distance, timeRemaining))

        local success = teleportAndEatFood(foodData)
        if success then
            totalEaten = totalEaten + 1
        end

        attemptCount = attemptCount + 1
        currentIndex = currentIndex + 1
    end

    print(string.format("Food farm completed! Total eaten: %d in %d seconds", totalEaten, FARM_DURATION))

    -- Find and teleport to closest track start
    print("🚀 Finding closest track start...")
    local closestStart = findClosestTrackStart()

    if closestStart then
        print(string.format("🎯 Closest track: %s (Distance: %.2f studs)", closestStart.trackName, closestStart.distance))

        local teleportCFrame = CFrame.new(closestStart.position + Vector3.new(0, 5, 0))
        humanoidRootPart.CFrame = teleportCFrame

        print(string.format("✅ Successfully teleported to %s track start!", closestStart.trackName))
    else
        warn("❌ No track starts found!")

        -- Fallback to restaurant start if no other tracks found
        local restaurantStart = Workspace.Tracks:FindFirstChild("Resturaunt")
        if restaurantStart then
            local start = restaurantStart:FindFirstChild("Start")
            if start then
                local teleportPosition
                if start:IsA("Model") then
                    teleportPosition = start:GetPivot()
                elseif start:IsA("BasePart") then
                    teleportPosition = start.CFrame
                end

                if teleportPosition then
                    humanoidRootPart.CFrame = teleportPosition + Vector3.new(0, 5, 0)
                    print("✅ Fallback: Teleported to restaurant start!")
                end
            end
        end
    end

    print("🔚 Script completed and exiting...")
end

-- Execute the timed farm
timedFoodFarm()
