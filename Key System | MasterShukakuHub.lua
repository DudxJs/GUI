
local service = 4700 --Set your Platoboost Id 
local secret = "c05d9ff2-c2cb-4080-bbe4-8499e318f1d0" --Set Your Platoboost Api key
local useNonce = true; 
local onMessage = function(message)  game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", { Text = message; }) end;


repeat task.wait(1) until game:IsLoaded() or game.Players.LocalPlayer;


local requestSending = false;
local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor, fGetHwid = setclipboard or toclipboard, request or http_request, string.char, tostring, string.sub, os.time, math.random, math.floor, gethwid or function() return game:GetService("Players").LocalPlayer.UserId end
local cachedLink, cachedTime = "", 0;
local HttpService = game:GetService("HttpService")

function lEncode(data)
    return HttpService:JSONEncode(data)
end
function lDecode(data)
    return HttpService:JSONDecode(data)
end
local function lDigest(input)
    local inputStr = tostring(input)
    
    
    local hash = {}
    for i = 1, #inputStr do
        table.insert(hash, string.byte(inputStr, i))
    end

    local hashHex = ""
    for _, byte in ipairs(hash) do
        hashHex = hashHex .. string.format("%02x", byte)
    end
    
    return hashHex
end
local host = "https://api.platoboost.com";
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
});
if hostResponse.StatusCode ~= 200 or hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net";
end

function cacheLink()
    if cachedTime + (10*60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({
                service = service,
                identifier = lDigest(fGetHwid())
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        });

        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body);

            if decoded.success == true then
                cachedLink = decoded.data.url;
                cachedTime = fOsTime();
                return true, cachedLink;
            else
                onMessage(decoded.message);
                return false, decoded.message;
            end
        elseif response.StatusCode == 429 then
            local msg = "you are being rate limited, please wait 20 seconds and try again.";
            onMessage(msg);
            return false, msg;
        end

        local msg = "Failed to cache link.";
        onMessage(msg);
        return false, msg;
    else
        return true, cachedLink;
    end
end



cacheLink();

local generateNonce = function()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end


for _ = 1, 5 do
    local oNonce = generateNonce();
    task.wait(0.2)
    if generateNonce() == oNonce then
        local msg = "platoboost nonce error.";
        onMessage(msg);
        error(msg);
    end
end

local copyLink = function()
    local success, link = cacheLink();
    
    if success then
        print("SetClipBoard")
        fSetClipboard(link);
    end
end

local redeemKey = function(key)
    local nonce = generateNonce();
    local endpoint = host .. "/public/redeem/" .. fToString(service);

    local body = {
        identifier = lDigest(fGetHwid()),
        key = key
    }

    if useNonce then
        body.nonce = nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = {
            ["Content-Type"] = "application/json"
        }
    });

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);
        if decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                        return true;
                    else
                        onMessage("failed to verify integrity.");
                        return false;
                    end    
                else
                    return true;
                end
            else
                onMessage("key is invalid.");
                return false;
            end
        else
            if fStringSub(decoded.message, 1, 27) == "unique constraint violation" then
                onMessage("you already have an active key, please wait for it to expire before redeeming it.");
                return false;
            else
                onMessage(decoded.message);
                return false;
            end
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false; 
    end
end


local verifyKey = function(key)
    if requestSending == true then
        onMessage("a request is already being sent, please slow down.");
        return false;
    else
        requestSending = true;
    end

    local nonce = generateNonce();
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key;

    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce;
    end
    local response = fRequest({
        Url = endpoint,
        Method = "GET",
    });

    requestSending = false;

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);
        if decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    return true;
                else
                    return true;
                end
            else
                if fStringSub(key, 1, 4) == "FREE_" then
                    return redeemKey(key);
                else
                    onMessage("key is invalid.");
                    return false;
                end
            end
        else
            onMessage(decoded.message);
            return false;
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false;
    end
end


local getFlag = function(name)
    local nonce = generateNonce();
    local endpoint = host .. "/public/flag/" .. fToString(service) .. "?name=" .. name;

    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "GET",
    });

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);
        if decoded.success == true then
            if useNonce then
                if decoded.data.hash == lDigest(fToString(decoded.data.value) .. "-" .. nonce .. "-" .. secret) then
                    return decoded.data.value;
                else
                    onMessage("failed to verify integrity.");
                    return nil;
                end
            else
                return decoded.data.value;
            end
        else
            onMessage(decoded.message);
            return nil;
        end
    else
        return nil;
    end
end

-- 🔐 Sistema de salvamento da Key
local HttpService = game:GetService("HttpService")
local keyFolder = "MasterShukakuHubKey"
local keyFile = keyFolder.."/key.json"

local function salvarKey(key)
	if not isfolder(keyFolder) then
		makefolder(keyFolder)
	end
	writefile(keyFile, HttpService:JSONEncode({ key = key }))
end

local function carregarKey()
	if isfile(keyFile) then
		local conteudo = readfile(keyFile)
		local ok, data = pcall(function()
			return HttpService:JSONDecode(conteudo)
		end)
		if ok and data and data.key then
			return data.key
		end
	end
	return nil
end

-- ⏳ Tenta usar a Key salva automaticamente
local keySalva = carregarKey()
if keySalva then
	local valido = verifyKey(keySalva)
	if valido then
    _G.KeyOk = true
     task.wait()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/DudxJs/Dudx_jsHub/refs/heads/main/MasterShukakuHub_Protected"))()
		return -- Sai do script, já está liberado
	end
end

-- 📦 GUI
task.spawn(function()
	local TweenService = game:GetService("TweenService")

	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")
	local Exit = Instance.new("TextButton")
	local Title = Instance.new("TextLabel")
	local Getkey = Instance.new("TextButton")
	local Checkkey = Instance.new("TextButton")
	local GetkeyCorner = Instance.new("UICorner")
	local CheckkeyCorner = Instance.new("UICorner")
	local TextBox = Instance.new("TextBox")
	local TextBoxCorner = Instance.new("UICorner")
	local TextLabel = Instance.new("TextLabel")

	ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Name = "KeySystemGui"

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
	Frame.Size = UDim2.new(0, 360, 0, 230)
	Frame.ClipsDescendants = true
	Frame.Active = true
	Frame.Draggable = true

	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = Frame

	UIStroke.Parent = Frame
	UIStroke.Color = Color3.fromRGB(255, 0, 0)
	UIStroke.Thickness = 2

	Exit.Name = "Exit"
	Exit.Parent = Frame
	Exit.BackgroundTransparency = 1
	Exit.Position = UDim2.new(0.93, 0, 0.025, 0)
	Exit.Size = UDim2.new(0, 25, 0, 20)
	Exit.Font = Enum.Font.GothamSemibold
	Exit.Text = "X"
	Exit.TextColor3 = Color3.fromRGB(255, 0, 0)
	Exit.TextScaled = true
	Exit.ZIndex = 2

	Title.Name = "Title"
	Title.Parent = Frame
	Title.Text = "KEY SYSTEM"
	Title.Position = UDim2.new(0, 0, 0, 0)
	Title.Size = UDim2.new(1, 0, 0, 30)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Color3.fromRGB(255, 0, 0)
	Title.Font = Enum.Font.GothamSemibold
	Title.TextScaled = true
	Title.ZIndex = 1

	Getkey.Name = "Getkey"
	Getkey.Parent = Frame
	Getkey.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Getkey.Position = UDim2.new(0.31, 0, 0.5, 0)
	Getkey.Size = UDim2.new(0, 130, 0, 32)
	Getkey.Font = Enum.Font.GothamSemibold
	Getkey.Text = "GET KEY"
	Getkey.TextColor3 = Color3.fromRGB(255, 0, 0)
	Getkey.TextScaled = true

	GetkeyCorner.CornerRadius = UDim.new(0, 8)
	GetkeyCorner.Parent = Getkey

	Checkkey.Name = "Checkkey"
	Checkkey.Parent = Frame
	Checkkey.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Checkkey.Position = UDim2.new(0.31, 0, 0.75, 0)
	Checkkey.Size = UDim2.new(0, 130, 0, 32)
	Checkkey.Font = Enum.Font.GothamSemibold
	Checkkey.Text = "CHECK KEY"
	Checkkey.TextColor3 = Color3.fromRGB(255, 0, 0)
	Checkkey.TextScaled = true

	CheckkeyCorner.CornerRadius = UDim.new(0, 8)
	CheckkeyCorner.Parent = Checkkey

	TextBox.Parent = Frame
	TextBox.Text = ""
	TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.Position = UDim2.new(0.08, 0, 0.17, 0)
	TextBox.Size = UDim2.new(0, 305, 0, 40)
	TextBox.Font = Enum.Font.GothamSemibold
	TextBox.PlaceholderText = "Digite sua Key"
	TextBox.TextScaled = true

	TextBoxCorner.CornerRadius = UDim.new(0, 6)
	TextBoxCorner.Parent = TextBox

	TextLabel.Parent = Frame
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0.08, 0, 0.17, 0)
	TextLabel.Size = UDim2.new(0, 305, 0, 40)
	TextLabel.Font = Enum.Font.GothamSemibold
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextTransparency = 0.5
	TextLabel.TextScaled = true
	TextLabel.Text = "Digite sua Key"
	TextLabel.ZIndex = 2

	-- Hover animado
	local function animateButton(button)
		local original = button.BackgroundColor3
		local hover = Color3.fromRGB(60, 0, 0)
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.3), { BackgroundColor3 = hover }):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.3), { BackgroundColor3 = original }):Play()
		end)
	end

	animateButton(Getkey)
	animateButton(Checkkey)
	animateButton(Exit)

	-- Animação de entrada
	Frame.Position = UDim2.new(0.3, 0, 1.2, 0)
	TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.3, 0, 0.3, 0)
	}):Play()

	-- Texto fantasma no TextBox
	TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if TextBox.Text == "" then
			TextLabel.Text = "Digite sua Key"
		else
			TextLabel.Text = TextBox.Text
		end
	end)

	-- CHECK KEY
	Checkkey.MouseButton1Down:Connect(function()
		if TextBox and TextBox.Text and TextBox.Text ~= "" then
			local chave = TextBox.Text
			local Verify = verifyKey(chave)
			if Verify then
				salvarKey(chave)
            _G.KeyOk = true
				loadstring(game:HttpGet("https://raw.githubusercontent.com/DudxJs/Dudx_jsHub/refs/heads/main/MasterShukakuHub_Protected"))()
			else
				onMessage("Key inválida.")
			end
		end
	end)

	-- GET KEY
	Getkey.MouseButton1Down:Connect(function()
		copyLink()
	end)

	-- FECHAR
	Exit.MouseButton1Down:Connect(function()
		TweenService:Create(Frame, TweenInfo.new(0.3), {
			Position = UDim2.new(0.3, 0, 1.2, 0)
		}):Play()
		task.wait(0.35)
		ScreenGui:Destroy()
	end)
end)