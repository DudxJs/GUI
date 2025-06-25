-- ✨ ENHANCED MUSIC ID PUBLISHER - VERSÃO 2.3 ✨
-- GUI Unificada com Efeitos RGB e Botão Flutuante
-- Compatível com Delta Executor e outros executores HTTP

local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local request = (http_request or request or http_get or syn and syn.request)

if not request then
	warn("❌ Seu executor não suporta http_request.")
	return
end

-- 🌐 CONFIGURAÇÃO DA API
local API_URL = "https://script.google.com/macros/s/AKfycbwWj5H1HmWcXR9OCPQJAKQC-K5QPwulGUJ_4o5N2xKB5GB8aAB20Z0xAVqhrbKvcHB1Ow/exec"

-- 🎨 CORES RGB ANIMADAS
local RGB_COLORS = {
	Color3.fromRGB(255, 0, 128),  -- Rosa
	Color3.fromRGB(0, 255, 128),  -- Verde Ciano  
	Color3.fromRGB(128, 0, 255),  -- Roxo
	Color3.fromRGB(255, 128, 0),  -- Laranja
	Color3.fromRGB(0, 128, 255),  -- Azul Ciano
}

-- 🏗️ CRIAÇÃO DA INTERFACE PRINCIPAL
local function createMainGUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "EnhancedMusicPublisher"
	gui.Parent = player:WaitForChild("PlayerGui")
	gui.ResetOnSpawn = false
	
	-- 🔮 Container principal (sem background preto)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 500, 0, 600)
	mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
	mainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
	mainFrame.BackgroundTransparency = 0.1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = gui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 20)
	mainCorner.Parent = mainFrame
	
	-- 🌈 Borda RGB animada
	local borderFrame = Instance.new("Frame")
	borderFrame.Name = "BorderFrame"
	borderFrame.Size = UDim2.new(1, 4, 1, 4)
	borderFrame.Position = UDim2.new(0, -2, 0, -2)
	borderFrame.BackgroundColor3 = RGB_COLORS[1]
	borderFrame.BorderSizePixel = 0
	borderFrame.Parent = mainFrame
	borderFrame.ZIndex = mainFrame.ZIndex - 1
	
	local borderCorner = Instance.new("UICorner")
	borderCorner.CornerRadius = UDim.new(0, 22)
	borderCorner.Parent = borderFrame
	
	-- ❌ Botão fechar/minimizar
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -40, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 16
	closeButton.Font = Enum.Font.GothamBold
	closeButton.ZIndex = 10
	closeButton.Parent = mainFrame
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeButton
	
	-- 📜 ScrollingFrame para todo o conteúdo
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ContentScroll"
	scrollFrame.Size = UDim2.new(1, -10, 1, -10)
	scrollFrame.Position = UDim2.new(0, 5, 0, 5)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ScrollBarImageColor3 = RGB_COLORS[1]
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 650) -- Altura total do conteúdo
	scrollFrame.Parent = mainFrame
	
	-- Animação da barra de rolagem RGB
	spawn(function()
		local colorIndex = 1
		while scrollFrame.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			local tween = TweenService:Create(
				scrollFrame,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ScrollBarImageColor3 = RGB_COLORS[colorIndex]}
			)
			tween:Play()
			wait(2)
		end
	end)
	
	-- Frame para lista de músicas (inicialmente invisível)
	local musicListFrame = Instance.new("Frame")
	musicListFrame.Name = "MusicListFrame"
	musicListFrame.Size = UDim2.new(1, 0, 1, 0)
	musicListFrame.Position = UDim2.new(0, 0, 0, 0)
	musicListFrame.BackgroundTransparency = 1
	musicListFrame.Visible = false
	musicListFrame.Parent = scrollFrame
	
	local musicListScroll = Instance.new("ScrollingFrame")
	musicListScroll.Name = "MusicListScroll"
	musicListScroll.Size = UDim2.new(1, -20, 1, -100)
	musicListScroll.Position = UDim2.new(0, 10, 0, 80)
	musicListScroll.BackgroundTransparency = 1
	musicListScroll.BorderSizePixel = 0
	musicListScroll.ScrollBarThickness = 8
	musicListScroll.ScrollBarImageColor3 = RGB_COLORS[1]
	musicListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	musicListScroll.Parent = musicListFrame
	
	-- Título da lista de músicas
	local musicListTitle = Instance.new("TextLabel")
	musicListTitle.Name = "MusicListTitle"
	musicListTitle.Size = UDim2.new(1, -80, 0, 60)
	musicListTitle.Position = UDim2.new(0, 20, 0, 20)
	musicListTitle.BackgroundTransparency = 1
	musicListTitle.Text = "🎵 MÚSICAS PUBLICADAS"
	musicListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	musicListTitle.TextSize = 20
	musicListTitle.Font = Enum.Font.GothamBold
	musicListTitle.TextXAlignment = Enum.TextXAlignment.Left
	musicListTitle.Parent = musicListFrame
	
	-- Botão voltar na lista
	local backButton = Instance.new("TextButton")
	backButton.Name = "BackButton"
	backButton.Size = UDim2.new(0, 60, 0, 30)
	backButton.Position = UDim2.new(1, -80, 0, 30)
	backButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	backButton.BorderSizePixel = 0
	backButton.Text = "← VOLTAR"
	backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	backButton.TextSize = 12
	backButton.Font = Enum.Font.GothamBold
	backButton.Parent = musicListFrame
	
	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(0, 8)
	backCorner.Parent = backButton
	
	return gui, mainFrame, borderFrame, scrollFrame, closeButton, musicListFrame, musicListScroll, backButton
end

-- 🎭 FUNÇÃO PARA ANIMAR BORDA RGB
local function animateRGBBorder(borderFrame)
	local colorIndex = 1
	local function cycleBorder()
		while borderFrame.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			local tween = TweenService:Create(
				borderFrame,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{BackgroundColor3 = RGB_COLORS[colorIndex]}
			)
			tween:Play()
			wait(1)
		end
	end
	spawn(cycleBorder)
end

-- 🏷️ FUNÇÃO PARA CRIAR TÍTULO
local function createTitle(parent)
	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "TitleFrame"
	titleFrame.Size = UDim2.new(1, -40, 0, 80)
	titleFrame.Position = UDim2.new(0, 20, 0, 20)
	titleFrame.BackgroundTransparency = 1
	titleFrame.Parent = parent
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 1, 0)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🎵 MUSIC ID PUBLISHER"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 24
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextStrokeTransparency = 0.5
	titleLabel.TextStrokeColor3 = RGB_COLORS[1]
	titleLabel.Parent = titleFrame
	
	-- Animar cor do título
	spawn(function()
		local colorIndex = 1
		while titleLabel.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			local tween = TweenService:Create(
				titleLabel,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{TextStrokeColor3 = RGB_COLORS[colorIndex]}
			)
			tween:Play()
			wait(2)
		end
	end)
	
	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "SubtitleLabel"
	subtitleLabel.Size = UDim2.new(1, 0, 0, 25)
	subtitleLabel.Position = UDim2.new(0, 0, 1, 5)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = "Compartilhe seus IDs favoritos do Roblox"
	subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	subtitleLabel.TextSize = 14
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.Parent = titleFrame
	
	return titleFrame
end

-- 📝 FUNÇÃO PARA CRIAR CAMPOS INPUT
local function createInputField(parent, placeholder, posY, maxLength)
	local inputFrame = Instance.new("Frame")
	inputFrame.Name = placeholder.."Frame"
	inputFrame.Size = UDim2.new(1, -40, 0, 50)
	inputFrame.Position = UDim2.new(0, 20, 0, posY)
	inputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	inputFrame.BorderSizePixel = 0
	inputFrame.Parent = parent
	
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 10)
	inputCorner.Parent = inputFrame
	
	local inputBox = Instance.new("TextBox")
	inputBox.Name = placeholder.."Box"
	inputBox.Size = UDim2.new(1, -20, 1, -10)
	inputBox.Position = UDim2.new(0, 10, 0, 5)
	inputBox.BackgroundTransparency = 1
	inputBox.PlaceholderText = placeholder
	inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	inputBox.Text = ""
	inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputBox.TextSize = 16
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.Parent = inputFrame
	
	-- Contador de caracteres
	local charCounter = Instance.new("TextLabel")
	charCounter.Name = "CharCounter"
	charCounter.Size = UDim2.new(0, 60, 0, 20)
	charCounter.Position = UDim2.new(1, -70, 1, 5)
	charCounter.BackgroundTransparency = 1
	charCounter.Text = "0/"..maxLength
	charCounter.TextColor3 = Color3.fromRGB(120, 120, 120)
	charCounter.TextSize = 12
	charCounter.Font = Enum.Font.Gotham
	charCounter.Parent = inputFrame
	
	-- Efeito de foco RGB
	inputBox.Focused:Connect(function()
		local focusTween = TweenService:Create(
			inputFrame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{BackgroundColor3 = Color3.fromRGB(40, 40, 40)}
		)
		focusTween:Play()
		
		-- Animar borda RGB
		spawn(function()
			local colorIndex = 1
			while inputBox:IsFocused() do
				colorIndex = colorIndex % #RGB_COLORS + 1
				inputFrame.BorderSizePixel = 2
				inputFrame.BorderColor3 = RGB_COLORS[colorIndex]
				wait(0.5)
			end
			inputFrame.BorderSizePixel = 0
		end)
	end)
	
	inputBox.FocusLost:Connect(function()
		local unfocusTween = TweenService:Create(
			inputFrame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{BackgroundColor3 = Color3.fromRGB(25, 25, 25)}
		)
		unfocusTween:Play()
		inputFrame.BorderSizePixel = 0
	end)
	
	-- Atualizar contador de caracteres
	inputBox:GetPropertyChangedSignal("Text"):Connect(function()
		local currentLength = #inputBox.Text
		charCounter.Text = currentLength.."/"..maxLength
		
		if currentLength > maxLength * 0.8 then
			charCounter.TextColor3 = Color3.fromRGB(255, 100, 100)
		else
			charCounter.TextColor3 = Color3.fromRGB(120, 120, 120)
		end
		
		-- Limitar caracteres
		if currentLength > maxLength then
			inputBox.Text = string.sub(inputBox.Text, 1, maxLength)
		end
	end)
	
	return inputBox
end

-- 🎛️ FUNÇÃO PARA CRIAR DROPDOWN DE CATEGORIA
local function createCategoryDropdown(parent, posY)
	local categories = {"Funk", "Phonk", "Hip Hop", "Electronic", "Rock", "Pop", "Classical", "Jazz", "Other"}
	local selectedCategory = ""
	
	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Name = "CategoryFrame"
	dropdownFrame.Size = UDim2.new(1, -40, 0, 50)
	dropdownFrame.Position = UDim2.new(0, 20, 0, posY)
	dropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	dropdownFrame.BorderSizePixel = 0
	dropdownFrame.Parent = parent
	
	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, 10)
	dropdownCorner.Parent = dropdownFrame
	
	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Name = "CategoryButton"
	dropdownButton.Size = UDim2.new(1, -20, 1, -10)
	dropdownButton.Position = UDim2.new(0, 10, 0, 5)
	dropdownButton.BackgroundTransparency = 1
	dropdownButton.Text = "Selecionar Categoria"
	dropdownButton.TextColor3 = Color3.fromRGB(180, 180, 180)
	dropdownButton.TextSize = 16
	dropdownButton.Font = Enum.Font.Gotham
	dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
	dropdownButton.Parent = dropdownFrame
	
	-- Ícone dropdown
	local dropdownIcon = Instance.new("TextLabel")
	dropdownIcon.Name = "DropdownIcon"
	dropdownIcon.Size = UDim2.new(0, 30, 1, 0)
	dropdownIcon.Position = UDim2.new(1, -30, 0, 0)
	dropdownIcon.BackgroundTransparency = 1
	dropdownIcon.Text = "▼"
	dropdownIcon.TextColor3 = Color3.fromRGB(180, 180, 180)
	dropdownIcon.TextSize = 12
	dropdownIcon.Font = Enum.Font.Gotham
	dropdownIcon.Parent = dropdownFrame
	
	-- Lista de opções
	local optionsList = Instance.new("Frame")
	optionsList.Name = "OptionsList"
	optionsList.Size = UDim2.new(1, 0, 0, #categories * 40)
	optionsList.Position = UDim2.new(0, 0, 1, 5)
	optionsList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	optionsList.BorderSizePixel = 0
	optionsList.Visible = false
	optionsList.ZIndex = 10
	optionsList.Parent = dropdownFrame
	
	local optionsCorner = Instance.new("UICorner")
	optionsCorner.CornerRadius = UDim.new(0, 10)
	optionsCorner.Parent = optionsList
	
	-- Criar opções
	for i, category in ipairs(categories) do
		local optionButton = Instance.new("TextButton")
		optionButton.Name = "Option"..i
		optionButton.Size = UDim2.new(1, 0, 0, 40)
		optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 40)
		optionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		optionButton.BorderSizePixel = 0
		optionButton.Text = category
		optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		optionButton.TextSize = 14
		optionButton.Font = Enum.Font.Gotham
		optionButton.Parent = optionsList
		
		-- Efeito hover
		optionButton.MouseEnter:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end)
		
		optionButton.MouseLeave:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		end)
		
		optionButton.MouseButton1Click:Connect(function()
			selectedCategory = category
			dropdownButton.Text = category
			dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			optionsList.Visible = false
			dropdownIcon.Text = "▼"
		end)
	end
	
	-- Toggle dropdown
	dropdownButton.MouseButton1Click:Connect(function()
		optionsList.Visible = not optionsList.Visible
		dropdownIcon.Text = optionsList.Visible and "▲" or "▼"
	end)
	
	return function() return selectedCategory end
end

-- 👤 FUNÇÃO PARA CRIAR PREVIEW DO USUÁRIO
local function createUserPreview(parent, posY)
	local previewFrame = Instance.new("Frame")
	previewFrame.Name = "UserPreview"
	previewFrame.Size = UDim2.new(1, -40, 0, 80)
	previewFrame.Position = UDim2.new(0, 20, 0, posY)
	previewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	previewFrame.BorderSizePixel = 0
	previewFrame.Parent = parent
	
	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 10)
	previewCorner.Parent = previewFrame
	
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Name = "AvatarFrame"
	avatarFrame.Size = UDim2.new(0, 60, 0, 60)
	avatarFrame.Position = UDim2.new(0, 10, 0, 10)
	avatarFrame.BackgroundColor3 = RGB_COLORS[1]
	avatarFrame.BorderSizePixel = 0
	avatarFrame.Parent = previewFrame
	
	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = avatarFrame
	
	-- Animar borda do avatar
	spawn(function()
		local colorIndex = 1
		while avatarFrame.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			local tween = TweenService:Create(
				avatarFrame,
				TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{BackgroundColor3 = RGB_COLORS[colorIndex]}
			)
			tween:Play()
			wait(3)
		end
	end)
	
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "AvatarImage"
	avatarImage.Size = UDim2.new(1, -4, 1, -4)
	avatarImage.Position = UDim2.new(0, 2, 0, 2)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
	avatarImage.Parent = avatarFrame
	
	local avatarImageCorner = Instance.new("UICorner")
	avatarImageCorner.CornerRadius = UDim.new(1, 0)
	avatarImageCorner.Parent = avatarImage
	
	local playerNameLabel = Instance.new("TextLabel")
	playerNameLabel.Name = "PlayerName"
	playerNameLabel.Size = UDim2.new(1, -80, 0, 25)
	playerNameLabel.Position = UDim2.new(0, 80, 0, 15)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Text = player.DisplayName
	playerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	playerNameLabel.TextSize = 16
	playerNameLabel.Font = Enum.Font.GothamBold
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.Parent = previewFrame
	
	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Name = "Username"
	usernameLabel.Size = UDim2.new(1, -80, 0, 20)
	usernameLabel.Position = UDim2.new(0, 80, 0, 45)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = "@"..player.Name
	usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	usernameLabel.TextSize = 14
	usernameLabel.Font = Enum.Font.Gotham
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.Parent = previewFrame
	
	return previewFrame
end

-- 🔔 FUNÇÃO PARA CRIAR FEEDBACK
local function createFeedback(parent, posY)
	local feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Name = "FeedbackLabel"
	feedbackLabel.Size = UDim2.new(1, -40, 0, 30)
	feedbackLabel.Position = UDim2.new(0, 20, 0, posY)
	feedbackLabel.BackgroundTransparency = 1
	feedbackLabel.Text = ""
	feedbackLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	feedbackLabel.TextSize = 14
	feedbackLabel.Font = Enum.Font.Gotham
	feedbackLabel.TextWrapped = true
	feedbackLabel.Parent = parent
	
	return feedbackLabel
end

-- 🚀 FUNÇÃO PARA CRIAR BOTÃO ESTILIZADO
local function createStyledButton(parent, text, posY, color, callback)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = text.."Frame"
	buttonFrame.Size = UDim2.new(1, -40, 0, 50)
	buttonFrame.Position = UDim2.new(0, 20, 0, posY)
	buttonFrame.BackgroundColor3 = color
	buttonFrame.BorderSizePixel = 0
	buttonFrame.Parent = parent
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = buttonFrame
	
	local button = Instance.new("TextButton")
	button.Name = text.."Button"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Position = UDim2.new(0, 0, 0, 0)
	button.BackgroundTransparency = 1
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.Parent = buttonFrame
	
	-- Efeitos de hover e clique
	button.MouseEnter:Connect(function()
		local hoverTween = TweenService:Create(
			buttonFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, -35, 0, 55)}
		)
		hoverTween:Play()
	end)
	
	button.MouseLeave:Connect(function()
		local leaveTween = TweenService:Create(
			buttonFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, -40, 0, 50)}
		)
		leaveTween:Play()
	end)
	
	button.MouseButton1Click:Connect(function()
		-- Efeito de clique
		local clickTween = TweenService:Create(
			buttonFrame,
			TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, -45, 0, 45)}
		)
		clickTween:Play()
		
		clickTween.Completed:Connect(function()
			local releaseTween = TweenService:Create(
				buttonFrame,
				TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{Size = UDim2.new(1, -40, 0, 50)}
			)
			releaseTween:Play()
		end)
		
		if callback then
			callback()
		end
	end)
	
	-- Efeito RGB pulsante
	spawn(function()
		while buttonFrame.Parent do
			local pulseTween = TweenService:Create(
				buttonFrame,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{BackgroundColor3 = Color3.new(color.R * 1.2, color.G * 1.2, color.B * 1.2)}
			)
			pulseTween:Play()
			pulseTween.Completed:Wait()
			
			local returnTween = TweenService:Create(
				buttonFrame,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{BackgroundColor3 = color}
			)
			returnTween:Play()
			returnTween.Completed:Wait()
		end
	end)
	
	return button
end
-- 📡 FUNÇÃO PARA PUBLICAR MÚSICA
local function publishMusic(nameBox, idBox, getCategoryFunc, feedbackLabel)
	local nome = nameBox.Text
	local id = idBox.Text
	local categoria = getCategoryFunc()
	
	-- Validações
	if nome == "" or id == "" or categoria == "" then
		feedbackLabel.Text = "⚠️ Preencha todos os campos."
		feedbackLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
		return
	end
	
	if #id > 50 or not tonumber(id) then
		feedbackLabel.Text = "⚠️ ID inválido (apenas números, máx 50 caracteres)."
		feedbackLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end
	
	if #nome > 20 then
		feedbackLabel.Text = "⚠️ Nome muito longo (máx 20 caracteres)."
		feedbackLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end
	
	feedbackLabel.Text = "🔄 Publicando música..."
	feedbackLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
	
	local dados = {
		ID_Musica = id,
		Nome = nome,
		Categoria = categoria,
		PlayerName = player.Name,
		DisplayName = player.DisplayName,
		UserId = player.UserId,
		Foto = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
	}
	
	local body = HttpService:JSONEncode(dados)
	local success, response = pcall(function()
		return request({
			Url = API_URL,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = body
		})
	end)
	
	if success and response and response.Body then
		if response.Body:find("Erro") then
			feedbackLabel.Text = "⚠️ "..response.Body
			feedbackLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
		else
			feedbackLabel.Text = "✅ Música publicada com sucesso!"
			feedbackLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			
			-- Limpar campos após sucesso
			nameBox.Text = ""
			idBox.Text = ""
		end
	else
		feedbackLabel.Text = "❌ Falha na conexão. Tente novamente."
		feedbackLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end
-- 📋 FUNÇÃO PARA EXIBIR LISTA NA MESMA GUI
local function showMusicListInGUI(musicListFrame, musicListScroll, mainScrollFrame)
	-- Esconder o conteúdo principal e mostrar a lista
	for _, child in pairs(mainScrollFrame:GetChildren()) do
		if child.Name ~= "MusicListFrame" then
			child.Visible = false
		end
	end
	musicListFrame.Visible = true
	
	-- Animar barra de scroll da lista
	spawn(function()
		local colorIndex = 1
		while musicListScroll.Parent and musicListFrame.Visible do
			colorIndex = colorIndex % #RGB_COLORS + 1
			local tween = TweenService:Create(
				musicListScroll,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ScrollBarImageColor3 = RGB_COLORS[colorIndex]}
			)
			tween:Play()
			wait(2)
		end
	end)
end
-- 📋 FUNÇÃO PARA VOLTAR AO MENU PRINCIPAL
local function showMainContent(musicListFrame, mainScrollFrame)
	-- Esconder lista e mostrar conteúdo principal
	musicListFrame.Visible = false
	for _, child in pairs(mainScrollFrame:GetChildren()) do
		if child.Name ~= "MusicListFrame" then
			child.Visible = true
		end
	end
end
-- 🎵 FUNÇÃO PARA CRIAR CARD DE MÚSICA
local function createMusicCard(parent, musicData, yPosition)
	local cardFrame = Instance.new("Frame")
	cardFrame.Name = "MusicCard"
	cardFrame.Size = UDim2.new(1, -20, 0, 100)
	cardFrame.Position = UDim2.new(0, 10, 0, yPosition)
	cardFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	cardFrame.BorderSizePixel = 0
	cardFrame.Parent = parent
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 15)
	cardCorner.Parent = cardFrame
	
	-- Avatar do usuário
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Name = "AvatarFrame"
	avatarFrame.Size = UDim2.new(0, 70, 0, 70)
	avatarFrame.Position = UDim2.new(0, 15, 0, 15)
	avatarFrame.BackgroundColor3 = RGB_COLORS[math.random(1, #RGB_COLORS)]
	avatarFrame.BorderSizePixel = 0
	avatarFrame.Parent = cardFrame
	
	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = avatarFrame
	
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "AvatarImage"
	avatarImage.Size = UDim2.new(1, -4, 1, -4)
	avatarImage.Position = UDim2.new(0, 2, 0, 2)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = musicData.Foto or "https://www.roblox.com/headshot-thumbnail/image?userId="..musicData.UserId.."&width=150&height=150&format=png"
	avatarImage.Parent = avatarFrame
	
	local avatarImageCorner = Instance.new("UICorner")
	avatarImageCorner.CornerRadius = UDim.new(1, 0)
	avatarImageCorner.Parent = avatarImage
	
	-- Informações da música
	local musicName = Instance.new("TextLabel")
	musicName.Name = "MusicName"
	musicName.Size = UDim2.new(0, 250, 0, 25)
	musicName.Position = UDim2.new(0, 100, 0, 15)
	musicName.BackgroundTransparency = 1
	musicName.Text = "🎵 " .. (musicData.Nome or "Nome não disponível")
	musicName.TextColor3 = Color3.fromRGB(255, 255, 255)
	musicName.TextSize = 16
	musicName.Font = Enum.Font.GothamBold
	musicName.TextXAlignment = Enum.TextXAlignment.Left
	musicName.TextTruncate = Enum.TextTruncate.AtEnd
	musicName.Parent = cardFrame
	
	local publisherName = Instance.new("TextLabel")
	publisherName.Name = "PublisherName"
	publisherName.Size = UDim2.new(0, 250, 0, 20)
	publisherName.Position = UDim2.new(0, 100, 0, 40)
	publisherName.BackgroundTransparency = 1
	publisherName.Text = "👤 Por: " .. (musicData.DisplayName or musicData.PlayerName or "Usuário")
	publisherName.TextColor3 = Color3.fromRGB(180, 180, 180)
	publisherName.TextSize = 14
	publisherName.Font = Enum.Font.Gotham
	publisherName.TextXAlignment = Enum.TextXAlignment.Left
	publisherName.Parent = cardFrame
	
	local musicCategory = Instance.new("TextLabel")
	musicCategory.Name = "MusicCategory"
	musicCategory.Size = UDim2.new(0, 250, 0, 20)
	musicCategory.Position = UDim2.new(0, 100, 0, 65)
	musicCategory.BackgroundTransparency = 1
	musicCategory.Text = "📂 " .. (musicData.Categoria or "Outros")
	musicCategory.TextColor3 = Color3.fromRGB(150, 150, 150)
	musicCategory.TextSize = 12
	musicCategory.Font = Enum.Font.Gotham
	musicCategory.TextXAlignment = Enum.TextXAlignment.Left
	musicCategory.Parent = cardFrame
	
	-- ID da música
	local musicId = Instance.new("TextLabel")
	musicId.Name = "MusicId"
	musicId.Size = UDim2.new(0, 120, 0, 30)
	musicId.Position = UDim2.new(1, -250, 0, 20)
	musicId.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	musicId.BorderSizePixel = 0
	musicId.Text = "🆔 " .. (musicData.ID_Musica or "N/A")
	musicId.TextColor3 = Color3.fromRGB(255, 255, 255)
	musicId.TextSize = 14
	musicId.Font = Enum.Font.GothamBold
	musicId.Parent = cardFrame
	
	local idCorner = Instance.new("UICorner")
	idCorner.CornerRadius = UDim.new(0, 8)
	idCorner.Parent = musicId
	
	-- Botão copiar
	local copyButton = Instance.new("TextButton")
	copyButton.Name = "CopyButton"
	copyButton.Size = UDim2.new(0, 100, 0, 35)
	copyButton.Position = UDim2.new(1, -115, 0, 55)
	copyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
	copyButton.BorderSizePixel = 0
	copyButton.Text = "📋 COPIAR"
	copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	copyButton.TextSize = 12
	copyButton.Font = Enum.Font.GothamBold
	copyButton.Parent = cardFrame
	
	local copyCorner = Instance.new("UICorner")
	copyCorner.CornerRadius = UDim.new(0, 8)
	copyCorner.Parent = copyButton
	
	-- Efeito hover no botão
	copyButton.MouseEnter:Connect(function()
		local hoverTween = TweenService:Create(
			copyButton,
			TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{BackgroundColor3 = Color3.fromRGB(70, 170, 255)}
		)
		hoverTween:Play()
	end)
	
	copyButton.MouseLeave:Connect(function()
		local leaveTween = TweenService:Create(
			copyButton,
			TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{BackgroundColor3 = Color3.fromRGB(50, 150, 255)}
		)
		leaveTween:Play()
	end)
	
	-- Função de copiar
	copyButton.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(tostring(musicData.ID_Musica))
			copyButton.Text = "✅ COPIADO"
			copyButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
			
			wait(1.5)
			copyButton.Text = "📋 COPIAR"
			copyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
		else
			copyButton.Text = "❌ N/A"
			copyButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
			
			wait(1.5)
			copyButton.Text = "📋 COPIAR"
			copyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
		end
	end)
	
	-- Data (simulada - você pode adicionar timestamp real na API)
	local dateLabel = Instance.new("TextLabel")
	dateLabel.Name = "DateLabel"
	dateLabel.Size = UDim2.new(0, 120, 0, 15)
	dateLabel.Position = UDim2.new(1, -250, 0, 50)
	dateLabel.BackgroundTransparency = 1
	dateLabel.Text = "📅 " .. os.date("%d/%m/%Y")
	dateLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
	dateLabel.TextSize = 11
	dateLabel.Font = Enum.Font.Gotham
	dateLabel.Parent = cardFrame
	
	return cardFrame
end
-- 📋 FUNÇÃO PARA VER LISTA DE MÚSICAS NA MESMA GUI
local function viewMusicList(feedbackLabel, musicListFrame, musicListScroll, mainScrollFrame)
	feedbackLabel.Text = "🔄 Carregando lista de músicas..."
	feedbackLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
	
	local success, response = pcall(function()
		return request({
			Url = API_URL,
			Method = "GET"
		})
	end)
	
	if success and response and response.Body then
		local ok, dados = pcall(function()
			return HttpService:JSONDecode(response.Body)
		end)
		
		if ok and dados then
			-- Limpar lista anterior
			for _, child in pairs(musicListScroll:GetChildren()) do
				if child.Name == "MusicCard" then
					child:Destroy()
				end
			end
			
			-- Calcular altura total necessária
			local totalHeight = #dados * 110 + 20
			musicListScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
			
			-- Criar cards para cada música
			for i, musicData in ipairs(dados) do
				local yPos = (i - 1) * 110 + 10
				createMusicCard(musicListScroll, musicData, yPos)
			end
			
			-- Mostrar a lista
			showMusicListInGUI(musicListFrame, musicListScroll, mainScrollFrame)
			
			feedbackLabel.Text = "✅ Lista carregada! ("..#dados.." músicas)"
			feedbackLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			feedbackLabel.Text = "⚠️ Erro ao processar dados do servidor."
			feedbackLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
		end
	else
		feedbackLabel.Text = "❌ Erro ao buscar lista de músicas."
		feedbackLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end
-- 🔗 FUNÇÃO PARA CRIAR BOTÃO FLUTUANTE
local function createFloatingButton()
	local floatingGui = Instance.new("ScreenGui")
	floatingGui.Name = "FloatingMusicButton"
	floatingGui.Parent = player:WaitForChild("PlayerGui")
	floatingGui.ResetOnSpawn = false
	
	local floatingButton = Instance.new("TextButton")
	floatingButton.Name = "FloatingButton"
	floatingButton.Size = UDim2.new(0, 60, 0, 60)
	floatingButton.Position = UDim2.new(0, 20, 0.5, -30)
	floatingButton.BackgroundColor3 = RGB_COLORS[1]
	floatingButton.BorderSizePixel = 0
	floatingButton.Text = "🎵"
	floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	floatingButton.TextSize = 24
	floatingButton.Font = Enum.Font.GothamBold
	floatingButton.Parent = floatingGui
	
	local floatingCorner = Instance.new("UICorner")
	floatingCorner.CornerRadius = UDim.new(1, 0)
	floatingCorner.Parent = floatingButton
	
	-- Animar cores do botão flutuante
	spawn(function()
		local colorIndex = 1
		while floatingButton.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			local tween = TweenService:Create(
				floatingButton,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{BackgroundColor3 = RGB_COLORS[colorIndex]}
			)
			tween:Play()
			wait(2)
		end
	end)
	
	return floatingGui, floatingButton
end
-- 🏁 FUNÇÃO PRINCIPAL
local function main()
	-- Criar interface principal
	local gui, mainFrame, borderFrame, scrollFrame, closeButton, musicListFrame, musicListScroll, backButton = createMainGUI()
	
	-- Criar botão flutuante
	local floatingGui, floatingButton = createFloatingButton()
	
	-- Animar borda RGB
	animateRGBBorder(borderFrame)
	
	-- Criar elementos dentro do ScrollFrame
	local titleFrame = createTitle(scrollFrame)
	local nameBox = createInputField(scrollFrame, "Nome da Música", 120, 20)
	local idBox = createInputField(scrollFrame, "ID da Música (apenas números)", 190, 50)
	local getCategoryFunc = createCategoryDropdown(scrollFrame, 260)
	local userPreview = createUserPreview(scrollFrame, 330)
	local feedbackLabel = createFeedback(scrollFrame, 430)
	
	-- Filtrar apenas números no campo ID
	idBox:GetPropertyChangedSignal("Text"):Connect(function()
		local filteredText = string.gsub(idBox.Text, "[^%d]", "")
		if filteredText ~= idBox.Text then
			idBox.Text = filteredText
		end
	end)
	
	-- Criar botões
	local publishButton = createStyledButton(
		scrollFrame, 
		"📤 PUBLICAR MÚSICA", 
		480, 
		Color3.fromRGB(255, 50, 120),
		function()
			publishMusic(nameBox, idBox, getCategoryFunc, feedbackLabel)
		end
	)
	
	local listButton = createStyledButton(
		scrollFrame, 
		"📋 VER MÚSICAS", 
		540, 
		Color3.fromRGB(50, 120, 255),
		function()
			viewMusicList(feedbackLabel, musicListFrame, musicListScroll, scrollFrame)
		end
	)
	
	-- Configurar botões de controle
	closeButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		floatingButton.Visible = true
	end)
	
	floatingButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = true
		floatingButton.Visible = false
		showMainContent(musicListFrame, scrollFrame)
	end)
	
	backButton.MouseButton1Click:Connect(function()
		showMainContent(musicListFrame, scrollFrame)
	end)
	
	-- Efeito de entrada animado
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	local entranceTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 500, 0, 600)}
	)
	entranceTween:Play()
	
	-- Inicialmente esconder botão flutuante
	floatingButton.Visible = false
	
	print("🎉 Enhanced Music ID Publisher v2.3 carregado com sucesso!")
	print("✨ Interface unificada com efeitos RGB ativada!")
	print("🔘 Use o botão flutuante para abrir/fechar a GUI!")
end
-- 🚀 EXECUTAR SCRIPT
main()