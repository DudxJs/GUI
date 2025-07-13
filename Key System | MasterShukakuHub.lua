local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 🔗 SEUS LINKS
local SCRIPT_API = "https://script.google.com/macros/s/AKfycbygnV5poqrdJlh-jnGszxxyiF2le11dARkZDsughPBL71tCishEpGHZTucDPWwFbd9ekA/exec"
local REDIRECIONADOR_BASE = "https://dudxjs.github.io/redirecionador.html?token="

-- 🔧 Função para pegar o IP do jogador
local function getIP()
	local success, result = pcall(function()
		return game:HttpGet("https://api.ipify.org")
	end)
	if success then
		return result
	else
		warn("Não foi possível obter o IP.")
		return nil
	end
end

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "KeySystem"

local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Text = "🔑 Sistema de Key"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local getKeyBtn = Instance.new("TextButton", frame)
getKeyBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
getKeyBtn.Size = UDim2.new(0.8, 0, 0, 35)
getKeyBtn.Text = "🚀 Obter Key"
getKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
getKeyBtn.TextColor3 = Color3.new(1, 1, 1)
getKeyBtn.Font = Enum.Font.SourceSansBold
getKeyBtn.TextSize = 18

local input = Instance.new("TextBox", frame)
input.PlaceholderText = "Digite sua key aqui..."
input.Position = UDim2.new(0.1, 0, 0.55, 0)
input.Size = UDim2.new(0.8, 0, 0, 35)
input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
input.TextColor3 = Color3.new(1, 1, 1)
input.Font = Enum.Font.SourceSans
input.TextSize = 16

local validarBtn = Instance.new("TextButton", frame)
validarBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
validarBtn.Size = UDim2.new(0.8, 0, 0, 30)
validarBtn.Text = "✅ Validar Key"
validarBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
validarBtn.TextColor3 = Color3.new(1, 1, 1)
validarBtn.Font = Enum.Font.SourceSansBold
validarBtn.TextSize = 16

local aviso = Instance.new("TextLabel", frame)
aviso.Position = UDim2.new(0, 0, 1, 0)
aviso.Size = UDim2.new(1, 0, 0, 30)
aviso.BackgroundTransparency = 1
aviso.TextColor3 = Color3.new(1, 1, 1)
aviso.Font = Enum.Font.SourceSansItalic
aviso.TextSize = 14
aviso.Text = ""

-- 🛠️ Ações dos botões

getKeyBtn.MouseButton1Click:Connect(function()
	local ip = getIP()
	if not ip then
		aviso.Text = "❌ Erro ao obter IP."
		return
	end

	local response = http_request({
		Url = SCRIPT_API,
		Method = "POST",
		Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
		Body = "ip=" .. ip
	})

	local tokenTemp = response.Body
	if not tokenTemp or tokenTemp == "" then
		aviso.Text = "❌ Erro ao gerar token."
		return
	end

	-- Monta o link do redirecionador com token
	local redirLink = REDIRECIONADOR_BASE .. tokenTemp
	local encodedLink = HttpService:UrlEncode(redirLink)

	-- Monta o Linkvertise (exemplo usando link-hub.net)
	local linkvertise = "https://direct-link.net/1365094/xLN5EoHIKeJz?o=" .. encodedLink

	setclipboard(linkvertise)
	aviso.Text = "✅ Link copiado! Acesse via navegador."
end)

validarBtn.MouseButton1Click:Connect(function()
	local ip = getIP()
	if not ip then
		aviso.Text = "❌ Erro ao obter IP."
		return
	end

	local keyDigitada = input.Text

	local urlValidar = SCRIPT_API .. "?tokenKey=" .. keyDigitada .. "&ip=" .. ip

	local resposta = http_request({
		Url = urlValidar,
		Method = "GET"
	})

	if resposta.Body == "true" then
		aviso.Text = "✅ Key válida! Acesso liberado."
		-- Aqui você pode liberar o script do jogo:
		print("SCRIPT LIBERADO!")
	else
		aviso.Text = "❌ Key inválida ou expirada."
	end
end)
