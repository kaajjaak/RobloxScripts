-- LocalScript
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local VirtualUser = game:GetService('VirtualUser')

local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')

-- Wait for data to load
while not player:GetAttribute('DataLoaded') do
    task.wait()
end

-- Variables for automation
local autoOpenBestEnabled = false
local autoOpenTargetEnabled = false
local autoSellEnabled = false
local selectedRarities = {}
local targetCrate = nil
local autoOpenBestConnection = nil
local autoOpenTargetConnection = nil

-- Available rarities (based on the inventory script)
local availableRarities = { 'Gold', 'Red', 'Pink', 'Purple', 'Blue' }

-- Create the main GUI
local screenGui = Instance.new('ScreenGui')
screenGui.Name = 'AutomationGUI'
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new('Frame')
mainFrame.Name = 'MainFrame'
mainFrame.Size = UDim2.new(0, 400, 0, 700)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Add corner rounding
local mainCorner = Instance.new('UICorner')
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new('Frame')
titleBar.Name = 'TitleBar'
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new('UICorner')
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Title text
local titleText = Instance.new('TextLabel')
titleText.Name = 'TitleText'
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = 'Automation Panel'
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- Close button
local closeButton = Instance.new('TextButton')
closeButton.Name = 'CloseButton'
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
closeButton.BorderSizePixel = 0
closeButton.Text = 'X'
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new('UICorner')
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Content frame
local contentFrame = Instance.new('Frame')
contentFrame.Name = 'ContentFrame'
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Auto Open Best Section
local autoOpenBestLabel = Instance.new('TextLabel')
autoOpenBestLabel.Name = 'AutoOpenBestLabel'
autoOpenBestLabel.Size = UDim2.new(1, 0, 0, 30)
autoOpenBestLabel.Position = UDim2.new(0, 0, 0, 0)
autoOpenBestLabel.BackgroundTransparency = 1
autoOpenBestLabel.Text = 'Auto Open Best Crate'
autoOpenBestLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOpenBestLabel.TextScaled = true
autoOpenBestLabel.Font = Enum.Font.Gotham
autoOpenBestLabel.TextXAlignment = Enum.TextXAlignment.Left
autoOpenBestLabel.Parent = contentFrame

local autoOpenBestToggle = Instance.new('TextButton')
autoOpenBestToggle.Name = 'AutoOpenBestToggle'
autoOpenBestToggle.Size = UDim2.new(0, 60, 0, 25)
autoOpenBestToggle.Position = UDim2.new(1, -60, 0, 2.5)
autoOpenBestToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
autoOpenBestToggle.BorderSizePixel = 0
autoOpenBestToggle.Text = 'OFF'
autoOpenBestToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOpenBestToggle.TextScaled = true
autoOpenBestToggle.Font = Enum.Font.GothamBold
autoOpenBestToggle.Parent = autoOpenBestLabel

local openBestToggleCorner = Instance.new('UICorner')
openBestToggleCorner.CornerRadius = UDim.new(0, 4)
openBestToggleCorner.Parent = autoOpenBestToggle

-- Auto Open Target Section
local autoOpenTargetLabel = Instance.new('TextLabel')
autoOpenTargetLabel.Name = 'AutoOpenTargetLabel'
autoOpenTargetLabel.Size = UDim2.new(1, 0, 0, 30)
autoOpenTargetLabel.Position = UDim2.new(0, 0, 0, 40)
autoOpenTargetLabel.BackgroundTransparency = 1
autoOpenTargetLabel.Text = 'Auto Open Target Crate'
autoOpenTargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOpenTargetLabel.TextScaled = true
autoOpenTargetLabel.Font = Enum.Font.Gotham
autoOpenTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
autoOpenTargetLabel.Parent = contentFrame

local autoOpenTargetToggle = Instance.new('TextButton')
autoOpenTargetToggle.Name = 'AutoOpenTargetToggle'
autoOpenTargetToggle.Size = UDim2.new(0, 60, 0, 25)
autoOpenTargetToggle.Position = UDim2.new(1, -60, 0, 2.5)
autoOpenTargetToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
autoOpenTargetToggle.BorderSizePixel = 0
autoOpenTargetToggle.Text = 'OFF'
autoOpenTargetToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOpenTargetToggle.TextScaled = true
autoOpenTargetToggle.Font = Enum.Font.GothamBold
autoOpenTargetToggle.Parent = autoOpenTargetLabel

local openTargetToggleCorner = Instance.new('UICorner')
openTargetToggleCorner.CornerRadius = UDim.new(0, 4)
openTargetToggleCorner.Parent = autoOpenTargetToggle

-- Target Crate Selector
local targetCrateLabel = Instance.new('TextLabel')
targetCrateLabel.Name = 'TargetCrateLabel'
targetCrateLabel.Size = UDim2.new(1, 0, 0, 25)
targetCrateLabel.Position = UDim2.new(0, 0, 0, 75)
targetCrateLabel.BackgroundTransparency = 1
targetCrateLabel.Text = 'Select Target Crate:'
targetCrateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetCrateLabel.TextScaled = true
targetCrateLabel.Font = Enum.Font.Gotham
targetCrateLabel.TextXAlignment = Enum.TextXAlignment.Left
targetCrateLabel.Parent = contentFrame

local targetCrateDropdown = Instance.new('TextButton')
targetCrateDropdown.Name = 'TargetCrateDropdown'
targetCrateDropdown.Size = UDim2.new(1, 0, 0, 30)
targetCrateDropdown.Position = UDim2.new(0, 0, 0, 105)
targetCrateDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
targetCrateDropdown.BorderSizePixel = 0
targetCrateDropdown.Text = 'Select a crate...'
targetCrateDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
targetCrateDropdown.TextScaled = true
targetCrateDropdown.Font = Enum.Font.Gotham
targetCrateDropdown.TextXAlignment = Enum.TextXAlignment.Left
targetCrateDropdown.Parent = contentFrame

local dropdownCorner = Instance.new('UICorner')
dropdownCorner.CornerRadius = UDim.new(0, 4)
dropdownCorner.Parent = targetCrateDropdown

-- Dropdown arrow
local dropdownArrow = Instance.new('TextLabel')
dropdownArrow.Name = 'DropdownArrow'
dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
dropdownArrow.BackgroundTransparency = 1
dropdownArrow.Text = '▼'
dropdownArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownArrow.TextScaled = true
dropdownArrow.Font = Enum.Font.Gotham
dropdownArrow.Parent = targetCrateDropdown

-- Dropdown list (initially hidden)
local dropdownList = Instance.new('ScrollingFrame')
dropdownList.Name = 'DropdownList'
dropdownList.Size = UDim2.new(1, 0, 0, 120)
dropdownList.Position = UDim2.new(0, 0, 0, 140)
dropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.ScrollBarThickness = 6
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownList.Parent = contentFrame

local dropdownListCorner = Instance.new('UICorner')
dropdownListCorner.CornerRadius = UDim.new(0, 4)
dropdownListCorner.Parent = dropdownList

local dropdownLayout = Instance.new('UIListLayout')
dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownLayout.Padding = UDim.new(0, 2)
dropdownLayout.Parent = dropdownList

-- Auto Sell Section
local autoSellLabel = Instance.new('TextLabel')
autoSellLabel.Name = 'AutoSellLabel'
autoSellLabel.Size = UDim2.new(1, 0, 0, 30)
autoSellLabel.Position = UDim2.new(0, 0, 0, 270)
autoSellLabel.BackgroundTransparency = 1
autoSellLabel.Text = 'Auto Sell Items'
autoSellLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSellLabel.TextScaled = true
autoSellLabel.Font = Enum.Font.Gotham
autoSellLabel.TextXAlignment = Enum.TextXAlignment.Left
autoSellLabel.Parent = contentFrame

local autoSellToggle = Instance.new('TextButton')
autoSellToggle.Name = 'AutoSellToggle'
autoSellToggle.Size = UDim2.new(0, 60, 0, 25)
autoSellToggle.Position = UDim2.new(1, -60, 0, 2.5)
autoSellToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
autoSellToggle.BorderSizePixel = 0
autoSellToggle.Text = 'OFF'
autoSellToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSellToggle.TextScaled = true
autoSellToggle.Font = Enum.Font.GothamBold
autoSellToggle.Parent = autoSellLabel

local sellToggleCorner = Instance.new('UICorner')
sellToggleCorner.CornerRadius = UDim.new(0, 4)
sellToggleCorner.Parent = autoSellToggle

-- Rarity Selection Label
local rarityLabel = Instance.new('TextLabel')
rarityLabel.Name = 'RarityLabel'
rarityLabel.Size = UDim2.new(1, 0, 0, 25)
rarityLabel.Position = UDim2.new(0, 0, 0, 310)
rarityLabel.BackgroundTransparency = 1
rarityLabel.Text = 'Select Rarities to Sell:'
rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rarityLabel.TextScaled = true
rarityLabel.Font = Enum.Font.Gotham
rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
rarityLabel.Parent = contentFrame

-- Rarity checkboxes
local rarityFrame = Instance.new('Frame')
rarityFrame.Name = 'RarityFrame'
rarityFrame.Size = UDim2.new(1, 0, 0, 175)
rarityFrame.Position = UDim2.new(0, 0, 0, 340)
rarityFrame.BackgroundTransparency = 1
rarityFrame.Parent = contentFrame

local rarityCheckboxes = {}

for i, rarity in ipairs(availableRarities) do
    local checkboxFrame = Instance.new('Frame')
    checkboxFrame.Name = rarity .. 'Frame'
    checkboxFrame.Size = UDim2.new(1, 0, 0, 30)
    checkboxFrame.Position = UDim2.new(0, 0, 0, (i - 1) * 35)
    checkboxFrame.BackgroundTransparency = 1
    checkboxFrame.Parent = rarityFrame

    local checkbox = Instance.new('TextButton')
    checkbox.Name = rarity .. 'Checkbox'
    checkbox.Size = UDim2.new(0, 25, 0, 25)
    checkbox.Position = UDim2.new(0, 0, 0, 2.5)
    checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ''
    checkbox.Parent = checkboxFrame

    local checkboxCorner = Instance.new('UICorner')
    checkboxCorner.CornerRadius = UDim.new(0, 4)
    checkboxCorner.Parent = checkbox

    local checkmark = Instance.new('TextLabel')
    checkmark.Name = 'Checkmark'
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = '✓'
    checkmark.TextColor3 = Color3.fromRGB(85, 255, 85)
    checkmark.TextScaled = true
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Visible = false
    checkmark.Parent = checkbox

    local rarityText = Instance.new('TextLabel')
    rarityText.Name = rarity .. 'Text'
    rarityText.Size = UDim2.new(1, -35, 1, 0)
    rarityText.Position = UDim2.new(0, 35, 0, 0)
    rarityText.BackgroundTransparency = 1
    rarityText.Text = rarity
    rarityText.TextColor3 = Color3.fromRGB(255, 255, 255)
    rarityText.TextScaled = true
    rarityText.Font = Enum.Font.Gotham
    rarityText.TextXAlignment = Enum.TextXAlignment.Left
    rarityText.Parent = checkboxFrame

    rarityCheckboxes[rarity] = {
        checkbox = checkbox,
        checkmark = checkmark,
        selected = false,
    }
end

-- Status label
local statusLabel = Instance.new('TextLabel')
statusLabel.Name = 'StatusLabel'
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 1, -40)
statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statusLabel.BorderSizePixel = 0
statusLabel.Text = 'Status: Ready'
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = contentFrame

local statusCorner = Instance.new('UICorner')
statusCorner.CornerRadius = UDim.new(0, 4)
statusCorner.Parent = statusLabel

-- Functions
function getAllCrates()
    local crates = {}
    for _, crateModule in pairs(ReplicatedStorage.CratesGame.Crates:GetChildren()) do
        local crateData = require(crateModule)
        table.insert(crates, { module = crateModule, data = crateData })
    end

    -- Sort by price
    table.sort(crates, function(a, b)
        return a.data.Price < b.data.Price
    end)

    return crates
end

function populateDropdown()
    local crates = getAllCrates()

    -- Clear existing items
    for _, child in pairs(dropdownList:GetChildren()) do
        if child:IsA('TextButton') then
            child:Destroy()
        end
    end

    -- Add crate options
    for i, crate in ipairs(crates) do
        local option = Instance.new('TextButton')
        option.Name = crate.data.Name
        option.Size = UDim2.new(1, -10, 0, 25)
        option.Position = UDim2.new(0, 5, 0, 0)
        option.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        option.BorderSizePixel = 0
        option.Text = crate.data.Name .. ' ($' .. crate.data.Price .. ')'
        option.TextColor3 = Color3.fromRGB(255, 255, 255)
        option.TextScaled = true
        option.Font = Enum.Font.Gotham
        option.TextXAlignment = Enum.TextXAlignment.Left
        option.LayoutOrder = i
        option.Parent = dropdownList

        local optionCorner = Instance.new('UICorner')
        optionCorner.CornerRadius = UDim.new(0, 3)
        optionCorner.Parent = option

        option.MouseButton1Click:Connect(function()
            targetCrate = crate.module
            targetCrateDropdown.Text = crate.data.Name
                    .. ' ($'
                    .. crate.data.Price
                    .. ')'
            dropdownList.Visible = false
            dropdownArrow.Text = '▼'
            statusLabel.Text = 'Target set: ' .. crate.data.Name
        end)
    end

    -- Update canvas size
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, #crates * 27)
end

function getBestAffordableCrate()
    local playerMoney = player.Money.Value
    local bestCrate = nil
    local bestPrice = 0
    local freeCrate = nil

    for _, crateModule in pairs(ReplicatedStorage.CratesGame.Crates:GetChildren()) do
        local crateData = require(crateModule)

        if crateData.Name == 'Free Case' then
            freeCrate = crateModule
        end

        if crateData.Price <= playerMoney and crateData.Price > bestPrice then
            bestCrate = crateModule
            bestPrice = crateData.Price
        end
    end

    return bestCrate or freeCrate
end

function getFreeCrate()
    for _, crateModule in pairs(ReplicatedStorage.CratesGame.Crates:GetChildren()) do
        local crateData = require(crateModule)
        if crateData.Name == 'Free Case' then
            return crateModule
        end
    end
    return nil
end

function autoOpenBestCrate()
    local bestCrate = getBestAffordableCrate()

    if bestCrate then
        local crateData = require(bestCrate)
        statusLabel.Text = 'Opening Best: '
                .. crateData.Name
                .. ' ($'
                .. crateData.Price
                .. ')'
        ReplicatedStorage.RollCrate:Fire(bestCrate)
    else
        statusLabel.Text = 'No crates available!'
    end
end

function autoOpenTargetCrate()
    if not targetCrate then
        statusLabel.Text = 'No target crate selected!'
        return
    end

    local targetData = require(targetCrate)
    local playerMoney = player.Money.Value

    if playerMoney >= targetData.Price then
        statusLabel.Text = 'Opening Target: '
                .. targetData.Name
                .. ' ($'
                .. targetData.Price
                .. ')'
        ReplicatedStorage.RollCrate:Fire(targetCrate)
    else
        local freeCrate = getFreeCrate()
        if freeCrate then
            local freeData = require(freeCrate)
            statusLabel.Text = 'Saving for '
                    .. targetData.Name
                    .. ' - Opening: '
                    .. freeData.Name
            ReplicatedStorage.RollCrate:Fire(freeCrate)
        else
            statusLabel.Text = 'Cannot find Free Case!'
        end
    end
end

function autoSellSelectedRarities()
    if not autoSellEnabled or #selectedRarities == 0 then
        return
    end

    local inventory = ReplicatedStorage.FetchInventory:InvokeServer()
    if not inventory then
        return
    end

    local itemsSold = 0

    for _, item in ipairs(inventory) do
        local itemData = ReplicatedStorage.CratesGame.Items:FindFirstChild(
                item.n,
                true
        )

        if itemData and not item.l then
            for _, selectedRarity in ipairs(selectedRarities) do
                if itemData.ItemRarity.Value == selectedRarity then
                    local sellResult = ReplicatedStorage.SellItem:InvokeServer(
                            item.s
                    )

                    if sellResult.Success then
                        itemsSold = itemsSold + 1
                        task.wait(0.05)
                    end
                    break
                end
            end
        end
    end

    if itemsSold > 0 then
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

-- Initialize dropdown
populateDropdown()

-- Event connections
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if autoOpenBestConnection then
        autoOpenBestConnection:Disconnect()
    end
    if autoOpenTargetConnection then
        autoOpenTargetConnection:Disconnect()
    end
end)

targetCrateDropdown.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
    dropdownArrow.Text = dropdownList.Visible and '▲' or '▼'
end)

autoOpenBestToggle.MouseButton1Click:Connect(function()
    autoOpenBestEnabled = not autoOpenBestEnabled

    -- Disable target mode if best mode is enabled
    if autoOpenBestEnabled and autoOpenTargetEnabled then
        autoOpenTargetEnabled = false
        autoOpenTargetToggle.Text = 'OFF'
        autoOpenTargetToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        if autoOpenTargetConnection then
            task.cancel(autoOpenTargetConnection)
            autoOpenTargetConnection = nil
        end
    end

    if autoOpenBestEnabled then
        autoOpenBestToggle.Text = 'ON'
        autoOpenBestToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        statusLabel.Text = 'Auto Open Best: Enabled'

        autoOpenBestConnection = task.spawn(function()
            while autoOpenBestEnabled do
                autoOpenBestCrate()
                task.wait(2)
            end
        end)
    else
        autoOpenBestToggle.Text = 'OFF'
        autoOpenBestToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        statusLabel.Text = 'Auto Open Best: Disabled'

        if autoOpenBestConnection then
            task.cancel(autoOpenBestConnection)
            autoOpenBestConnection = nil
        end
    end
end)

autoOpenTargetToggle.MouseButton1Click:Connect(function()
    autoOpenTargetEnabled = not autoOpenTargetEnabled

    -- Disable best mode if target mode is enabled
    if autoOpenTargetEnabled and autoOpenBestEnabled then
        autoOpenBestEnabled = false
        autoOpenBestToggle.Text = 'OFF'
        autoOpenBestToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        if autoOpenBestConnection then
            task.cancel(autoOpenBestConnection)
            autoOpenBestConnection = nil
        end
    end

    if autoOpenTargetEnabled then
        if not targetCrate then
            statusLabel.Text = 'Please select a target crate first!'
            autoOpenTargetEnabled = false
            return
        end

        autoOpenTargetToggle.Text = 'ON'
        autoOpenTargetToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        statusLabel.Text = 'Auto Open Target: Enabled'

        autoOpenTargetConnection = task.spawn(function()
            while autoOpenTargetEnabled do
                autoOpenTargetCrate()
                task.wait(2)
            end
        end)
    else
        autoOpenTargetToggle.Text = 'OFF'
        autoOpenTargetToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        statusLabel.Text = 'Auto Open Target: Disabled'

        if autoOpenTargetConnection then
            task.cancel(autoOpenTargetConnection)
            autoOpenTargetConnection = nil
        end
    end
end)

autoSellToggle.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled

    if autoSellEnabled then
        autoSellToggle.Text = 'ON'
        autoSellToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 85)

        task.spawn(function()
            while autoSellEnabled do
                autoSellSelectedRarities()
                task.wait(3)
            end
        end)
    else
        autoSellToggle.Text = 'OFF'
        autoSellToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
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
    end)
end

-- Anti-idle with periodic input simulation
task.spawn(function()
    while true do
        task.wait(600)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Initial status
statusLabel.Text = 'Status: Ready'