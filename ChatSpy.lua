-- Bloqueio de execução múltipla universal para Roblox
local scriptId = "ChatSpy" -- Troque esse nome para um identificador único se quiser permitir múltiplos scripts distintos

if _G["executou_"..scriptId] then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Erro";
            Text = "Este script já foi executado e não pode ser executado novamente!";
            Duration = 5;
        })
    end)
    return -- Para o script aqui
else
    _G["executou_"..scriptId] = true
end

-- ChatSpy GUI - Tema preto/vermelho, botão mobile redondo, metade visível no rodapé com seta vermelha para cima
-- O botão só aparece quando a GUI está fechada, e fica colado no centro inferior da tela

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Criação da GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChatSpyGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Visible = false

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 20)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(255, 30, 30)
MainUIStroke.Thickness = 2
MainUIStroke.Transparency = 0.18
MainUIStroke.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 0))
}
Gradient.Rotation = 115
Gradient.Parent = MainFrame

-- Topbar decorativa
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "💬 ChatSpy"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 30
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Botão de fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
CloseButton.BackgroundTransparency = 0.1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 26
CloseButton.Parent = TopBar

local CloseUICorner = Instance.new("UICorner")
CloseUICorner.CornerRadius = UDim.new(1, 0)
CloseUICorner.Parent = CloseButton

local CloseUIStroke = Instance.new("UIStroke")
CloseUIStroke.Color = Color3.fromRGB(255, 60, 60)
CloseUIStroke.Thickness = 2
CloseUIStroke.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.17), {BackgroundColor3 = Color3.fromRGB(180, 0, 0)}):Play()
    TweenService:Create(CloseButton, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 180, 180)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.17), {BackgroundColor3 = Color3.fromRGB(60, 0, 0)}):Play()
    TweenService:Create(CloseButton, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)

-- BOTÃO "IR PARA O FIM" ao lado do botão de fechar, com contador
local GoToBottomButton = Instance.new("TextButton")
GoToBottomButton.Name = "GoToBottomButton"
GoToBottomButton.Size = UDim2.new(0, 45, 0, 35)
GoToBottomButton.Position = UDim2.new(1, -85, 0, 5)
GoToBottomButton.AnchorPoint = Vector2.new(1, 0)
GoToBottomButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GoToBottomButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
GoToBottomButton.BorderSizePixel = 2
GoToBottomButton.TextColor3 = Color3.fromRGB(255, 0, 0)
GoToBottomButton.Text = "▼"
GoToBottomButton.Font = Enum.Font.GothamBold
GoToBottomButton.TextSize = 24
GoToBottomButton.Visible = false
GoToBottomButton.Parent = TopBar
local goBtnCorner = Instance.new("UICorner")
goBtnCorner.CornerRadius = UDim.new(1, 0)
goBtnCorner.Parent = GoToBottomButton

-- Notificação de mensagens não lidas
local UnreadLabel = Instance.new("TextLabel")
UnreadLabel.Size = UDim2.new(0, 22, 0, 22)
UnreadLabel.Position = UDim2.new(1, -6, 0, -6)
UnreadLabel.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
UnreadLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UnreadLabel.TextSize = 15
UnreadLabel.Font = Enum.Font.GothamBold
UnreadLabel.Text = ""
UnreadLabel.AnchorPoint = Vector2.new(1, 0)
UnreadLabel.BackgroundTransparency = 0
UnreadLabel.Visible = false
UnreadLabel.Parent = GoToBottomButton
local unreadCorner = Instance.new("UICorner")
unreadCorner.CornerRadius = UDim.new(1, 0)
unreadCorner.Parent = UnreadLabel

local unreadCount = 0

-- Botão mobile REDONDO, metade visível na base, com seta vermelha
local MobileButton = Instance.new("ImageButton")
MobileButton.Name = "MobileToggleButton"
MobileButton.Size = UDim2.new(0, 80, 0, 80)
MobileButton.Position = UDim2.new(0.5, 0, 1, 40) -- metade da bola 'afundada'
MobileButton.AnchorPoint = Vector2.new(0.5,1)
MobileButton.BackgroundTransparency = 0
MobileButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MobileButton.BorderSizePixel = 0
MobileButton.Visible = false
MobileButton.Parent = ScreenGui
MobileButton.ZIndex = 100

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1,0)
btnCorner.Parent = MobileButton

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 40, 40)
btnStroke.Thickness = 3
btnStroke.Parent = MobileButton

-- Sombra discreta
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 18, 1, 18)
shadow.Position = UDim2.new(0, -9, 0, -9)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0,0,0)
shadow.ImageTransparency = 0.68
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10,10,118,118)
shadow.Parent = MobileButton
shadow.ZIndex = 99

-- Seta vermelha para cima (Unicode)
local Arrow = Instance.new("TextLabel")
Arrow.Size = UDim2.new(0, 44, 0, 44)
Arrow.Position = UDim2.new(0.5, -22, 0.45, -22)
Arrow.BackgroundTransparency = 1
Arrow.Text = "˄" -- ou "▲"
Arrow.TextColor3 = Color3.fromRGB(255, 40, 40)
Arrow.Font = Enum.Font.GothamBlack
Arrow.TextSize = 52
Arrow.Parent = MobileButton
Arrow.ZIndex = 101

-- Exibe o botão apenas se for mobile ou touch, e GUI estiver fechada
local function updateMobileButtonVisibility()
    if UserInputService.TouchEnabled and not MainFrame.Visible then
        MobileButton.Visible = true
    else
        MobileButton.Visible = false
    end
end

-- Ao tocar no botão: abre a GUI e esconde o botão
MobileButton.MouseButton1Click:Connect(function()
    MobileButton.Visible = false
    MainFrame.Position = UDim2.new(0.3, 0, 1, 0)
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.3, 0, 0.2, 0)}):Play()
end)

-- Função para fechar a GUI e mostrar o botão mobile novamente
local function CloseGUI()
    TweenService:Create(MainFrame, TweenInfo.new(0.38, Enum.EasingStyle.Quint), {Position = UDim2.new(0.3, 0, 1.2, 0)}):Play()
    wait(0.38)
    MainFrame.Visible = false
    updateMobileButtonVisibility()
end

CloseButton.MouseButton1Click:Connect(CloseGUI)

-- Mensagens (ScrollingFrame)
local MessageList = Instance.new("ScrollingFrame")
MessageList.Name = "MessageList"
MessageList.Size = UDim2.new(1, -18, 1, -65)
MessageList.Position = UDim2.new(0, 9, 0, 55)
MessageList.CanvasSize = UDim2.new(0, 0, 0, 0)
MessageList.AutomaticCanvasSize = Enum.AutomaticSize.Y
MessageList.ScrollBarThickness = 7
MessageList.BackgroundTransparency = 0.14
MessageList.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
MessageList.BorderSizePixel = 0
MessageList.Parent = MainFrame

local MessageUICorner = Instance.new("UICorner")
MessageUICorner.CornerRadius = UDim.new(0, 15)
MessageUICorner.Parent = MessageList

local MessageUIStroke = Instance.new("UIStroke")
MessageUIStroke.Color = Color3.fromRGB(255, 30, 30)
MessageUIStroke.Thickness = 1
MessageUIStroke.Transparency = 0.28
MessageUIStroke.Parent = MessageList

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MessageList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 7)

-- Funções de rolagem inteligente
local function IsAtBottom()
    local tolerance = 100
    return MessageList.CanvasPosition.Y + MessageList.AbsoluteWindowSize.Y >= MessageList.AbsoluteCanvasSize.Y - tolerance
end

local function ShowGoToBottomButton()
    GoToBottomButton.Visible = true
end

local function HideGoToBottomButton()
    GoToBottomButton.Visible = false
end

GoToBottomButton.MouseButton1Click:Connect(function()
    MessageList.CanvasPosition = Vector2.new(0, MessageList.CanvasSize.Y.Offset)
    HideGoToBottomButton()
    unreadCount = 0
    UnreadLabel.Visible = false
end)

-- Título animado vermelho-pulso
spawn(function()
    while Title and Title.Parent do
        TweenService:Create(Title, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255,30,30)}):Play()
        wait(1.5)
        TweenService:Create(Title, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 60, 60)}):Play()
        wait(1.5)
    end
end)

-- Função para adicionar mensagem
local function AddMessage(senderName, senderUserId, text)
    local MessageFrame = Instance.new("Frame")
    MessageFrame.Size = UDim2.new(1, -10, 0, 70)
    MessageFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    MessageFrame.BackgroundTransparency = 0.19
    MessageFrame.BorderSizePixel = 0
    MessageFrame.LayoutOrder = tick()
    MessageFrame.ClipsDescendants = true
    MessageFrame.Parent = MessageList
    MessageFrame.Position = UDim2.new(0, 5, 0, 0)
    MessageFrame.ZIndex = 3

    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 12)
    msgCorner.Parent = MessageFrame

    local msgStroke = Instance.new("UIStroke")
    msgStroke.Color = Color3.fromRGB(255, 40, 40)
    msgStroke.Thickness = 0.7
    msgStroke.Transparency = 0.7
    msgStroke.Parent = MessageFrame

    -- Avatar
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 50, 0, 50)
    Avatar.Position = UDim2.new(0, 8, 0, 10)
    Avatar.BackgroundTransparency = 0.25
    Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..senderUserId.."&width=420&height=420&format=png"
    Avatar.Parent = MessageFrame
    Avatar.ScaleType = Enum.ScaleType.Fit
    Avatar.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    Avatar.ZIndex = 4

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1,0)
    avatarCorner.Parent = Avatar

    -- Nome + Mensagem
    local NameAndText = Instance.new("TextLabel")
    NameAndText.Size = UDim2.new(1, -70, 1, -10)
    NameAndText.Position = UDim2.new(0, 65, 0, 5)
    NameAndText.BackgroundTransparency = 1
    NameAndText.TextXAlignment = Enum.TextXAlignment.Left
    NameAndText.TextYAlignment = Enum.TextYAlignment.Top
    NameAndText.Font = Enum.Font.GothamSemibold
    NameAndText.TextSize = 18
    NameAndText.TextWrapped = true
    NameAndText.Text = "<b><font color=\"rgb(255,60,60)\">"..senderName.."</font></b> <font color=\"rgb(255,200,200)\">:</font> "..text
    NameAndText.RichText = true
    NameAndText.TextColor3 = Color3.fromRGB(255,200,200)
    NameAndText.Parent = MessageFrame
    NameAndText.ZIndex = 4

    -- Efeito fade in animado na mensagem
    MessageFrame.BackgroundTransparency = 1
    NameAndText.TextTransparency = 1
    Avatar.ImageTransparency = 1
    TweenService:Create(MessageFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0.19}):Play()
    TweenService:Create(NameAndText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(Avatar, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()

    -- Efeito de brilho ao passar mouse na mensagem
    MessageFrame.MouseEnter:Connect(function()
        TweenService:Create(MessageFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 0, 0)}):Play()
    end)
    MessageFrame.MouseLeave:Connect(function()
        TweenService:Create(MessageFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 0, 0)}):Play()
    end)

    -- Atualizar CanvasSize
    MessageList.CanvasSize = UDim2.new(0, 0, 0, MessageList.UIListLayout.AbsoluteContentSize.Y)
    task.defer(function()
        if IsAtBottom() then
            MessageList.CanvasPosition = Vector2.new(0, MessageList.CanvasSize.Y.Offset)
            HideGoToBottomButton()
            unreadCount = 0
            UnreadLabel.Visible = false
        else
            unreadCount = unreadCount + 1
            UnreadLabel.Text = tostring(unreadCount)
            UnreadLabel.Visible = true
            ShowGoToBottomButton()
        end
    end)
end

-- Evento de rolagem manual: esconder botão se voltar ao fim
MessageList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if IsAtBottom() then
        HideGoToBottomButton()
        unreadCount = 0
        UnreadLabel.Visible = false
    end
end)

-- Conexões para jogadores
local Connections = {}

local function SpyPlayer(player)
    if Connections[player] then
        Connections[player]:Disconnect()
    end
    Connections[player] = player.Chatted:Connect(function(msg)
        AddMessage(player.Name, player.UserId, msg)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    SpyPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    SpyPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if Connections[player] then
        Connections[player]:Disconnect()
        Connections[player] = nil
    end
end)

-- Atalho de teclado para mostrar/ocultar (PC)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        if not MainFrame.Visible then
            MobileButton.Visible = false
            MainFrame.Position = UDim2.new(0.3, 0, 1, 0)
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.3, 0, 0.2, 0)}):Play()
        else
            CloseGUI()
        end
    end
end)

-- Sombra para MainFrame
local function CreateDropShadow(guiObject, radius, transparency)
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.BackgroundTransparency = 1
    DropShadow.Image = "rbxassetid://1316045217"
    DropShadow.ImageColor3 = Color3.fromRGB(60, 0, 0)
    DropShadow.ImageTransparency = transparency or 0.65
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    DropShadow.Size = UDim2.new(1, radius, 1, radius)
    DropShadow.Position = UDim2.new(0, -radius/2, 0, -radius/2)
    DropShadow.ZIndex = guiObject.ZIndex - 1
    DropShadow.Parent = guiObject
end
CreateDropShadow(MainFrame, 32, 0.78)

-- Dica visual
local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, 0, 0, 25)
Hint.Position = UDim2.new(0, 0, 1, -30)
Hint.BackgroundTransparency = 1
if UserInputService.TouchEnabled then
    Hint.Text = "Toque na seta para mostrar/ocultar o ChatSpy!"
else
    Hint.Text = "Pressione <b>F4</b> para mostrar/ocultar o ChatSpy!"
end
Hint.TextColor3 = Color3.fromRGB(255,60,60)
Hint.Font = Enum.Font.Gotham
Hint.TextSize = 16
Hint.TextStrokeTransparency = 0.5
Hint.RichText = true
Hint.Parent = MainFrame
Hint.ZIndex = 5

TweenService:Create(Hint, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {TextTransparency = 0.65}):Play()
wait(5)
TweenService:Create(Hint, TweenInfo.new(1), {TextTransparency = 1}):Play()
wait(1)
Hint:Destroy()

-- Inicializa visibilidade correta do botão
updateMobileButtonVisibility()