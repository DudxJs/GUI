-- Script completo com bolinha vermelha de seleção analógica (touchpad), clique por botão e ajustes finais
-- Inclui nomeação de HUDs (Universal/Por Experiência) e atribuição de teclas de atalho.
-- Este script deve estar em um LocalScript, por exemplo em StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService") -- Necessário para JSONEncode/Decode
local RS = game:GetService("RunService") -- Adicionei aqui para organização

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Nome do arquivo para salvar/carregar dados
-- ATENÇÃO: readfile/writefile NÃO FUNCIONAM em jogos publicados no Roblox.
-- Para persistência real, você DEVE usar DataStoreService (via ServerScript).
local fileName = "hud_editor_saves.json"

---
--- 1. Tela de Introdução
---
local introGui = Instance.new("ScreenGui", PlayerGui)
introGui.Name = "HUD_Intro"
introGui.ResetOnSpawn = false

local fundoIntro = Instance.new("Frame", introGui)
fundoIntro.Size = UDim2.new(1, 0, 1, 0)
fundoIntro.BackgroundColor3 = Color3.new(0, 0, 0)
fundoIntro.BackgroundTransparency = 0.4

local aviso = Instance.new("TextLabel", fundoIntro)
aviso.Size = UDim2.new(0.5, 0, 0.15, 0)
aviso.Position = UDim2.new(0.25, 0, 0.4, 0)
aviso.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
aviso.TextColor3 = Color3.new(1, 1, 1)
aviso.TextSize = 20
aviso.Font = Enum.Font.GothamBold
aviso.Text = "Pressione F6 ou Ctrl Esquerdo para abrir o HUD Manager"
Instance.new("UICorner", aviso).CornerRadius = UDim.new(0, 10)

task.wait(6)
fundoIntro:Destroy()

---
--- 2. GUI Principal do Editor
---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EditorDeBotoes"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.Enabled = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 190)
MainFrame.Position = UDim2.new(0, 20, 0, 80)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local function criarBotao(texto, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Text = texto
	btn.Parent = MainFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local selecionarBtn = criarBotao("✏️ Selecionar Botão", 10)
local salvarBtn = criarBotao("💾 Salvar HUD", 60)
local carregarBtn = criarBotao("📂 HUDs Salvos", 110)

local modoSelecionando = false

---
--- 3. Cursor Analógico e Controles
---
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

-- Variáveis para armazenar as conexões de eventos do touchpad e do clickBtn
local touchpadInputBeganConn
local touchpadInputChangedConn
local touchpadInputEndedConn
local moveConnection -- Já existente
local clickBtnConnection

local moving = false
local lastInput = nil

local function updateCursorPosition(dir)
	if not cursor.Visible then return end
	local pos = cursor.Position
	local dx, dy = dir.X * 5, dir.Y * 5 -- sensibilidade aumentada
	local newX = math.clamp(pos.X.Offset + dx, 0, ScreenGui.AbsoluteSize.X - cursor.AbsoluteSize.X)
	local newY = math.clamp(pos.Y.Offset + dy, 0, ScreenGui.AbsoluteSize.Y - cursor.AbsoluteSize.Y)
	cursor.Position = UDim2.new(0, newX, 0, newY)
end

local function enableTouchpad()
	cursor.Visible = true
	touchpad.Visible = true
	clickBtn.Visible = true
	local direction = Vector2.zero

    -- Desconecta as conexões existentes antes de criar novas
    if touchpadInputBeganConn then touchpadInputBeganConn:Disconnect() end
    if touchpadInputChangedConn then touchpadInputChangedConn:Disconnect() end
    if touchpadInputEndedConn then touchpadInputEndedConn:Disconnect() end
    if moveConnection then moveConnection:Disconnect() end
    if clickBtnConnection then clickBtnConnection:Disconnect() end -- Desconecta a conexão do clickBtn também

    touchpadInputBeganConn = touchpad.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			moving = true
			lastInput = input.Position
		end
	end)

    touchpadInputChangedConn = touchpad.InputChanged:Connect(function(input)
		if moving and input.UserInputType == Enum.UserInputType.Touch then
			direction = (input.Position - lastInput)/6 -- sensibilidade aumentada
			lastInput = input.Position
		end
	end)

    touchpadInputEndedConn = touchpad.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			moving = false
			direction = Vector2.zero
		end
	end)

	moveConnection = RS.RenderStepped:Connect(function()
		if moving then
			updateCursorPosition(direction)
		end
	end)

    -- Conecta o evento MouseButton1Click do clickBtn aqui, para ser gerenciado com o touchpad
    clickBtnConnection = clickBtn.MouseButton1Click:Connect(function()
        local pos = Vector2.new(cursor.AbsolutePosition.X + cursor.AbsoluteSize.X/2, cursor.AbsolutePosition.Y + cursor.AbsoluteSize.Y/2)
        local under = player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(pos.X, pos.Y)
        for _, gui in ipairs(under) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and not gui:IsDescendantOf(ScreenGui) then
                modoSelecionando = false
                cursor.Visible = false
                touchpad.Visible = false
                clickBtn.Visible = false
                selecionarBtn.Text = "✏️ Selecionar Botão" -- Resetar o texto do botão "Selecionar Botão"
                MostrarInfoDoBotao(gui)
                return
            end
        end
    end)
end

-- Inicialmente a GUI fica oculta
ScreenGui.Enabled = false

-- Função para alternar visibilidade ao pressionar Ctrl ou F6
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F6 or input.KeyCode == Enum.KeyCode.LeftControl then
		ScreenGui.Enabled = not ScreenGui.Enabled
        -- Garante que o cursor e touchpad sejam desativados se a GUI principal for fechada
        if not ScreenGui.Enabled then
            modoSelecionando = false
            cursor.Visible = false
            touchpad.Visible = false
            clickBtn.Visible = false
            selecionarBtn.Text = "✏️ Selecionar Botão"
            -- Desconecta todas as conexões do touchpad quando a GUI é fechada
            if touchpadInputBeganConn then touchpadInputBeganConn:Disconnect() end
            if touchpadInputChangedConn then touchpadInputChangedConn:Disconnect() end
            if touchpadInputEndedConn then touchpadInputEndedConn:Disconnect() end
            if moveConnection then moveConnection:Disconnect() end
            if clickBtnConnection then clickBtnConnection:Disconnect() end
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
        -- Desconecta todas as conexões do touchpad quando o modo de seleção é desativado manualmente
        if touchpadInputBeganConn then touchpadInputBeganConn:Disconnect() end
        if touchpadInputChangedConn then touchpadInputChangedConn:Disconnect() end
        if touchpadInputEndedConn then touchpadInputEndedConn:Disconnect() end
        if moveConnection then moveConnection:Disconnect() end
        if clickBtnConnection then clickBtnConnection:Disconnect() end
		return
	end

	modoSelecionando = true
	selecionarBtn.Text = "📈 Tocando para selecionar..."
	enableTouchpad()
end)

---
--- 4. Funções de Informação e Edição de Botões
---

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
    
    local hotkey = botao:GetAttribute("HUD_Hotkey") -- Mantido para exibir, mas sem a funcionalidade de atribuição
    if hotkey then
        AddInfo("⌨️ Atalho: " .. hotkey)
    else
        AddInfo("⌨️ Atalho: Nenhum")
    end


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
	
	local function marcarComoModificado(botao)
        -- Setar atributo para indicar que o botão foi modificado
        -- Isso é usado na lógica de salvamento para pegar apenas os botões alterados
	    botao:SetAttribute("HUD_Modificado", true)
	end

	local painel = Instance.new("Frame")
	painel.Size = UDim2.new(0, 260, 0, 350) -- Aumenta o tamanho para o novo botão
	painel.Position = UDim2.new(0.5, -130, 0.5, -175) -- Ajusta a posição
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
		marcarComoModificado(botao)
	end)

    CriarBotao("📏 Diminuir Tamanho", function()
		botao.Size = botao.Size + UDim2.new(0, -20, 0, -20)
		marcarComoModificado(botao)
	end)

	CriarBotao("➡️ Mover para Direita", function()
		botao.Position = botao.Position + UDim2.new(0, 20, 0, 0)
		marcarComoModificado(botao)
	end)

    CriarBotao("⬅️ Mover para Esquerda", function()
		botao.Position = botao.Position + UDim2.new(0, -20, 0, 0)
		marcarComoModificado(botao)
	end)

    CriarBotao("⬆️ Mover para Cima", function()
		botao.Position = botao.Position + UDim2.new(0, 0, 0, -20)
		marcarComoModificado(botao)
	end)

    CriarBotao("⬇️ Mover para Baixo", function()
		botao.Position = botao.Position + UDim2.new(0, 0, 0, 20)
		marcarComoModificado(botao)
	end)

	CriarBotao("🎨 Cor Aleatória", function()
		botao.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
		marcarComoModificado(botao)
	end)

	CriarBotao("💬 Editar Texto/Imagem", function()
        local currentTextOrImage = ""
        if botao:IsA("TextButton") then
            currentTextOrImage = botao.Text
        elseif botao:IsA("ImageButton") then
            currentTextOrImage = botao.Image
        end

        local inputPrompt = Instance.new("Frame")
        inputPrompt.Size = UDim2.new(0, 250, 0, 120)
        inputPrompt.Position = UDim2.new(0.5, -125, 0.5, -60)
        inputPrompt.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        inputPrompt.Parent = fundo -- Painel pop-up sobre o fundo escuro
        Instance.new("UICorner", inputPrompt).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.Text = "Novo Texto ou ID de Imagem:"
        label.TextColor3 = Color3.new(1,1,1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = inputPrompt

        local textBoxInput = Instance.new("TextBox")
        textBoxInput.Size = UDim2.new(1, -20, 0, 30)
        textBoxInput.Position = UDim2.new(0, 10, 0, 40)
        textBoxInput.Text = currentTextOrImage
        textBoxInput.PlaceholderText = "Digite texto ou rbxassetid://..."
        textBoxInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        textBoxInput.TextColor3 = Color3.new(1,1,1)
        textBoxInput.TextSize = 14
        textBoxInput.Font = Enum.Font.Gotham
        textBoxInput.Parent = inputPrompt
        Instance.new("UICorner", textBoxInput).CornerRadius = UDim.new(0, 6)
        textBoxInput:CaptureFocus()

        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(0.45, 0, 0, 30)
        applyBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
        applyBtn.Text = "Aplicar"
        applyBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
        applyBtn.TextColor3 = Color3.new(1,1,1)
        applyBtn.Font = Enum.Font.GothamBold
        applyBtn.TextSize = 14
        applyBtn.Parent = inputPrompt
        Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

        local cancelInputBtn = Instance.new("TextButton")
        cancelInputBtn.Size = UDim2.new(0.45, 0, 0, 30)
        cancelInputBtn.Position = UDim2.new(0.5, 10, 0.7, 0)
        cancelInputBtn.Text = "Cancelar"
        cancelInputBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
        cancelInputBtn.TextColor3 = Color3.new(1,1,1)
        cancelInputBtn.Font = Enum.Font.GothamBold
        cancelInputBtn.TextSize = 14
        cancelInputBtn.Parent = inputPrompt
        Instance.new("UICorner", cancelInputBtn).CornerRadius = UDim.new(0, 6)

        applyBtn.MouseButton1Click:Connect(function()
            if botao:IsA("TextButton") then
                botao.Text = textBoxInput.Text
            elseif botao:IsA("ImageButton") then
                botao.Image = textBoxInput.Text
            end
            marcarComoModificado(botao)
            inputPrompt:Destroy()
        end)

        cancelInputBtn.MouseButton1Click:Connect(function()
            inputPrompt:Destroy()
        end)
	end)

	CriarBotao("🌫️ + Transparência", function()
		botao.BackgroundTransparency = math.clamp(botao.BackgroundTransparency + 0.1, 0, 1)
		marcarComoModificado(botao)
	end)

    CriarBotao("🌫️ - Transparência", function()
		botao.BackgroundTransparency = math.clamp(botao.BackgroundTransparency - 0.1, 0, 1)
		marcarComoModificado(botao)
	end)

	CriarBotao("❌ Excluir Botão", function()
		botao:Destroy()
		fundo:Destroy()
		marcarComoModificado(botao)
	end)

	CriarBotao("✅ Sair", function()
		fundo:Destroy()
	end)
end

---
--- 5. Salvamento e Carregamento de HUDs
---

-- Função para pegar dados do botão
local function getButtonData(botao)
	local data = {
		Size = {botao.Size.X.Scale, botao.Size.X.Offset, botao.Size.Y.Scale, botao.Size.Y.Offset},
		Position = {botao.Position.X.Scale, botao.Position.X.Offset, botao.Position.Y.Scale, botao.Position.Y.Offset},
		Color = {math.floor(botao.BackgroundColor3.R * 255), math.floor(botao.BackgroundColor3.G * 255), math.floor(botao.BackgroundColor3.B * 255)},
		Transparency = botao.BackgroundTransparency,
		Text = botao:IsA("TextButton") and botao.Text or nil,
		Image = botao:IsA("ImageButton") and botao.Image or nil
	}
    -- Removido: Hotkey saving
	return data
end

-- Função para pegar caminho completo do objeto
local function getFullPath(obj)
	local path = obj.Name
	local parent = obj.Parent
	while parent and parent ~= game do
		path = parent.Name .. "." .. path
		parent = parent.Parent
	end
	return path
end

-- Função para buscar nome da experiência via HttpService (substituindo http_request)
local function getExperienceName(expId)
	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = "https://games.roblox.com/v1/games?universeIds=" .. tostring(expId),
			Method = "GET"
		})
	end)
	if success and response.Success and response.StatusCode == 200 then
		local data = HttpService:JSONDecode(response.Body)
		return data.data and data.data[1] and data.data[1].name or "Experiência Desconhecida"
	else
		warn("Erro ao buscar nome da experiência: ", response and response.StatusCode, response and response.Body)
		return "Erro ao buscar nome"
	end
end

salvarBtn.MouseButton1Click:Connect(function()
    -- Desabilita o botão para evitar cliques múltiplos enquanto a pop-up está aberta
    salvarBtn.Active = false

    local inputPanel = Instance.new("Frame")
    inputPanel.Size = UDim2.new(0, 300, 0, 200) -- Aumenta o tamanho para acomodar o novo botão
    inputPanel.Position = UDim2.new(0.5, -150, 0.5, -100)
    inputPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    inputPanel.BorderSizePixel = 0
    inputPanel.Parent = ScreenGui
    Instance.new("UICorner", inputPanel).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "Nomear e Salvar HUD"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = inputPanel

    local nameTextBox = Instance.new("TextBox")
    nameTextBox.Size = UDim2.new(1, -40, 0, 40)
    nameTextBox.Position = UDim2.new(0.5, -((nameTextBox.Size.X.Offset)/2), 0.5, -50) -- Ajusta posição
    nameTextBox.PlaceholderText = "Digite o nome do HUD aqui..."
    nameTextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    nameTextBox.TextColor3 = Color3.new(1, 1, 1)
    nameTextBox.TextSize = 16
    nameTextBox.Font = Enum.Font.Gotham
    nameTextBox.Parent = inputPanel
    Instance.new("UICorner", nameTextBox).CornerRadius = UDim.new(0, 6)
    nameTextBox.TextXAlignment = Enum.TextXAlignment.Center
    nameTextBox:CaptureFocus()

    -- Novo botão de toggle para HUD Universal/Experiência
    local isUniversal = false -- Estado inicial: por experiência
    local universalToggleBtn = Instance.new("TextButton")
    universalToggleBtn.Size = UDim2.new(1, -40, 0, 30)
    universalToggleBtn.Position = UDim2.new(0.5, -((universalToggleBtn.Size.X.Offset)/2), 0.5, 0) -- Posição abaixo do TextBox
    universalToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    universalToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    universalToggleBtn.Font = Enum.Font.Gotham
    universalToggleBtn.TextSize = 14
    universalToggleBtn.Parent = inputPanel
    Instance.new("UICorner", universalToggleBtn).CornerRadius = UDim.new(0, 6)
    
    local function updateToggleText()
        if isUniversal then
            universalToggleBtn.Text = "🌎 HUD Universal (Todos os Jogos)"
            universalToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 170) -- Azul para universal
        else
            universalToggleBtn.Text = "🎮 HUD Por Experiência (Somente Este Jogo)"
            universalToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Cinza para por experiência
        end
    end
    updateToggleText() -- Define o texto inicial

    universalToggleBtn.MouseButton1Click:Connect(function()
        isUniversal = not isUniversal
        updateToggleText()
    end)

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.45, 0, 0, 30)
    confirmBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
    confirmBtn.Text = "Salvar"
    confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
    confirmBtn.TextColor3 = Color3.new(1, 1, 1)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 14
    confirmBtn.Parent = inputPanel
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.45, 0, 0, 30)
    cancelBtn.Position = UDim2.new(0.5, 10, 0.75, 0)
    cancelBtn.Text = "Cancelar"
    cancelBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 14
    cancelBtn.Parent = inputPanel
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

    confirmBtn.MouseButton1Click:Connect(function()
        local hudName = nameTextBox.Text
        if string.len(hudName) == 0 then
            warn("Nome do HUD não pode ser vazio!")
            -- Pode adicionar um aviso na tela aqui para o usuário
            return
        end

        local data = {}
        if isfile(fileName) then
            data = HttpService:JSONDecode(readfile(fileName))
        end

        -- A estrutura agora terá 'universalHuds' e 'experiences'
        data.universalHuds = data.universalHuds or {}
        data.experiences = data.experiences or {}

        local currentHUDData = {}
        for _, botao in ipairs(player.PlayerGui:GetDescendants()) do
            if (botao:IsA("TextButton") or botao:IsA("ImageButton")) and botao:GetAttribute("HUD_Modificado") then
                local caminho = getFullPath(botao)
                currentHUDData[caminho] = getButtonData(botao)
            end
        end

        if isUniversal then
            data.universalHuds[hudName] = currentHUDData -- Salva como HUD universal
        else
            local placeId = tostring(game.PlaceId)
            data.experiences[placeId] = data.experiences[placeId] or {huds = {}}
            data.experiences[placeId].huds[hudName] = currentHUDData -- Salva por experiência
        end

        writefile(fileName, HttpService:JSONEncode(data))
        salvarBtn.Text = "✅ Salvo!"
        task.wait(1.5)
        salvarBtn.Text = "💾 Salvar HUD"
        inputPanel:Destroy()
        salvarBtn.Active = true
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        inputPanel:Destroy()
        salvarBtn.Active = true
    end)
end)

carregarBtn.MouseButton1Click:Connect(function()
    if not isfile(fileName) then return end
    local data = HttpService:JSONDecode(readfile(fileName))

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HUDLoaderUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui

    local fundo = Instance.new("Frame", screenGui)
    fundo.Size = UDim2.new(1, 0, 1, 0)
    fundo.BackgroundColor3 = Color3.new(0, 0, 0)
    fundo.BackgroundTransparency = 0.4
    fundo.ZIndex = 100

    local painel = Instance.new("Frame", fundo)
    painel.Size = UDim2.new(0, 400, 0, 300)
    painel.Position = UDim2.new(0.5, -200, 0.5, -150)
    painel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    painel.ZIndex = 101
    Instance.new("UICorner", painel).CornerRadius = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame", painel)
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ZIndex = 102
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local placeId = tostring(game.PlaceId)
    local universalHuds = data.universalHuds or {}
    local experienceData = data.experiences and data.experiences[placeId]
    local currentExperienceHuds = experienceData and experienceData.huds or {}

    local anyHudFound = false

    -- Adiciona HUDs Universais
    for hudName, hudData in pairs(universalHuds) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(40, 90, 170) -- Azul para HUDs universais
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 13
        btn.Font = Enum.Font.Gotham
        btn.ZIndex = 103
        btn.Text = "🌍 Universal HUD: " .. hudName
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for caminho, props in pairs(hudData or {}) do
                local success, obj = pcall(function()
                    local parts = caminho:split(".")
                    local o = game
                    for _, p in ipairs(parts) do
                        o = o:FindFirstChild(p)
                        if not o then break end
                    end
                    return o
                end)

                if success and obj and (obj:IsA("TextButton") or obj:IsA("ImageButton")) then
                    local d = props
                    obj.Size = UDim2.new(d.Size[1], d.Size[2], d.Size[3], d.Size[4])
                    obj.Position = UDim2.new(d.Position[1], d.Position[2], d.Position[3], d.Position[4])
                    obj.BackgroundColor3 = Color3.fromRGB(d.Color[1], d.Color[2], d.Color[3])
                    obj.BackgroundTransparency = d.Transparency
                    if d.Text then obj.Text = d.Text end
                    if d.Image then obj.Image = d.Image end
                    -- Removido: Hotkey loading
                end
            end
            screenGui:Destroy()
        end)
        anyHudFound = true
    end

    -- Adiciona HUDs da Experiência Atual
    for hudName, hudData in pairs(currentExperienceHuds) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Cinza para HUDs por experiência
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 13
        btn.Font = Enum.Font.Gotham
        btn.ZIndex = 103
        btn.Text = "🎮 Experiência HUD: " .. hudName
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for caminho, props in pairs(hudData or {}) do
                local success, obj = pcall(function()
                    local parts = caminho:split(".")
                    local o = game
                    for _, p in ipairs(parts) do
                        o = o:FindFirstChild(p)
                        if not o then break end
                    end
                    return o
                end)

                if success and obj and (obj:IsA("TextButton") or obj:IsA("ImageButton")) then
                    local d = props
                    obj.Size = UDim2.new(d.Size[1], d.Size[2], d.Size[3], d.Size[4])
                    obj.Position = UDim2.new(d.Position[1], d.Position[2], d.Position[3], d.Position[4])
                    obj.BackgroundColor3 = Color3.fromRGB(d.Color[1], d.Color[2], d.Color[3])
                    obj.BackgroundTransparency = d.Transparency
                    if d.Text then obj.Text = d.Text end
                    if d.Image then obj.Image = d.Image end
                    -- Removido: Hotkey loading
                end
            end
            screenGui:Destroy()
        end)
        anyHudFound = true
    end

    if not anyHudFound then
        local noHudText = Instance.new("TextLabel", scroll)
        noHudText.Size = UDim2.new(1, -10, 0, 30)
        noHudText.BackgroundTransparency = 1
        noHudText.TextColor3 = Color3.fromRGB(200, 200, 200)
        noHudText.TextSize = 14
        noHudText.Font = Enum.Font.Gotham
        noHudText.Text = "Nenhum HUD salvo encontrado."
        noHudText.TextWrapped = true
        noHudText.TextXAlignment = Enum.TextXAlignment.Center
    end

    local fechar = Instance.new("TextButton", painel)
    fechar.Size = UDim2.new(1, -10, 0, 30)
    fechar.Position = UDim2.new(0, 5, 1, -35)
    fechar.Text = "❌ Fechar"
    fechar.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
    fechar.TextColor3 = Color3.new(1, 1, 1)
    fechar.Font = Enum.Font.GothamBold
    fechar.TextSize = 14
    fechar.ZIndex = 103
    Instance.new("UICorner", fechar).CornerRadius = UDim.new(0, 6)

    fechar.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end)