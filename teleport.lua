--// Services
local Players = game:GetService("Players")

getgenv().NOVA_TP_CONFIG = {}

local function getByRole(role)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            local char = plr.Character
            local bp = plr:FindFirstChild("Backpack")
            if char and bp then
                if role == "Murderer" and (char:FindFirstChild("Knife") or bp:FindFirstChild("Knife")) then
                    return plr
                end
                if role == "Sheriff" and (char:FindFirstChild("Gun") or bp:FindFirstChild("Gun")) then
                    return plr
                end
            end
        end
    end
end

function NOVA_TP_CONFIG.ToRole(role)
    local target = getByRole(role)
    if not target or not target.Character then return end

    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local thrp = target.Character:FindFirstChild("HumanoidRootPart")
    if hrp and thrp then
        hrp.CFrame = thrp.CFrame * CFrame.new(0,0,3)
    end
end
