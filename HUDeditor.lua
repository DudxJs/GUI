--[[
    HUD Manager Script

    Este script permite que você edite a posição, tamanho, cor, transparência e texto/imagem
    de botões de GUI (TextButton e ImageButton) em tempo real.
    Ele também inclui um sistema de salvamento e carregamento de layouts de HUD.

    ATENÇÃO: Este script está configurado para um ambiente de execução como o Delta executor,
    onde 'readfile()' e 'writefile()' funcionam. Para um jogo Roblox publicado
    (no cliente oficial), você precisaria usar 'DataStoreService' para persistência.

    Instalação: Coloque este script em um LocalScript, por exemplo, em StarterPlayerScripts.
]]

--==================================================================================================
-- 1. SERVIÇOS E VARIÁVEIS GLOBAIS
--==================================================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService") -- Adicionado para animações suaves

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Nome do arquivo para salvar/carregar dados
local fileName = "hud_editor_saves.json"

-- Variáveis de estado do editor
local modoSelecionando = false
local moving = false
local lastInput = nil
local isUniversal = false -- Estado do toggle de HUD Universal/Por Experiência para salvar

-- Conexões de eventos do touchpad/cursor
local touchpadInputBeganConn
local touchpadInputChangedConn
local touchpadInputEndedConn
local moveConnection
local clickBtnConnection

--==================================================================================================
-- 2. DEFINIÇÃO E ESTILIZAÇÃO DA INTERFACE GRÁFICA (GUI)
-- Esta seção foca apenas na criação e no estilo dos elementos visuais, com efeitos e cores RGB.
--==================================================================================================

-- 2.1. Estilos Comuns e Cores RGB
local BLACK = Color3.fromRGB(15, 15, 15)
local DARK_GREY = Color3.fromRGB(30, 30, 30)
local ACCENT_COLOR_R = Color3.fromRGB(255, 0, 0) -- Red
local ACCENT_COLOR_G = Color3.fromRGB(0, 255, 0) -- Green
local ACCENT_COLOR_B = Color3.fromRGB(0, 0, 255) -- Blue
local TEXT_COLOR_LIGHT = Color3.new(1, 1, 1) -- Branco
local TEXT_COLOR_DARK = Color3.fromRGB(200, 200, 200)

local CORNER_RADIUS_MEDIUM = UDim.new(0, 8)
local CORNER_RADIUS_SMALL = UDim.new(0, 6)

-- Estilo base para botões interativos
local function applyButtonStyle(button, baseColor, hoverColor, clickColor)
    button.BackgroundColor3 = baseColor
    button.TextColor3 = TEXT_COLOR_LIGHT
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.TextScaled = false
    button.TextWrapped = true
    Instance.new("UICorner", button).CornerRadius = CORNER_RADIUS_SMALL
    Instance.new("UIStroke", button).Color = Color3.fromRGB(50,50,50)
    Instance.new("UIStroke", button).Thickness = 1
    Instance.new("UIStroke", button).Transparency = 0.5


    local originalColor = baseColor
    local originalTransparency = button.BackgroundTransparency
    local hoverTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local clickTweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, hoverTweenInfo, {BackgroundColor3 = hoverColor, BackgroundTransparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, hoverTweenInfo, {BackgroundColor3 = originalColor, BackgroundTransparency = originalTransparency}):Play()
    end)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, clickTweenInfo, {BackgroundColor3 = clickColor, BackgroundTransparency = 0}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, clickTweenInfo, {BackgroundColor3 = hoverColor, BackgroundTransparency = 0}):Play()
    end)
end

-- 2.2. Tela de Introdução (Aviso Inicial)
local introGui = Instance.new("ScreenGui")
introGui.Name = "HUD_Intro"
introGui.ResetOnSpawn = false
introGui.Parent = PlayerGui

local fundoIntro = Instance.new("Frame")
fundoIntro.Name = "IntroBackground"
fundoIntro.Size = UDim2.new(1, 0, 1, 0)
fundoIntro.BackgroundColor3 = BLACK
fundoIntro.BackgroundTransparency = 0.7 -- Mais transparente ainda
fundoIntro.Parent = introGui

local aviso = Instance.new("TextLabel")
aviso.Name = "IntroMessage"
aviso.Size = UDim2.new(0.6, 0, 0.2, 0) -- Maior e mais central
aviso.Position = UDim2.new(0.2, 0, 0.4, 0)
aviso.BackgroundColor3 = DARK_GREY
aviso.TextColor3 = TEXT_COLOR_LIGHT
aviso.TextSize = 24 -- Texto maior
aviso.Font = Enum.Font.GothamBold
aviso.Text = "Pressione F6 ou Ctrl Esquerdo para abrir o HUD Manager"
aviso.ZIndex = 2
aviso.Parent = fundoIntro
Instance.new("UICorner", aviso).CornerRadius = UDim.new(0, 15) -- Cantos mais arredondados
Instance.new("UIStroke", aviso).Color = ACCENT_COLOR_B -- Borda azul
Instance.new("UIStroke", aviso).Thickness = 2
Instance.new("UIPadding", aviso).PaddingLeft = UDim.new(0,10)
Instance.new("UIPadding", aviso).PaddingRight = UDim.new(0,10)

-- Efeito de gradiente pulsante para o aviso (agora mais sutil)
local avisoGradient = Instance.new("UIGradient", aviso)
avisoGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, ACCENT_COLOR_B), -- Use uma cor RGB clara aqui
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0,0,0))
}
avisoGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0.0, 0.8), -- Inicia quase transparente
    NumberSequenceKeypoint.new(0.5, 0.2), -- Pico menos transparente
    NumberSequenceKeypoint.new(1.0, 0.8)  -- Termina quase transparente
}
avisoGradient.Rotation = 90
-- Animacao do gradiente de fundo
local gradientTweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0)
local gradientTween = TweenService:Create(avisoGradient, gradientTweenInfo, {Offset = Vector2.new(0.5, 0)})
gradientTween:Play()


-- 2.3. GUI Principal do Editor (Painel Lateral)
local EditorScreenGui = Instance.new("ScreenGui")
EditorScreenGui.Name = "HUD_EditorMain"
EditorScreenGui.ResetOnSpawn = false
EditorScreenGui.IgnoreGuiInset = true
EditorScreenGui.DisplayOrder = 999999
EditorScreenGui.Enabled = false
EditorScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "EditorPanel"
MainFrame.Size = UDim2.new(0, 200, 0, 250) -- Ligeiramente maior
MainFrame.Position = UDim2.new(0, 20, 0, 80)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Parent = EditorScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = CORNER_RADIUS_MEDIUM

-- Adiciona um gradiente RGB ao MainFrame (já era sutil, sem alterações)
local frameGradient = Instance.new("UIGradient", MainFrame)
frameGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, ACCENT_COLOR_R),
    ColorSequenceKeypoint.new(0.5, ACCENT_COLOR_G),
    ColorSequenceKeypoint.new(1.0, ACCENT_COLOR_B)
}
frameGradient.Rotation = 45 -- Rotacao diagonal
frameGradient.Transparency = NumberSequence.new(0.9, 0.9) -- Quase invisível, apenas um brilho sutil

local innerFrame = Instance.new("Frame", MainFrame)
innerFrame.Size = UDim2.new(1,-4,1,-4) -- Borda de 2 pixels
innerFrame.Position = UDim2.new(0,2,0,2)
innerFrame.BackgroundColor3 = DARK_GREY
innerFrame.BorderSizePixel = 0
Instance.new("UICorner", innerFrame).CornerRadius = UDim.new(0, 6)

local panelLayout = Instance.new("UIListLayout", innerFrame)
panelLayout.Padding = UDim.new(0, 8) -- Mais espaçamento entre botões
panelLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
panelLayout.VerticalAlignment = Enum.VerticalAlignment.Center
panelLayout.FillDirection = Enum.FillDirection.Vertical
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 2.4. Botões de Ação do Editor (dentro do MainFrame)
-- Aplicando o estilo de botão com efeitos de hover
local buttonHeight = 45 -- Botões ligeiramente mais altos

selecionarBtn = Instance.new("TextButton") -- Reatribuindo para usar a função applyButtonStyle
selecionarBtn.Name = "SelectButton"
selecionarBtn.Size = UDim2.new(0.9, 0, 0, buttonHeight)
selecionarBtn.Text = "✏️ Selecionar Botão"
selecionarBtn.Parent = innerFrame
applyButtonStyle(selecionarBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70), ACCENT_COLOR_R) -- Vermelho no clique

salvarBtn = Instance.new("TextButton")
salvarBtn.Name = "SaveButton"
salvarBtn.Size = UDim2.new(0.9, 0, 0, buttonHeight)
salvarBtn.Text = "💾 Salvar HUD"
salvarBtn.Parent = innerFrame
applyButtonStyle(salvarBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70), ACCENT_COLOR_G) -- Verde no clique

carregarBtn = Instance.new("TextButton")
carregarBtn.Name = "LoadButton"
carregarBtn.Size = UDim2.new(0.9, 0, 0, buttonHeight)
carregarBtn.Text = "📂 HUDs Salvos"
carregarBtn.Parent = innerFrame
applyButtonStyle(carregarBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70), ACCENT_COLOR_B) -- Azul no clique

-- 2.5. Cursor Analógico e Controles (Visível apenas em modo de seleção)
local cursor = Instance.new("Frame")
cursor.Name = "VirtualCursor"
cursor.Size = UDim2.new(0, 16, 0, 16) -- Cursor ligeiramente maior
cursor.BackgroundColor3 = Color3.fromRGB(255, 20, 20) -- Vermelho mais vivo
cursor.Position = UDim2.new(0.5, -8, 0.5, -8)
cursor.ZIndex = 999998
cursor.Visible = false
cursor.AnchorPoint = Vector2.new(0, 0)
cursor.BorderSizePixel = 0
cursor.Parent = EditorScreenGui
Instance.new("UICorner", cursor).CornerRadius = UDim.new(1, 0)

local touchpad = Instance.new("Frame")
touchpad.Name = "TouchpadArea"
touchpad.Size = UDim2.new(1, 0, 0, 120) -- Touchpad maior
touchpad.Position = UDim2.new(0, 0, 1, -120)
touchpad.BackgroundColor3 = BLACK
touchpad.BackgroundTransparency = 0.8 -- MAIS TRANSPARENTE
touchpad.ZIndex = 998000
touchpad.Visible = false
touchpad.Parent = EditorScreenGui
Instance.new("UIStroke", touchpad).Color = ACCENT_COLOR_G -- Borda verde no touchpad
Instance.new("UIStroke", touchpad).Thickness = 2

local touchpadGradient = Instance.new("UIGradient", touchpad)
touchpadGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, ACCENT_COLOR_B),
    ColorSequenceKeypoint.new(1.0, ACCENT_COLOR_R)
}
touchpadGradient.Rotation = 0
touchpadGradient.Transparency = NumberSequence.new(0.8, 0.8) -- GRADIENTE MUITO TRANSPARENTE

local clickBtn = Instance.new("TextButton")
clickBtn.Name = "ClickVirtualButton"
clickBtn.Size = UDim2.new(0, 140, 0, 50) -- Botão de clique maior
clickBtn.Position = UDim2.new(1, -150, 1, -130)
clickBtn.Text = "⏺ Clicar"
clickBtn.ZIndex = 999999
clickBtn.Visible = false
clickBtn.Parent = EditorScreenGui
applyButtonStyle(clickBtn, Color3.fromRGB(150, 30, 30), Color3.fromRGB(200, 50, 50), ACCENT_COLOR_R) -- Estilo de clique vermelho

--==================================================================================================
-- 3. FUNÇÕES AUXILIARES
-- Esta seção contém funções que ajudam a lógica do script ou a criação dinâmica de GUIs.
--==================================================================================================

-- Função genérica para criar botões de edição dentro de um ScrollingFrame
local function CriarBotaoEdicao(parentScrollFrame, nome, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -10, 0, 35) -- Ligeiramente mais alto
	b.Text = nome
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = TEXT_COLOR_LIGHT
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Um pouco mais escuro
	b.ZIndex = 102
    b.TextScaled = false
    b.TextWrapped = true
	b.Parent = parentScrollFrame
	Instance.new("UICorner", b).CornerRadius = CORNER_RADIUS_SMALL
    Instance.new("UIStroke", b).Color = Color3.fromRGB(60,60,60) -- Borda suave
    Instance.new("UIStroke", b).Thickness = 1
    Instance.new("UIStroke", b).Transparency = 0.7

    -- Efeitos de hover e clique para botões de edição
    local originalColor = b.BackgroundColor3
    local originalTransparency = b.BackgroundTransparency
    local hoverTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local clickTweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, hoverTweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70), BackgroundTransparency = 0}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, hoverTweenInfo, {BackgroundColor3 = originalColor, BackgroundTransparency = originalTransparency}):Play()
    end)
    b.MouseButton1Down:Connect(function()
        TweenService:Create(b, clickTweenInfo, {BackgroundColor3 = ACCENT_COLOR_G, BackgroundTransparency = 0}):Play() -- Verde no clique
    end)
    b.MouseButton1Up:Connect(function()
        TweenService:Create(b, clickTweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70), BackgroundTransparency = 0}):Play()
    end)

	b.MouseButton1Click:Connect(callback)
	return b
end

-- Marca um botão como modificado para o salvamento
local function marcarComoModificado(botao)
	botao:SetAttribute("HUD_Modificado", true)
end

-- Atualiza a posição do cursor virtual
local function updateCursorPosition(dir)
	if not cursor.Visible then return end
	local pos = cursor.Position
	local dx, dy = dir.X * 5, dir.Y * 5 -- sensibilidade
	local newX = math.clamp(pos.X.Offset + dx, 0, EditorScreenGui.AbsoluteSize.X - cursor.AbsoluteSize.X)
	local newY = math.clamp(pos.Y.Offset + dy, 0, EditorScreenGui.AbsoluteSize.Y - cursor.AbsoluteSize.Y)
	cursor.Position = UDim2.new(0, newX, 0, newY)
end

-- Ativa/desativa o touchpad e o cursor virtual
local function enableTouchpad()
	cursor.Visible = true
	touchpad.Visible = true
	clickBtn.Visible = true
	local direction = Vector2.zero

    -- Desconecta as conexões existentes antes de criar novas (evita vazamento de memória)
    if touchpadInputBeganConn then touchpadInputBeganConn:Disconnect() end
    if touchpadInputChangedConn then touchpadInputChangedConn:Disconnect() end
    if touchpadInputEndedConn then touchpadInputEndedConn:Disconnect() end
    if moveConnection then moveConnection:Disconnect() end
    if clickBtnConnection then clickBtnConnection:Disconnect() end

    touchpadInputBeganConn = touchpad.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			moving = true
			lastInput = input.Position
		end
	end)

    touchpadInputChangedConn = touchpad.InputChanged:Connect(function(input)
		if moving and input.UserInputType == Enum.UserInputType.Touch then
			direction = (input.Position - lastInput)/6 -- sensibilidade
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

    clickBtnConnection = clickBtn.MouseButton1Click:Connect(function()
        local pos = Vector2.new(cursor.AbsolutePosition.X + cursor.AbsoluteSize.X/2, cursor.AbsolutePosition.Y + cursor.AbsoluteSize.Y/2)
        local under = player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(pos.X, pos.Y)
        for _, gui in ipairs(under) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and not gui:IsDescendantOf(EditorScreenGui) then
                modoSelecionando = false
                cursor.Visible = false
                touchpad.Visible = false
                clickBtn.Visible = false
                selecionarBtn.Text = "✏️ Selecionar Botão"
                MostrarInfoDoBotao(gui)
                return
            end
        end
    end)
end

-- Desativa o touchpad e limpa as conexões
local function disableTouchpadAndCursor()
    modoSelecionando = false
    cursor.Visible = false
    touchpad.Visible = false
    clickBtn.Visible = false
    selecionarBtn.Text = "✏️ Selecionar Botão"
    if touchpadInputBeganConn then touchpadInputBeganConn:Disconnect() end
    if touchpadInputChangedConn then touchpadInputChangedConn:Disconnect() end
    if touchpadInputEndedConn then touchpadInputEndedConn:Disconnect() end
    if moveConnection then moveConnection:Disconnect() end
    if clickBtnConnection then clickBtnConnection:Disconnect() end
end

-- Obtém dados de um botão para salvamento
local function getButtonData(botao)
	local data = {
		Size = {botao.Size.X.Scale, botao.Size.X.Offset, botao.Size.Y.Scale, botao.Size.Y.Offset},
		Position = {botao.Position.X.Scale, botao.Position.X.Offset, botao.Position.Y.Scale, botao.Position.Y.Offset},
		Color = {math.floor(botao.BackgroundColor3.R * 255), math.floor(botao.BackgroundColor3.G * 255), math.floor(botao.BackgroundColor3.B * 255)},
		Transparency = botao.BackgroundTransparency,
		Text = botao:IsA("TextButton") and botao.Text or nil,
		Image = botao:IsA("ImageButton") and botao.Image or nil
	}
	return data
end

-- Obtém o caminho completo de um objeto na hierarquia
local function getFullPath(obj)
	local path = obj.Name
	local parent = obj.Parent
	while parent and parent ~= game do
		path = parent.Name .. "." .. path
		parent = parent.Parent
	end
	return path
end

-- Busca o nome da experiência via HttpService (para HUDs por experiência)
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

-- Atualiza o texto do botão de toggle Universal/Experiência
local function updateToggleText(button)
    local baseColor, hoverColor, clickColor
    if isUniversal then
        baseColor = ACCENT_COLOR_B
        hoverColor = Color3.fromRGB(0, 50, 255)
        clickColor = Color3.fromRGB(0, 100, 255)
        button.Text = "🌎 HUD Universal (Todos os Jogos)"
    else
        baseColor = Color3.fromRGB(50, 50, 50)
        hoverColor = Color3.fromRGB(70, 70, 70)
        clickColor = Color3.fromRGB(90, 90, 90)
        button.Text = "🎮 HUD Por Experiência (Somente Este Jogo)"
    end
    -- Aplicar cores com tween para suavidade na atualização
    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = baseColor}):Play()
    -- Reaplicar os eventos de hover/click para as novas cores
    local originalHoverColor = hoverColor
    local originalClickColor = clickColor

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = originalHoverColor, BackgroundTransparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = baseColor, BackgroundTransparency = 0}):Play()
    end)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = originalClickColor, BackgroundTransparency = 0}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = originalHoverColor, BackgroundTransparency = 0}):Play()
    end)
end

--==================================================================================================
-- 4. FUNÇÕES DE EXIBIÇÃO E EDIÇÃO DE PAINÉIS (Dinamicamente Criados)
-- Esta seção contém as funções que criam GUIs temporárias para interação do usuário.
--==================================================================================================

-- Exibe um painel com informações do botão selecionado
function MostrarInfoDoBotao(botao)
	local fundo = Instance.new("Frame")
	fundo.Name = "InfoOverlay"
	fundo.Size = UDim2.new(1, 0, 1, 0)
	fundo.BackgroundColor3 = BLACK
	fundo.BackgroundTransparency = 0.6
	fundo.ZIndex = 100
	fundo.Parent = EditorScreenGui

	local painel = Instance.new("Frame")
	painel.Name = "InfoPanel"
	painel.Size = UDim2.new(0, 380, 0, 280) -- Painel maior
	painel.Position = UDim2.new(0.5, -190, 0.5, -125)
	painel.BackgroundColor3 = DARK_GREY
	painel.ZIndex = 101
	painel.Parent = fundo
	Instance.new("UICorner", painel).CornerRadius = CORNER_RADIUS_MEDIUM
    Instance.new("UIStroke", painel).Color = ACCENT_COLOR_G -- Borda verde
    Instance.new("UIStroke", painel).Thickness = 2

	local layout = Instance.new("UIListLayout", painel)
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center

	local function AddInfo(txt)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -20, 0, 25)
		l.Text = txt
		l.TextColor3 = TEXT_COLOR_DARK
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.Gotham
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextSize = 14
		l.ZIndex = 102
		l.Parent = painel
        l.TextScaled = false
        l.TextWrapped = true
	end

	local titulo = Instance.new("TextLabel")
	titulo.Name = "InfoTitle"
	titulo.Text = "🔎 Informações do Botão"
	titulo.Size = UDim2.new(1, -20, 0, 35)
	titulo.TextColor3 = TEXT_COLOR_LIGHT
	titulo.BackgroundTransparency = 1
	titulo.Font = Enum.Font.GothamBold
	titulo.TextSize = 18
	titulo.ZIndex = 102
	titulo.Parent = painel
    Instance.new("UIStroke", titulo).Color = ACCENT_COLOR_R -- Borda vermelha
    Instance.new("UIStroke", titulo).Thickness = 1
    Instance.new("UIPadding", titulo).PaddingLeft = UDim.new(0,10)
    Instance.new("UIPadding", titulo).PaddingRight = UDim.new(0,10)

	if botao:IsA("TextButton") then
		AddInfo("📝 Texto: " .. botao.Text)
	elseif botao:IsA("ImageButton") then
		AddInfo("🖼️ Imagem: " .. botao.Image)
	end

	AddInfo("🏷️ Nome: " .. botao.Name)
	AddInfo("📂 Caminho: " .. botao:GetFullName())
    AddInfo("⌨️ Atalho: Nenhum (função removida)")

	local prosseguir = Instance.new("TextButton")
	prosseguir.Name = "EditButtonConfirm"
	prosseguir.Size = UDim2.new(0.9, 0, 0, 40)
	prosseguir.Text = "✅ Editar Botão"
	prosseguir.ZIndex = 103
	prosseguir.Parent = painel
	applyButtonStyle(prosseguir, Color3.fromRGB(40, 150, 90), Color3.fromRGB(60, 180, 110), ACCENT_COLOR_G) -- Verde de confirmação

	local cancelar = Instance.new("TextButton")
	cancelar.Name = "CancelInfo"
	cancelar.Size = UDim2.new(0.9, 0, 0, 40)
	cancelar.Text = "❌ Cancelar"
	cancelar.ZIndex = 103
	cancelar.Parent = painel
	applyButtonStyle(cancelar, Color3.fromRGB(150, 40, 40), Color3.fromRGB(180, 60, 60), ACCENT_COLOR_R) -- Vermelho de cancelamento

	prosseguir.MouseButton1Click:Connect(function()
		fundo:Destroy()
		AbrirEditor(botao)
	end)

	cancelar.MouseButton1Click:Connect(function()
		fundo:Destroy()
	end)
end

-- Abre o painel de edição para um botão específico
function AbrirEditor(botao)
	local fundo = Instance.new("Frame")
	fundo.Name = "EditorOverlay"
	fundo.Size = UDim2.new(1, 0, 1, 0)
	fundo.BackgroundColor3 = BLACK
	fundo.BackgroundTransparency = 0.6
	fundo.ZIndex = 100
	fundo.Parent = EditorScreenGui
	
	local painel = Instance.new("Frame")
	painel.Name = "EditorPanelDynamic"
	painel.Size = UDim2.new(0, 280, 0, 400) -- Painel maior
	painel.Position = UDim2.new(0.5, -140, 0.5, -200)
	painel.BackgroundColor3 = DARK_GREY
	painel.ZIndex = 101
	painel.Parent = fundo
	Instance.new("UICorner", painel).CornerRadius = CORNER_RADIUS_MEDIUM
    Instance.new("UIStroke", painel).Color = ACCENT_COLOR_R -- Borda vermelha
    Instance.new("UIStroke", painel).Thickness = 2

	local scroll = Instance.new("ScrollingFrame", painel)
	scroll.Name = "EditorScrollFrame"
	scroll.Size = UDim2.new(1, -10, 1, -10)
	scroll.Position = UDim2.new(0, 5, 0, 5)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 8 -- Barra de rolagem mais grossa
	scroll.ZIndex = 102
    scroll.ScrollBarImageColor3 = Color3.fromRGB(120,120,120) -- Cor da barra de rolagem
    scroll.Active = true

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	-- Botões de Edição (usando CriarBotaoEdicao)
	CriarBotaoEdicao(scroll, "📏 Aumentar Tamanho", function()
		botao.Size = botao.Size + UDim2.new(0, 20, 0, 20)
		marcarComoModificado(botao)
	end)

    CriarBotaoEdicao(scroll, "📏 Diminuir Tamanho", function()
		botao.Size = botao.Size + UDim2.new(0, -20, 0, -20)
		marcarComoModificado(botao)
	end)

	CriarBotaoEdicao(scroll, "➡️ Mover para Direita", function()
		botao.Position = botao.Position + UDim2.new(0, 20, 0, 0)
		marcarComoModificado(botao)
	end)

    CriarBotaoEdicao(scroll, "⬅️ Mover para Esquerda", function()
		botao.Position = botao.Position + UDim2.new(0, -20, 0, 0)
		marcarComoModificado(botao)
	end)

    CriarBotaoEdicao(scroll, "⬆️ Mover para Cima", function()
		botao.Position = botao.Position + UDim2.new(0, 0, 0, -20)
		marcarComoModificado(botao)
	end)

    CriarBotaoEdicao(scroll, "⬇️ Mover para Baixo", function()
		botao.Position = botao.Position + UDim2.new(0, 0, 0, 20)
		marcarComoModificado(botao)
	end)

	CriarBotaoEdicao(scroll, "🎨 Cor Aleatória", function()
		botao.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
		marcarComoModificado(botao)
	end)

	CriarBotaoEdicao(scroll, "💬 Editar Texto/Imagem", function()
        local currentTextOrImage = ""
        if botao:IsA("TextButton") then
            currentTextOrImage = botao.Text
        elseif botao:IsA("ImageButton") then
            currentTextOrImage = botao.Image
        end

        local inputPrompt = Instance.new("Frame")
        inputPrompt.Name = "TextInputPrompt"
        inputPrompt.Size = UDim2.new(0, 280, 0, 150) -- Maior
        inputPrompt.Position = UDim2.new(0.5, -140, 0.5, -75)
        inputPrompt.BackgroundColor3 = BLACK
        inputPrompt.Parent = fundo
        Instance.new("UICorner", inputPrompt).CornerRadius = CORNER_RADIUS_MEDIUM
        Instance.new("UIStroke", inputPrompt).Color = ACCENT_COLOR_B -- Borda azul
        Instance.new("UIStroke", inputPrompt).Thickness = 2

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.Text = "Novo Texto ou ID de Imagem:"
        label.TextColor3 = TEXT_COLOR_LIGHT
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.TextScaled = false
        label.Parent = inputPrompt

        local textBoxInput = Instance.new("TextBox")
        textBoxInput.Size = UDim2.new(1, -40, 0, 35)
        textBoxInput.Position = UDim2.new(0.5, -20, 0, 50)
        textBoxInput.Text = currentTextOrImage
        textBoxInput.PlaceholderText = "Digite texto ou rbxassetid://..."
        textBoxInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        textBoxInput.TextColor3 = TEXT_COLOR_LIGHT
        textBoxInput.TextSize = 14
        textBoxInput.Font = Enum.Font.Gotham
        textBoxInput.Parent = inputPrompt
        Instance.new("UICorner", textBoxInput).CornerRadius = CORNER_RADIUS_SMALL
        textBoxInput.TextXAlignment = Enum.TextXAlignment.Center
        textBoxInput:CaptureFocus()

        local applyBtn = Instance.new("TextButton")
        applyBtn.Name = "ApplyButton"
        applyBtn.Size = UDim2.new(0.45, 0, 0, 40)
        applyBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
        applyBtn.Text = "Aplicar"
        applyBtn.Parent = inputPrompt
        applyButtonStyle(applyBtn, Color3.fromRGB(40, 150, 90), Color3.fromRGB(60, 180, 110), ACCENT_COLOR_G)

        local cancelInputBtn = Instance.new("TextButton")
        cancelInputBtn.Name = "CancelInputButton"
        cancelInputBtn.Size = UDim2.new(0.45, 0, 0, 40)
        cancelInputBtn.Position = UDim2.new(0.5, 10, 0.7, 0)
        cancelInputBtn.Text = "Cancelar"
        cancelInputBtn.Parent = inputPrompt
        applyButtonStyle(cancelInputBtn, Color3.fromRGB(150, 40, 40), Color3.fromRGB(180, 60, 60), ACCENT_COLOR_R)

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

	CriarBotaoEdicao(scroll, "🌫️ + Transparência", function()
		botao.BackgroundTransparency = math.clamp(botao.BackgroundTransparency + 0.1, 0, 1)
		marcarComoModificado(botao)
	end)

    CriarBotaoEdicao(scroll, "🌫️ - Transparência", function()
		botao.BackgroundTransparency = math.clamp(botao.BackgroundTransparency - 0.1, 0, 1)
		marcarComoModificado(botao)
	end)

	CriarBotaoEdicao(scroll, "❌ Excluir Botão", function()
		botao:Destroy()
		fundo:Destroy()
	end)

	CriarBotaoEdicao(scroll, "✅ Sair", function()
		fundo:Destroy()
	end)
end

--==================================================================================================
-- 5. LÓGICA PRINCIPAL E CONEXÕES DE EVENTOS
-- Esta seção orquestra o comportamento do script, conectando eventos e chamando funções.
--==================================================================================================

-- 5.1. Inicialização da Tela de Introdução
task.wait(6)
fundoIntro:Destroy() -- Destrói o fundo da intro após o aviso

-- 5.2. Conexão para Abrir/Fechar o Editor
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F6 or input.KeyCode == Enum.KeyCode.LeftControl then
		EditorScreenGui.Enabled = not EditorScreenGui.Enabled
        if not EditorScreenGui.Enabled then
            disableTouchpadAndCursor() -- Desativa o touchpad e cursor quando o editor é fechado
        end
	end
end)

-- 5.3. Evento do Botão "Selecionar Botão"
selecionarBtn.MouseButton1Click:Connect(function()
	if modoSelecionando then
		disableTouchpadAndCursor()
		return
	end
	modoSelecionando = true
	selecionarBtn.Text = "📈 Tocando para selecionar..."
	enableTouchpad()
end)

-- 5.4. Evento do Botão "Salvar HUD"
salvarBtn.MouseButton1Click:Connect(function()
    salvarBtn.Active = false -- Desabilita para evitar cliques múltiplos

    local inputPanel = Instance.new("Frame")
    inputPanel.Name = "SaveHUDPrompt"
    inputPanel.Size = UDim2.new(0, 320, 0, 220) -- Painel maior
    inputPanel.Position = UDim2.new(0.5, -160, 0.5, -110)
    inputPanel.BackgroundColor3 = BLACK
    inputPanel.BorderSizePixel = 0
    inputPanel.Parent = EditorScreenGui
    Instance.new("UICorner", inputPanel).CornerRadius = CORNER_RADIUS_MEDIUM
    Instance.new("UIStroke", inputPanel).Color = ACCENT_COLOR_G -- Borda verde
    Instance.new("UIStroke", inputPanel).Thickness = 2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "Nomear e Salvar HUD"
    title.TextColor3 = TEXT_COLOR_LIGHT
    title.Transparency = 1
    title.BackgroundColor3 = BLACK
    title.Font = Enum.Font.GothamBold
    title.TextSize = 32
    title.Parent = inputPanel
    Instance.new("UIStroke", title).Color = ACCENT_COLOR_B
    Instance.new("UIStroke", title).Thickness = 1
    Instance.new("UIPadding", title).PaddingLeft = UDim.new(0,10)
    Instance.new("UIPadding", title).PaddingRight = UDim.new(0,10)

    local nameTextBox = Instance.new("TextBox")
    nameTextBox.Name = "HUDNameInput"
    nameTextBox.Size = UDim2.new(1, -40, 0, 45) -- Campo de texto maior
    nameTextBox.Position = UDim2.new(0, 20, 0, 55)
    nameTextBox.PlaceholderText = "Digite o nome do HUD aqui..."
    nameTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    nameTextBox.TextColor3 = TEXT_COLOR_LIGHT
    nameTextBox.TextSize = 16
    nameTextBox.Font = Enum.Font.Gotham
    nameTextBox.Parent = inputPanel
    Instance.new("UICorner", nameTextBox).CornerRadius = CORNER_RADIUS_SMALL
    Instance.new("UIPadding", nameTextBox).PaddingLeft = UDim.new(0,10)
    Instance.new("UIPadding", nameTextBox).PaddingRight = UDim.new(0,10)
    nameTextBox.TextXAlignment = Enum.TextXAlignment.Center
    nameTextBox:CaptureFocus()

    local universalToggleBtn = Instance.new("TextButton")
    universalToggleBtn.Name = "UniversalToggle"
    universalToggleBtn.Size = UDim2.new(1, -40, 0, 40)
    universalToggleBtn.Position = UDim2.new(0, 20, 0, 110)
    universalToggleBtn.Parent = inputPanel
    Instance.new("UIPadding", universalToggleBtn).PaddingLeft = UDim.new(0,10)
    Instance.new("UIPadding", universalToggleBtn).PaddingRight = UDim.new(0,10)
    applyButtonStyle(universalToggleBtn, Color3.fromRGB(50,50,50), Color3.fromRGB(70,70,70), ACCENT_COLOR_B) -- Estilo base, updateToggleText cuidará da cor
    updateToggleText(universalToggleBtn) -- Garante o estado inicial correto

    universalToggleBtn.MouseButton1Click:Connect(function()
        isUniversal = not isUniversal
        updateToggleText(universalToggleBtn)
    end)

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Name = "ConfirmSaveButton"
    confirmBtn.Size = UDim2.new(0.45, 0, 0, 40)
    confirmBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
    confirmBtn.Text = "Salvar"
    confirmBtn.Parent = inputPanel
    applyButtonStyle(confirmBtn, Color3.fromRGB(40, 150, 90), Color3.fromRGB(60, 180, 110), ACCENT_COLOR_G)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Name = "CancelSaveButton"
    cancelBtn.Size = UDim2.new(0.45, 0, 0, 40)
    cancelBtn.Position = UDim2.new(0.5, 10, 0.75, 0)
    cancelBtn.Text = "Cancelar"
    cancelBtn.Parent = inputPanel
    applyButtonStyle(cancelBtn, Color3.fromRGB(150, 40, 40), Color3.fromRGB(180, 60, 60), ACCENT_COLOR_R)

    confirmBtn.MouseButton1Click:Connect(function()
        local hudName = nameTextBox.Text
        if string.len(hudName) == 0 then
            warn("Nome do HUD não pode ser vazio!")
            return
        end

        local data = {}
        if isfile(fileName) then
            data = HttpService:JSONDecode(readfile(fileName))
        end

        data.universalHuds = data.universalHuds or {}
        data.experiences = data.experiences or {}

        local currentHUDData = {}
        for _, guiChild in ipairs(player.PlayerGui:GetDescendants()) do
            if (guiChild:IsA("TextButton") or guiChild:IsA("ImageButton")) and guiChild:GetAttribute("HUD_Modificado") then
                local caminho = getFullPath(guiChild)
                currentHUDData[caminho] = getButtonData(guiChild)
            end
        end

        if isUniversal then
            data.universalHuds[hudName] = currentHUDData
        else
            local placeId = tostring(game.PlaceId)
            data.experiences[placeId] = data.experiences[placeId] or {huds = {}}
            data.experiences[placeId].huds[hudName] = currentHUDData
        end

        writefile(fileName, HttpService:JSONEncode(data))
        salvarBtn.Text = "✅ Salvo!"
        inputPanel:Destroy()
        task.wait(1.5)
        salvarBtn.Text = "💾 Salvar HUD"
        salvarBtn.Active = true
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        inputPanel:Destroy()
        salvarBtn.Active = true
    end)
end)

-- 5.5. Evento do Botão "HUDs Salvos"
carregarBtn.MouseButton1Click:Connect(function()
    if not isfile(fileName) then
        warn("Nenhum arquivo de salvamento encontrado.")
        return
    end
    local data = HttpService:JSONDecode(readfile(fileName))

    local loaderScreenGui = Instance.new("ScreenGui")
    loaderScreenGui.Name = "HUDLoaderUI"
    loaderScreenGui.ResetOnSpawn = false
    loaderScreenGui.IgnoreGuiInset = true
    loaderScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loaderScreenGui.Parent = PlayerGui

    local fundo = Instance.new("Frame", loaderScreenGui)
    fundo.Name = "LoadOverlay"
    fundo.Size = UDim2.new(1, 0, 1, 0)
    fundo.BackgroundColor3 = BLACK
    fundo.BackgroundTransparency = 0.6
    fundo.ZIndex = 100

    local painel = Instance.new("Frame", fundo)
    painel.Name = "LoadPanel"
    painel.Size = UDim2.new(0, 420, 0, 350) -- Painel maior
    painel.Position = UDim2.new(0.5, -210, 0.5, -175)
    painel.BackgroundColor3 = DARK_GREY
    painel.ZIndex = 101
    Instance.new("UICorner", painel).CornerRadius = CORNER_RADIUS_MEDIUM
    Instance.new("UIStroke", painel).Color = ACCENT_COLOR_B -- Borda azul
    Instance.new("UIStroke", painel).Thickness = 2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "Selecione um HUD Salvo"
    title.TextColor3 = TEXT_COLOR_LIGHT
    title.BackgroundColor3 = DARK_GREY
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = painel
    Instance.new("UIPadding", title).PaddingLeft = UDim.new(0,10)
    Instance.new("UIPadding", title).PaddingRight = UDim.new(0,10)

    local scroll = Instance.new("ScrollingFrame", painel)
    scroll.Name = "LoadScrollFrame"
    scroll.Size = UDim2.new(1, -20, 1, -60) -- Ajusta o tamanho para o título e botão de fechar
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ZIndex = 102
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 8
    scroll.ScrollBarImageColor3 = Color3.fromRGB(120,120,120)
    scroll.Active = true

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
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
        btn.Name = "UniversalHUD_" .. hudName
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Text = "🌍 Universal HUD: " .. hudName
        applyButtonStyle(btn, Color3.fromRGB(0, 60, 120), Color3.fromRGB(0, 90, 150), ACCENT_COLOR_B) -- Azul para universal
        anyHudFound = true

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
                    obj:SetAttribute("HUD_Modificado", true)
                end
            end
            loaderScreenGui:Destroy()
        end)
    end

    -- Adiciona HUDs da Experiência Atual
    for hudName, hudData in pairs(currentExperienceHuds) do
        local btn = Instance.new("TextButton", scroll)
        btn.Name = "ExperienceHUD_" .. hudName
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Text = "🎮 Experiência HUD: " .. hudName
        applyButtonStyle(btn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70), ACCENT_COLOR_G) -- Cinza para experiência
        anyHudFound = true

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
                    obj:SetAttribute("HUD_Modificado", true)
                end
            end
            loaderScreenGui:Destroy()
        end)
    end

    if not anyHudFound then
        local noHudText = Instance.new("TextLabel", scroll)
        noHudText.Name = "NoHUDsFound"
        noHudText.Size = UDim2.new(1, -10, 0, 40)
        noHudText.BackgroundTransparency = 1
        noHudText.TextColor3 = TEXT_COLOR_DARK
        noHudText.TextSize = 16
        noHudText.Font = Enum.Font.GothamBold
        noHudText.Text = "Nenhum HUD salvo encontrado.\nSalve seu primeiro HUD para vê-lo aqui!"
        noHudText.TextWrapped = true
        noHudText.TextXAlignment = Enum.TextXAlignment.Center
    end

    local fechar = Instance.new("TextButton", painel)
    fechar.Name = "CloseLoaderButton"
    fechar.Size = UDim2.new(0, 75, 0, 30)
    fechar.Position = UDim2.new(0, 330, 0, 12)
    fechar.Text = "❌ Fechar"
    fechar.Parent = painel
    applyButtonStyle(fechar, Color3.fromRGB(150, 40, 40), Color3.fromRGB(180, 60, 60), ACCENT_COLOR_R)

    fechar.MouseButton1Click:Connect(function()
        loaderScreenGui:Destroy()
    end)
end)