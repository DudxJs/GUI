local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local LINKVERTISE = "https://link-target.net/1365094/MXTCaMBiYdlX"
local REDIRECIONADOR_BASE = "https://dudxjs.github.io/rv-redirector/redirecionador.html?token="
local URL_VALIDAR_KEY = "https://script.google.com/macros/s/AKfycbygnV5poqrdJlh-jnGszxxyiF2le11dARkZDsughPBL71tCishEpGHZTucDPWwFbd9ekA/exec"

-- Interface
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "KeySystem"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🔐 Sistema de Key"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BorderSizePixel = 0
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local keyInput = Instance.new("TextBox", frame)
keyInput.PlaceholderText = "Digite sua key aqui"
keyInput.Size = UDim2.new(1, -20, 0, 30)
keyInput.Position = UDim2.new(0, 10, 0, 50)
keyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.BorderSizePixel = 0
keyInput.Font = Enum.Font.SourceSans
keyInput.TextSize = 16

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 90)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 16
statusLabel.TextWrapped = true

local getKeyButton = Instance.new("TextButton", frame)
getKeyButton.Text = "📥 Pegar Key"
getKeyButton.Size = UDim2.new(0.5, -15, 0, 35)
getKeyButton.Position = UDim2.new(0, 10, 1, -45)
getKeyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
getKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyButton.Font = Enum.Font.SourceSansBold
getKeyButton.TextSize = 16

local validarButton = Instance.new("TextButton", frame)
validarButton.Text = "✅ Validar Key"
validarButton.Size = UDim2.new(0.5, -15, 0, 35)
validarButton.Position = UDim2.new(0.5, 5, 1, -45)
validarButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
validarButton.TextColor3 = Color3.fromRGB(255, 255, 255)
validarButton.Font = Enum.Font.SourceSansBold
validarButton.TextSize = 16

-- Funções
local function abrirLinkvertise()
	local token = tostring(math.random(100000, 999999)) .. tostring(math.random(1000, 9999))
	local url = REDIRECIONADOR_BASE .. token

	-- Registra o IP e token na planilha
	pcall(function()
		HttpService:GetAsync(URL_VALIDAR_KEY .. "?registrarToken=" .. token)
	end)

	-- Abre o Linkvertise (o redirecionador receberá o token)
	statusLabel.Text = "Redirecionando para o site..."
	task.wait(0.8)
	setclipboard(url)
	statusLabel.Text = "✅ Link copiado! Cole no navegador após passar pelo Linkvertise."
	task.spawn(function()
		game:GetService("StarterGui"):SetCore("OpenUrl", LINKVERTISE)
	end)
end

local function validarKey()
	local key = keyInput.Text
	if key == "" then
		statusLabel.Text = "❗ Digite a key antes de validar."
		return
	end

	statusLabel.Text = "🔄 Validando key..."

	local success, resposta = pcall(function()
		return HttpService:GetAsync(URL_VALIDAR_KEY .. "?validarKey=" .. key)
	end)

	if not success then
		statusLabel.Text = "❌ Erro ao conectar."
		return
	end

	local status
	pcall(function()
		status = HttpService:JSONDecode(resposta).status
	end)

	if status == "VALIDA" then
		statusLabel.Text = "✅ Key válida! Acesso liberado!"
		-- Libere o script aqui
	elseif status == "EXPIRADA" then
		statusLabel.Text = "⏰ Key expirada. Gere uma nova."
	elseif status == "INVALIDA" then
		statusLabel.Text = "❌ Key inválida para este dispositivo."
	else
		statusLabel.Text = "❌ Erro inesperado: " .. tostring(resposta)
	end
end

-- Eventos
getKeyButton.MouseButton1Click:Connect(abrirLinkvertise)
validarButton.MouseButton1Click:Connect(validarKey)
