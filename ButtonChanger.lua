-- Limpa se já existir
local player = game.Players.LocalPlayer
local existingGui = player.PlayerGui:FindFirstChild("BotaoDetector")
if existingGui then
	existingGui:Destroy()
end

-- Criar GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BotaoDetector"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0.6, 0)
MainFrame.Position = UDim2.new(1, -310, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Barra título
local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Text = "🔍 Lista de Botões"
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 16
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

-- Botões de controle (baixo do título)
local TopButtons = Instance.new("Frame")
TopButtons.Name = "TopButtons"
TopButtons.Size = UDim2.new(1, -10, 0, 30)
TopButtons.Position = UDim2.new(0, 5, 0, 35)
TopButtons.BackgroundTransparency = 1
TopButtons.Parent = MainFrame

local UIListTop = Instance.new("UIListLayout", TopButtons)
UIListTop.FillDirection = Enum.FillDirection.Horizontal
UIListTop.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListTop.SortOrder = Enum.SortOrder.LayoutOrder
UIListTop.Padding = UDim.new(0, 5)

-- Função para criar botões de controle
local function CriarBotao(nome, texto)
	local botao = Instance.new("TextButton")
	botao.Name = nome
	botao.Size = UDim2.new(0, 90, 1, 0)
	botao.Text = texto
	botao.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	botao.TextColor3 = Color3.fromRGB(255, 255, 255)
	botao.Font = Enum.Font.Gotham
	botao.TextSize = 13
	botao.Parent = TopButtons
	Instance.new("UICorner", botao).CornerRadius = UDim.new(0, 6)
	return botao
end

local botaoLimpar = CriarBotao("BotaoLimpar", "🧹 Limpar")
local botaoVerificacao = CriarBotao("BotaoVerificacao", "⛔ Parado")
local botaoFechar = CriarBotao("BotaoFechar", "❌ Fechar")

-- Scrolling Frame para listar os botões detectados
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Name = "ListaBotoes"
Scrolling.Size = UDim2.new(1, -10, 1, -70)
Scrolling.Position = UDim2.new(0, 5, 0, 65)
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
Scrolling.ScrollBarThickness = 6
Scrolling.BackgroundTransparency = 1
Scrolling.BorderSizePixel = 0
Scrolling.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", Scrolling)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Variável controle verificação
local verificando = false
local modoEdicaoAtivo = false
local painelEdicao

-- Função para limpar lista
local function LimparLista()
	for _, item in pairs(Scrolling:GetChildren()) do
		if item:IsA("GuiObject") and item ~= UIListLayout then
			item:Destroy()
		end
	end
	Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- Evento Limpar
botaoLimpar.MouseButton1Click:Connect(function()
	LimparLista()
end)

-- Evento Fechar
botaoFechar.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Função para entrar em modo de edição
local function SairModoEdicao()
	if painelEdicao and painelEdicao.Parent then
		painelEdicao.Parent:Destroy()
	end
	modoEdicaoAtivo = false
end

function MostrarInfoDoBotao(botaoOriginal)
	if modoEdicaoAtivo then return end
	modoEdicaoAtivo = true

	-- Fundo de bloqueio
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

	local titulo = Instance.new("TextLabel")
	titulo.Text = "🔎 Informações do Botão"
	titulo.Size = UDim2.new(1, -20, 0, 30)
	titulo.TextColor3 = Color3.new(1, 1, 1)
	titulo.BackgroundTransparency = 1
	titulo.Font = Enum.Font.GothamBold
	titulo.TextSize = 16
	titulo.ZIndex = 102
	titulo.Parent = painel

	local function AddInfo(texto)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 0, 20)
		label.Text = texto
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextSize = 13
		label.ZIndex = 102
		label.Parent = painel
	end

	-- Mostrar conteúdo
	if botaoOriginal:IsA("TextButton") then
		AddInfo("📝 Texto: " .. botaoOriginal.Text)
	elseif botaoOriginal:IsA("ImageButton") then
		AddInfo("🖼️ Imagem: " .. botaoOriginal.Image)
	end

	AddInfo("🏷️ Nome: " .. botaoOriginal.Name)
	AddInfo("📂 Caminho: " .. botaoOriginal:GetFullName())

	-- Botão prosseguir
	local prosseguir = Instance.new("TextButton")
	prosseguir.Size = UDim2.new(1, -20, 0, 30)
	prosseguir.Text = "✅ Editar Botão"
	prosseguir.Font = Enum.Font.GothamBold
	prosseguir.TextSize = 14
	prosseguir.TextColor3 = Color3.new(1,1,1)
	prosseguir.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
	prosseguir.ZIndex = 102
	Instance.new("UICorner", prosseguir).CornerRadius = UDim.new(0, 6)
	prosseguir.Parent = painel

	prosseguir.MouseButton1Click:Connect(function()
		fundo:Destroy()
		modoEdicaoAtivo = false
		EntrarModoEdicao(botaoOriginal)
	end)

	-- Botão cancelar
	local cancelar = Instance.new("TextButton")
	cancelar.Size = UDim2.new(1, -20, 0, 30)
	cancelar.Text = "❌ Cancelar"
	cancelar.Font = Enum.Font.Gotham
	cancelar.TextSize = 14
	cancelar.TextColor3 = Color3.new(1,1,1)
	cancelar.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
	cancelar.ZIndex = 102
	Instance.new("UICorner", cancelar).CornerRadius = UDim.new(0, 6)
	cancelar.Parent = painel

	cancelar.MouseButton1Click:Connect(function()
		fundo:Destroy()
		modoEdicaoAtivo = false
	end)
end

function EntrarModoEdicao(botaoOriginal)
	if modoEdicaoAtivo then return end
	modoEdicaoAtivo = true

	-- Fundo escuro para bloquear interação
	local fundo = Instance.new("Frame")
	fundo.Size = UDim2.new(1, 0, 1, 0)
	fundo.BackgroundColor3 = Color3.new(0, 0, 0)
	fundo.BackgroundTransparency = 0.4
	fundo.ZIndex = 100
	fundo.Parent = ScreenGui

	-- Painel de edição
	painelEdicao = Instance.new("Frame")
	painelEdicao.Size = UDim2.new(0, 220, 0, 270)
	painelEdicao.Position = UDim2.new(0.5, -110, 0.5, -135)
	painelEdicao.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	painelEdicao.ZIndex = 101
	painelEdicao.Parent = fundo

	Instance.new("UICorner", painelEdicao).CornerRadius = UDim.new(0, 8)

	local titulo = Instance.new("TextLabel", painelEdicao)
	titulo.Size = UDim2.new(1, 0, 0, 30)
	titulo.BackgroundTransparency = 1
	titulo.Text = "✏️ Editando Botão"
	titulo.Font = Enum.Font.GothamBold
	titulo.TextSize = 15
	titulo.TextColor3 = Color3.new(1,1,1)
	titulo.ZIndex = 102

	-- Scrolling container dos botões de edição
local AreaScroll = Instance.new("ScrollingFrame")
AreaScroll.Size = UDim2.new(1, -20, 1, -40)
AreaScroll.Position = UDim2.new(0, 10, 0, 35)
AreaScroll.BackgroundTransparency = 1
AreaScroll.BorderSizePixel = 0
AreaScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AreaScroll.ScrollBarThickness = 6
AreaScroll.ZIndex = 101
AreaScroll.Parent = painelEdicao

local UIList = Instance.new("UIListLayout", AreaScroll)
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Atualiza tamanho da rolagem automaticamente
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	AreaScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

	-- Criar botão da interface de edição
	local function CriarOpcao(nome, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.Text = nome
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		btn.ZIndex = 102
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.Parent = AreaScroll
		btn.MouseButton1Click:Connect(callback)
	end

	-- Opções de edição
	CriarOpcao("📏 Aumentar tamanho", function()
		botaoOriginal.Size = botaoOriginal.Size + UDim2.new(0, 20, 0, 20)
	end)

	CriarOpcao("📉 Diminuir tamanho", function()
		local ns = botaoOriginal.Size - UDim2.new(0, 20, 0, 20)
		botaoOriginal.Size = UDim2.new(math.max(ns.X.Scale, 0), math.max(ns.X.Offset, 10), math.max(ns.Y.Scale, 0), math.max(ns.Y.Offset, 10))
	end)

	CriarOpcao("↔️ Mover para direita", function()
		botaoOriginal.Position = botaoOriginal.Position + UDim2.new(0, 20, 0, 0)
	end)

	CriarOpcao("↔️ Mover para esquerda", function()
		botaoOriginal.Position = botaoOriginal.Position - UDim2.new(0, 20, 0, 0)
	end)

	CriarOpcao("⬆️ Mover para cima", function()
		botaoOriginal.Position = botaoOriginal.Position - UDim2.new(0, 0, 0, 20)
	end)

	CriarOpcao("⬇️ Mover para baixo", function()
		botaoOriginal.Position = botaoOriginal.Position + UDim2.new(0, 0, 0, 20)
	end)

	CriarOpcao("🎨 Mudar Cor (aleatória)", function()
		botaoOriginal.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
	end)

	CriarOpcao("💬 Editar Texto/Imagem", function()
		if botaoOriginal:IsA("TextButton") then
			-- Pedir texto no console, por simplicidade
			print("Mude o texto do botão original no código ou adicione input box para modificar dinamicamente.")
			botaoOriginal.Text = "Novo Texto"
		elseif botaoOriginal:IsA("ImageButton") then
			botaoOriginal.Image = "rbxassetid://12345678" -- Coloque ID válido
		end
	end)

	CriarOpcao("🌫️ Aumentar Transparência", function()
		botaoOriginal.BackgroundTransparency = math.clamp(botaoOriginal.BackgroundTransparency + 0.2, 0, 1)
	end)

	CriarOpcao("🌫️ Diminuir Transparência", function()
		botaoOriginal.BackgroundTransparency = math.clamp(botaoOriginal.BackgroundTransparency - 0.2, 0, 1)
	end)

	CriarOpcao("❌ Excluir Botão", function()
		botaoOriginal:Destroy()
		SairModoEdicao()
	end)

	CriarOpcao("✅ Sair da Edição", function()
		SairModoEdicao()
	end)
end

-- Função para adicionar botão na lista (texto ou imagem)
local function AdicionarClone(botaoOriginal)
	if not botaoOriginal:IsDescendantOf(ScreenGui) then
		local clone

		if botaoOriginal:IsA("TextButton") then
			clone = Instance.new("TextButton")
			clone.Text = botaoOriginal.Text
			clone.Font = Enum.Font.Gotham
			clone.TextSize = 14
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
		elseif botaoOriginal:IsA("ImageButton") then
			clone = Instance.new("ImageButton")
			clone.Image = botaoOriginal.Image
		end

		if clone then
			clone.Size = UDim2.new(1, 0, 0, 40)
			clone.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			clone.BorderSizePixel = 0
			clone.LayoutOrder = math.random(1, 100000)

			Instance.new("UICorner", clone).CornerRadius = UDim.new(0, 6)

			clone.MouseButton1Click:Connect(function()
	MostrarInfoDoBotao(botaoOriginal)
end)

			clone.Parent = Scrolling

			task.wait()
			Scrolling.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
		end
	end
end

-- Função para escanear e listar botões visíveis no PlayerGui
local function EscanearBotoes()
	for _, gui in pairs(player.PlayerGui:GetChildren()) do
		if gui ~= ScreenGui then
			for _, obj in pairs(gui:GetDescendants()) do
				if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible and obj.AbsoluteSize.Magnitude > 0 then
					AdicionarClone(obj)
				end
			end
		end
	end
end

-- Evento botão verificar: liga/desliga e escaneia só na ativação
botaoVerificacao.MouseButton1Click:Connect(function()
	if verificando then
		verificando = false
		botaoVerificacao.Text = "⛔ Parado"
		LimparLista()
	else
		verificando = true
		botaoVerificacao.Text = "🔁 Verificar"
		LimparLista()
		EscanearBotoes()
	end
end)

-- GUI móvel: arrastar pela barra de título
local dragging, dragInput, dragStart, startPos
local UserInputService = game:GetService("UserInputService")

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

TitleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)