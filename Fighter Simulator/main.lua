run = true
autochest = false
autoheal = true
killBoss = true
print(run)

uis = game:GetService("UserInputService")
rp = game:GetService("ReplicatedStorage")

--// Services \\--
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")



--// Variables \\--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local X, Y = 0, 0

local character = Player.Character or Player.CharacterAdded:Wait() -- Wait for the character if it's not yet available
local costTextLabel = Player.PlayerGui.App.RegularChest.FrameMain.FrameInfo1X.TextLabelCost
local healthTextLabel = character.Head:WaitForChild("BillboardGuiNameTag"):WaitForChild("FrameHealth"):WaitForChild("TextLabelHPValue")

local function parseCost(costText)
    local value, unit = costText:match("^(%d+%.?%d*)(%a*)$")
    value = tonumber(value)

    if unit == "K" then
        value = value * 1e3
    elseif unit == "M" then
        value = value * 1e6
    elseif unit == "B" then
        value = value * 1e9
    end

    return value
end

local function sendLeftClick()
    -- Update Mouse Pos
    X, Y = Mouse.X, Mouse.Y + 10

    -- Send MouseButton1 (left-click) down and up events
    VirtualInputManager:SendMouseButtonEvent(X, Y, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(X, Y, 0, false, game, 1)
end

-- Call the function to send a single left-click


-- function to attack the target
local function attackTarget(targetPart)
    -- get the weapon service
    local weaponService = rp.Packages._Index["sleitnick_knit@1.4.7"].knit.Services.Weapon

    local function performAttack()
        weaponService.RF.StartMove:InvokeServer("attack3")
        weaponService.RF.StartMove:InvokeServer("attack2")
        weaponService.RF.StartMove:InvokeServer("attack1")
    end

    local function teleportToTarget()
        local humanoid = game.Players.LocalPlayer.Character.Humanoid
        local targetCFrame = targetPart.CFrame
        local targetPosition = targetCFrame.Position - targetCFrame.LookVector * 3
        humanoid.RootPart.CFrame = CFrame.new(targetPosition, targetCFrame.Position)
        return targetPosition
    end

    local function waitForTeleport(targetPosition)
        local humanoid = game.Players.LocalPlayer.Character.Humanoid
        while (humanoid.RootPart.Position - targetPosition).Magnitude > 5 do
            wait(0.1)
        end
    end

    local targetPosition = teleportToTarget()
    waitForTeleport(targetPosition)
    wait(1)
    teleportToTarget()
    sendLeftClick()

    local timeSinceLastClick = 0

    while (not game:GetService("Workspace"):FindFirstChild("Loot") and run and targetPart.Parent and targetPart.Parent:FindFirstChild("Humanoid")) do
        performAttack()
        wait(0.1)
        teleportToTarget()

        timeSinceLastClick = timeSinceLastClick + 1
        if timeSinceLastClick >= 5 then
            sendLeftClick()
            timeSinceLastClick = 0
        end
    end
    wait(0.1)
    return false
end

local function collectLoot()
    local lootPart = game:GetService("Workspace"):FindFirstChild("Loot")
    while lootPart do
        local humanoid = game.Players.LocalPlayer.Character.Humanoid
        local targetCFrame = lootPart.CFrame
        local targetPosition = targetCFrame.Position - targetCFrame.LookVector * 3
        humanoid.RootPart.CFrame = CFrame.new(targetPosition, targetCFrame.Position)

        repeat
            wait(0.1)
            game:GetService('ReplicatedStorage').Packages._Index['sleitnick_knit@1.4.7'].knit.Services.Loot.RF.SellLoot:InvokeServer()
        until (humanoid.MoveDirection == Vector3.new() and (humanoid.RootPart.Position - targetPosition).Magnitude < 5) or not lootPart:IsDescendantOf(game:GetService('Workspace'))

        if lootPart:IsDescendantOf(game:GetService('Workspace')) then
            wait(0.1)
            game:GetService('ReplicatedStorage').Packages._Index['sleitnick_knit@1.4.7'].knit.Services.Loot.RF.SellLoot:InvokeServer()
        end

        lootPart = game:GetService("Workspace"):FindFirstChild("Loot")
    end
end

local function autoHeal()
    while true do
        while autoheal do
            local healthText = healthTextLabel.Text
            local currentHealth, maxHealth = healthText:match("^(%d+)/(%d+)$")

            -- Convert the values from strings to numbers
            currentHealth = tonumber(currentHealth)
            maxHealth = tonumber(maxHealth)

            -- Check if current health is below 50% of max health
            if currentHealth < maxHealth * 0.5 then
                local args = {
                    [1] = "heal"
                }

                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("Weapon"):WaitForChild("RF"):WaitForChild("StartHoldMove"):InvokeServer(unpack(args))
            end

            wait(1) -- Add a delay between health checks
        end
        wait(0.1)
    end
end

local function autoChest()
    while true do
        while autochest do
            local costText = costTextLabel.Text
            local numericCost = parseCost(costText)
            if game:GetService("Players").LocalPlayer.leaderstats.Coins.Value > numericCost then
                local chest = {
                    [1] = 1,
                    [2] = game:GetService('Workspace').Worlds:getChildren()[1].Name,
                    [3] = "Berserker",
                    [4] = 1
                }

                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("Chest"):WaitForChild("RF"):WaitForChild("UnlockChests"):InvokeServer(unpack(chest))
                wait(5)
            else
                wait(1) -- Add a delay to prevent excessive checking
            end
        end
        wait(0.1)
    end
end

local lastTargetIndex = 0

local function mainLoop()
    while true do
        while run do
            wait(0.1)
            collectLoot()
            local world = game:GetService('Workspace').Worlds:getChildren()[1]
            local mobs = world.Mobs['4']:getChildren()
            if killBoss then
                mobs = world.Mobs['5']:getChildren()
                table.sort(mobs, function(a, b)
                    return tonumber(a.Name) > tonumber(b.Name)
                end)
                lastTargetIndex = 1
            else
                lastTargetIndex = (lastTargetIndex % #mobs) + 1
                if not mobs[lastTargetIndex] then
                    lastTargetIndex = 1
                end
            end

            local targetMob = mobs[lastTargetIndex]

            if targetMob then
                local targetPart = targetMob.HumanoidRootPart
                local success = attackTarget(targetPart)
                wait(0.1)
                -- If the attack is not successful, collect the loot
                if not success then
                    collectLoot()
                end
            else
                -- If there's no target mob, collect the loot
                collectLoot()
            end

            wait(0.1) -- Add a small delay to prevent excessive resource usage
        end
        wait(0.1)
    end
end

local function getCurrentWorld()
    local world = game:GetService('Workspace').Worlds:getChildren()[1].Name
    return world
end

local function purchaseNextWorld()
    local currentWorld = getCurrentWorld()
    local nextWorld = "World" .. tostring(tonumber(string.sub(currentWorld, 6)) + 1)

    local success = pcall(function()
        local args = {
            [1] = nextWorld
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("World"):WaitForChild("RF"):WaitForChild("PurchaseWorld"):InvokeServer(unpack(args))
    end)

    return success, nextWorld
end

local function loadWorld(worldName)
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("World"):WaitForChild("RF"):WaitForChild("LoadWorld"):InvokeServer(unpack(worldName))
end

local function levelUp()
    local success, nextWorld = purchaseNextWorld()

    if success then
        wait(0.1)
        loadWorld(nextWorld)
    end
end

-- Creating the GUI
local function createGui()
    local screenGui = Instance.new("ScreenGui", Player.PlayerGui)
    screenGui.Name = "KeybindsGui"

    local function createLabel(text, position, color)
        local label = Instance.new("TextLabel", screenGui)
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(1, -200, 1, position)
        label.Size = UDim2.new(0, 200, 0, 20)
        label.Font = Enum.Font.SourceSans
        label.Text = text
        label.TextColor3 = color
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Right
        label.TextYAlignment = Enum.TextYAlignment.Center
        return label
    end

    local runLabel = createLabel("Run (Toggle): N", -100, run and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
    local autoChestLabel = createLabel("AutoChest (Toggle): M", -80, autochest and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
    local killBossLabel = createLabel("KillBoss (Toggle): B", -60, killBoss and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
    local levelUpLabel = createLabel("Level Up: V", -40, Color3.new(0, 0, 1)) -- Blue
    local collectLootLabel = createLabel("Collect Loot: X", -20, Color3.new(0, 0, 1)) -- Blue

    return runLabel, autoChestLabel, killBossLabel
end

local runLabel, autoChestLabel, killBossLabel = createGui()


uis.InputBegan:Connect(function(input)
    if (uis:GetFocusedTextBox()) then
        return ; -- make sure player's not chatting!
    end
    if input.KeyCode == Enum.KeyCode.N then
        run = not run
        runLabel.TextColor3 = run and Color3.new(0, 1, 0) or Color3.new(1, 0, 0) -- Green if on, red if off
    end
    if input.KeyCode == Enum.KeyCode.M then
        autochest = not autochest
        autoChestLabel.TextColor3 = autochest and Color3.new(0, 1, 0) or Color3.new(1, 0, 0) -- Green if on, red if off
    end
    if input.KeyCode == Enum.KeyCode.B then
        killBoss = not killBoss
        killBossLabel.TextColor3 = killBoss and Color3.new(0, 1, 0) or Color3.new(1, 0, 0) -- Green if on, red if off
    end
    if input.KeyCode == Enum.KeyCode.V then
        levelUp()
    end
    if input.KeyCode == Enum.KeyCode.X then
        collectLoot()
    end

end)


coroutine.wrap(mainLoop)() -- Start the mainLoop function in a separate coroutine
coroutine.wrap(autoHeal)() -- Start the autoHeal function in a separate coroutine
coroutine.wrap(autoChest)() -- Start the autoChest function in a separate coroutine

