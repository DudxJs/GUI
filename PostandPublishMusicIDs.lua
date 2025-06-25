-- SERVIÇOS
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- LINK DO GOOGLE SCRIPT
local ENDPOINT = "https://script.google.com/macros/s/AKfycby7WodcKOViego3O3P2Zld8yb_gaEZiVnb4U8vqAojvFzwtYHPplvcQWwdYNkjhq8Lj/exec"

-- CATEGORIAS DISPONÍVEIS
local CATEGORIAS = {"Funk", "Forró/Piseiro", "Phonk", "Sad", "Eletrônica"}
local categoriaSelecionada = CATEGORIAS[1]

-- GUI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "MusicasGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 450, 0, 600)
frame.Position = UDim2.new(0.5, -225, 0.5, -300)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0

local nomeBox = Instance.new("TextBox", frame)
nomeBox.PlaceholderText = "Nome da música"
nomeBox.Size = UDim2.new(1, -20, 0, 30)
nomeBox.Position = UDim2.new(0, 10, 0, 10)
nomeBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
nomeBox.TextColor3 = Color3.new(1, 1, 1)
nomeBox.Font = Enum.Font.SourceSans
nomeBox.TextSize = 18

local idBox = Instance.new("TextBox", frame)
idBox.PlaceholderText = "ID da música"
idBox.Size = UDim2.new(1, -20, 0, 30)
idBox.Position = UDim2.new(0, 10, 0, 50)
idBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
idBox.TextColor3 = Color3.new(1, 1, 1)
idBox.Font = Enum.Font.SourceSans
idBox.TextSize = 18

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
dropdown.Font = Enum.Font.SourceSans

local dropdownList = Instance.new("Frame", frame)
dropdownList.Size = UDim2.new(1, -20, 0, #CATEGORIAS * 25)
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
	opcao.Font = Enum.Font.SourceSans
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
enviarBtn.Position = UDim2.new(0, 10, 0, 160 + #CATEGORIAS * 25)
enviarBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
enviarBtn.TextColor3 = Color3.new(1, 1, 1)
enviarBtn.Font = Enum.Font.SourceSans

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 0, 260)
scroll.Position = UDim2.new(0, 10, 0, 200 + #CATEGORIAS * 25)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function atualizarLista()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local sucesso, resposta = pcall(function()
		return HttpService:GetAsync(ENDPOINT)
	end)

	if sucesso and resposta then
		local dados = HttpService:JSONDecode(resposta)
		for _, item in ipairs(dados) do
			local card = Instance.new("Frame")
			card.Size = UDim2.new(1, 0, 0, 100)
			card.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			card.BorderSizePixel = 0
			card.Parent = scroll

			local titulo = Instance.new("TextLabel", card)
			titulo.Text = item.Nome .. "  [" .. item.Categoria .. "]"
			titulo.Font = Enum.Font.SourceSansBold
			titulo.TextSize = 18
			titulo.TextColor3 = Color3.new(1, 1, 1)
			titulo.Size = UDim2.new(1, -10, 0, 20)
			titulo.Position = UDim2.new(0, 5, 0, 5)
			titulo.BackgroundTransparency = 1

			local autor = Instance.new("TextLabel", card)
			autor.Text = "De " .. item.DisplayName .. " (" .. item.Username .. ") - " .. item.DataPostagem
			autor.Font = Enum.Font.SourceSans
			autor.TextSize = 16
			autor.TextColor3 = Color3.fromRGB(200, 200, 200)
			autor.Size = UDim2.new(1, -10, 0, 20)
			autor.Position = UDim2.new(0, 5, 0, 30)
			autor.BackgroundTransparency = 1

			local idTexto = Instance.new("TextLabel", card)
			idTexto.Text = "ID: " .. item.MusicId
			idTexto.Font = Enum.Font.SourceSans
			idTexto.TextSize = 16
			idTexto.TextColor3 = Color3.fromRGB(220, 220, 220)
			idTexto.Size = UDim2.new(1, -70, 0, 20)
			idTexto.Position = UDim2.new(0, 5, 0, 60)
			idTexto.BackgroundTransparency = 1

			local copiar = Instance.new("TextButton", card)
			copiar.Text = "Copiar"
			copiar.Font = Enum.Font.SourceSans
			copiar.TextSize = 16
			copiar.Size = UDim2.new(0, 60, 0, 20)
			copiar.Position = UDim2.new(1, -65, 0, 60)
			copiar.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
			copiar.TextColor3 = Color3.new(1, 1, 1)
			copiar.MouseButton1Click:Connect(function()
				setclipboard(item.MusicId)
			end)
		end
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	else
		warn("Falha ao obter dados da planilha")
	end
end

local recarregarBtn = Instance.new("TextButton", frame)
recarregarBtn.Text = "Recarregar Lista"
recarregarBtn.Size = UDim2.new(1, -20, 0, 30)
recarregarBtn.Position = UDim2.new(0, 10, 1, -40)
recarregarBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
recarregarBtn.TextColor3 = Color3.new(1, 1, 1)
recarregarBtn.Font = Enum.Font.SourceSans
recarregarBtn.MouseButton1Click:Connect(atualizarLista)

enviarBtn.MouseButton1Click:Connect(function()
	local nome = nomeBox.Text
	local id = idBox.Text:gsub("%s+", "")

	if nome == "" or id == "" then
		mensagemLabel.Text = "Preencha todos os campos"
		return
	end

	if not tonumber(id) then
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

	if sucesso and resposta then
		local body = typeof(resposta) == "table" and resposta.Body or resposta
		if typeof(body) == "table" then
			body = body.Body or ""
		end
		if string.find(body, "duplicado") then
			mensagemLabel.Text = "Esse ID já foi publicado."
		elseif string.find(body, "sucesso") then
			mensagemLabel.Text = "Publicado com sucesso!"
			atualizarLista()
		else
			mensagemLabel.Text = "Erro: resposta desconhecida"
		end
	else
		mensagemLabel.Text = "Erro ao conectar ao site"
	end
end)

frame:AddChild(dropdownList)
atualizarLista()
