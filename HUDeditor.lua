-- Script completo com bolinha vermelha de seleção analógica (touchpad), clique por botão e ajustes finais

local player = game.Players.LocalPlayer
local guiAntiga = player.PlayerGui:FindFirstChild("EditorDeBotoes")
if guiAntiga then guiAntiga:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EditorDeBotoes"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999 -- Sempre por cima de tudo
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- GUI Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 50)
MainFrame.Position = UDim2.new(0, 20, 0, 80)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local selecionarBtn = Instance.new("TextButton")
selecionarBtn.Size = UDim2.new(1, -10, 1, -10)
selecionarBtn.Position = UDim2.new(0, 5, 0, 5)
selecionarBtn.Text = "✏️ Selecionar Botão"
selecionarBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
selecionarBtn.TextColor3 = Color3.new(1, 1, 1)
selecionarBtn.Font = Enum.Font.Gotham
selecionarBtn.TextSize = 14
selecionarBtn.Parent = MainFrame
Instance.new("UICorner", selecionarBtn).CornerRadius = UDim.new(0, 6)

local modoSelecionando = false

-- Bolinha vermelha
local cursor = Instance.new("Frame")
cursor.Size = UDim2.new(0, 12, 0, 12)
cursor.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
cursor.Position = UDim2.new(0.5, -6, 0.5, -6)
cursor.ZIndex = 999998 -- Muito acima
cursor.Visible = false
cursor.AnchorPoint = Vector2.new(0, 0)
cursor.BorderSizePixel = 0
cursor.Name = "VirtualCursor"
cursor.Parent = ScreenGui
Instance.new("UICorner", cursor).CornerRadius = UDim.new(1, 0)

-- Touchpad
local touchpad = Instance.new("Frame")
touchpad.Size = UDim2.new(1, 0, 0, 100)
touchpad.Position = UDim2.new(0, 0, 1, -100)
touchpad.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
touchpad.BackgroundTransparency = 0.4
touchpad.ZIndex = 998000
touchpad.Visible = false
touchpad.Name = "Touchpad"
touchpad.Parent = ScreenGui

-- Botão de clique
local clickBtn = Instance.new("TextButton")
clickBtn.Size = UDim2.new(0, 120, 0, 40)
clickBtn.Position = UDim2.new(1, -130, 1, -110)
clickBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
clickBtn.Text = "⏺ Clicar"
clickBtn.TextColor3 = Color3.new(1, 1, 1)
clickBtn.Font = Enum.Font.GothamBold
clickBtn.TextSize = 14
clickBtn.ZIndex = 999999
clickBtn.Visible = false
clickBtn.Parent = ScreenGui
Instance.new("UICorner", clickBtn).CornerRadius = UDim.new(0, 6)

-- Movimento analógico
local moving = false
local lastInput = nil
local moveConnection = nil
local RS = game:GetService("RunService")

local function updateCursorPosition(dir)
	if not cursor.Visible then return end
	local pos = cursor.Position
	local dx, dy = dir.X * 5, dir.Y * 5 -- sensibilidade aumentada de 2 para 5
	local newX = math.clamp(pos.X.Offset + dx, 0, ScreenGui.AbsoluteSize.X - cursor.AbsoluteSize.X)
	local newY = math.clamp(pos.Y.Offset + dy, 0, ScreenGui.AbsoluteSize.Y - cursor.AbsoluteSize.Y)
	cursor.Position = UDim2.new(0, newX, 0, newY)
end

local function enableTouchpad()
	cursor.Visible = true
	touchpad.Visible = true
	clickBtn.Visible = true
	local direction = Vector2.zero

	touchpad.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			moving = true
			lastInput = input.Position
		end
	end)

	touchpad.InputChanged:Connect(function(input)
		if moving and input.UserInputType == Enum.UserInputType.Touch then
			direction = (input.Position - lastInput)/6 -- sensibilidade aumentada
			lastInput = input.Position
		end
	end)

	touchpad.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			moving = false
			direction = Vector2.zero
		end
	end)

	if moveConnection then moveConnection:Disconnect() end
	moveConnection = RS.RenderStepped:Connect(function()
		if moving then
			updateCursorPosition(direction)
		end
	end)
end

-- Clique no botão clicável
clickBtn.MouseButton1Click:Connect(function()
	local pos = Vector2.new(cursor.AbsolutePosition.X + cursor.AbsoluteSize.X/2, cursor.AbsolutePosition.Y + cursor.AbsoluteSize.Y/2)
	local under = player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(pos.X, pos.Y)
	for _, gui in ipairs(under) do
		if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and not gui:IsDescendantOf(ScreenGui) then
			modoSelecionando = false
			cursor.Visible = false
			touchpad.Visible = false
			clickBtn.Visible = false
			MostrarInfoDoBotao(gui)
			return
		end
	end
end)

selecionarBtn.MouseButton1Click:Connect(function()
	if modoSelecionando then
		modoSelecionando = false
		cursor.Visible = false
		touchpad.Visible = false
		clickBtn.Visible = false
		selecionarBtn.Text = "✏️ Selecionar Botão"
		return
	end

	modoSelecionando = true
	selecionarBtn.Text = "📈 Tocando para selecionar..."
	enableTouchpad()
end)

-- Função para mostrar informações antes da edição
function MostrarInfoDoBotao(botao)
	local fundo = Instance.new("Frame")
	fundo.Size = UDim2.new(1, 0, 1, 0)
	fundo.BackgroundColor3 = Color3.new(0, 0, 0)
	fundo.BackgroundTransparency = 0.4
	fundo.ZIndex = 100
	fundo.Parent = ScreenGui

	local painel = Instance.new("Frame")
	painel.Size = UDim2.new(0, 350, 0, 220)
	painel.Position = UDim2.new(0.5, -175, 0.5, -110)
	painel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	painel.ZIndex = 101
	painel.Parent = fundo
	Instance.new("UICorner", painel).CornerRadius = UDim.new(0, 8)

	local layout = Instance.new("UIListLayout", painel)
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local function AddInfo(txt)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -20, 0, 20)
		l.Text = txt
		l.TextColor3 = Color3.fromRGB(200, 200, 200)
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.Gotham
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextSize = 13
		l.ZIndex = 102
		l.Parent = painel
	end

	local titulo = Instance.new("TextLabel")
	titulo.Text = "🔎 Informações do Botão"
	titulo.Size = UDim2.new(1, -20, 0, 30)
	titulo.TextColor3 = Color3.new(1, 1, 1)
	titulo.BackgroundTransparency = 1
	titulo.Font = Enum.Font.GothamBold
	titulo.TextSize = 16
	titulo.ZIndex = 102
	titulo.Parent = painel

	if botao:IsA("TextButton") then
		AddInfo("📝 Texto: " .. botao.Text)
	elseif botao:IsA("ImageButton") then
		AddInfo("🖼️ Imagem: " .. botao.Image)
	end

	AddInfo("🏷️ Nome: " .. botao.Name)
	AddInfo("📂 Caminho: " .. botao:GetFullName())

	local prosseguir = Instance.new("TextButton")
	prosseguir.Size = UDim2.new(1, -20, 0, 30)
	prosseguir.Text = "✅ Editar Botão"
	prosseguir.Font = Enum.Font.GothamBold
	prosseguir.TextSize = 14
	prosseguir.TextColor3 = Color3.new(1,1,1)
	prosseguir.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
	prosseguir.ZIndex = 102
	prosseguir.Parent = painel
	Instance.new("UICorner", prosseguir).CornerRadius = UDim.new(0, 6)

	prosseguir.MouseButton1Click:Connect(function()
		fundo:Destroy()
		AbrirEditor(botao)
	end)

	local cancelar = Instance.new("TextButton")
	cancelar.Size = UDim2.new(1, -20, 0, 30)
	cancelar.Text = "❌ Cancelar"
	cancelar.Font = Enum.Font.Gotham
	cancelar.TextSize = 14
	cancelar.TextColor3 = Color3.new(1,1,1)
	cancelar.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
	cancelar.ZIndex = 102
	cancelar.Parent = painel
	Instance.new("UICorner", cancelar).CornerRadius = UDim.new(0, 6)

	cancelar.MouseButton1Click:Connect(function()
		fundo:Destroy()
	end)
end

-- Painel de edição
function AbrirEditor(botao)
	local fundo = Instance.new("Frame")
	fundo.Size = UDim2.new(1, 0, 1, 0)
	fundo.BackgroundColor3 = Color3.new(0, 0, 0)
	fundo.BackgroundTransparency = 0.4
	fundo.ZIndex = 100
	fundo.Parent = ScreenGui

	local painel = Instance.new("Frame")
	painel.Size = UDim2.new(0, 260, 0, 300)
	painel.Position = UDim2.new(0.5, -130, 0.5, -150)
	painel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	painel.ZIndex = 101
	painel.Parent = fundo
	Instance.new("UICorner", painel).CornerRadius = UDim.new(0, 8)

	local scroll = Instance.new("ScrollingFrame", painel)
	scroll.Size = UDim2.new(1, -10, 1, -10)
	scroll.Position = UDim2.new(0, 5, 0, 5)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.ZIndex = 102

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	local function CriarBotao(nome, callback)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -10, 0, 30)
		b.Text = nome
		b.Font = Enum.Font.Gotham
		b.TextSize = 13
		b.TextColor3 = Color3.new(1,1,1)
		b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		b.ZIndex = 102
		b.Parent = scroll
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(callback)
	end

	CriarBotao("📏 Aumentar Tamanho", function()
		botao.Size = botao.Size + UDim2.new(0, 20, 0, 20)
	end)

     CriarBotao("📏 Diminuir Tamanho", function()
		botao.Size = botao.Size + UDim2.new(0, -20, 0, -20)
	end)

	CriarBotao("➡️ Mover para Direita", function()
		botao.Position = botao.Position + UDim2.new(0, 20, 0, 0)
	end)

    CriarBotao("⬅️ Mover para Esquerda", function()
		botao.Position = botao.Position + UDim2.new(0, -20, 0, 0)
	end)

     CriarBotao("⬆️ Mover para Cima", function()
		botao.Position = botao.Position + UDim2.new(0, 0, 0, -20)
	end)

     CriarBotao("⬇️ Mover para Baixo", function()
		botao.Position = botao.Position + UDim2.new(0, 0, 0, 20)
	end)

	CriarBotao("🎨 Cor Aleatória", function()
		botao.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
	end)

	CriarBotao("💬 Editar Texto/Imagem", function()
		if botao:IsA("TextButton") then
			botao.Text = "Novo Texto"
		elseif botao:IsA("ImageButton") then
			botao.Image = "rbxassetid://12345678"
		end
	end)

	CriarBotao("🌫️ + Transparência", function()
		botao.BackgroundTransparency = math.clamp(botao.BackgroundTransparency + 0.1, 0, 1)
	end)

    CriarBotao("🌫️ - Transparência", function()
		botao.BackgroundTransparency = math.clamp(botao.BackgroundTransparency - 0.1, 0, 1)
	end)

	CriarBotao("❌ Excluir Botão", function()
		botao:Destroy()
		fundo:Destroy()
	end)

	CriarBotao("✅ Sair", function()
		fundo:Destroy()
	end)
end