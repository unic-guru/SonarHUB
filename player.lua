--// Services
local Players = game:GetService("Players")

getgenv().NOVA_PLAYER_CONFIG = {}

local speed = 16
local jump = 50
local speedActive = false
local jumpActive = false

local function apply()
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.WalkSpeed = speedActive and speed or 16
    hum.JumpPower = jumpActive and jump or 50
end

function NOVA_PLAYER_CONFIG.SetSpeed(v)
    speed = v
    apply()
end

function NOVA_PLAYER_CONFIG.SetJump(v)
    jump = v
    apply()
end

function NOVA_PLAYER_CONFIG.SetSpeedActive(state)
    speedActive = state
    apply()
end

function NOVA_PLAYER_CONFIG.SetJumpActive(state)
    jumpActive = state
    apply()
end

Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    apply()
end)
