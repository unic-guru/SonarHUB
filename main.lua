--// Core
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--// Load modules
loadstring(game:HttpGet("https://raw.githubusercontent.com/unic-guru/test/main/esp.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/unic-guru/test/main/player.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/unic-guru/test/main/teleport.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/unic-guru/test/main/troll.lua"))()

--// Window
local Window = Fluent:CreateWindow({
    Title = "Sun HUB " .. Fluent.Version,
    SubTitle = "by NovaTeam",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 420),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.M
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "zap" }),
    Troll = Window:AddTab({ Title = "Troll", Icon = "skull" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--// ESP
do
    local Toggle = Tabs.ESP:AddToggle("RoleESP", {
        Title = "Enable Role ESP",
        Default = true
    })

    Toggle:OnChanged(function()
        NOVA_ESP_CONFIG.SetActive(Toggle.Value)
    end)

    Tabs.ESP:AddKeybind("ESPKey", {
        Title = "Toggle ESP",
        Default = "V",
        Mode = "Toggle"
    }):OnChanged(function()
        NOVA_ESP_CONFIG.SetKeybind(Enum.KeyCode[Options.ESPKey.Value])
    end)

    Tabs.ESP:AddColorpicker("MurdererColor", {
        Title = "Murderer",
        Default = Color3.fromRGB(255,0,0)
    }):OnChanged(function()
        NOVA_ESP_CONFIG.SetColor("Murderer", Options.MurdererColor.Value)
    end)

    Tabs.ESP:AddColorpicker("SheriffColor", {
        Title = "Sheriff",
        Default = Color3.fromRGB(0,0,255)
    }):OnChanged(function()
        NOVA_ESP_CONFIG.SetColor("Sheriff", Options.SheriffColor.Value)
    end)

    Tabs.ESP:AddColorpicker("InnocentColor", {
        Title = "Innocent",
        Default = Color3.fromRGB(255,255,255)
    }):OnChanged(function()
        NOVA_ESP_CONFIG.SetColor("Innocent", Options.InnocentColor.Value)
    end)
end

--// Player
do
    Tabs.Player:AddToggle("SpeedToggle", {
        Title = "Speed",
        Default = false
    }):OnChanged(function()
        NOVA_PLAYER_CONFIG.SetSpeedActive(Options.SpeedToggle.Value)
    end)

    Tabs.Player:AddSlider("SpeedValue", {
        Title = "WalkSpeed",
        Min = 16,
        Max = 100,
        Default = 16
    }):OnChanged(function(v)
        NOVA_PLAYER_CONFIG.SetSpeed(v)
    end)

    Tabs.Player:AddToggle("JumpToggle", {
        Title = "Jump",
        Default = false
    }):OnChanged(function()
        NOVA_PLAYER_CONFIG.SetJumpActive(Options.JumpToggle.Value)
    end)

    Tabs.Player:AddSlider("JumpValue", {
        Title = "JumpPower",
        Min = 50,
        Max = 150,
        Default = 50
    }):OnChanged(function(v)
        NOVA_PLAYER_CONFIG.SetJump(v)
    end)
end

--// Teleport
do
    Tabs.Teleport:AddButton({
        Title = "Teleport to Murderer",
        Callback = function()
            NOVA_TP_CONFIG.ToRole("Murderer")
        end
    })

    Tabs.Teleport:AddButton({
        Title = "Teleport to Sheriff",
        Callback = function()
            NOVA_TP_CONFIG.ToRole("Sheriff")
        end
    })
end

--// Troll
do
    Tabs.Troll:AddToggle("MurdererFling", {
        Title = "Murderer Fling",
        Default = false
    }):OnChanged(function()
        NOVA_TROLL_CONFIG.SetMurdererFling(Options.MurdererFling.Value)
    end)

    Tabs.Troll:AddToggle("SheriffFling", {
        Title = "Sheriff Fling",
        Default = false
    }):OnChanged(function()
        NOVA_TROLL_CONFIG.SetSheriffFling(Options.SheriffFling.Value)
    end)
end

--// Addons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("SunHUB")
SaveManager:SetFolder("SunHUB/MM2")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
