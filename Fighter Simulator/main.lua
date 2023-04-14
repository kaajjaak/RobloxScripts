run = true
autochest = false
autoheal = true
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



uis.InputBegan:Connect(function(input)
    if (uis:GetFocusedTextBox()) then
        return; -- make sure player's not chatting!
    end
    if input.KeyCode == Enum.KeyCode.N then
        run = false
    end
    if input.KeyCode == Enum.KeyCode.M then
        autochest = not autochest
    end

end)

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
    end

    teleportToTarget()
    wait(0.1)
    sendLeftClick()

    while (targetPart.Parent and targetPart.Parent:FindFirstChild("Humanoid") and targetPart.Parent.Humanoid.Health > 0 and run) do
        performAttack()
        wait(0.1)
        teleportToTarget()
    end

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
    end
end

local function mainLoop()
    while run do
        local world = game:GetService('Workspace').Worlds:getChildren()[1]
        local targetMob = world.Mobs['5']:getChildren()[1]

        if targetMob then
            local targetPart = targetMob.HumanoidRootPart
            local success = attackTarget(targetPart)

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
end

coroutine.wrap(mainLoop)() -- Start the mainLoop function in a separate coroutine
coroutine.wrap(autoHeal)() -- Start the autoHeal function in a separate coroutine
coroutine.wrap(autoChest)() -- Start the autoChest function in a separate coroutine

