-- LocalScript (place in StarterPlayerScripts or StarterGui)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for data to load
while not player:GetAttribute("DataLoaded") do
    task.wait()
end

-- Variables for automation
local autoOpenEnabled = false
local autoSellEnabled = false
local selectedRarities = {}
local autoOpenConnection = nil

-- Available rarities (based on the inventory script)
local availableRarities = {"Gold", "Red", "Pink", "Purple", "Blue"}

-- Create the main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutomationGUI"
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Add corner rounding
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Automation Panel"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Auto Open Section
local autoOpenLabel = Instance.new("TextLabel")
autoOpenLabel.Name = "AutoOpenLabel"
autoOpenLabel.Size = UDim2.new(1, 0, 0, 30)
autoOpenLabel.Position = UDim2.new(0, 0, 0, 0)
autoOpenLabel.BackgroundTransparency = 1
autoOpenLabel.Text = "Auto Open Best Crate"
autoOpenLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOpenLabel.TextScaled = true
autoOpenLabel.Font = Enum.Font.Gotham
autoOpenLabel.TextXAlignment = Enum.TextXAlignment.Left
autoOpenLabel.Parent = contentFrame

local autoOpenToggle = Instance.new("TextButton")
autoOpenToggle.Name = "AutoOpenToggle"
autoOpenToggle.Size = UDim2.new(0, 60, 0, 25)
autoOpenToggle.Position = UDim2.new(1, -60, 0, 2.5)
autoOpenToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
autoOpenToggle.BorderSizePixel = 0
autoOpenToggle.Text = "OFF"
autoOpenToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOpenToggle.TextScaled = true
autoOpenToggle.Font = Enum.Font.GothamBold
autoOpenToggle.Parent = autoOpenLabel

local openToggleCorner = Instance.new("UICorner")
openToggleCorner.CornerRadius = UDim.new(0, 4)
openToggleCorner.Parent = autoOpenToggle

-- Auto Sell Section
local autoSellLabel = Instance.new("TextLabel")
autoSellLabel.Name = "AutoSellLabel"
autoSellLabel.Size = UDim2.new(1, 0, 0, 30)
autoSellLabel.Position = UDim2.new(0, 0, 0, 50)
autoSellLabel.BackgroundTransparency = 1
autoSellLabel.Text = "Auto Sell Items"
autoSellLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSellLabel.TextScaled = true
autoSellLabel.Font = Enum.Font.Gotham
autoSellLabel.TextXAlignment = Enum.TextXAlignment.Left
autoSellLabel.Parent = contentFrame

local autoSellToggle = Instance.new("TextButton")
autoSellToggle.Name = "AutoSellToggle"
autoSellToggle.Size = UDim2.new(0, 60, 0, 25)
autoSellToggle.Position = UDim2.new(1, -60, 0, 2.5)
autoSellToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
autoSellToggle.BorderSizePixel = 0
autoSellToggle.Text = "OFF"
autoSellToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSellToggle.TextScaled = true
autoSellToggle.Font = Enum.Font.GothamBold
autoSellToggle.Parent = autoSellLabel

local sellToggleCorner = Instance.new("UICorner")
sellToggleCorner.CornerRadius = UDim.new(0, 4)
sellToggleCorner.Parent = autoSellToggle

-- Rarity Selection Label
local rarityLabel = Instance.new("TextLabel")
rarityLabel.Name = "RarityLabel"
rarityLabel.Size = UDim2.new(1, 0, 0, 25)
rarityLabel.Position = UDim2.new(0, 0, 0, 90)
rarityLabel.BackgroundTransparency = 1
rarityLabel.Text = "Select Rarities to Sell:"
rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rarityLabel.TextScaled = true
rarityLabel.Font = Enum.Font.Gotham
rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
rarityLabel.Parent = contentFrame

-- Rarity checkboxes
local rarityFrame = Instance.new("Frame")
rarityFrame.Name = "RarityFrame"
rarityFrame.Size = UDim2.new(1, 0, 0, 200)
rarityFrame.Position = UDim2.new(0, 0, 0, 120)
rarityFrame.BackgroundTransparency = 1
rarityFrame.Parent = contentFrame

local rarityCheckboxes = {}

for i, rarity in ipairs(availableRarities) do
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Name = rarity .. "Frame"
    checkboxFrame.Size = UDim2.new(1, 0, 0, 30)
    checkboxFrame.Position = UDim2.new(0, 0, 0, (i-1) * 35)
    checkboxFrame.BackgroundTransparency = 1
    checkboxFrame.Parent = rarityFrame

    local checkbox = Instance.new("TextButton")
    checkbox.Name = rarity .. "Checkbox"
    checkbox.Size = UDim2.new(0, 25, 0, 25)
    checkbox.Position = UDim2.new(0, 0, 0, 2.5)
    checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.Parent = checkboxFrame

    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 4)
    checkboxCorner.Parent = checkbox

    local checkmark = Instance.new("TextLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = Color3.fromRGB(85, 255, 85)
    checkmark.TextScaled = true
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Visible = false
    checkmark.Parent = checkbox

    local rarityText = Instance.new("TextLabel")
    rarityText.Name = rarity .. "Text"
    rarityText.Size = UDim2.new(1, -35, 1, 0)
    rarityText.Position = UDim2.new(0, 35, 0, 0)
    rarityText.BackgroundTransparency = 1
    rarityText.Text = rarity
    rarityText.TextColor3 = Color3.fromRGB(255, 255, 255)
    rarityText.TextScaled = true
    rarityText.Font = Enum.Font.Gotham
    rarityText.TextXAlignment = Enum.TextXAlignment.Left
    rarityText.Parent = checkboxFrame

    rarityCheckboxes[rarity] = {checkbox = checkbox, checkmark = checkmark, selected = false}
end

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 1, -40)
statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = contentFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 4)
statusCorner.Parent = statusLabel

-- Functions
function getBestAffordableCrate()
    local playerMoney = player.Money.Value
    local bestCrate = nil
    local bestPrice = 0
    local freeCrate = nil

    for _, crateModule in pairs(ReplicatedStorage.CratesGame.Crates:GetChildren()) do
        local crateData = require(crateModule)

        if crateData.Name == "Free Case" then
            freeCrate = crateModule
        end

        if crateData.Price <= playerMoney and crateData.Price > bestPrice then
            bestCrate = crateModule
            bestPrice = crateData.Price
        end
    end

    return bestCrate or freeCrate
end

function autoOpenBestCrate()
    local bestCrate = getBestAffordableCrate()

    if bestCrate then
        local crateData = require(bestCrate)
        statusLabel.Text = "Opening: " .. crateData.Name .. " ($" .. crateData.Price .. ")"
        ReplicatedStorage.RollCrate:Fire(bestCrate)
    else
        statusLabel.Text = "No crates available!"
    end
end

function autoSellSelectedRarities()
    if not autoSellEnabled or #selectedRarities == 0 then
        return
    end

    local inventory = ReplicatedStorage.FetchInventory:InvokeServer()
    if not inventory then return end

    local itemsSold = 0

    for _, item in ipairs(inventory) do
        local itemData = ReplicatedStorage.CratesGame.Items:FindFirstChild(item.n, true)

        if itemData and not item.l then
            for _, selectedRarity in ipairs(selectedRarities) do
                if itemData.ItemRarity.Value == selectedRarity then
                    local sellResult = ReplicatedStorage.SellItem:InvokeServer(item.s)

                    if sellResult.Success then
                        itemsSold = itemsSold + 1
                        task.wait(0.05) -- Small delay to prevent server overload
                    end
                    break
                end
            end
        end
    end

    if itemsSold > 0 then
        statusLabel.Text = "Sold " .. itemsSold .. " items"
        ReplicatedStorage.UpdateNetworth:InvokeServer()
        ReplicatedStorage.ReloadStatistics:Fire()
        ReplicatedStorage.ReloadInventory:Fire()
    end
end

function updateSelectedRarities()
    selectedRarities = {}
    for rarity, data in pairs(rarityCheckboxes) do
        if data.selected then
            table.insert(selectedRarities, rarity)
        end
    end
end

-- Event connections
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if autoOpenConnection then
        autoOpenConnection:Disconnect()
    end
end)

autoOpenToggle.MouseButton1Click:Connect(function()
    autoOpenEnabled = not autoOpenEnabled

    if autoOpenEnabled then
        autoOpenToggle.Text = "ON"
        autoOpenToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        statusLabel.Text = "Auto Open: Enabled"

        autoOpenConnection = task.spawn(function()
            while autoOpenEnabled do
                autoOpenBestCrate()
                task.wait(2) -- Wait 2 seconds between opens
            end
        end)
    else
        autoOpenToggle.Text = "OFF"
        autoOpenToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        statusLabel.Text = "Auto Open: Disabled"

        if autoOpenConnection then
            task.cancel(autoOpenConnection)
            autoOpenConnection = nil
        end
    end
end)

autoSellToggle.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled

    if autoSellEnabled then
        autoSellToggle.Text = "ON"
        autoSellToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        statusLabel.Text = "Auto Sell: Enabled"

        task.spawn(function()
            while autoSellEnabled do
                autoSellSelectedRarities()
                task.wait(3) -- Wait 3 seconds between sell cycles
            end
        end)
    else
        autoSellToggle.Text = "OFF"
        autoSellToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        statusLabel.Text = "Auto Sell: Disabled"
    end
end)

-- Checkbox connections
for rarity, data in pairs(rarityCheckboxes) do
    data.checkbox.MouseButton1Click:Connect(function()
        data.selected = not data.selected
        data.checkmark.Visible = data.selected

        if data.selected then
            data.checkbox.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        else
            data.checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end

        updateSelectedRarities()
        statusLabel.Text = "Selected: " .. #selectedRarities .. " rarities"
    end)
end

-- Anti-idle with periodic input simulation
task.spawn(function()
    while true do
        task.wait(600) -- Wait 10 minutes (600 seconds)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)


-- Initial status
statusLabel.Text = "Status: Ready"
