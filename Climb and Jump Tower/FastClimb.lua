local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local speedBoostEnabled = true
local normalWalkSpeed = 16
local climbingBoostSpeed = 10000 -- Adjust this value as needed

local function speedBooster()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Check if player is climbing (walkspeed is not 16)
    if humanoid.WalkSpeed ~= normalWalkSpeed and speedBoostEnabled then
        humanoid.WalkSpeed = climbingBoostSpeed
        -- Optional: Also boost jump power while climbing
        if humanoid.JumpPower then
            humanoid.JumpPower = 100
        elseif humanoid.JumpHeight then
            humanoid.JumpHeight = 50
        end
    end
end

-- Run the speed booster continuously
local connection = RunService.Heartbeat:Connect(speedBooster)

print("🚀 Speed booster activated!")
print("  Normal speed:", normalWalkSpeed)
print("  Climbing boost:", climbingBoostSpeed)
print("  Will auto-boost when climbing is detected")

-- Optional: Toggle function
local function toggleSpeedBoost()
    speedBoostEnabled = not speedBoostEnabled
    if speedBoostEnabled then
        print("✅ Speed boost enabled")
    else
        print("❌ Speed boost disabled")
    end
end