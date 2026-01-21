--[[ === Core === ]]--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")




--[[ === Fluent === ]]--
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()



--[[ === Globals === ]]--
local MISC_CONFIG = {}
local ESP_CONFIG = {}
local AUTO_CONFIG = {}
local TROLL_CONFIG = {}
local TELEPORTS_CONFIG = {}

local player = Players.LocalPlayer



--[[ === File "misc.lua" === ]]--
--! Methods
local function getDroppedGun()
    local drop = game.Workspace:FindFirstChild("GunDrop")
    if drop and drop:IsA("BasePart") then
        return drop
    end
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v.Name == "GunDrop" or (v:IsA("Model") and v:FindFirstChild("GunDrop")) then
            return v:FindFirstChild("GunDrop") or v
        end
    end
    return nil
end

--! Config Methods
function MISC_CONFIG.PickGun()
    local gun = getDroppedGun()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp and gun then
        local oldPos = hrp.CFrame
        
        hrp.CFrame = gun.CFrame
        
        task.wait(0.2) 
        
        hrp.CFrame = oldPos
    end
end



--[[ === File "esp.lua" === ]]--
local eg_startEvent = ReplicatedStorage.Remotes.Gameplay.RoundStart
local eg_roleColors = {
    ["Innocent"] = Color3.new(1,1,1),
    ["Murderer"] = Color3.new(1,0,0),
    ["Sheriff"] = Color3.new(0,0,1),
}
local eg_active = true
local eg_gunEsp = false
local eg_gunHighlight

--! Methods
local function getRole(plr)
    local character = plr.Character
    local backpack = plr:FindFirstChild("Backpack")

    if not character or not backpack then return "Innocent" end

    if character:FindFirstChild("Knife") or backpack:FindFirstChild("Knife") then
        return "Murderer"
    elseif character:FindFirstChild("Gun") or backpack:FindFirstChild("Gun") then
        return "Sheriff"
    else
        return "Innocent"
    end
end

--! Callbacks
local function loadCharacter(chr)
    local highlight = Instance.new("Highlight")
    highlight.Name = "NovaESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineColor = eg_roleColors[getRole(Players:GetPlayerFromCharacter(chr))]
    highlight.Parent = chr

    chr.ChildAdded:Connect(function(child)
        if child.Name == "Gun" then
            chr["NovaESP_Highlight"].OutlineColor = eg_roleColors["Sheriff"]
        end
    end)
end
local function loadPlayer(plr)
    if plr.Character then
        loadCharacter(plr.Character)
    end

    plr.CharacterAdded:Connect(function(chr)
        loadCharacter(chr)
    end)
end

--! Config Methods
function ESP_CONFIG.SetActive(state)
    print(state)
    eg_active = state

    for _, plr in Players:GetPlayers() do
        local char = plr.Character
        if not char then continue end

        char["NovaESP_Highlight"].Enabled = eg_active
    end
end
function ESP_CONFIG.SetColor(role, color)
    eg_roleColors[role] = color

    for _, plr in Players:GetPlayers() do
        local char = plr.Character
        if not char then continue end

        char["NovaESP_Highlight"].OutlineColor = eg_roleColors[getRole(plr)]
    end
end
function ESP_CONFIG.SetGunEsp(state)
    eg_gunEsp = state

    if not eg_gunHighlight then return end

    eg_gunHighlight.Enabled = state
end

--! Connections
Players.PlayerAdded:Connect(function(plr)
    loadPlayer(plr)
end)
eg_startEvent.OnClientEvent:Connect(function(_, data)
    for username, info in data do
        local player = Players:FindFirstChild(username)
        if not player then continue end

        player.Character["NovaESP_Highlight"].OutlineColor = eg_roleColors[info.Role]
    end
end)
workspace.DescendantAdded:Connect(function(child)
    if child.Name == "GunDrop" then
        local highlight = Instance.new("Highlight")
        highlight.Parent = child
        highlight.Adornee = child
        highlight.Enabled = eg_gunEsp
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color3.new(0,1,0)

        eg_gunHighlight = highlight
    end
end)

--! Run
for _, plr in Players:GetPlayers() do
    loadPlayer(plr)
end



--[[ === File "auto.lua" === ]]--
local ag_autoFarmCoins = false

--! Methods
local function setNoclip(state)
  local character = Players.LocalPlayer.Character
  if not character then return end
  
  if state then
    character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
  else
    character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
  end

  for _, parte in pairs(character:GetDescendants()) do   
    if parte:IsA("BasePart") then       
      parte.CanCollide = state
    end
  end
end
local function getCoinContainer()
  for _, i in workspace:GetChildren() do
    local coinContainer = i:FindFirstChild("CoinContainer")
    if not coinContainer then continue end
    return coinContainer
  end
end
local function getNearestCoin()
    local character = Players.LocalPlayer.Character
    if not character then return end
    local coinContainer = getCoinContainer()
    local nearestCoin
    local lastDistance = 2^53

    if not coinContainer then return end

    for _, coinVisual in coinContainer:GetChildren() do
        if not coinVisual:FindFirstChild("CoinVisual") then continue end
        if not coinVisual.CoinVisual:FindFirstChild("MainCoin") then continue end
        if coinVisual.CoinVisual.MainCoin.Transparency ~= 0 then continue end
        local distance = (coinVisual.Position - character.HumanoidRootPart.Position).Magnitude
        if distance < lastDistance then
        lastDistance = distance
        nearestCoin = coinVisual
        end
    end

    return nearestCoin, lastDistance
end
local function autoFarmCoins()
    local character = Players.LocalPlayer.Character
    if not character then return end
    local coin, dist = getNearestCoin()

    setNoclip(true)
    while coin and ag_autoFarmCoins do
        local time = dist/25

        local h = Instance.new("Highlight", coin.CoinVisual.MainCoin)
        h.Adornee = coin.CoinVisual.MainCoin

        TweenService:Create(character.HumanoidRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(coin.Position + Vector3.new(0,-1,0)) * CFrame.Angles(math.rad(-90),0,0)
        }):Play()

        task.wait(time)

        coin, dist = getNearestCoin()
    end
    setNoclip(false)
end

--! Config Methods
function AUTO_CONFIG.SetAutoFarmCoins(state)
    ag_autoFarmCoins = state
    if state then
        autoFarmCoins()
    end
end

--! Connections
eg_startEvent.OnClientEvent:Connect(function()
    if ag_autoFarmCoins then
        task.wait(1.2)
        autoFarmCoins()
    end
end)



--[[ === File "troll.lua" === ]]--
--! Config Methods
function TROLL_CONFIG.FlingMurdererGUI()
    local player = game.Players.LocalPlayer
    local rs = game:GetService("RunService")

    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    local mainFrame = Instance.new("Frame", screenGui)
    local dragHandle = Instance.new("Frame", mainFrame)
    local dragLabel = Instance.new("TextLabel", dragHandle)
    local toggleBtn = Instance.new("TextButton", mainFrame)
    local corner = Instance.new("UICorner", mainFrame)
    local btnCorner = Instance.new("UICorner", toggleBtn)
    local handleCorner = Instance.new("UICorner", dragHandle)

    mainFrame.Size = UDim2.new(0, 150, 0, 65)
    mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.Active = true
    mainFrame.Draggable = true
    corner.CornerRadius = UDim.new(0, 4)

    dragHandle.Size = UDim2.new(1, 0, 0, 22)
    dragHandle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    handleCorner.CornerRadius = UDim.new(0, 4)

    dragLabel.Size = UDim2.new(1, 0, 1, 0)
    dragLabel.Text = "  MURDER FLING"
    dragLabel.TextSize = 11
    dragLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dragLabel.TextXAlignment = Enum.TextXAlignment.Left
    dragLabel.BackgroundTransparency = 1
    dragLabel.Font = Enum.Font.Code

    toggleBtn.Size = UDim2.new(1, -20, 0, 30)
    toggleBtn.Position = UDim2.new(0, 10, 0, 28)
    toggleBtn.Text = "ACTIVATE"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleBtn.Font = Enum.Font.Code
    toggleBtn.TextSize = 13
    btnCorner.CornerRadius = UDim.new(0, 2)

    local flingActive = false

    local function getMurderer()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then
                    return p.Character
                end
            end
        end
        return nil
    end

    toggleBtn.MouseButton1Click:Connect(function()
        flingActive = not flingActive
        if flingActive then
            toggleBtn.Text = "5ngay..."
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
            toggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
            
            task.spawn(function()
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local lastSafePos = hrp.CFrame
                
                local bPos = Instance.new("BodyPosition", hrp)
                bPos.P = 1500000
                bPos.D = 1000 
                bPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                local bAng = Instance.new("BodyAngularVelocity", hrp)
                bAng.AngularVelocity = Vector3.new(0, 999999, 0)
                bAng.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

                local angle = 0
                while flingActive do
                    local m_char = getMurderer()
                    if m_char and m_char:FindFirstChild("HumanoidRootPart") then
                        if m_char.HumanoidRootPart.Position.Y < -2 then
                            flingActive = false
                            break
                        end

                        for _, v in pairs(char:GetChildren()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                        
                        angle = angle + 0.4 
                        local m_hrp = m_char.HumanoidRootPart
                        local offset = Vector3.new(math.cos(angle) * 3, 1.5, math.sin(angle) * 3)
                        bPos.Position = m_hrp.Position + offset
                    else
                        flingActive = false 
                    end
                    rs.Heartbeat:Wait()
                end
                
                bPos:Destroy()
                bAng:Destroy()
                hrp.Velocity = Vector3.new(0,0,0) 
                hrp.RotVelocity = Vector3.new(0,0,0)
                hrp.Anchored = true 
                task.wait(0.1)
                hrp.Anchored = false
                hrp.CFrame = lastSafePos 
                
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
                
                toggleBtn.Text = "ACTIVATE"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end)
        else
            flingActive = false
        end
    end)
end
function TROLL_CONFIG.FlingSheriffGUI()
    local player = game.Players.LocalPlayer
    local rs = game:GetService("RunService")

    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    local mainFrame = Instance.new("Frame", screenGui)
    local dragHandle = Instance.new("Frame", mainFrame)
    local dragLabel = Instance.new("TextLabel", dragHandle)
    local toggleBtn = Instance.new("TextButton", mainFrame)
    local corner = Instance.new("UICorner", mainFrame)
    local btnCorner = Instance.new("UICorner", toggleBtn)
    local handleCorner = Instance.new("UICorner", dragHandle)

    mainFrame.Size = UDim2.new(0, 150, 0, 65)
    mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.Active = true
    mainFrame.Draggable = true
    corner.CornerRadius = UDim.new(0, 4)

    dragHandle.Size = UDim2.new(1, 0, 0, 22)
    dragHandle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    handleCorner.CornerRadius = UDim.new(0, 4)

    dragLabel.Size = UDim2.new(1, 0, 1, 0)
    dragLabel.Text = "  SHERIFF FLING"
    dragLabel.TextSize = 11
    dragLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dragLabel.TextXAlignment = Enum.TextXAlignment.Left
    dragLabel.BackgroundTransparency = 1
    dragLabel.Font = Enum.Font.Code

    toggleBtn.Size = UDim2.new(1, -20, 0, 30)
    toggleBtn.Position = UDim2.new(0, 10, 0, 28)
    toggleBtn.Text = "ACTIVATE"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleBtn.Font = Enum.Font.Code
    toggleBtn.TextSize = 13
    btnCorner.CornerRadius = UDim.new(0, 2)

    local flingActive = false

    local function getMurderer()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun") then
                    return p.Character
                end
            end
        end
        return nil
    end

    toggleBtn.MouseButton1Click:Connect(function()
        flingActive = not flingActive
        if flingActive then
            toggleBtn.Text = "5nviadao..."
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
            toggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
            
            task.spawn(function()
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local lastSafePos = hrp.CFrame
                
                local bPos = Instance.new("BodyPosition", hrp)
                bPos.P = 1500000
                bPos.D = 1000 
                bPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                local bAng = Instance.new("BodyAngularVelocity", hrp)
                bAng.AngularVelocity = Vector3.new(0, 999999, 0)
                bAng.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

                local angle = 0
                while flingActive do
                    local m_char = getMurderer()
                    if m_char and m_char:FindFirstChild("HumanoidRootPart") then
                        if m_char.HumanoidRootPart.Position.Y < -2 then
                            flingActive = false
                            break
                        end

                        for _, v in pairs(char:GetChildren()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                        
                        angle = angle + 0.4 
                        local m_hrp = m_char.HumanoidRootPart
                        local offset = Vector3.new(math.cos(angle) * 3, 1.5, math.sin(angle) * 3)
                        bPos.Position = m_hrp.Position + offset
                    else
                        flingActive = false 
                    end
                    rs.Heartbeat:Wait()
                end
                
                bPos:Destroy()
                bAng:Destroy()
                hrp.Velocity = Vector3.new(0,0,0) 
                hrp.RotVelocity = Vector3.new(0,0,0)
                hrp.Anchored = true 
                task.wait(0.1)
                hrp.Anchored = false
                hrp.CFrame = lastSafePos 
                
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
                
                toggleBtn.Text = "ACTIVATE"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end)
        else
            flingActive = false
        end
    end)
end



--[[ === File "teleports.lua" === ]]--
--! Methods
local function hasTool(player, toolName)
    if not player then return false end

    local char = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")

    if char and char:FindFirstChild(toolName) then
        return true
    end

    if backpack and backpack:FindFirstChild(toolName) then
        return true
    end

    return false
end
local function getMurdererCharacter()
    for _, player in ipairs(Players:GetPlayers()) do
        if hasTool(player, "Knife") then
            return player.Character
        end
    end
    return nil
end
local function getSheriffCharacter()
    for _, player in ipairs(Players:GetPlayers()) do
        if hasTool(player, "Gun") then
            return player.Character
        end
    end
    return nil
end
local function teleportTo(pos)
    local character = player.Character
    local root = character and character.HumanoidRootPart

    if not root then return end

    root.CFrame = CFrame.new(pos)
end

--! Config Methods
function TELEPORTS_CONFIG.TeleportToMurderer()
    teleportTo((getMurdererCharacter().HumanoidRootPart.CFrame * CFrame.new(0,0,5)).Position)
end

function TELEPORTS_CONFIG.TeleportToSheriff()
    teleportTo((getSheriffCharacter().HumanoidRootPart.CFrame * CFrame.new(0,0,5)).Position)
end

function TELEPORTS_CONFIG.TeleportTo(pos)
    teleportTo(pos)
end



--[[ === Build === ]]--
local Window = Fluent:CreateWindow({
    Title = "SonarHUB " .. Fluent.Version,
    SubTitle = "by NovaTeam",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 400),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.M
})

local Tabs = { --Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
    Main = Window:AddTab({ Title = "Main", Icon = "settings-2" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "bot" }),
    Troll = Window:AddTab({ Title = "Troll", Icon = "venetian-mask" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
}



--[[ === Misc Tab === ]]--
Tabs.Main:AddButton({
    Title = "Pick gun (if is dropped)",
    Callback = function()
        MISC_CONFIG.PickGun()
    end,
})



--[[ === Visuals Tab === ]]--
--! Roles ESP
local o0; o0 = Tabs.Visuals:AddToggle("Toggle", {
    Title = "ESP",
    Default = true,
    Callback = function()
        if not o0 then return end
        ESP_CONFIG.SetActive(o0.Value)
    end,
})

local o1 = Tabs.Visuals:AddKeybind("Keybind", {
    Title = "Toggle ESP",
    Mode = "Toggle",
    Default = "V",
})
o1:OnClick(function()
    o0:SetValue(not o0.Value)
end)

--! Murderer Color
local o2 = Tabs.Visuals:AddColorpicker("Colorpicker", {
    Title = "Murderer Color",
    Default = Color3.new(1, 0, 0)
})
o2:OnChanged(function()
    ESP_CONFIG.SetColor("Murderer", o2.Value)
end)

--! Sheriff Color
local o3 = Tabs.Visuals:AddColorpicker("Colorpicker", {
    Title = "Sheriff Color",
    Default = Color3.new(0, 0, 1)
})
o3:OnChanged(function()
    ESP_CONFIG.SetColor("Sheriff", o3.Value)
end)

--! Innocent Color
local o4 = Tabs.Visuals:AddColorpicker("Colorpicker", {
    Title = "Innocent Color",
    Default = Color3.new(1, 1, 1)
 })
o4:OnChanged(function()
    ESP_CONFIG.SetColor("Innocent", o4.Value)
end)

local o4_1 = Tabs.Visuals:AddToggle("Toggle", {Title = "Gun ESP", Default = false })
o4_1:OnChanged(function()
    ESP_CONFIG.SetGunEsp(o4_1.Value)
end)



--[[ === Auto Tab === ]]--
local o4_2 = Tabs.Auto:AddToggle("Toggle", {Title = "Auto Farm Coins", Default = false })
o4_2:OnChanged(function()
    AUTO_CONFIG.SetAutoFarmCoins(o4_2.Value)
end)


--[[ === Troll Tab === ]]--
Tabs.Troll:AddButton({
    Title = "Fling Murderer GUI",
    Callback = function()
        TROLL_CONFIG.FlingMurdererGUI()
    end,
})

Tabs.Troll:AddButton({
    Title = "Fling Sheriff GUI",
    Callback = function()
        TROLL_CONFIG.FlingSheriffGUI()
    end,
})



--[[ === Teleports Tab === ]]--
local o5 = Tabs.Teleports:AddButton({
    Title = "Teleport to Murderer",
    Callback = function()
        TELEPORTS_CONFIG.TeleportToMurderer()
    end,
})

local o6 = Tabs.Teleports:AddButton({
    Title = "Teleport to Sheriff",
    Callback = function()
        TELEPORTS_CONFIG.TeleportToSheriff()
    end,
})

local o7 = Tabs.Teleports:AddButton({
    Title = "Teleport to Lobby",
    Callback = function()
        TELEPORTS_CONFIG.TeleportTo(Vector3.new(14, 504, -45))
    end,
})



--[[ === Fluent End === ]]--
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 5
})
