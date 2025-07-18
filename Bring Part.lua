local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Create Modern GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "Gui"
Gui.Parent = gethui()
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 230)
Main.Position = UDim2.new(0.5, -160, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

-- Add rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

-- Title Bar
local Label = Instance.new("TextLabel")
Label.Name = "Label"
Label.Size = UDim2.new(1, 0, 0, 40)
Label.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Label.BorderSizePixel = 0
Label.Text = "Bring Parts V2 By TengeMan"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 16
Label.Font = Enum.Font.GothamBold
Label.Parent = Main

local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim.new(0, 8)
UICorner_2.Parent = Label

-- Player Input Box
local Box = Instance.new("TextBox")
Box.Name = "Box"
Box.Size = UDim2.new(0.85, 0, 0, 40)
Box.Position = UDim2.new(0.075, 0, 0.3, 0)
Box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Box.BorderSizePixel = 0
Box.PlaceholderText = "Player here"
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
Box.TextSize = 14
Box.Font = Enum.Font.GothamSemibold
Box.Parent = Main

local UICorner_3 = Instance.new("UICorner")
UICorner_3.CornerRadius = UDim.new(0, 6)
UICorner_3.Parent = Box

-- Toggle Button
local Button = Instance.new("TextButton")
Button.Name = "Button"
Button.Size = UDim2.new(0.85, 0, 0, 45)
Button.Position = UDim2.new(0.075, 0, 0.50, 0)
Button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
Button.BorderSizePixel = 0
Button.Text = "Bring | Off"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 16
Button.Font = Enum.Font.GothamBold
Button.Parent = Main

local UICorner_4 = Instance.new("UICorner")
UICorner_4.CornerRadius = UDim.new(0, 6)
UICorner_4.Parent = Button

-- Add Bring Parts to Everyone Button
local EveryoneButton = Instance.new("TextButton")
EveryoneButton.Name = "EveryoneButton"
EveryoneButton.Size = UDim2.new(0.85, 0, 0, 40)
EveryoneButton.Position = UDim2.new(0.075, 0, 0.75, 0)
EveryoneButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
EveryoneButton.BorderSizePixel = 0
EveryoneButton.Text = "Bring Parts to Everyone"
EveryoneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EveryoneButton.TextSize = 16
EveryoneButton.Font = Enum.Font.GothamBold
EveryoneButton.Parent = Main

local UICorner_6 = Instance.new("UICorner")
UICorner_6.CornerRadius = UDim.new(0, 6)
UICorner_6.Parent = EveryoneButton

-- Core Variables
local LocalPlayer = Players.LocalPlayer
local character
local targetPart -- Will be either Torso or HumanoidRootPart

-- Toggle Visibility
mainStatus = true
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessedEvent then
        mainStatus = not mainStatus
        Main.Visible = mainStatus
    end
end)

-- Setup Network
local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(Part)
        if Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end

    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(Workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end

    EnablePartControl()
end

local function ForcePart(v)
    -- Skip if it's a tool handle or part of a tool/character
    if v:IsA("BasePart") and not v.Anchored and 
       not v.Parent:FindFirstChildOfClass("Humanoid") and 
       not v.Parent:FindFirstChild("Head") and 
       v.Name ~= "Handle" and 
       not v.Parent:IsA("Tool") and 
       not v.Parent:IsA("HopperBin") then
        
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        
        if v:FindFirstChild("Attachment") then
            v:FindFirstChild("Attachment"):Destroy()
        end
        if v:FindFirstChild("AlignPosition") then
            v:FindFirstChild("AlignPosition"):Destroy()
        end
        if v:FindFirstChild("Torque") then
            v:FindFirstChild("Torque"):Destroy()
        end
        
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1
    end
end

local blackHoleActive = false
local DescendantAddedConnection

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        Button.Text = "Bring Parts | On"
        Button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        for _, v in ipairs(Workspace:GetDescendants()) do
            ForcePart(v)
        end

        DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then
                ForcePart(v)
            end
        end)

        spawn(function()
            while blackHoleActive and RunService.RenderStepped:Wait() do
                if targetPart then
                    Attachment1.WorldCFrame = targetPart.CFrame
                end
            end
        end)
    else
        Button.Text = "Bring Parts | Off"
        Button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        if DescendantAddedConnection then
            DescendantAddedConnection:Disconnect()
        end
    end
end

local function getPlayer(name)
    local lowerName = string.lower(name)
    for _, p in pairs(Players:GetPlayers()) do
        local lowerPlayer = string.lower(p.Name)
        if string.find(lowerPlayer, lowerName) then
            return p
        elseif string.find(string.lower(p.DisplayName), lowerName) then
            return p
        end
    end
end

local player = nil

local function VDOYZQL_fake_script() -- Box.Script 
    local script = Instance.new('Script', Box)

    script.Parent.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            player = getPlayer(Box.Text)
            if player then
                Box.Text = player.Name
                print("Player found:", player.Name)
            else
                print("Player not found")
            end
        end
    end)
end
coroutine.wrap(VDOYZQL_fake_script)()

local function JUBNQKI_fake_script() -- Button.Script 
    local script = Instance.new('Script', Button)

    script.Parent.MouseButton1Click:Connect(function()
        if player then
            character = player.Character or player.CharacterAdded:Wait()
            -- Check for both Torso and HumanoidRootPart
            targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
            if targetPart then
                toggleBlackHole()
            else
                print("Couldn't find Torso or HumanoidRootPart")
            end
        else
            print("Player is not selected")
        end
    end)
end
coroutine.wrap(JUBNQKI_fake_script)()

-- Bring Parts to Everyone functionality
local function bringPartsToEveryone()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            character = player.Character or player.CharacterAdded:Wait()
            -- Check for both Torso and HumanoidRootPart
            targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
            if targetPart then
                toggleBlackHole()
                wait(1.2)
            end
        end
    end
end

EveryoneButton.MouseButton1Click:Connect(bringPartsToEveryone)