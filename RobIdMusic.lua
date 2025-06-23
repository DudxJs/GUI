--[[ 
    GUI Customizada: Tema Preto com Detalhes RGB e Efeitos
    Script por: DudxJs + Copilot (2025)
    ------------------------------------------
    - Efeitos de "RGB Glow" nos elementos
    - Gradientes animados nas bordas
    - Sombras suaves e fontes estilizadas
    - Botões com hover animado
    - Layout moderno e responsivo
    - Busca por Username ou DisplayName
    - Notificação/Animação ao copiar
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Função para criar gradiente RGB animado
local function createAnimatedGradient(parent, rotationSpeed)
    local uiGradient = Instance.new("UIGradient", parent)
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,89)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,98)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,233,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,60,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,89)),
    }
    uiGradient.Rotation = 0
    task.spawn(function()
        while uiGradient.Parent do
            uiGradient.Rotation = (uiGradient.Rotation + (rotationSpeed or 1)) % 360
            task.wait(0.03)
        end
    end)
    return uiGradient
end

local function addShadow(parent, transparency)
    local shadow = Instance.new("ImageLabel", parent)
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ZIndex = parent.ZIndex - 1
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    return shadow
end

local function makeDraggable(gui)
	local dragging, dragInput, dragStart, startPos
	gui.Active = true
	gui.Selectable = true
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- GUI principal
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "BoomboxFinderRGB"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 350, 0, 210)
frame.Position = UDim2.new(0.5, -175, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.ZIndex = 2
makeDraggable(frame)

-- Bordas RGB
local border = Instance.new("Frame", frame)
border.Name = "RGBBorder"
border.Size = UDim2.new(1, 0, 1, 0)
border.Position = UDim2.new(0,0,0,0)
border.BackgroundTransparency = 1
border.BorderSizePixel = 0
border.ZIndex = 5

local rgbLineTop = Instance.new("Frame", border)
rgbLineTop.Size = UDim2.new(1, 0, 0, 4)
rgbLineTop.Position = UDim2.new(0, 0, 0, -4)
rgbLineTop.BorderSizePixel = 0
rgbLineTop.BackgroundColor3 = Color3.fromRGB(255,255,255)
rgbLineTop.ZIndex = 6
createAnimatedGradient(rgbLineTop, 2)

local rgbLineBottom = rgbLineTop:Clone()
rgbLineBottom.Parent = border
rgbLineBottom.Position = UDim2.new(0,0,1,0)
createAnimatedGradient(rgbLineBottom, -2)

local rgbLineLeft = Instance.new("Frame", border)
rgbLineLeft.Size = UDim2.new(0, 4, 1, 0)
rgbLineLeft.Position = UDim2.new(0, -4, 0, 0)
rgbLineLeft.BorderSizePixel = 0
rgbLineLeft.BackgroundColor3 = Color3.fromRGB(255,255,255)
rgbLineLeft.ZIndex = 6
createAnimatedGradient(rgbLineLeft, 2)

local rgbLineRight = rgbLineLeft:Clone()
rgbLineRight.Parent = border
rgbLineRight.Position = UDim2.new(1, 0, 0, 0)
createAnimatedGradient(rgbLineRight, -2)

addShadow(frame, 0.5)

-- Glow interno
local glow = Instance.new("ImageLabel", frame)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084"
glow.Size = UDim2.new(1, 60, 1, 60)
glow.Position = UDim2.new(0, -30, 0, -30)
glow.ImageColor3 = Color3.fromRGB(0,255,255)
glow.ImageTransparency = 0.86
glow.ZIndex = 1

-- Título estilizado com gradiente RGB
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 42)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "✨ Verificar Boombox ✨"
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.ZIndex = 10
local grad = createAnimatedGradient(title, 1.5)
grad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0,0.12),
    NumberSequenceKeypoint.new(1,0.12)
}

-- Caixa de texto com efeito
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -32, 0, 44)
input.Position = UDim2.new(0, 16, 0, 52)
input.PlaceholderText = "Digite o nome ou displayname do jogador"
input.Text = ""
input.TextScaled = true
input.Font = Enum.Font.GothamSemibold
input.ClearTextOnFocus = false
input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
input.TextColor3 = Color3.fromRGB(180,255,255)
input.BorderSizePixel = 0
input.ZIndex = 9
local gradInput = createAnimatedGradient(input, 3)
gradInput.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0,0.3),
    NumberSequenceKeypoint.new(1,0.3)
}

-- Créditos discretos
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, -10, 0, 16)
credit.Position = UDim2.new(0, 5, 1, -18)
credit.BackgroundTransparency = 1
credit.Text = "Made By: Dudx_js"
credit.TextColor3 = Color3.fromRGB(80, 90, 110)
credit.TextTransparency = 0.4
credit.Font = Enum.Font.GothamSemibold
credit.TextSize = 14
credit.TextXAlignment = Enum.TextXAlignment.Right
credit.ZIndex = 15

-- Botão com efeito hover RGB
local function styleButton(btn, baseColor)
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = baseColor or Color3.fromRGB(28,28,28)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextStrokeTransparency = 0.5
    btn.BorderSizePixel = 0
    btn.ZIndex = 10
    local grad = createAnimatedGradient(btn, 2.5)
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.15),
        NumberSequenceKeypoint.new(1,0.15)
    }
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(0,255,255)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = baseColor or Color3.fromRGB(28,28,28)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)
end

local checkButton = Instance.new("TextButton", frame)
checkButton.Size = UDim2.new(1, -32, 0, 42)
checkButton.Position = UDim2.new(0, 16, 0, 104)
checkButton.Text = "Verificar"
checkButton.TextScaled = true
styleButton(checkButton)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, -32, 0, 34)
closeBtn.Position = UDim2.new(0, 16, 0, 158)
closeBtn.Text = "Fechar"
closeBtn.TextScaled = true
styleButton(closeBtn, Color3.fromRGB(28,10,28))

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Notificação de cópia (animação/efeito)
local function showCopyNotification(parent)
    local notif = Instance.new("TextLabel")
    notif.AnchorPoint = Vector2.new(0.5, 0.5)
    notif.Position = UDim2.new(0.5, 0, 0, -22)
    notif.Size = UDim2.new(0.7, 0, 0, 32)
    notif.BackgroundTransparency = 0.15
    notif.BackgroundColor3 = Color3.fromRGB(14, 22, 24)
    notif.Text = "ID copiado!"
    notif.TextColor3 = Color3.fromRGB(0,255,200)
    notif.TextScaled = true
    notif.Font = Enum.Font.GothamBold
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    notif.Parent = parent

    -- Efeito de gradiente RGB na notificação
    createAnimatedGradient(notif, 6)

    -- Animação de fade in/out
    notif.TextTransparency = 1
    notif.BackgroundTransparency = 1
    local tweenService = game:GetService("TweenService")
    local t1 = tweenService:Create(notif, TweenInfo.new(0.15), {TextTransparency = 0, BackgroundTransparency = 0.15})
    t1:Play()
    t1.Completed:Wait()
    wait(1.1)
    local t2 = tweenService:Create(notif, TweenInfo.new(0.25), {TextTransparency = 1, BackgroundTransparency = 1})
    t2:Play()
    t2.Completed:Wait()
    notif:Destroy()
end

-- Mostrar resultado bonito
local function mostrarResultado(id)
	local resultGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
	resultGui.Name = "ResultadoBoomboxRGB"
	local box = Instance.new("Frame", resultGui)
	box.Size = UDim2.new(0, 320, 0, 150)
	box.Position = UDim2.new(0.5, -160, 0.5, -75)
	box.BackgroundColor3 = Color3.fromRGB(20,20,20)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.ZIndex = 2
	makeDraggable(box)
	addShadow(box, 0.4)
	createAnimatedGradient(box, 2)
	local glow = Instance.new("ImageLabel", box)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857084"
	glow.Size = UDim2.new(1, 40, 1, 40)
	glow.Position = UDim2.new(0, -20, 0, -20)
	glow.ImageColor3 = Color3.fromRGB(0,255,255)
	glow.ImageTransparency = 0.86
	glow.ZIndex = 1

	local text = Instance.new("TextBox", box)
	text.Size = UDim2.new(1, -24, 0, 46)
	text.Position = UDim2.new(0, 12, 0, 14)
	text.Text = id
	text.TextEditable = false
	text.TextScaled = true
	text.ClearTextOnFocus = false
	text.Font = Enum.Font.GothamBold
	text.BackgroundColor3 = Color3.fromRGB(28,28,28)
    text.ZIndex = 16
	text.TextColor3 = Color3.fromRGB(0,255,255)
	text.BorderSizePixel = 0
	createAnimatedGradient(text, 2.5)

	local copy = Instance.new("TextButton", box)
	copy.Size = UDim2.new(0.5, -10, 0, 38)
	copy.Position = UDim2.new(0, 10, 0, 74)
	copy.Text = "Copiar"
	copy.TextScaled = true
	styleButton(copy, Color3.fromRGB(30,32,30))

	local close = Instance.new("TextButton", box)
	close.Size = UDim2.new(0.5, -10, 0, 38)
	close.Position = UDim2.new(0.5, 0, 0, 74)
	close.Text = "Fechar"
	close.TextScaled = true
	styleButton(close, Color3.fromRGB(32,30,30))

	copy.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(id)
		end
        showCopyNotification(box)
	end)
	close.MouseButton1Click:Connect(function()
		resultGui:Destroy()
	end)
end

-- Lógica de busca: agora aceita DisplayName ou Username
checkButton.MouseButton1Click:Connect(function()
	local texto = input.Text:lower()
	local achado = nil
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local nameMatch = player.Name:lower():find(texto)
			local displayMatch = player.DisplayName and player.DisplayName:lower():find(texto)
			if nameMatch or displayMatch then
				achado = player
				break
			end
		end
	end

	if achado and achado.Character then
		for _, obj in ipairs(achado.Character:GetDescendants()) do
			if obj:IsA("Sound") and obj.Playing then
				local id = obj.SoundId:match("%d+")
				if id then
					mostrarResultado(id)
					return
				end
			end
		end
	end

	mostrarResultado("Nenhuma música encontrada.")
end)