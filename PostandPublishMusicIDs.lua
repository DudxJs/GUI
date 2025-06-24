-- SERVIÇOS
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- LINK DO GOOGLE SCRIPT (substitua abaixo)
local ENDPOINT = "https://script.google.com/macros/s/AKfycbzLHH1OxdnQ4cOEtvveuCPlVoAkb9D8TfcC7KXk39E9P2mOEC1ZjUcpMo3TSmBxt1DM/exec"

-- CATEGORIAS DISPONÍVEIS
local CATEGORIAS = {"Funk", "Forró/Piseiro", "Phonk", "Sad", "Eletrônica"}
local categoriaSelecionada = CATEGORIAS[1]

-- GUI PRINCIPAL
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "MusicasGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 450, 0, 550)
frame.Position = UDim2.new(0.5, -225, 0.5, -275)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0

local nomeBox = Instance.new("TextBox", frame)
nomeBox.PlaceholderText = "Nome da música"
nomeBox.Size = UDim2.new(1, -20, 0, 30)
nomeBox.Position = UDim2.new(0, 10, 0, 10)
nomeBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
nomeBox.TextColor3 = Color3.new(1, 1, 1)

local idBox = Instance.new("TextBox", frame)
idBox.PlaceholderText = "ID da música"
idBox.Size = UDim2.new(1, -20, 0, 30)
idBox.Position = UDim2.new(0, 10, 0, 50)
idBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
idBox.TextColor3 = Color3.new(1, 1, 1)

local mensagemLabel = Instance.new("TextLabel", frame)
mensagemLabel.Text = ""
mensagemLabel.Size = UDim2.new(1, -20, 0, 20)
mensagemLabel.Position = UDim2.new(0, 10, 0, 90)
mensagemLabel.BackgroundTransparency = 1
mensagemLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
mensagemLabel.TextScaled = true
mensagemLabel.Font = Enum.Font.SourceSansBold

local dropdown = Instance.new("TextButton", frame)
dropdown.Text = "Categoria: " .. categoriaSelecionada
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 120)
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.new(1, 1, 1)

local dropdownList = Instance.new("Frame", frame)
dropdownList.Size = UDim2.new(1, -20, 0, 150)
dropdownList.Position = UDim2.new(0, 10, 0, 150)
dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropdownList.Visible = false

local layout = Instance.new("UIListLayout", dropdownList)
layout.SortOrder = Enum.SortOrder.LayoutOrder

for _, categoria in ipairs(CATEGORIAS) do
	local opcao = Instance.new("TextButton", dropdownList)
	opcao.Text = categoria
	opcao.Size = UDim2.new(1, 0, 0, 25)
	opcao.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	opcao.TextColor3 = Color3.new(1, 1, 1)
	opcao.MouseButton1Click:Connect(function()
		categoriaSelecionada = categoria
		dropdown.Text = "Categoria: " .. categoria
		dropdownList.Visible = false
	end)
end

dropdown.MouseButton1Click:Connect(function()
	dropdownList.Visible = not dropdownList.Visible
end)

local enviarBtn = Instance.new("TextButton", frame)
enviarBtn.Text = "Publicar"
enviarBtn.Size = UDim2.new(1, -20, 0, 30)
enviarBtn.Position = UDim2.new(0, 10, 0, 310)
enviarBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
enviarBtn.TextColor3 = Color3.new(1, 1, 1)

local function verificarIdValido(id)
	return tonumber(id) ~= nil
end

enviarBtn.MouseButton1Click:Connect(function()
	local nome = nomeBox.Text
	local id = idBox.Text:gsub("%s+", "")

	if nome == "" or id == "" then
		mensagemLabel.Text = "Preencha todos os campos"
		return
	end

	if not verificarIdValido(id) then
		mensagemLabel.Text = "ID inválido (apenas números)"
		return
	end

	mensagemLabel.Text = "Enviando..."

	local dados = {
		Nome = nome,
		MusicId = id,
		Categoria = categoriaSelecionada,
		Username = player.Name,
		DisplayName = player.DisplayName,
		UserId = tostring(player.UserId),
		DataPostagem = os.date("%d/%m/%Y %H:%M:%S")
	}

	local json = HttpService:JSONEncode(dados)

	local sucesso, resposta = pcall(function()
		return http_request({
			Url = ENDPOINT,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = json
		})
	end)

	if sucesso and resposta and resposta.Success then
		local body = resposta.Body or ""
		if string.find(body, "duplicado") then
			mensagemLabel.Text = "Esse ID já foi publicado."
		elseif string.find(body, "sucesso") then
			mensagemLabel.Text = "Publicado com sucesso!"
		else
			mensagemLabel.Text = "Erro: resposta desconhecida"
		end
	else
		mensagemLabel.Text = "Erro ao conectar ao site"
	end
end)

mensagemLabel.Text = ""
