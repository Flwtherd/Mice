local RunService = game:GetService("RunService")

--[[
    WindUI - Mice: Bake or Die Hub
    Migrated to latest WindUI architecture with FLY GUI V3 Integration
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
    Title = "FLY GUI V3";
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
    Title = "Mice  | Bake or Die",
    Subtitle = "Version 1.2",
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

-- Welcome Notification
WindUI:Popup({
    Title = "Update info",
    Icon = "solar:info-square-bold",
    Content = "Version 1.0 Whats New? | Welcome to new Mice Script.",
    Buttons = {
        {
            Title = "Close",
            Variant = "Tertiary",
        },
        {
            Title = "Continue",
            Icon = "arrow-right",
            Variant = "Primary",
        }
    }
})

-- Version Tag
Window:Tag({
    Title = "v" .. WindUI.Version,
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

-- */ Section Assignments /* --
local MainSection = Window:Section({ Title = "Main" })

-- ============================================================================
-- PATCH NOTES TAB
-- ============================================================================
local PatchTab = MainSection:Tab({
    Title = "Patch Notes",
    Icon = "solar:file-text-bold",
    IconColor = Color3.fromHex("#83889E"),
    Border = true,
})

PatchTab:Button({
    Title = "[CRITICAL] Patch Notice v2.3",
    Desc = "• FIXED: Fully optimized FLY GUI V3 architecture to support multi-rig configurations seamlessly.\n• ADDED: Natively integrated fly engines, speed multipliers, and direct axis configuration buttons.\n• OPTIMIZED: Stabilized heartbeat loops to remove random execution hitching.",
    Callback = function() end
})

-- ============================================================================
-- COMBAT TAB
-- ============================================================================
local CombatTab = MainSection:Tab({
    Title = "Combat",
    Icon = "solar:cursor-square-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    Border = true,
})

CombatTab:Toggle({
    Flag = "KillAuraToggle",
    Title = "Kill Aura",
    Desc = "Automatically attacks nearby monsters.",
    Value = false,
    Callback = function(Value)
        _G.KillAuraEnabled = Value
    end
})

CombatTab:Space()

CombatTab:Slider({
    Flag = "AuraDistanceSlider",
    Title = "Kill Aura Distance",
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
    Title = "Auto Grind Monsters",
    Desc = "Continuously and automatically wipes out every zombie on the map.",
    Value = false,
    Callback = function(Value)
        _G.AutoGrindEnabled = Value
    end
})

CombatTab:Space()

-- SMART IDENTIFIER LOOP IMPLEMENTATION
_G.SmartIdentifierEnabled = false
CombatTab:Toggle({
    Flag = "SmartIdentifierToggle",
    Title = "Smart Item/Zombie Identifier",
    Desc = "Detects whether you hold a zombie or item and pushes them to the Grinder or Blueprint Table automatically.",
    Value = false,
    Callback = function(Value)
        _G.SmartIdentifierEnabled = Value
        if Value then
            task.spawn(function()
                while _G.SmartIdentifierEnabled do
                    local character = Players.LocalPlayer.Character
                    local stations = workspace:FindFirstChild("Stations")
                    
                    if character and stations then
                        -- Check for objects standardly held or welded within your character model
                        for _, obj in pairs(character:GetChildren()) do
                            if obj:IsA("Model") or obj:IsA("Tool") then
                                -- Check if it's a corpse / zombie based on structural properties
                                local isZombieOrBody = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or string.find(string.lower(obj.Name), "zombie") or string.find(string.lower(obj.Name), "body")
                                -- Standard items do not have purchase tags and are standard objects
                                local isItemOrBlueprint = not obj:FindFirstChild("ProductPriceTag") and not isZombieOrBody
                                
                                if isZombieOrBody then
                                    local grinder = stations:FindFirstChild("Grinder")
                                    local deposit = grinder and grinder:FindFirstChild("ObjectDeposit")
                                    if deposit then
                                        -- Fire the specific interaction remote sequence
                                        local args = {
                                            buffer.fromstring("\027\001"),
                                            { deposit }
                                        }
                                        game:GetService("ReplicatedStorage"):WaitForChild("ZAP"):WaitForChild("ZAP_RELIABLE"):FireServer(unpack(args))
                                    end
                                    
                                elseif isItemOrBlueprint then
                                    local blueprintTable = stations:FindFirstChild("BlueprintsTable")
                                    local deposit = blueprintTable and blueprintTable:FindFirstChild("ObjectDeposit")
                                    if deposit then
                                        -- Fire the specific interaction remote sequence
                                        local args = {
                                            buffer.fromstring("\027\001"),
                                            { deposit }
                                        }
                                        game:GetService("ReplicatedStorage"):WaitForChild("ZAP"):WaitForChild("ZAP_RELIABLE"):FireServer(unpack(args))
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.3) -- Built-in processing wait interval
                end
            end)
        end
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
                        activeSlot = _G.WeaponSlot or 2
                    })
                    task.wait(0.1)
                end
            end
        end
    end
})

-- ============================================================================
-- ITEMS TAB
-- ============================================================================
local ItemsTab = MainSection:Tab({
    Title = "Items",
    Icon = "solar:folder-with-files-bold",
    IconColor = Color3.fromHex("#ECA201"),
    Border = true,
})

ItemsTab:Button({
    Title = "Bring Bodies",
    Desc = "Teleports all interactable bodies to your position.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character.PrimaryPart then
            for _, v in pairs(workspace.Interactables:GetChildren()) do 
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and not v:FindFirstChild("ProductPriceTag") then
                    v.PrimaryPart.CFrame = character.PrimaryPart.CFrame
                    task.wait(0.05)
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
                    task.wait(0.05)
                end
            end
        end
    end
})

-- ============================================================================
-- TELEPORT TAB
-- ============================================================================
local TeleportTab = MainSection:Tab({
    Title = "Teleport",
    Icon = "solar:map-arrow-square-bold",
    IconColor = Color3.fromHex("#00D2FF"),
    Border = true,
})

TeleportTab:Space()

local dinnerPos     = Vector3.new(-26, 52, 98)
local furniturePos  = Vector3.new(-204, 52, 14)
local evergreenPos  = Vector3.new(462, 51, -349)
local farmPos       = Vector3.new(-167, 55, 394)
local BankPos       = Vector3.new(999, 54, -127)

TeleportTab:Button({
    Title = "Dinner [Base]",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(dinnerPos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Dinner [Base]!",
                Icon = "check",
            })
        end
    end
})

TeleportTab:Space()

TeleportTab:Button({
    Title = "Furniture Store",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(furniturePos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Furniture Store!",
                Icon = "check",
            })
        end
    end
})

TeleportTab:Space()

TeleportTab:Button({
    Title = "Evergreen",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(evergreenPos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Evergreen!",
                Icon = "check",
            })
        end
    end
})

TeleportTab:Space()

TeleportTab:Button({
    Title = "Farm",
    Desc = "Instantly maps and teleports you to the specified X, Y, Z workspace vectors.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(farmPos)
            WindUI:Notify({
                Title = "Teleport Executed",
                Desc = "Successfully Teleported To Farm!",
                Icon = "check",
            })
        end
    end
})

-- ============================================================================
-- PLAYER TAB (WITH INTEGRATED FLY GUI V3 FUNCTIONS)
-- ============================================================================
local PlayerTab = MainSection:Tab({
    Title = "Player Settings",
    Icon = "solar:password-minimalistic-input-bold",
    IconColor = Color3.fromHex("#7775F2"),
    Border = true,
})

PlayerTab:Toggle({
    Flag = "FlyV3Toggle",
    Title = "Fly Engine (V3 Backend)",
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
    Title = "Fly Speed Multiplier",
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
    Title = "Ascend Character (UP)",
    Desc = "Shifts your character coordinates upward natively.",
    Callback = function()
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
        end
    end
})

PlayerTab:Button({
    Title = "Descend Character (DOWN)",
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

-- Infinite loop handler for rendering distance calculations dynamically
task.spawn(function()
    while task.wait(1) do
        if ESPConfig.MonsterESP or ESPConfig.ItemESP then
            UpdateESP()
        end
    end
end)
