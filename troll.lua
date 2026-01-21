--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

getgenv().NOVA_TROLL_CONFIG = {}

local murdererConn
local sheriffConn

local function flingTo(getTarget)
    return RunService.Heartbeat:Connect(function()
        local char = Players.LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local target = getTarget()
        if not (hrp and target and target:FindFirstChild("HumanoidRootPart")) then return end

        hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,1.5,2)
        hrp.Velocity = Vector3.new(0,80,0)
    end)
end

function NOVA_TROLL_CONFIG.SetMurdererFling(state)
    if murdererConn then murdererConn:Disconnect() murdererConn = nil end
    if state then
        murdererConn = flingTo(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
                    return p.Character
                end
            end
        end)
    end
end

function NOVA_TROLL_CONFIG.SetSheriffFling(state)
    if sheriffConn then sheriffConn:Disconnect() sheriffConn = nil end
    if state then
        sheriffConn = flingTo(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then
                    return p.Character
                end
            end
        end)
    end
end
