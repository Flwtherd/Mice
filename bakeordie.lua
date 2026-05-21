local RunService = game:GetService("RunService")

--[[
    WindUI - Mice: Bake or Die Hub [Version 1.0 BETA]
    Created May 2026 - Giraffiecy and Phoenix
]]

-- Environment Safety Setup
local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    else
        if cloneref(game:GetService("RunService")):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- Load Game Remotes
local ZAP = require(ReplicatedStorage.Client.ClientRemotes)
local ZapReliable = ReplicatedStorage:WaitForChild("ZAP"):WaitForChild("ZAP_RELIABLE")

-- ESP Setup Variables
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = game.CoreGui

local ESPConfig = {
    MonsterESP = false,
    ItemESP = false,
    ShowNames = true,
    ShowDistance = true,
    ShowHighlight = true
}

-- Fly GUI V3 Integration Core States
_G.FlyV3Active = false
_G.FlyV3Speeds = 1
local tpwalking = false

-- Send Native Integration Notification
game:GetService("StarterGui"):SetCore("SendNotification", { 
    Title = "FLY";
    Text = "Integrated Natively into WindUI Framework";
    Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
})

-- Handle Re-spawning Stability
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.7)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
    if char:FindFirstChild("Animate") then
        char.Animate.Disabled = false
    end
end)

-- Engine execution helper for TP movement calculations
local function StartTpWalk()
    tpwalking = false
    task.wait()
    tpwalking = true
    for i = 1, _G.FlyV3Speeds do
        task.spawn(function()
            local hb = game:GetService("RunService").Heartbeat    
            while tpwalking and hb:Wait() do
                local chr = Players.LocalPlayer.Character
                local hum = chr and chr:FindFirstChildOfClass("Humanoid")
                if chr and hum and hum.Parent and hum.MoveDirection.Magnitude > 0 then
                    chr:TranslateBy(hum.MoveDirection)
                end
            end
        end)
    end
end

-- */ Window Initialization /* --
local Window = WindUI:CreateWindow({
    Title = "Mice  |  Bake or Die [BETA]",
    Subtitle = "Version 1.0",
    Folder = "BakeOrDieHub",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    Size = UDim2.fromOffset(550, 420),
    HideSearchBar = false,

    OpenButton = {
        Title = "Open Bake or Die",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#FF3030"),
            Color3.fromHex("#FF9E2F")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default",
    },
})

-- ============================================================================
-- PERSISTENT POPUP MANAGEMENT
-- ============================================================================
local showPopup = true
local SaveFileName = "BakeOrDie_PopupData.json"

if readfile and isfile and isfile(SaveFileName) then
    local data = HttpService:JSONDecode(readfile(SaveFileName))
    if data and data.FirstTimeViewed == true then
        showPopup = false
    end
end

if showPopup then
    WindUI:Popup({
        Title = "Update info",
        Icon = "solar:info-square-bold",
        Content = "Version 1.1 Is Created [Whats New?]\n• Added network-driven Auto Grinder machine processing\n• Added network-driven Auto Blueprint machine processing\n• Included step-by-step feature operation guides",
        Buttons = {
            {
                Title = "Close",
                Variant = "Tertiary",
            },
            {
                Title = "Continue",
                Icon = "arrow-right",
                Variant = "Primary",
                Callback = function()
                    if writefile then
                        local payload = HttpService:JSONEncode({FirstTimeViewed = true})
                        writefile(SaveFileName, payload)
                    end
                end
            }
        }
    })
end

-- Version Tag
Window:Tag({
    Title = "v1.0 Beta",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

-- */ Section Assignments /* --
local MainSection = Window:Section({ Title = "Main" })

-- ============================================================================
-- 1. PATCH NOTES TAB
-- ============================================================================
local PatchTab = MainSection:Tab({
    Title = "Patch Notes",
    Icon = "solar:file-text-bold",
    IconColor = Color3.fromHex("#83889E"),
    Border = true,
})

PatchTab:Label({
    Title = "[UPDATE] Patch Notice v1.1 Beta",
    Desc = "• ADDED: Network-level automated interaction loops for both Blueprint tables and Grinder stations.\n• INSTRUCTIONS: Guide details loaded directly into the Combat section.\n• SECURITY: Pre-obfuscation stabilization checks applied.",
})

-- ============================================================================
-- 2. COMBAT TAB
-- ============================================================================
local CombatTab = MainSection:Tab({
    Title = "Combat",
    Icon = "solar:cursor-square-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    Border = true,
})

-- Machine Loop Instructions
CombatTab:Label({
    Title = "How to Use Auto Station Deposit:",
    Desc = "1. Collect your items/zombies first.\n2. Turn on the desired Station Toggle below.\n3. Wait for the loop to complete and finish!",
})

CombatTab:Space()

CombatTab:Toggle({
    Flag = "KillAuraToggle",
    Title = "Aura kill",
    Desc = "Automatically attacks nearby monsters.",
    Value = false,
    Callback = function(Value)
        _G.KillAuraEnabled = Value
    end
})

CombatTab:Space()

CombatTab:Slider({
    Flag = "AuraDistanceSlider",
    Title = "Kill Aura",
    Desc = "Adjust the range of your Kill Aura.",
    IsTooltip = true,
    Step = 1,
    Value = {
        Min = 10,
        Max = 50,
        Default = 25,
    },
    Callback = function(Value)
        _G.AuraDistance = Value
    end
})

CombatTab:Space()

CombatTab:Toggle({
    Flag = "AutoGrindToggle",
    Title = "Auto Kill all [BETA]",
    Desc = "Continuously and automatically wipes out every zombie on the map.",
    Value = false,
    Callback = function(Value)
        _G.AutoGrindEnabled = Value
    end
})

CombatTab:Space()

-- New Station Loops Toggles
CombatTab:Toggle({
    Flag = "StationGrinderToggle",
    Title = "Grind Items",
    Desc = "Repeatedly processes items into the Grinder station deposit slot automatically.",
    Value = false,
    Callback = function(Value)
        _G.StationGrindActive = Value
    end
})

CombatTab:Space()

CombatTab:Toggle({
    Flag = "StationBlueprintToggle",
    Title = "Grind Zombies",
    Desc = "Repeatedly processes items into the Blueprints Table deposit slot automatically.",
    Value = false,
    Callback = function(Value)
        _G.StationBlueprintActive = Value
    end
})

CombatTab:Space()

CombatTab:Button({
    Title = "Kill All Zombies (Manual)",
    Desc = "Attacks every monster currently in the game once.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, monster in pairs(workspace.Monsters:GetChildren()) do
                if monster:FindFirstChild("HumanoidRootPart") then
                    ZAP.meleeAttack.fire({
                        monsters = {monster},
                        civilians = {},
                        activeSlot = _G.WeaponSlot
                    })
                    task.wait(0.1)
                end
            end
        end
    end
})

-- ============================================================================
-- 3. ITEMS TAB
-- ============================================================================
local ItemsTab = MainSection:Tab({
    Title = "Items",
    Icon = "solar:folder-with-files-bold",
    IconColor = Color3.fromHex("#ECA201"),
    Border = true,
})

ItemsTab:Button({
    Title = "Bring Bodies [Zombies]",
    Desc = "Teleports all interactable bodies to your position.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character.PrimaryPart then
            for _, v in pairs(workspace.Interactables:GetChildren()) do 
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and not v:FindFirstChild("ProductPriceTag") then
                    v.PrimaryPart.CFrame = character.PrimaryPart.CFrame
                    task.wait(0.01)
                end
            end
        end
    end
})

ItemsTab:Space()

ItemsTab:Button({
    Title = "Bring All Items",
    Desc = "Teleports all regular items to your position.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character.PrimaryPart then
            for _, v in pairs(workspace.Interactables:GetChildren()) do 
                if v:IsA("Model") and not v:FindFirstChild("ProductPriceTag") and v.PrimaryPart then
                    v.PrimaryPart.CFrame = character.PrimaryPart.CFrame
                    task.wait(0.01)
                end
            end
        end
    end
})

-- ============================================================================
-- 4. PLAYER TAB (WITH INTEGRATED FLY GUI V3 FUNCTIONS)
-- ============================================================================
local PlayerTab = MainSection:Tab({
    Title = "Player",
    Icon = "solar:password-minimalistic-input-bold",
    IconColor = Color3.fromHex("#7775F2"),
    Border = true,
})

PlayerTab:Toggle({
    Flag = "FlyV3Toggle",
    Title = "Fly",
    Desc = "Toggles standard core system flight modes natively.",
    Value = false,
    Callback = function(Value)
        _G.FlyV3Active = Value
        local speaker = Players.LocalPlayer
        local character = speaker.Character
        
        if not character or not character:FindFirstChildOfClass("Humanoid") then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if not _G.FlyV3Active then
            for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() humanoid:SetStateEnabled(state, true) end)
            end
            humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            if character:FindFirstChild("Animate") then character.Animate.Disabled = false end
            tpwalking = false
        else
            StartTpWalk()
            if character:FindFirstChild("Animate") then character.Animate.Disabled = true end
            
            for _, anim in next, humanoid:GetPlayingAnimationTracks() do
                anim:AdjustSpeed(0)
            end
            
            for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() humanoid:SetStateEnabled(state, false) end)
            end
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    end
})

PlayerTab:Space()

PlayerTab:Slider({
    Flag = "FlyV3SpeedSlider",
    Title = "Fly Speed",
    Desc = "Increases vector movement velocity steps dynamically.",
    IsTooltip = true,
    Step = 1,
    Value = {
        Min = 1,
        Max = 20,
        Default = 1,
    },
    Callback = function(Value)
        _G.FlyV3Speeds = Value
        if _G.FlyV3Active then
            StartTpWalk()
        end
    end
})

PlayerTab:Space()

PlayerTab:Button({
    Title = "UP",
    Desc = "Shifts your character coordinates upward natively.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
        end
    end
})

PlayerTab:Button({
    Title = "DOWN",
    Desc = "Shifts your character coordinates downward natively.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
        end
    end
})

PlayerTab:Space()

PlayerTab:Slider({
    Flag = "WalkspeedSlider",
    Title = "WalkSpeed",
    Desc = "Modify your walking movement speed.",
    IsTooltip = true,
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = 16,
    },
    Callback = function(Value)
        _G.WalkSpeed = Value
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:Space()

PlayerTab:Slider({
    Flag = "JumpPowerSlider",
    Title = "JumpPower",
    Desc = "Modify your maximum jump height.",
    IsTooltip = true,
    Step = 1,
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(Value)
        _G.JumpPower = Value
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = Value
        end
    end
})

PlayerTab:Space()

PlayerTab:Dropdown({
    Flag = "WeaponSlotDropdown",
    Title = "Weapon Slot",
    Desc = "Select the active weapon slot utilized by combat functions.",
    Values = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
    Value = "2",
    Callback = function(Option)
        _G.WeaponSlot = tonumber(Option)
    end
})

-- ============================================================================
-- 5. TELEPORT TAB
-- ============================================================================
local TeleportTab = MainSection:Tab({
    Title = "Teleport",
    Icon = "solar:map-arrow-square-bold",
    IconColor = Color3.fromHex("#00D2FF"),
    Border = true,
})

TeleportTab:Space()

-- Placeholder target positions since TargetX, TargetY, TargetZ were completely missing.
-- Replace Vector3.new(0, 10, 0) with your actual coordinate choices.
local targetPos = Vector3.new(0, 10, 0)

TeleportTab:Button({
    Title = "Dinner [Base]",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Dinner [Base]!",
                Icon = "check",
            })
        end
    end
})

-- Fixed syntax: unclosed string literal on description fixed
TeleportTab:Button({
    Title = "Furniture Store",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Furniture Store!",
                Icon = "check",
            })
        end
    end
})

-- Fixed syntax: unclosed string literal on description fixed
TeleportTab:Button({
    Title = "Evergreen",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Evergreen!",
                Icon = "check",
            })
        end
    end
})

-- Fixed syntax: unclosed string literal on description fixed
TeleportTab:Button({
    Title = "Farm",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Farm!",
                Icon = "check",
            })
        end
    end
})

-- ============================================================================
-- ESP TAB & FUNCTIONS
-- ============================================================================
local ESPTab = MainSection:Tab({
    Title = "ESP",
    Icon = "solar:check-square-bold",
    IconColor = Color3.fromHex("#10C550"),
    Border = true,
})

local UpdateESP

ESPTab:Toggle({
    Flag = "MonsterESPToggle",
    Title = "Monster ESP",
    Desc = "Highlights all hostile monsters.",
    Value = false,
    Callback = function(Value)
        ESPConfig.MonsterESP = Value
        UpdateESP()
    end
})

ESPTab:Space()

ESPTab:Toggle({
    Flag = "ItemESPToggle",
    Title = "Item ESP",
    Desc = "Highlights interactable bodies and items.",
    Value = false,
    Callback = function(Value)
        ESPConfig.ItemESP = Value
        UpdateESP()
    end
})

ESPTab:Space()

ESPTab:Toggle({
    Flag = "ESPNamesToggle",
    Title = "Show Names",
    Desc = "Displays object or entity names.",
    Value = true,
    Callback = function(Value)
        ESPConfig.ShowNames = Value
        UpdateESP()
    end
})

ESPTab:Space()

ESPTab:Toggle({
    Flag = "ESPDistanceToggle",
    Title = "Show Distance",
    Desc = "Displays distance measurements in studs.",
    Value = true,
    Callback = function(Value)
        ESPConfig.ShowDistance = Value
        UpdateESP()
    end
})

ESPTab:Space()

ESPTab:Toggle({
    Flag = "ESPHighlightToggle",
    Title = "Show Highlight",
    Desc = "Renders an outline/fill mesh highlight through walls.",
    Value = true,
    Callback = function(Value)
        ESPConfig.ShowHighlight = Value
        UpdateESP()
    end
})

function CreateESP(part, color, name, distance)
    local espGroup = {}
    
    if ESPConfig.ShowNames or ESPConfig.ShowDistance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = name .. "_Billboard"
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = ESPFolder
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ""
        
        if ESPConfig.ShowNames and ESPConfig.ShowDistance then
            textLabel.Text = name .. "\n" .. math.floor(distance) .. " studs"
        elseif ESPConfig.ShowNames then
            textLabel.Text = name
        elseif ESPConfig.ShowDistance then
            textLabel.Text = math.floor(distance) .. " studs"
        end
        
        textLabel.TextColor3 = color
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.Parent = billboard
        
        table.insert(espGroup, billboard)
    end
    
    if ESPConfig.ShowHighlight then
        local highlight = Instance.new("Highlight")
        highlight.Name = name .. "_Highlight"
        highlight.Adornee = part
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = ESPFolder
        table.insert(espGroup, highlight)
    end
    
    return espGroup
end

function ClearESP()
    for _, child in pairs(ESPFolder:GetChildren()) do
        child:Destroy()
    end
end

UpdateESP = function()
    ClearESP()
    
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local playerRoot = character.HumanoidRootPart
    
    if ESPConfig.MonsterESP then
        for _, monster in pairs(workspace.Monsters:GetChildren()) do
            if monster:IsA("Model") then
                local targetPart = monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChild("Head") or monster.PrimaryPart
                if targetPart then
                    local distance = (playerRoot.Position - targetPart.Position).Magnitude
                    CreateESP(targetPart, Color3.fromRGB(255, 50, 50), "Monster: " .. monster.Name, distance)
                end
            end
        end
    end
    
    if ESPConfig.ItemESP then
        for _, item in pairs(workspace.Interactables:GetChildren()) do
            if item:IsA("Model") then
                local isBody = item:FindFirstChild("HumanoidRootPart")
                local isItem = not item:FindFirstChild("ProductPriceTag")
                
                if isBody or isItem then
                    local targetPart = item:FindFirstChild("HumanoidRootPart") or item.PrimaryPart
                    if targetPart then
                        local distance = (playerRoot.Position - targetPart.Position).Magnitude
                        local espName = isBody and "Body: " .. item.Name or "Item: " .. item.Name
                        local espColor = isBody and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(50, 255, 50)
                        CreateESP(targetPart, espColor, espName, distance)
                    end
                end
            end
        end
    end
end

-- ============================================================================
-- CONFIGURATION MANAGER PANEL
-- ============================================================================
if not RunService:IsStudio() and writefile and printidentity() then
    local ConfigTab = MainSection:Tab({
        Title = "Config Center",
        Icon = "solar:folder-with-files-bold",
        IconColor = Color3.fromHex("#7775F2"),
        Border = true,
    })

    local ConfigManager = Window.ConfigManager
    local ConfigName = "default"

    local ConfigNameInput = ConfigTab:Input({
        Title = "Config Profiler",
        Icon = "file-cog",
        Callback = function(value)
            ConfigName = value
        end
    })

    ConfigTab:Space()

    local AllConfigs = ConfigManager:AllConfigs()
    local DefaultValue = table.find(AllConfigs, ConfigName) and ConfigName or nil

    local AllConfigsDropdown = ConfigTab:Dropdown({
        Title = "Saved Presets",
        Desc = "Choose an existing configuration payload",
        Values = AllConfigs,
        Value = DefaultValue,
        Callback = function(value)
            ConfigName = value
            ConfigNameInput:Set(value)
        end,
    })

    ConfigTab:Space()

    ConfigTab:Button({
        Title = "Save Preset",
        Justify = "Center",
        Callback = function()
            Window.CurrentConfig = ConfigManager:Config(ConfigName)
            if Window.CurrentConfig:Save() then
                WindUI:Notify({
                    Title = "Config Saved",
                    Desc = "Config '" .. ConfigName .. "' successfully processed.",
                    Icon = "check",
                })
            end
            AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
        end,
    })

    ConfigTab:Space()

    ConfigTab:Button({
        Title = "Load Preset",
        Justify = "Center",
        Callback = function()
            Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
            if Window.CurrentConfig:Load() then
                WindUI:Notify({
                    Title = "Config Operational",
                    Desc = "Loaded '" .. ConfigName .. "' settings.",
                    Icon = "refresh-cw",
                })
            end
        end,
    })
end

-- ============================================================================
-- BACKGROUND EXECUTION LOOPS
-- ============================================================================

-- Thread 1: Infinite Automated Grid Engine
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.AutoGrindEnabled then
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local slot = _G.WeaponSlot
                local targets = {}
                
                for _, monster in pairs(workspace.Monsters:GetChildren()) do
                    if monster:FindFirstChild("HumanoidRootPart") then
                        table.insert(targets, monster)
                    end
                end
                
                if #targets > 0 then
                    ZAP.meleeAttack.fire({
                        monsters = targets,
                        civilians = {},
                        activeSlot = slot
                    })
                end
            end
        end
    end
end)

-- Thread 2: Kill Aura Proximity Sweeper
task.spawn(function()
    while true do
        task.wait(0.01)
        if _G.KillAuraEnabled and not _G.AutoGrindEnabled then
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local root = character.HumanoidRootPart
                local slot = _G.WeaponSlot 
                local distance = _G.AuraDistance or 25
                
                for _, monster in pairs(workspace.Monsters:GetChildren()) do
                    if monster:FindFirstChild("HumanoidRootPart") then
                        local monsterDistance = (root.Position - monster.HumanoidRootPart.Position).Magnitude
                        if monsterDistance < distance then
                            ZAP.meleeAttack.fire({
                                monsters = {monster},
                                civilians = {},
                                activeSlot = slot
                            })
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Thread 3: Stat State Forcer
task.spawn(function()
    while true do
        task.wait(1)
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            if _G.WalkSpeed then
                character.Humanoid.WalkSpeed = _G.WalkSpeed
            end
            if _G.JumpPower then
                character.Humanoid.JumpPower = _G.JumpPower
            end
        end
    end
end)

-- Thread 4: Visual Refresh Controller
task.spawn(function()
    while true do
        task.wait(0.5)
        if ESPConfig.MonsterESP or ESPConfig.ItemESP then
            UpdateESP()
        else
            ClearESP()
        end
    end
end)

-- New Thread:
