-- ✅ GUI POSTAGEM DE MÚSICAS 100% FUNCIONAL VIA HTTP_REQUEST (DELTA EXECUTOR COMPATÍVEL)
-- Copie e cole diretamente no Delta Executor

local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local request = (http_request or http_get or syn and syn.request)

if not request then
	warn("❌ Seu executor não suporta http_request.")
	return
end

local url = "https://script.google.com/macros/s/AKfycbwWj5H1HmWcXR9OCPQJAKQC-K5QPwulGUJ_4o5N2xKB5GB8aAB20Z0xAVqhrbKvcHB1Ow/exec"

-- 🧱 INTERFACE
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PostarMusica"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 290)
frame.Position = UDim2.new(0.5, -200, 0.5, -145)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local function criarTexto(nome, posY)
	local box = Instance.new("TextBox", frame)
	box.PlaceholderText = nome
	box.Size = UDim2.new(1, -20, 0, 30)
	box.Position = UDim2.new(0, 10, 0, posY)
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	return box
end

local nomeBox = criarTexto("Nome da Música (max 20)", 10)
local idBox = criarTexto("ID da Música (só números, máx 50)", 50)
local catBox = criarTexto("Categoria (Funk, Phonk...)", 90)

local feedback = Instance.new("TextLabel", frame)
feedback.Position = UDim2.new(0, 10, 0, 130)
feedback.Size = UDim2.new(1, -20, 0, 20)
feedback.BackgroundTransparency = 1
feedback.TextColor3 = Color3.fromRGB(200, 200, 200)
feedback.Font = Enum.Font.Gotham
feedback.TextSize = 14
feedback.Text = ""

local pubBtn = Instance.new("TextButton", frame)
pubBtn.Text = "📤 Publicar"
pubBtn.Size = UDim2.new(1, -20, 0, 35)
pubBtn.Position = UDim2.new(0, 10, 0, 160)
pubBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
pubBtn.TextColor3 = Color3.new(1,1,1)
pubBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", pubBtn).CornerRadius = UDim.new(0, 6)

local verBtn = Instance.new("TextButton", frame)
verBtn.Text = "📋 Ver IDs Publicados (console)"
verBtn.Size = UDim2.new(1, -20, 0, 30)
verBtn.Position = UDim2.new(0, 10, 0, 205)
verBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
verBtn.TextColor3 = Color3.new(1,1,1)
verBtn.Font = Enum.Font.Gotham
Instance.new("UICorner", verBtn).CornerRadius = UDim.new(0, 6)

-- 📨 PUBLICAR
pubBtn.MouseButton1Click:Connect(function()
	local nome = nomeBox.Text
	local id = idBox.Text
	local cat = catBox.Text

	if nome == "" or id == "" or cat == "" then
		feedback.Text = "⚠️ Preencha todos os campos."
		return
	end
	if #id > 50 or not tonumber(id) then
		feedback.Text = "⚠️ ID inválido."
		return
	end
	if #nome > 20 then
		feedback.Text = "⚠️ Nome muito longo."
		return
	end

	local dados = {
		ID_Musica = id,
		Nome = nome,
		Categoria = cat,
		PlayerName = player.Name,
		DisplayName = player.DisplayName,
		UserId = player.UserId,
		Foto = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
	}

	local body = HttpService:JSONEncode(dados)
	local success, response = pcall(function()
		return request({
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = body
		})
	end)

	if success and response and response.Body then
		if response.Body:find("Erro") then
			feedback.Text = "⚠️ "..response.Body
		else
			feedback.Text = "✅ Publicado com sucesso!"
		end
	else
		feedback.Text = "❌ Falha na publicação."
	end
end)

-- 📥 VER LISTA
verBtn.MouseButton1Click:Connect(function()
	feedback.Text = "🔄 Carregando IDs..."
	local success, response = pcall(function()
		return request({
			Url = url,
			Method = "GET"
		})
	end)

	if success and response and response.Body then
		local dados = HttpService:JSONDecode(response.Body)
		print("🟢 IDs Publicados:")
		for _, post in ipairs(dados) do
			print("🎵 "..post.Nome.." | ID: "..post.ID_Musica.." | 👤 "..post.DisplayName.." | 📂 "..post.Categoria)
		end
		feedback.Text = "✅ IDs carregados no console."
	else
		feedback.Text = "❌ Erro ao buscar IDs."
	end
end)

-- Fim do Script