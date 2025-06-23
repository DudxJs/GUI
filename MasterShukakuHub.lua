loadstring(game:HttpGet("https://pastebin.com/raw/d6B4BhyA", true))() -- Abertura

loadstring(game:HttpGet("https://raw.githubusercontent.com/DudxJs/GUI/main/GUI.lua"))()

local gui = _G.DudxJsGUI:New("MasterShukaku Hub", "rbxassetid://92433947031436")

-- ==================
--  ⬇️Tab Buttons⬇️
-- ==================

local House = gui:AddTab("House")
local Avatar = gui:AddTab("Avatar")
local Car = gui:AddTab("Car")
local Fun = gui:AddTab("Fun")
local Itens = gui:AddTab("Build")
local Others = gui:AddTab("Others")
local Teleportes = gui:AddTab("Teleportes")
local Misc = gui:AddTab("Misc")
local Kill = gui:AddTab("Kill")
local Tools = gui:AddTab("Tools")
local Premium = gui:AddTab("Premium")
local Map = gui:AddTab("Map")
local Visual = gui:AddTab("Visual")
local Scripts = gui:AddTab("Scripts")

-- ==================================
--  ⬇️ RP Nome/Bio Inicialização ⬇️
-- ==================================

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local RPNameColorRemote = ReplicatedStorage.RE["1RPNam1eColo1r"]
local RPBioColorRemote = ReplicatedStorage.RE["1RPNam1eColo1r"]
local RPNameTextRemote = ReplicatedStorage.RE["1RPNam1eTex1t"]
local RPBioTextRemote = ReplicatedStorage.RE["1RPNam1eTex1t"]

-- Altere os valores abaixo se quiser mudar nome, bio ou cores
local rpName = "M\210\137A\210\137S\210\137T\210\137E\210\137R\210\137  S\210\137H\210\137U\210\137K\210\137A\210\137K\210\137U\210\137"
local rpBio = "\227\128\178Script Feito Por: Dudx_js\227\128\134"

local rpNameColor = Color3.fromRGB(163, 2, 0)  -- Ajuste conforme desejado
local rpBioColor = Color3.fromRGB(0, 0, 0)     -- Ajuste conforme desejado

-- Define a cor do nome RP
RPNameColorRemote:FireServer("PickingRPNameColor", rpNameColor)

-- Define a cor da bio RP
RPBioColorRemote:FireServer("PickingRPBioColor", rpBioColor)

-- Define o texto do nome RP
RPNameTextRemote:FireServer("RolePlayName", rpName)

-- Define o texto da bio RP
RPBioTextRemote:FireServer("RolePlayBio", rpBio)

-- ====================
--  ⬇️House Buttons⬇️
-- ====================

House:AddLabel("House Bio")

House:AddInput("Bio Text", "", function(value)
args = {
        [1] = "BusinessName",
        [2] = value
    }
    game:GetService("ReplicatedStorage").RE["1RPHous1eEven1t"]:FireServer(unpack(args))
end)

local rainbowConnection
local running = false

House:AddSwitch("Rainbow House Bio", function(state)
    if state then
        running = true
        rainbowConnection = task.spawn(function()
            while running do
                local success, errorMessage = pcall(function()
                    local players = game:GetService("Players")
                    local replicatedStorage = game:GetService("ReplicatedStorage")
                    local localPlayer = players.LocalPlayer
                    local colorEvent = replicatedStorage:WaitForChild("RE"):WaitForChild("1RPHous1eEven1tColo1r")
                    local colorFrames = localPlayer.PlayerGui.MainGUIHandler.HouseControl.HomeBus.HomeText.Picks.Frame:GetChildren()
                    local numColors = #colorFrames
                    
                    for i = 1, numColors do
                        if not running then break end -- parada segura no meio do processo
                        local colorFrame = colorFrames[i]
                        if colorFrame and colorFrame:IsA("GuiObject") and colorFrame:FindFirstChild("Color") then
                             args = {
                                [1] = "PickingBusinessNameColor",
                                [2] = colorFrame.Color
                            }
                            colorEvent:FireServer(unpack(args))
                            task.wait(0.7)
                        end
                    end
                    
                    task.wait(1)
                end)

                if not success then
                    warn("Error in Rainbow House Bio loop:", errorMessage)
                    task.wait(5)
                end
            end
        end)
    else
        running = false
    end
end)

House:AddLabel("House Design")

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage.RE:FindFirstChild("1Player1sHous1e")
local runningRainbow = false

-- Duração da transição em segundos
local duration = 3 

-- Função para gerar uma cor aleatória suave (menos saturada)
local function getRandomColor()
    local r = math.random(50, 255) / 255
    local g = math.random(50, 255) / 255
    local b = math.random(50, 255) / 255
    return Color3.new(r, g, b)
end

-- Interpolação linear entre duas cores (lerp)
local function lerpColor(a, b, t)
    local r = a.R + (b.R - a.R) * t
    local g = a.G + (b.G - a.G) * t
    local b = a.B + (b.B - a.B) * t
    return Color3.new(r, g, b)
end

local function smoothColorTransition()
    local currentColor = getRandomColor()
    local targetColor = getRandomColor()

    while runningRainbow do
        local startTime = tick()
        while tick() - startTime < duration do
            if not runningRainbow then return end
            local elapsed = tick() - startTime
            local alpha = elapsed / duration
            local newColor = lerpColor(currentColor, targetColor, alpha)

            Remote:FireServer("ColorPickHouse", newColor)

            task.wait(0.1)
        end

        currentColor = targetColor
        targetColor = getRandomColor()
    end
end

-- Assumindo que House é um objeto que cria toggles na sua UI
House:AddSwitch("Rainbow House", function(state)
    runningRainbow = state
    if state then
        task.spawn(smoothColorTransition)
    end
end)

House:AddLabel("House Settings")

local SelectHouse
local SelectedPlayerName

 function GetExistentHouses()
	local houseTable = {}
	for _, v in pairs(workspace["001_Lots"]:GetChildren()) do
		if string.find(v.Name, "House") and v:FindFirstChild("HousePickedByPlayer") then
			table.insert(houseTable, {
				FullName = v.Owner.Value,
				HouseNumber = v.Number.Number.Value,
				Model = v
			})
		end
	end
	return houseTable
end

 function FindHouseByPartialName(partialName)
	partialName = partialName:lower()
	for _, data in pairs(GetExistentHouses()) do
		if string.find(data.FullName:lower(), partialName) then
			return data
		end
	end
end

House:AddInput("Target Player", "", function(txt)
 		local result = FindHouseByPartialName(txt)
		if result then
			SelectHouse = result.HouseNumber
			SelectedPlayerName = result.FullName
			warn("[+]", "Found: " .. SelectedPlayerName .. " - House #" .. SelectHouse)
		else
			SelectHouse = nil
			SelectedPlayerName = nil
			warn("[-]", "No matching house found")
		end
	end)

House:AddButton("Teleport to the house", function()
		if not SelectHouse then return end
		for _, v in pairs(workspace["001_Lots"]:GetChildren()) do
			if v.Name ~= "DontDelete" and v.Number.Number.Value == SelectHouse then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.WorldPivot.Position)
				break
			end
		end
	end)

House:AddButton("Teleport to the vault", function()
		if not SelectHouse then return end
		for _, v in pairs(workspace["001_Lots"]:GetChildren()) do
			if v.Name ~= "DontDelete" and v.Number.Number.Value == SelectHouse then
				local safe = v.HousePickedByPlayer.HouseModel["001_Safe"]
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(safe.WorldPivot.Position)
				break
			end
		end
	end)

House:AddSwitch("Noclip through the house door", function(Value)
		if not SelectHouse then return end
		for _, v in pairs(workspace["001_Lots"]:GetChildren()) do
			if v.Name ~= "DontDelete" and v.Number.Number.Value == SelectHouse then
				pcall(function()
					local doors = v.HousePickedByPlayer.HouseModel["001_HouseDoors"].HouseDoorFront:GetChildren()
					for _, part in pairs(doors) do
						if part:IsA("BasePart") then
							part.CanCollide = not Value
						end
					end
				end)
				break
			end
		end
	end)

House:AddSwitch("Spam Bell", function(Value)
		getgenv().ChaosHubAutoSpawnDoorbellValue = Value
		task.spawn(function()
			while getgenv().ChaosHubAutoSpawnDoorbellValue do
				if not SelectHouse then break end
				for _, v in pairs(workspace["001_Lots"]:GetChildren()) do
					if v.Name ~= "DontDelete" and v.Number.Number.Value == SelectHouse then
						fireclickdetector(v.HousePickedByPlayer.HouseModel["001_DoorBell"].TouchBell.ClickDetector)
						break
					end
				end
				task.wait(0.5)
			end
		end)
	end)

House:AddSwitch("Spam Knock", function(Value)
		getgenv().ShnmaxAutoSpawnDoorValue = Value
		task.spawn(function()
			while getgenv().ShnmaxAutoSpawnDoorValue do
				if not SelectHouse then break end
				for _, v in pairs(workspace["001_Lots"]:GetChildren()) do
					if v.Name ~= "DontDelete" and v.Number.Number.Value == SelectHouse then
						fireclickdetector(v.HousePickedByPlayer.HouseModel["001_HouseDoors"].HouseDoorFront.Knock.TouchBell.ClickDetector)
						break
					end
				end
				task.wait(0.5)
			end
		end)
	end)

House:AddLabel("House Settings Player")

House:AddButton("House Fire", function()
 args = {
    [1] = "PlayerWantsFireOnFirePassNotShowingAnyone"
}

game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e"):FireServer(unpack(args))
  	end)

local loopTravaPorta = false
local Remote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e")

local function portaLoop()
    while loopTravaPorta do
         args = { [1] = "LockDoors" }
        Remote:FireServer(unpack(args))
        wait(1.5) -- intervalo entre trava/destrava (ajustável)
    end
end

House:AddSwitch("Spam Door Lock", function(state)
    loopTravaPorta = state
    if state then
        spawn(portaLoop)
    end
end)

local poolLoopAtivo = false
local Remote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e")

local function poolLoop()
    while poolLoopAtivo do
         args = { [1] = "PoolOnOff" }
        Remote:FireServer(unpack(args))
        wait(2) -- tempo entre liga/desliga (ajustável)
    end
end

House:AddSwitch("Spam Pool", function(state)
    poolLoopAtivo = state
    if state then
        spawn(poolLoop)
    end
end)

local runningGarage = false
House:AddSwitch("Spam Garage", function(state)
    runningGarage = state
    if state then
        spawn(function()
            while runningGarage do
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e"):FireServer("GarageDoor")
                wait(0.5)
            end
        end)
        print("Loop Garagem ON")
    else
        print("Loop Garagem OFF")
    end
end)

-- Loop Cortinas
local runningCurtains = false
House:AddSwitch("Spam Curtains", function(state)
    runningCurtains = state
    if state then
        spawn(function()
            while runningCurtains do
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e"):FireServer("Curtains")
                wait(0.5)
            end
        end)
        print("Loop Cortinas ON")
    else
        print("Loop Cortinas OFF")
    end
end)

local runningBaby = false
House:AddSwitch("Spam Baby Stuff", function(state)
    runningBaby = state
    if state then
        spawn(function()
            while runningBaby do
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e"):FireServer("BabyOptionYes")
                wait(0.5)
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sHous1e"):FireServer("BabyOptionNo")
                wait(0.5)
            end
        end)
        print("Loop Bebês ON")
    else
        print("Loop Bebês OFF")
    end
end)

House:AddButton("AntiBlock - UnbanHouse", function()
 loadstring(game:HttpGet('https://pastebin.com/raw/17dSEXCP'))()
end)

-- =====================
--  ⬇️Avatar Buttons⬇️
-- =====================

Avatar:AddLabel("Normal Name")
Avatar:AddInput("RP Name", "", function(value)
 args = {
[1] = "RolePlayName", [2] = value

}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eTex1t"):FireServer(unpack(args))
    end)

local trocandoCores = false

Avatar:AddButton("Rainbow Name", function()
    if trocandoCores then return end
    trocandoCores = true

    task.spawn(function()
        while trocandoCores do
            -- Gira o hue com base no tempo para obter cores sempre diferentes e vivas
            local hue = (tick() % 10) / 10
            local color = Color3.fromHSV(hue, 1, 1)

            local args = {
                [1] = "PickingRPNameColor",
                [2] = color
            }

            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RE"):FindFirstChild("1RPNam1eColo1r")
            if remote then
                remote:FireServer(unpack(args))
            end

            task.wait(0.15)
        end
    end)
end)

Avatar:AddButton("Off Rainbow Name", function()
    trocandoCores = false
end)

Avatar:AddLabel("Normal Bio")
Avatar:AddInput("RP Bio", "", function(value)
    local args = {
        [1] = "RolePlayBio",
        [2] = value
    }
    local event = game:GetService("ReplicatedStorage").RE:FindFirstChild("1RPNam1eTex1t")
    if event then
        event:FireServer(unpack(args))
    else
        warn("Evento não encontrado!")
    end
end)

Avatar:AddButton("Rainbow Bio", function()
    if trocandoCores then return end
    trocandoCores = true

    task.spawn(function()
        while trocandoCores do
            -- Gira o hue com base no tempo para obter cores sempre diferentes e vivas
            local hue = (tick() % 10) / 10
            local color = Color3.fromHSV(hue, 1, 1)

            local args = {
                [1] = "PickingRPBioColor",
                [2] = color
            }

            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RE"):FindFirstChild("1RPNam1eColo1r")
            if remote then
                remote:FireServer(unpack(args))
            end

            task.wait(0.15)
        end
    end)
end)

Avatar:AddButton("Off Rainbow Bio", function()
    trocandoCores = false
end)

Avatar:AddLabel("FE Avatar Copier")

local P, R, LP = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("Players").LocalPlayer
local tgt, last, mode = nil, nil, "Brookhaven"

local function W(id) pcall(function() R.Remotes.Wear:InvokeServer(tonumber(id)) end) end

local function RB()
	do R.Remotes.ChangeCharacterBody:InvokeServer({0,0,0,0,0,0}, "AllBlocky") end
end

local function ST(uid)
	do
		local s, r = pcall(function() return P:GetCharacterAppearanceInfoAsync(uid) end)
		if s and r.bodyColors and r.bodyColors.HeadColor then
			R.Remotes.ChangeBodyColor:FireServer(tostring(r.bodyColors.HeadColor))
		end
	end
end

local function CC(d)
	do
		for _, i in ipairs{d.Shirt, d.Pants, d.GraphicTShirt, d.Face} do
			if tonumber(i) and i ~= 0 then W(i) task.wait(0.1) end
		end
	end
end

local function CA(d)
	do
		pcall(function()
			for _, v in ipairs(d:GetAccessories(true)) do
				if v.AssetId then W(v.AssetId) task.wait(0.1) end
			end
		end)
	end
end

local function CB(d, src)
	do
		local p = {
			tonumber(d.Torso), tonumber(d.RightArm), tonumber(d.LeftArm),
			tonumber(d.RightLeg), tonumber(d.LeftLeg), tonumber(d.Head)
		}
		R.Remotes.ChangeCharacterBody:InvokeServer(p, src)
	end
end

local function CAn(d)
	do
		for _, i in ipairs{
			d.IdleAnimation, d.WalkAnimation, d.RunAnimation,
			d.JumpAnimation, d.FallAnimation, d.SwimAnimation
		} do
			if tonumber(i) and i ~= 0 then W(i) task.wait(0.1) end
		end
	end
end

local function CopyB(p)
	do
		local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
		if not h then return end
		local d = h:GetAppliedDescription()
		local b = p.Character:FindFirstChildOfClass("BodyColors")
		if b and b.HeadColor then
			R.Remotes.ChangeBodyColor:FireServer(tostring(b.HeadColor))
		end
		pcall(function()
			CA(LP.Character:FindFirstChildOfClass("Humanoid"):GetAppliedDescription())
			RB() CA(d) task.wait(0.1)
			CB(d, "ShnmaxHub") CC(d) CAn(d)
		end)
	end
end

local function CopyO(uid)
	do
		pcall(function()
			local d = P:GetHumanoidDescriptionFromUserId(uid)
			CA(LP.Character:FindFirstChildOfClass("Humanoid"):GetAppliedDescription())
			RB() CA(d) task.wait(0.1)
			CB(d, "ShnmaxHub") CC(d) CAn(d)
			ST(uid)
		end)
	end
end

local function Find(name)
	if not name or name == "" then return end
	name = name:lower()
	local res = {}
	for _, p in ipairs(P:GetPlayers()) do
		if p ~= LP and p.Name:lower():find(name, 1, true) then
			table.insert(res, p)
		end
	end
	table.sort(res, function(a, b)
		local sa, sb = a.Name:lower():sub(1, #name) == name, b.Name:lower():sub(1, #name) == name
		if sa and not sb then return true end
		if not sa and sb then return false end
		return #a.Name < #b.Name
	end)
	return res[1]
end

Avatar:AddInput("Target Player", "type name..", function(txt)
	if txt == "" then if last then txt = last else return end end
	local p = Find(txt)
	if p then tgt, last = p, p.Name end
end)

Avatar:AddDropdown("Copy Meathod", {"Brookhaven", "Original Avatar"}, function(opt)
	mode = opt
end)

Avatar:AddButton("Copy Avatar", function()
	if not tgt then return end
	if mode == "Brookhaven" then CopyB(tgt) else CopyO(tgt.UserId) end
end)

Avatar:AddButton("Copy Avatar Nearest", function()
	local c, d = nil, math.huge
	for _, p in pairs(P:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local m = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
			if m < d then c, d = p, m end
		end
	end
	if c then if mode == "Brookhaven" then CopyB(c) else CopyO(c.UserId) end end
end)

Avatar:AddButton("Copy Avatar Random", function()
	local list = {}
	for _, p in pairs(P:GetPlayers()) do
		if p ~= LP then table.insert(list, p) end
	end
	if #list > 0 then
		local r = list[math.random(1, #list)]
		if mode == "Brookhaven" then CopyB(r) else CopyO(r.UserId) end
	end
end)
    
Avatar:AddLabel("Avatar")

Avatar:AddButton("Old R6 Animation", function()
 loadstring(game:HttpGet('https://gist.githubusercontent.com/Imperador950/f9e54330eb4a92331204aae37ec11aef/raw/db18d1c348beb8a79931346597137518966f2188/Byshelby'))()
end)

Avatar:AddButton("Old R15 Animation", function()
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Parar e remover todas as animações ativas
for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
track:Stop()
track:Destroy()
end

-- Remover objetos Animation de dentro do personagem
for _, descendant in ipairs(character:GetDescendants()) do
if descendant:IsA("Animation") then
descendant:Destroy()
end
end

-- Forçar remoção de AnimationId em objetos suspeitos
for _, obj in ipairs(character:GetDescendants()) do
if obj:IsA("Tool") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
for _, child in ipairs(obj:GetDescendants()) do
if child:IsA("Animation") then
child:Destroy()
end
end
end
end
end)

Avatar:AddLabel("Job Section")

local ChangeJobLoopEnabled = false

local function changeJobLoop()
while ChangeJobLoopEnabled do
args = {
[1] = "Dancer"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "Grocery Store"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "Police"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "Hospital"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "Fire House"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "Teacher"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "Student"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "Bank"
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
wait(0,5)
args = {
[1] = "S.W.A.T."
}

game:GetService("ReplicatedStorage").Remotes.GiveJobUIMenu:FireServer(unpack(args))
end
end

Avatar:AddSwitch("Loop Jobs", function(Value)
if Value then
ChangeJobLoopEnabled = true
changeJobLoop()
else
ChangeJobLoopEnabled = false
end
end)

Avatar:AddLabel("Character Settings")

local StarterGui = game:GetService("StarterGui")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local function getHumanoid()
character = player.Character or player.CharacterAdded:Wait()
return character:FindFirstChildOfClass("Humanoid")
end

local function notify(title, text, duration)
StarterGui:SetCore("SendNotification", {
Title = title,
Text = text,
Duration = duration or 3
})
end

Avatar:AddInput("Speed", "", function(text)
local value = tonumber(text)
local humanoid = getHumanoid()
if humanoid and value then
humanoid.WalkSpeed = value
notify("Velocidade Alterada", "Nova velocidade: " .. value)
else
warn("Valor inválido para velocidade")
notify("Erro", "Valor inválido para velocidade")
end
end)

Avatar:AddInput("Jump", "", function(text)
local value = tonumber(text)
local humanoid = getHumanoid()
if humanoid and value then
humanoid.JumpPower = value
notify("Salto Alterado", "Novo salto: " .. value)
else
warn("Valor inválido para salto")
notify("Erro", "Valor inválido para salto")
end
end)

Avatar:AddButton("Reset Walkspeed/Jumppower", function()
local humanoid = getHumanoid()
if humanoid then
humanoid.WalkSpeed = 16
humanoid.JumpPower = 50
notify("Valores Restaurados", "Velocidade e salto padrão aplicados.")
else
warn("Humanoid não encontrado!")
notify("Erro", "Humanoid não encontrado!")
end
end)

Avatar:AddButton("Refresh Avatar", function()
game:GetService("ReplicatedStorage").Remotes.ResetCharacterAppearance:FireServer()
end)

Avatar:AddButton("Reset 1", function()
local character = game.Players.LocalPlayer.Character
local humanoid = character:FindFirstChild("Humanoid")

for _, part in pairs(character:GetChildren()) do  
	if part:IsA("Part") or part:IsA("BasePart") or part:IsA("MeshPart") then  
		if part.Anchored then  
			part.Anchored = false  
		end  
	end  
end  

if humanoid then  
	humanoid.Health = 0  
end

end)

Avatar:AddButton("Reset 2", function()
local character = game.Players.LocalPlayer.Character
if not character then return end

for _, part in pairs(character:GetChildren()) do  
	if part:IsA("Part") or part:IsA("BasePart") or part:IsA("MeshPart") then  
		if part.Anchored then  
			part.Anchored = false  
		end  
	end  
end  

local upperTorso = character:FindFirstChild("UpperTorso")  
if upperTorso then  
	upperTorso:Destroy()  
end

end)

Avatar:AddLabel("Character Appearance")

Avatar:AddButton("Fire Avatar", function()
local player = game.Players.LocalPlayer
local character = player.Character
if not character then return end

local house = workspace:FindFirstChild("001_Lots") and workspace["001_Lots"]:FindFirstChild(player.Name .. "House")  
local mall = house  
	and house:FindFirstChild("HousePickedByPlayer")  
	and house.HousePickedByPlayer:FindFirstChild("HouseModel")  
	and house.HousePickedByPlayer.HouseModel:FindFirstChild("001_BBQ")  
	and house.HousePickedByPlayer.HouseModel["001_BBQ"]:FindFirstChild("CatchFire")  

local hrp = character:FindFirstChild("HumanoidRootPart")  

if mall and hrp then  
	firetouchinterest(hrp, mall, 0)  
	task.wait()  
	firetouchinterest(hrp, mall, 1)  
end

end)

local FireLoopAtivo = false

local function toggleFireLoop(ativo)
FireLoopAtivo = ativo
notify("Loop Fire", ativo and "Ativado" or "Desativado")

if ativo then  
    task.spawn(function()  
        while FireLoopAtivo do  
            local house = Workspace:FindFirstChild("001_Lots") and Workspace["001_Lots"]:FindFirstChild(player.Name .. "House")  
            local mall = house and house:FindFirstChild("HousePickedByPlayer") and house.HousePickedByPlayer:FindFirstChild("HouseModel"):FindFirstChild("001_BBQ"):FindFirstChild("CatchFire")  
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")  
            if mall and hrp then  
                firetouchinterest(hrp, mall, 0)  
                task.wait()  
                firetouchinterest(hrp, mall, 1)  
            end  
            task.wait(1)  
        end  
    end)  
end

end

Avatar:AddSwitch("Loop Fire Avatar", function(state)
toggleFireLoop(state)
end)

Avatar:AddButton("Smoke Avatar", function()
local mall = Workspace:FindFirstChild("WorkspaceCom") and Workspace.WorkspaceCom:FindFirstChild("001_Mall")
mall = mall and mall:FindFirstChild("001_Pizza") and mall["001_Pizza"]:FindFirstChild("CatchFire")
local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if mall and hrp then
firetouchinterest(hrp, mall, 0)
task.wait()
firetouchinterest(hrp, mall, 1)
end
end)

local SmokeLoopAtivo = false

function toggleSmokeLoop(ativo)
SmokeLoopAtivo = ativo
notify("Loop Smoke", ativo and "Ativado" or "Desativado")

if ativo then  
    task.spawn(function()  
        while SmokeLoopAtivo do  
            local mall = Workspace:FindFirstChild("WorkspaceCom") and Workspace.WorkspaceCom:FindFirstChild("001_Mall")  
            mall = mall and mall:FindFirstChild("001_Pizza") and mall["001_Pizza"]:FindFirstChild("CatchFire")  
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")  
            if mall and hrp then  
                firetouchinterest(hrp, mall, 0)  
                task.wait()  
                firetouchinterest(hrp, mall, 1)  
            end  
            task.wait(1)  
        end  
    end)  
end

end

Avatar:AddSwitch("Loop Smoke Avatar", function(state)
toggleSmokeLoop(state)
end)

Avatar:AddLabel("Body Section")
Avatar:AddButton("FE Faceless", function()
local head = game.Players.LocalPlayer.Character:WaitForChild("Head")
local face = head:FindFirstChildOfClass("Decal")
if face then
face.Texture = "rbxassetid://0"
end
end)

Avatar:AddButton("FE Naked", function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local shirt = character:FindFirstChildOfClass("Shirt")  
if shirt then shirt:Destroy() end  

local pants = character:FindFirstChildOfClass("Pants")  
if pants then pants:Destroy() end

end)

Avatar:AddButton("Refresh Avatar", function()
game:GetService("ReplicatedStorage").Remotes.ResetCharacterAppearance:FireServer()
end)

Avatar:AddLabel("Custom Hats, Hairs, and some...")

Avatar:AddInput("Id Box", "", function(Value)
args = {
[1] = Value
}

game:GetService("ReplicatedStorage").Remotes.Wear:InvokeServer(unpack(args))
end)

Avatar:AddButton("Refresh Avatar", function()
game:GetService("ReplicatedStorage").Remotes.ResetCharacterAppearance:FireServer()
end)

-- ==================
--  ⬇️Car Buttons⬇️
-- ==================

-- URL para carregar a playlist
local playlistUrl = "https://pastebin.com/raw/uDreR61A"

-- Carregar a playlist dinamicamente
local PlayList = loadstring(game:HttpGet(playlistUrl))()

-- Verificar se a playlist foi carregada corretamente
if PlayList then
    print("Playlist carregada com sucesso!")
else
    error("Erro ao carregar a playlist!")
end

-- Função para tocar música no carro e na moto/scooter
local function playMusic(musicId)
    if musicId and musicId ~= "" then
        -- Carro
        local argsCar = {
            [1] = "PickingCarMusicText", -- Customize com o evento correto
            [2] = musicId
        }
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer(unpack(argsCar))
        print("Tocando música no carro com ID:", musicId)

        -- Moto/Scooter
        local Argument1 = game:GetService("ReplicatedStorage").RE["1NoMoto1rVehicle1s"]
        Argument1:FireServer(
            "PickingScooterMusicText",
            musicId -- agora também usa o mesmo musicId informado
        )
        print("Tocando música na moto/scooter com ID:", musicId)
    else
        print("Por favor, insira um ID de música válido.")
    end
end
-- Variável para armazenar o último ID de música selecionado ou digitado
local lastMusicId = nil

-- Aba Música

-- Label informativo
Car:AddLabel("Music Car ID『Gamepass』")

-- Input para digitar o ID da música
Car:AddInput("Digite o ID da Música", "Ex.: 12345678", function(id)
    local musicId = tonumber(id) -- Converter para número
    if musicId then
        lastMusicId = id -- Atualizar o último ID
        print("ID da Música atualizado pelo Input:", lastMusicId)
    else
        print("ID inválido. Por favor, insira um número.")
    end
end)

-- Dropdown para selecionar uma música da PlayList
local musicOptions = {}
for _, song in pairs(PlayList) do
    table.insert(musicOptions, song.Name) -- Adiciona somente o nome ao Dropdown
end

Car:AddDropdown("Escolha uma música", musicOptions, function(selectedName)
    for _, song in pairs(PlayList) do
        if selectedName == song.Name then
            lastMusicId = song.ID -- Atualizar o último ID
            print("ID da Música atualizado pelo Dropdown:", lastMusicId)
            break
        end
    end
end)

-- Botão para tocar música
Car:AddButton("Tocar Música", function()
    if lastMusicId then
        playMusic(lastMusicId) -- Tocar música com o último ID
    else
        print("Nenhum ID de música foi selecionado ou digitado.")
    end
end)

Car:AddLabel("Target Car Player")

local Vehicles = workspace:FindFirstChild("Vehicles")
local Player = game.Players.LocalPlayer
local SelectCar

local Tabela = {}
if Vehicles then
    for _, car in ipairs(Vehicles:GetChildren()) do
        if car:IsA("Model") then
            table.insert(Tabela, car.Name)
        end
    end
end

local CarDropdown = Car:AddDropdown("Vehicle - ", Tabela, function(Value)
        SelectCar = Value
    end)

Car:AddButton("Teleport to Vehicle", function()
local Car = Vehicles:FindFirstChild(tostring(SelectCar))
  if Car then
    for _, basepart in ipairs(Car:GetDescendants()) do
      if basepart:IsA("BasePart") then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(basepart.Position)
      end
    end
  end
end)

Car:AddButton("Teleport to Seat", function()
    local Car = Vehicles:FindFirstChild(tostring(SelectCar))
    local Character = Player.Character
    if Car and Character then
        local Seat = Car:FindFirstChild("Body") and Car.Body:FindFirstChild("VehicleSeat") or Car:FindFirstChildWhichIsA("VehicleSeat")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")

        if Seat and RootPart then
            RootPart.CFrame = Seat.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

Car:AddButton("Pull Vehicle", function()
        local Car = Vehicles:FindFirstChild(tostring(SelectCar))
        local Character = Player.Character
        if Car and Character then
            local Seat = Car:FindFirstChild("Body") and Car.Body:FindFirstChild("VehicleSeat")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")

            if Seat and Humanoid and RootPart then
                if not Car.PrimaryPart then
                    local try = Car:FindFirstChild("Primary") or Car:FindFirstChildWhichIsA("BasePart")
                    if try then
                        Car.PrimaryPart = try
                    end
                end

                if Car.PrimaryPart then
                    local OldPos = RootPart.CFrame

                    repeat
                        task.wait()
                        RootPart.CFrame = Seat.CFrame
                    until Humanoid.Sit

                    task.wait(0.7)

                    Car:SetPrimaryPartCFrame(OldPos)
                end
            end
        end
    end)
    
Car:AddLabel("Tank Section")

local player = game:GetService("Players").LocalPlayer
local spamConns = {}

local function explode(car)
    local p = car:FindFirstChild("Body") and car.Body:FindFirstChild("BodyPanels")
    local s = p and p:FindFirstChild("Shoot")
    local cd = s and s:FindFirstChildOfClass("ClickDetector")
    if cd then fireclickdetector(cd) end
end

local function toggleSpam(type, enable)
    if spamConns[type] then
        spamConns[type]:Disconnect()
        spamConns[type] = nil
    end

    if not enable then return end

    spamConns[type] = game:GetService("RunService").Heartbeat:Connect(function()
        local v = workspace:FindFirstChild("Vehicles")
        if not v then return end

        for _, car in ipairs(v:GetChildren()) do
            if car:IsA("Model") then
                if type == "Own" and car.Name == player.Name .. "Car" then
                    explode(car)
                elseif type == "All" and car.Name ~= player.Name .. "Car" then
                    explode(car)
                end
            end
        end
    end)
end

Car:AddSwitch("Spam Explode Tank", function(state)
    toggleSpam("Own", state)
end)

Car:AddSwitch("Spam Explode Every Tank", function(state)
    toggleSpam("All", state)
end)

Car:AddLabel("Car Settings (Premium Only) ")
 
local runningCarRainbow = false
local RunService = game:GetService("RunService")
local carRemote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r")

-- Reaproveita a função de gerar cores suaves
local function getRandomColor()
	local r = math.random(50, 255) / 255
	local g = math.random(50, 255) / 255
	local b = math.random(50, 255) / 255
	return Color3.new(r, g, b)
end

local function lerpColor(a, b, t)
	local r = a.R + (b.R - a.R) * t
	local g = a.G + (b.G - a.G) * t
	local b = a.B + (b.B - a.B) * t
	return Color3.new(r, g, b)
end

local function smoothCarColorTransition()
	local currentColor = getRandomColor()
	local targetColor = getRandomColor()
	local duration = 2.5 -- pode ajustar conforme feeling

	while runningCarRainbow do
		local startTime = tick()
		while tick() - startTime < duration do
			if not runningCarRainbow then return end
			local elapsed = tick() - startTime
			local alpha = elapsed / duration
			local newColor = lerpColor(currentColor, targetColor, alpha)

			carRemote:FireServer("PickingCarColor", newColor)

			task.wait(0.1)
		end

		currentColor = targetColor
		targetColor = getRandomColor()
	end
end

Car:AddSwitch("Rainbow Car", function(state)
	runningCarRainbow = state
	if state then
		task.spawn(smoothCarColorTransition)
		
	else
		
	end
end)

Car:AddButton("Remove Wheel", function()
 args = {
    [1] = "BlowFrontLeft"
}

game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer(unpack(args))
wait()
 args = {
    [1] = "BlowFrontRight"
}

game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer(unpack(args))
wait()
 args = {
    [1] = "BlowRearRight"
}

game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer(unpack(args))
wait() 
args = {
    [1] = "BlowRearLeft"
}

game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer(unpack(args))
end)

Car:AddSwitch("Spam Fire", function(state)
    runningFire = state
    if state then
        spawn(function()
            while runningFire do
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer("Fire")
                wait(2)
            end
        end)
        print("Loop Fire ON")
    else
        print("Loop Fire OFF")
    end
end)

local runningDuke1 = false
Car:AddSwitch("Spam Duke 1", function(state)
    runningDuke1 = state
    if state then
        spawn(function()
            while runningDuke1 do
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer("Duke1")
                wait(1)
            end
        end)
        print("Loop Duke 1 ON")
    else
        print("Loop Duke 1 OFF")
    end
end)

-- Loop Duke 2
local runningDuke2 = false
Car:AddSwitch("Spam Duke 2", function(state)
    runningDuke2 = state
    if state then
        spawn(function()
            while runningDuke2 do
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer("Duke")
                wait(1)
            end
        end)
        print("Loop Duke 2 ON")
    else
        print("Loop Duke 2 OFF")
    end
end)

Car:AddSwitch("Spam Turbo", function(state)
    runningSmoke = state
    if state then
        spawn(function()
            while runningSmoke do
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer("Smoke")
                wait(2)
            end
        end)
        print("Loop Fire ON")
    else
        print("Loop Fire OFF")
    end
end)

Car:AddLabel("Car Settings (Free) ")

local Player = game.Players.LocalPlayer
local Vehicles = workspace:FindFirstChild("Vehicles")

 function ApplyValueToCar(value)
    local car = Vehicles and Vehicles:FindFirstChild(Player.Name .. "Car")
    if car then
        local seat = car:FindFirstChild("Body") and car.Body:FindFirstChild("VehicleSeat")
        if seat then
            seat.TopSpeed.Value = value
            seat.Turbo.Value = value

             args = {
                [1] = "DriftingNumber",
                [2] = value
            }
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r"):FireServer(unpack(args))

            print("Speed =  " .. value)
        else
            print("Error sit in car first")
        end
    else
        print("Spawn a car first !")
    end
end

Car:AddInput("Speed Box", "Enter id here...", function(input)
        local num = tonumber(input)
        if num then
            ApplyValueToCar(num)
        else
            print("...")
        end
    end)
    
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Player1sCa1r")

-- Spam Horn
local hornActive = false
Car:AddSwitch("Spam Horn",  function(state)
    hornActive = state
    if state then
        spawn(function()
            while hornActive do
                remote:FireServer("Horn")
                wait(0.1)
            end
        end)
    end
end)

-- Spam Light
local lightActive = false
Car:AddSwitch("Spam Light", function(state)
    lightActive = state
    if state then
        spawn(function()
            while lightActive do
                remote:FireServer("Lights")
                wait(0.4)
            end
        end)
    end
end)

-- Spam Hazards
local hazardActive = false
Car:AddSwitch("Spam Hazards", function(state)
    hazardActive = state
    if state then
        spawn(function()
            while hazardActive do
                remote:FireServer("Hazards")
                wait(0.4)
            end
        end)
    end
end)

-- Spam Wheel
local wheelActive = false
Car:AddSwitch("Spam Wheel", function(state)
    wheelActive = state
    if state then
        spawn(function()
            while wheelActive do
                remote:FireServer("WheelNumber")
                wait(0.4)
            end
        end)
    end
end)

-- Spam Height
local heightActive = false
Car:AddSwitch("Spam Height", function(state)
    heightActive = state
    if state then
        spawn(function()
            while heightActive do
                remote:FireServer("VehicleHeight", 4)
                wait(1)
                remote:FireServer("VehicleHeight", 1)
                wait(1)
            end
        end)
    end
end)
    
Car:AddLabel("Bike Section")

local runningBikeRainbow = false
local bikeRemote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Player1sCa1r")

-- Reutiliza função global se já existir
local function getRandomColor()
	local r = math.random(50, 255) / 255
	local g = math.random(50, 255) / 255
	local b = math.random(50, 255) / 255
	return Color3.new(r, g, b)
end

local function lerpColor(a, b, t)
	local r = a.R + (b.R - a.R) * t
	local g = a.G + (b.G - a.G) * t
	local b = a.B + (b.B - a.B) * t
	return Color3.new(r, g, b)
end

local function smoothBikeColorTransition()
	local currentColor = getRandomColor()
	local targetColor = getRandomColor()
	local duration = 2.5 -- ajuste de acordo com o efeito desejado

	while runningBikeRainbow do
		local startTime = tick()
		while tick() - startTime < duration do
			if not runningBikeRainbow then return end
			local elapsed = tick() - startTime
			local alpha = elapsed / duration
			local newColor = lerpColor(currentColor, targetColor, alpha)

			bikeRemote:FireServer("NoMotorColor", newColor)
			task.wait(0.1)
		end

		currentColor = targetColor
		targetColor = getRandomColor()
	end
end

Car:AddSwitch("Rainbow Bike", function(state)
	runningBikeRainbow = state
	if state then
		print("Rainbow Bike ativado.")
		task.spawn(smoothBikeColorTransition)
	else
		print("Rainbow Bike desativado.")
	end
end)

-- ==================
--  ⬇️Fun Buttons⬇️
-- ==================

Fun:AddLabel("Sign Section")
Fun:AddButton("Get Sign", function()
    args = {[1] = "PickingTools", [2] = "Sign"}		
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(args))
    game.Players.LocalPlayer.Backpack["Sign"].Parent = game.Players.LocalPlayer.Character
end)

sign1 = ""
sign2 = ""
sign3 = ""
sign4 = ""
sign5 = ""
repeatNames = false

Fun:AddInput("Sign 1", "Enter text here...", function(value)
    sign1 = value
end)
Fun:AddInput("Sign 2", "Enter text here...", function(value)
    sign2 = value
end)
Fun:AddInput("Sign 3", "Enter text here...", function(value)
    sign3 = value
end)
Fun:AddInput("Sign 4", "Enter text here...", function(value)
    sign4 = value
end)
Fun:AddInput("Sign 5", "Enter text here...", function(value)
    sign5 = value
end)

Fun:AddSwitch("Validate", function(value)
    repeatNames = value
    while repeatNames do
        local args1 = { "Sign", "SignWords", sign1 }
        game:GetService("Players").LocalPlayer.Character.Sign.ToolSound:FireServer(unpack(args1))
        wait(0.2)
        local args2 = { "Sign", "SignWords", sign2 }
        game:GetService("Players").LocalPlayer.Character.Sign.ToolSound:FireServer(unpack(args2))
        wait(0.2)
        local args3 = { "Sign", "SignWords", sign3 }
        game:GetService("Players").LocalPlayer.Character.Sign.ToolSound:FireServer(unpack(args3))
        wait(0.2)
        local args4 = { "Sign", "SignWords", sign4 }
        game:GetService("Players").LocalPlayer.Character.Sign.ToolSound:FireServer(unpack(args4))
        wait(0.2)
        local args5 = { "Sign", "SignWords", sign5 }
        game:GetService("Players").LocalPlayer.Character.Sign.ToolSound:FireServer(unpack(args5))
    end
end)

Fun:AddLabel("Box Section")
Fun:AddButton("Get Box", function()
    args = {[1] = "PickingTools", [2] = "Box"}		
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(args))
    game.Players.LocalPlayer.Backpack["Box"].Parent = game.Players.LocalPlayer.Character
end)

Box1 = ""
Box2 = ""
Box3 = ""
Box4 = ""
Box5 = ""
repeatNames1 = false

Fun:AddInput("Box 1", "Enter text here...", function(value)
    Box1 = value
end)
Fun:AddInput("Box 2", "Enter text here...", function(value)
    Box2 = value
end)
Fun:AddInput("Box 3", "Enter text here...", function(value)
    Box3 = value
end)
Fun:AddInput("Box 4", "Enter text here...", function(value)
    Box4 = value
end)
Fun:AddInput("Box 5", "Enter text here...", function(value)
    Box5 = value
end)

Fun:AddSwitch("Validate", function(value)
    repeatNames1 = value
    while repeatNames1 do
        local args1 = { "Box", "SignWords", Box1 }
        game:GetService("Players").LocalPlayer.Character.Box.ToolSound:FireServer(unpack(args1))
        wait(0.2)
        local args2 = { "Box", "SignWords", Box2 }
        game:GetService("Players").LocalPlayer.Character.Box.ToolSound:FireServer(unpack(args2))
        wait(0.2)
        local args3 = { "Box", "SignWords", Box3 }
        game:GetService("Players").LocalPlayer.Character.Box.ToolSound:FireServer(unpack(args3))
        wait(0.2)
        local args4 = { "Box", "SignWords", Box4 }
        game:GetService("Players").LocalPlayer.Character.Box.ToolSound:FireServer(unpack(args4))
        wait(0.2)
        local args5 = { "Box", "SignWords", Box5 }
        game:GetService("Players").LocalPlayer.Character.Box.ToolSound:FireServer(unpack(args5))
    end
end)

Fun:AddLabel("Roses Section")
Fun:AddButton("Get Roses", function()
    args = {"PickingTools", "Roses"}
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(args))
    local player = game.Players.LocalPlayer
    local rose = player.Backpack:FindFirstChild("Roses")
    if rose then
        rose.Parent = player.Character
    end
end)

local toggleActive = false
function RosesColor()
    task.spawn(function()
        while toggleActive do
            local char = game.Players.LocalPlayer.Character
            if not char then break end
            local rose = char:FindFirstChild("Roses")
            if not rose then break end
            local sound = rose:FindFirstChild("ToolSound")
            if not sound then break end

            local sounds = {
                "http://www.roblox.com/asset/?id=5210399458",
                "http://www.roblox.com/asset/?id=5210414520",
                "http://www.roblox.com/asset/?id=5216708760"
            }
            for _, id in ipairs(sounds) do
                if not toggleActive then break end
                sound:FireServer("Roses", id)
                task.wait(0.2)
            end
        end
    end)
end

Fun:AddSwitch("Rainbow Roses", function(value)
    toggleActive = value
    if toggleActive then
        RosesColor()
    end
end)

-- Universal Tool Counter
local function CountTool(toolName)
    local player = game.Players.LocalPlayer
    local total = 0
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool.Name == toolName then
            total += 1
        end
    end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool.Name == toolName then
            total += 1
        end
    end
    return total
end

-- Universal Tool Duplicator
local function CreateDuplicator(toolName, labelName)
    Fun:AddLabel(labelName.." Section")

    local amount = 100

    Fun:AddInput("Amount", "", function(value)
        local number = tonumber(value)
        if number and number > 0 then
            amount = number
        else
            warn("Enter a valid number.")
        end
    end)

    Fun:AddButton("Dupe "..labelName, function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local backpack = player:WaitForChild("Backpack")
        local root = char:WaitForChild("HumanoidRootPart")

        local giveTools = workspace:FindFirstChild("WorkspaceCom")
            and workspace.WorkspaceCom:FindFirstChild("001_GiveTools")
        local toolObject = giveTools and giveTools:FindFirstChild(toolName)

        if not (toolObject and toolObject:FindFirstChildOfClass("ClickDetector")) then
            warn("Tool not found in Workspace.")
            return
        end

        local detector = toolObject:FindFirstChildOfClass("ClickDetector")
        local oldPos = root.CFrame

        task.spawn(function()
            while CountTool(toolName) < amount do
                root.CFrame = toolObject.CFrame
                fireclickdetector(detector)
                task.wait(0.01)
            end
            root.CFrame = oldPos
            print("Duplication complete: "..toolName.." x"..CountTool(toolName))
        end)
    end)
end

CreateDuplicator("Taser", "Taser")
CreateDuplicator("FireX", "FireX")
CreateDuplicator("Assault", "Gun")
CreateDuplicator("Basketball", "Balls")

-- Balls Looper Section
local ThrowActive = false
local ThrowThread

Fun:AddSwitch("Balls Looper", function(state)
    ThrowActive = state

    if state then
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()
        local char = player.Character or player.CharacterAdded:Wait()

        if not (player and mouse and char) then
            warn("Missing player, mouse or character")
            return
        end

        ThrowThread = task.spawn(function()
            while ThrowActive do
                for _, tool in ipairs(char:GetChildren()) do
                    if tool.Name == "Basketball" and tool:FindFirstChild("ClickEvent") then
                        tool.ClickEvent:FireServer(mouse.Hit.p)
                        task.wait(0.0003)
                    end
                end
                task.wait()
            end
        end)
    else
        if ThrowThread then
            task.cancel(ThrowThread)
            ThrowThread = nil
        end
    end
end)

Fun:AddLabel("Fling Section")
Fun:AddButton("Click Fling - By Shelby", function()
    loadstring(game:HttpGet('https://gist.githubusercontent.com/GistsPrivate/24ee609605cfaa52a28411cf8115535d/raw/5bac79672e8f1af9f98c92e1f0e232696f7f3858/gistfile1.txt'))()
end)

Fun:AddButton("FE DOORS", function()
    -- (Função igual ao original, apenas adaptada)
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")

    for _, child in ipairs(HRP:GetChildren()) do
        if child.Name:match("^SHNMAX_AttachDoor_%d+$") then
            child:Destroy()
        end
    end

    local ControlledDoors = {}

    local function SetupPart(part, index)
        if not (part:IsA("BasePart") and not part.Anchored and part.Name:lower():find("door")) then return end
        if part:FindFirstChild("SHNMAX_Attached") then return end

        part.CanCollide = false
        for _, obj in ipairs(part:GetChildren()) do
            if obj:IsA("AlignPosition") or obj:IsA("Torque") or obj:IsA("Attachment") then
                obj:Destroy()
            end
        end

        Instance.new("BoolValue", part).Name = "SHNMAX_Attached"
        local doorAttachment = Instance.new("Attachment", part)
        doorAttachment.Name = "SHNMAX_LocalAttach"
        local hrpAttachment = Instance.new("Attachment", HRP)
        hrpAttachment.Name = "SHNMAX_AttachDoor_" .. index

        local align = Instance.new("AlignPosition", part)
        align.Attachment0 = doorAttachment
        align.Attachment1 = hrpAttachment
        align.MaxForce = 1e35
        align.MaxVelocity = math.huge
        align.Responsiveness = 99999

        local torque = Instance.new("Torque", part)
        torque.Attachment0 = doorAttachment
        torque.RelativeTo = Enum.ActuatorRelativeTo.World
        torque.Torque = Vector3.new(
            math.random(-1e19, 1e19),
            math.random(-1e19, 1e19),
            math.random(-1e25, 1e25)
        )

        table.insert(ControlledDoors, {
            Part = part,
            Align = align,
            Attach = doorAttachment,
            HRPAttach = hrpAttachment
        })
    end

    local index = 1
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("door") then
            SetupPart(obj, index)
            index += 1
        end
    end

    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name:lower():find("door") then
            SetupPart(obj, #ControlledDoors + 1)
        end
    end)

    local function FlingPlayer(targetPlayer)
        local targetChar = targetPlayer.Character
        if not targetChar then return end

        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end

        local targetAttachment = targetHRP:FindFirstChild("SHNMAX_TargetAttachment")
        if not targetAttachment then
            targetAttachment = Instance.new("Attachment", targetHRP)
            targetAttachment.Name = "SHNMAX_TargetAttachment"
        end

        for _, door in ipairs(ControlledDoors) do
            if door.Align then
                door.Align.Attachment1 = targetAttachment
            end
        end

        local startTime = tick()
        local flingDone = false

        while tick() - startTime < 5 do
            if targetHRP.Velocity.Magnitude >= 40 then
                flingDone = true
                break
            end
            RunService.Heartbeat:Wait()
        end

        for _, door in ipairs(ControlledDoors) do
            if door.Align then
                door.Align.Attachment1 = door.HRPAttach
            end
        end

        print(string.format("[SHNMAX] Porta delivery para %s: %s", targetPlayer.Name, flingDone and "Flingado" or "Sem efeito"))
    end

    UserInputService.TouchTap:Connect(function(touchPositions, processed)
        if processed or not touchPositions[1] then return end
        local pos = touchPositions[1]
        local camera = Workspace.CurrentCamera
        local ray = camera:ScreenPointToRay(pos.X, pos.Y)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if result and result.Instance then
            local charModel = result.Instance:FindFirstAncestorOfClass("Model")
            local hitPlayer = Players:GetPlayerFromCharacter(charModel)
            if hitPlayer and hitPlayer ~= LocalPlayer then
                FlingPlayer(hitPlayer)
            end
        end
    end)
end)

Fun:AddLabel("Helicopter Section (Premium Only)")
Fun:AddLabel("Helicopter Spam Creates By :@Davi999")

Fun:AddSwitch("Helicopter Spam", function(state)
    getgenv().Toggle = state
    if state then
        local Players = game:GetService("Players")
        local Player = Players.LocalPlayer
        local Character = Player.Character
        local RootPart = Character.HumanoidRootPart
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local molestado1 = workspace.WorkspaceCom["001_HeliCloneButton"].Button
        task.spawn(function()
            while getgenv().Toggle do
                task.wait()
                RootPart.CFrame = molestado1.CFrame
                task.wait(0.1)
                fireclickdetector(molestado1.ClickDetector)
                task.wait(0.5)
                local molestado2 = workspace.WorkspaceCom["001_HeliStorage"]:FindFirstChild("PoliceStationHeli")
                if molestado2 then
                    repeat
                        RootPart.CFrame = molestado2.PrimaryPart.CFrame + Vector3.new(0, math.random(-1, 1), 0)
                        task.wait()
                    until Humanoid.Sit
                    task.wait(0.1)
                    Humanoid.Sit = false
                    task.wait()
                    repeat
                        RootPart.CFrame = molestado2.Passenger1.CFrame + Vector3.new(0, math.random(-1, 1), 0)
                        task.wait()
                    until Humanoid.Sit
                    task.wait(0.2)
                    RootPart.CFrame = CFrame.new(math.random(-40, 40), 4.549, math.random(-40, 40))
                    task.wait(0.2)
                    Humanoid.Sit = false
                    molestado2.Name = "PoliceStationHeliShnmaxhubAndCartolaHub"
                end
            end
        end)
    end
end)

Fun:AddSwitch("Canoe Spam", function(state)
    getgenv().Toggle = state
    if state then
        local Players = game:GetService("Players")
        local Player = Players.LocalPlayer
        local Character = Player.Character
        local RootPart = Character.HumanoidRootPart
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local molestado1 = workspace.WorkspaceCom["001_CanoeCloneButton"].Button
        task.spawn(function()
            while getgenv().Toggle do
                task.wait()
                RootPart.CFrame = molestado1.CFrame
                task.wait(0.1)
                fireclickdetector(molestado1.ClickDetector)
                task.wait(0.5)
                local molestado2 = workspace.WorkspaceCom["001_CanoeStorage"]:FindFirstChild("Canoe")
                if molestado2 and molestado2:FindFirstChild("VehicleSeat") then
                    repeat
                        RootPart.CFrame = molestado2.VehicleSeat.CFrame + Vector3.new(0, math.random(-1, 1), 0)
                        task.wait()
                    until Humanoid.Sit
                    task.wait(0.2)
                    RootPart.CFrame = CFrame.new(math.random(-40, 40), 4.549, math.random(-40, 40))
                    task.wait(0.2)
                    Humanoid.Sit = false
                    molestado2.Name = "CanoeShnmaxhubAndCartolaHub"
                end
            end
        end)
    end
end)

Fun:AddLabel("Helicopter Settings")
Fun:AddDropdown("Design List", {"Police", "Rescue", "Rich", "Military", "Agency", "Sheriff", "State Trooper"}, function(value)
    designHelico = value
end)

Fun:AddButton("Change Design", function()
    local meshIds = {
        Police = "PoliceMeshID",
        Rescue = "RescueMeshID",
        Rich = "TubeTVMeshID",
        Military = "MilitaryMeshID",
        Agency = "AgencyMeshID",
        Sheriff = "SheriffMeshID",
        ["State Trooper"] = "StateTrooperMeshID"
    }
    local meshId = meshIds[designHelico]
    if meshId then
        local args = {game.Players.LocalPlayer.Name, meshId}
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Max1y"):FireServer(unpack(args))
    end
end)

Fun:AddLabel("Horse Section")
Fun:AddButton("Tp All Horse", function()
    local players = game:GetService("Players")
    for _, player in pairs(players:GetPlayers()) do
        local args = {player}
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Hors1eRemot1e"):FireServer(unpack(args))
    end
end)

Fun:AddLabel("Modded Gun")
local function equipSniper()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player.Backpack
    local sniperTool = character:FindFirstChild("Sniper") or backpack:FindFirstChild("Sniper")

    if not sniperTool then
        local args = {"PickingTools", "Sniper"}
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args))
        task.wait(0.1)
        character.Humanoid:EquipTool(backpack:WaitForChild("Sniper"))
    elseif backpack:FindFirstChild("Sniper") then
        character.Humanoid:EquipTool(backpack["Sniper"])
    end
end

local function playSound(soundId)
    equipSniper()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local sniperHandle = character:FindFirstChild("Sniper") and character.Sniper:FindFirstChild("Handle")
    if sniperHandle then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = 0.1
        sound.Looped = false
        sound.Parent = player:WaitForChild("PlayerGui")
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
        local args = {sniperHandle, soundId, 1}
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Gu1nSound1s"):FireServer(unpack(args))
    end
end

Fun:AddButton("Jumpscare Gun", function()
    playSound(85435253347146)
end)
Fun:AddButton("Sus Gun", function()
    playSound(6701126635)
end)
Fun:AddButton("amongus Gun", function()
    playSound(6651571134)
end)
Fun:AddButton("Troll Laugh", function()
    playSound(7816195044)
end)
Fun:AddButton("Scream Entidade666 Gun", function()
    playSound(9043346124)
end)
Fun:AddButton("Tubers93 Gun", function()
    playSound(103215672097028)
end)

Fun:AddLabel("Sounds Gun")
local soundIdFromTextBox = nil

-- Adaptação para sua GUI: AddInput, AddButton, AddLabel
local function equipSniper()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player.Backpack
    local sniperTool = character:FindFirstChild("Sniper") or backpack:FindFirstChild("Sniper")

    if not sniperTool then
        local args = { "PickingTools", "Sniper" }
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args))
        task.wait(0.1)
        character.Humanoid:EquipTool(backpack:WaitForChild("Sniper"))
    elseif backpack:FindFirstChild("Sniper") then
        character.Humanoid:EquipTool(backpack["Sniper"])
    end
end

local function playSound(soundId)
    equipSniper()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local sniperHandle = character:FindFirstChild("Sniper") and character.Sniper:FindFirstChild("Handle")

    if sniperHandle then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = 0.1
        sound.Looped = false
        sound.Parent = player:WaitForChild("PlayerGui")
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)

        local args = { sniperHandle, tonumber(soundId), 1 }
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Gu1nSound1s"):FireServer(unpack(args))
    end
end

local soundIdFromTextBox = nil

Fun:AddInput("Sounds Box", "Enter Id here...", function(text)
    local num = tonumber(text)
    if num then
        soundIdFromTextBox = num
    end
end)

Fun:AddButton("Validate", function()
    if soundIdFromTextBox then
        playSound(soundIdFromTextBox)
    end
end)

Fun:AddLabel("Chat Troll Section")

Fun:AddButton("Press! Troll Error FilterChatMessage.Reconnecting..", function()
    if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(
            "hi\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\SHNMAXSCRIPTS: HELLO EVERYONE ☑️"
        )
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Not Supported",
            Text = "This game has the legacy ROBLOX chat version. The script can only be used in the new version of the ROBLOX chat. Sorry :("
        })
    end
end)

-- ====================
--  ⬇️Itens Buttons⬇️
-- ====================

Itens:AddLabel("Section Dupe Tools")

-- Dropdown for Item Selection
local ItemDropdown = Itens:AddDropdown("Select Item to Duplicate", {
    "Couch", "Crystal", "Crystals", "DSLR Camera", "SoccerBall", "EggLauncher",
    "Cuffs", "FireHose", "AgencyBook", "KeyCardWhite", "DuffleBagDiamonds",
    "BankGateKey", "SwordGold", "OldKey", "PaintRoller"
}, function(selectedItem)
    tool = selectedItem
end)

-- Dropdown for Quantity (simulating textbox)
Itens:AddDropdown("Number of Copies", {
    "1", "3", "5", "10", "15", "20", "30", "50", "100"
}, function(qtd)
    many = tonumber(qtd) or 0
end)

-- Remote References
local cleartoolremote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clea1rTool1s")
local picktoolremote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")

-- General Control
local stopProcess = false
local duping = true

-- Reset Function
local function resetCharacter()
    local player = game.Players.LocalPlayer
    if player.Character then
        player.Character:BreakJoints()
    end
end

-- Duplication Function
Itens:AddButton("Start Duplication", function()
    if tool == "None" then return end

    local player = game.Players.LocalPlayer
    local char = player.Character
    local oldcf = char.HumanoidRootPart.CFrame

    if char.Humanoid.Sit then
        char.Humanoid.Sit = false
        task.wait()
    end

    -- Teleport and Preparation
    local cam = workspace:FindFirstChild("Camera")
    if cam then cam:Destroy() end

    char.HumanoidRootPart.CFrame = CFrame.new(999999999, -495, 999999999)
    char.HumanoidRootPart.Anchored = true
    task.wait(0.5)

    -- Clear Tools
    for _, obj in pairs(char:GetChildren()) do
        if obj:IsA("Tool") and obj.Name ~= tool then
            obj.Parent = player.Backpack
        end
    end

    for _, t in pairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name ~= tool then
            t:Destroy()
        end
    end

    for _, t in pairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name ~= tool then
            t:Destroy()
        end
    end

    -- Rename and Prepare Tool
    local function handleTool(t)
        for _, part in pairs(t:GetDescendants()) do
            if part.Name == "Handle" then
                part.Name = "H⁥a⁥n⁥d⁥l⁥e"
                t.Parent = player.Backpack
                t.Parent = char
                return true
            end
        end
        return false
    end

    -- Ensure Clean Original Tool
    for _, t in pairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == tool then
            handleTool(t)
            repeat task.wait() until not char:FindFirstChild(t.Name)
        end
    end

    -- Duplication Loop
    for i = 1, many do
        if not duping then break end

        local cam = workspace:FindFirstChild("Camera")
        if cam then cam:Destroy() end

        picktoolremote:InvokeServer("PickingTools", tool)
        local newTool = player.Backpack:WaitForChild(tool)
        newTool.Parent = char

        task.wait()
        if newTool:FindFirstChild("Handle") then
            newTool.Handle.Name = "H⁥a⁥n⁥d⁥l⁥e"
        end

        newTool.Parent = player.Backpack
        newTool.Parent = char

        repeat
            local cam = workspace:FindFirstChild("Camera")
            if cam then cam:Destroy() end
            task.wait()
        until not char:FindFirstChild(tool)

        -- Notification
        game.StarterGui:SetCore("SendNotification", {
            Title = "Duplication",
            Text = "Duplicated [" .. tool .. "] (" .. i .. "/" .. many .. ")",
            Duration = 2,
            Icon = "rbxthumb://type=Asset&id=92433947031436&w=150&h=150"
        })
    end

    -- Final Reset
    char.HumanoidRootPart.Anchored = false
    repeat wait() until not char:FindFirstChild("HumanoidRootPart")
    repeat wait() until char:FindFirstChild("HumanoidRootPart")
    char.HumanoidRootPart.CFrame = oldcf
end)

-- Stop Button
Itens:AddButton("Stop Duplication", function()
    duping = false
end)

local BNumber = 2000

Itens:AddSwitch("Spam Basketball", function(state)
    if state then
        local Player = game.Players.LocalPlayer
        local Backpack = Player and Player:FindFirstChild("Backpack")
        local Mouse = Player and Player:GetMouse()
        local Character = Player and Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        local Clone = workspace:FindFirstChild("WorkspaceCom") and workspace.WorkspaceCom:FindFirstChild("001_GiveTools") and workspace.WorkspaceCom["001_GiveTools"]:FindFirstChild("Basketball")

        -- Verificações
        if not (Player and Backpack and Mouse and Character and Humanoid and RootPart and Clone) then
            warn("Erro: alguma instância necessária não foi encontrada.")
            return
        end

        local OldPos = RootPart.CFrame

        -- Spawn de bolas
        for i = 1, BNumber do
            task.wait()
            RootPart.CFrame = Clone.CFrame
            fireclickdetector(Clone:FindFirstChildOfClass("ClickDetector"))
        end

        task.wait()
        RootPart.CFrame = OldPos

        -- Loop de arremesso
        spawn(function()
            while state do
                task.wait()
                for _, tool in ipairs(Character:GetChildren()) do
                    if tool.Name == "Basketball" then
                        task.wait(0.0003)
                         args = {
                            Mouse.Hit.p
                        }
                        tool:FindFirstChild("ClickEvent"):FireServer(unpack(args))
                    end
                end
            end
        end)
    end
end)    

-- =====================
--  ⬇️Others Buttons⬇️
-- =====================

Others:AddLabel("Food Section")

Others:AddButton("Get Shopping Cart", function()
           args = {
          [1] = "PickingTools",
          [2] = "ShoppingCart"
          }
                        
picktoolremote:InvokeServer(unpack(args))
wait()
local character = player.Character
        local backpack = player.Backpack
        local humanoid = character:WaitForChild("Humanoid")
        local ShoppingCart = backpack:FindFirstChild("ShoppingCart")
        
        if not character:FindFirstChildOfClass("Tool") then
            if ShoppingCart then
                ShoppingCart.Parent = character
                humanoid:EquipTool(ShoppingCart)
             end
         end
    end)

local ChangeFoodCartloopEnabled = false
 
local function changeFoodLoop()
    while ChangeFoodCartloopEnabled do
     args = {
    [1] = "Banana"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
     args = {
    [1] = "Coke"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "Bloxaide"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "BottledWater"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "GreenApple"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "Apple"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "Pizza"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "ChipsBlue"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "Chips"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
wait(0.2)
 args = {
    [1] = "Milk"
}

game:GetService("Players").LocalPlayer.Character.ShoppingCart.ToolFood:FireServer(unpack(args))
      end
 end

Others:AddSwitch("Loop Food", function(Value)
        if Value then
               ChangeFoodCartloopEnabled = true
            changeFoodLoop()
        else
           ChangeFoodCartloopEnabled = false
        end
    end)
    
Others:AddLabel("Trail Section")
Others:AddButton("Enable Trail", function()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    local oldPos = hrp.CFrame
    local firstPos = CFrame.new(-349, 5, 98)

    local poolClick = Workspace:FindFirstChild("WorkspaceCom"):FindFirstChild("001_Hospital"):FindFirstChild("PoolClick")
    if poolClick and poolClick:FindFirstChild("ClickDetector") then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0

        hrp.CFrame = firstPos
        task.wait(1)
        hrp.CFrame = poolClick.CFrame
        fireclickdetector(poolClick.ClickDetector)
        task.wait(0.7)
        hrp.CFrame = oldPos

        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50

        notify("Trail", "Trail obtido com sucesso!")
    else
        warn("PoolClick ou ClickDetector não encontrado!")
        notify("Erro", "Trail não encontrado.")
    end
end)

Others:AddButton("Disable Trail", function()
	local character = game.Players.LocalPlayer.Character
	local humanoid = character:FindFirstChild("Humanoid")

	for _, part in pairs(character:GetChildren()) do
		if part:IsA("Part") or part:IsA("BasePart") or part:IsA("MeshPart") then
			if part.Anchored then
				part.Anchored = false
			end
		end
	end

	if humanoid then
		humanoid.Health = 0
	end
end)

Others:AddLabel("Sitting Section")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local antiToolSit = false
local antiCarSit = false
local conns = {}

local function updateSitState()
	local shouldPrevent = antiToolSit or antiCarSit
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Seated, not shouldPrevent)
	end
end

local function onCharacterAdded(char)
	local hum = char:WaitForChild("Humanoid")

	updateSitState()

	local conn = hum.StateChanged:Connect(function(_, new)
		if (antiToolSit or antiCarSit) and new == Enum.HumanoidStateType.Seated then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
	table.insert(conns, conn)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end

table.insert(conns, RunService.Heartbeat:Connect(updateSitState))

Others:AddSwitch("Anti Tool Sit", function(state)
	antiToolSit = state
	updateSitState()
end)

Others:AddSwitch("Anti Car Sit", function(state)
	antiCarSit = state
	updateSitState()
end)

Others:AddLabel("Airport")

Others:AddButton("Gun Detect", function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    local OldPos = RootPart.CFrame

    local ToolRemote = ReplicatedStorage:FindFirstChild("RE"):FindFirstChild("1Too1l")
    local ClearRemote = ReplicatedStorage:FindFirstChild("RE"):FindFirstChild("1Clea1rTool1s")

    if ToolRemote and ClearRemote then
        local success, err = pcall(function()
            ToolRemote:InvokeServer("PickingTools", "Sniper")
            local Sniper = Player.Backpack:FindFirstChild("Sniper")
            if Sniper then
                Sniper.Parent = Character
            end

            task.wait(0.5)
            RootPart.CFrame = CFrame.new(332, 4, 73)
            task.wait(2)
            RootPart.CFrame = OldPos
            task.wait(0.1)

            ClearRemote:FireServer("PlayerWantsToDeleteTool", "Sniper")
        end)

        if not success then
            warn("Gun Detect Failed: ", err)
        end
    else
        warn("Required remotes not found in ReplicatedStorage.RE")
    end
end)

Others:AddLabel("Chat Section (Roblox ban risk)")

local TextSave
local tcs = game:GetService("TextChatService")
local chat = tcs.ChatInputBarConfiguration.TargetTextChannel

function sendchat(msg)
	if tcs.ChatVersion == Enum.ChatVersion.LegacyChatService then
		game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(msg, "All")
	else
		chat:SendAsync(msg)
	end
end

Others:AddInput("Chat Box", "Enter text here...", function(text)
		TextSave = text
	end)

Others:AddButton("Validate", function()
		sendchat(TextSave)
	end)

local spamDelay = 1.2

Others:AddSwitch("Loop Chat", function(Value)
		getgenv().ShnmaxSpawnText = Value
		while getgenv().ShnmaxSpawnText do
			sendchat(TextSave)
			task.wait(spamDelay)
		end
	end)

Others:AddLabel("Commercial Section")
Others:AddInput("Commercial 1", "Enter text here...", function(value)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait(0.1)
local initialPosition = character.HumanoidRootPart.Position

local destination = Vector3.new(444.73675537109375, 63.137306213378906, 512.9107055664062)

character.HumanoidRootPart.CFrame = CFrame.new(destination)
         args = {
            [1] = "ReturningCommercialWords",
            [2] = 1,
            [4] = value
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))

         args = {
            [1] = "CommercialBackGround",
            [2] = 1,
            [3] = Color3.new(0, 0, 0)
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))

         args = {
            [1] = "CommercialWordColor",
            [2] = 1,
            [3] = Color3.new(1, 0, 0.0461044)
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))
wait(0.7)
character.HumanoidRootPart.CFrame = CFrame.new(initialPosition)
    end)

Others:AddInput("Commercial 2", "Enter text here...", function(value)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait(0.1)
local initialPosition = character.HumanoidRootPart.Position

local destination = Vector3.new(-634.5044555664062, 25.402376174926758, 362.7777404785156)

character.HumanoidRootPart.CFrame = CFrame.new(destination)
         args = {
            [1] = "ReturningCommercialWords",
            [2] = 2,
            [4] = value
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))

         args = {
            [1] = "CommercialBackGround",
            [2] = 2,
            [3] = Color3.new(0, 0, 0)
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))

         args = {
            [1] = "CommercialWordColor",
            [2] = 2,
            [3] = Color3.new(1, 0, 0.0461044)
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))
wait(0.7)
character.HumanoidRootPart.CFrame = CFrame.new(initialPosition)
    end)

Others:AddInput("Commercial 3", "Enter text here...", function(value)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait(0.1)
local initialPosition = character.HumanoidRootPart.Position

local destination = Vector3.new(-238.48960876464844, 88.5223617553711, -549.606689453125)

character.HumanoidRootPart.CFrame = CFrame.new(destination)
         args = {
            [1] = "ReturningCommercialWords",
            [2] = 3,
            [4] = value
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))

         args = {
            [1] = "CommercialBackGround",
            [2] = 3,
            [3] = Color3.new(0, 0, 0)
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))

         args = {
            [1] = "CommercialWordColor",
            [2] = 3,
            [3] = Color3.new(1, 0, 0.0461044)
        }
        game:GetService("ReplicatedStorage").RE["1Cemeter1y"]:FireServer(unpack(args))
wait(0.7)
character.HumanoidRootPart.CFrame = CFrame.new(initialPosition)
end)

-- =========================
--  ⬇️Teleportes Buttons⬇️
-- =========================

Teleportes:AddLabel("Teleports")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local function safeCall(func)
    local success, err = pcall(func)
    if not success then
        warn("Erro detectado: " .. err)
    end
end

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = "rbxthumb://type=Asset&id=92433947031436&w=150&h=150",
        Duration = 3
    })
end

local function teleportWithTween(targetPosition, nomeLocal)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if targetPosition and humanoidRootPart then
        local goal = {CFrame = CFrame.new(targetPosition)}
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
        tween:Play()

        tween.Completed:Connect(function()
            notify("Teleporte concluído", "Você foi para " .. nomeLocal)
        end)
    else
        warn("Posição ou personagem inválido para teleporte!")
    end
end

local teleportes = {
    {"Start", Vector3.new(-26.786, 4.549, -16.025)},
    {"Burger Barn", Vector3.new(149.82, 5.549, 60.242)},
    {"Motel", Vector3.new(170.196, 5.549, 266.061)},
    {"Police Station", Vector3.new(-119.9, 4.641, 8.176)},
    {"Ice Cream Shop", Vector3.new(-130.075, 4.649, -127.652)},
    {"Arcade", Vector3.new(-168.064, 4.649, -112.339)},
    {"Hair Salon", Vector3.new(-72.252, 4.649, -122.569)},
    {"Supermarket", Vector3.new(10.353, 4.649, -115.098)},
    {"Mall", Vector3.new(153.754, 4.775, -146.444)},
    {"Cinema", Vector3.new(198.996, -33.061, -179.751)},
    {"Airport", Vector3.new(295.139, 5.549, 40.569)},
    {"Bank", Vector3.new(1.074, 4.549, 237.577)},
    {"Clothing Store", Vector3.new(-41.549, 4.549, 238.717)},
    {"Cafe", Vector3.new(-96.891, 4.549, 236.663)},
    {"Library", Vector3.new(-129.832, 4.549, 242.131)},
    {"Post Office", Vector3.new(-183.435, 4.549, 240.83)},
    {"School", Vector3.new(-301.655, 4.749, 212.338)},
    {"Hospital", Vector3.new(-304.652, 4.636, 14.17)},
    {"Town Hall", Vector3.new(-354.4, 8.555, -101.754)},
    {"Fire Department", Vector3.new(-430.852, 4.549, -103.408)},
    {"Farm Horses", Vector3.new(-765.745, 4.149, -60.722)},
    {"Farm", Vector3.new(-842.876, 4.149, -395.368)},
    {"Drone Mountain", Vector3.new(-661.048, 251.373, 753.847)},
    {"Beach", Vector3.new(-236.487, 1.136, 760.252)},
    {"Forest House", Vector3.new(-186.256, 4.149, 1067.567)},
    {"Admin Island Shelby", Vector3.new(99948.8906, 10279.7881, -336.647461, 0.998488188, -0, -0.0549663343, 0, 1, -0, 0.0549663343, 0, 0.998488188)},
}

-- Substituir AddButton por NewButton
for _, info in ipairs(teleportes) do
    local nome, pos = info[1], info[2]
    Teleportes:AddButton("Teleporte " .. nome, function()
        safeCall(function()
            teleportWithTween(pos, nome)
        end)
    end)
end    

-- ===================
--  ⬇️Misc Buttons⬇️
-- ===================

Misc:AddLabel("Misc")

Misc:AddButton("Ant Lag All", function()
    local itemsToRemove = { "Laptop", "Bomb", "Phone", "FireEx", "FireHose", "Basketball" }
    local removeLookup = {}
    
    -- Adiciona os itens que devem ser removidos no dicionário
    for _, name in ipairs(itemsToRemove) do
        removeLookup[name] = true
    end

    local ClearDelay = 0.5 -- Delay entre cada varredura (ajustável)

    -- Função para destruir os itens do personagem
    local function destroyItemsInCharacter(character)
        if not character then return end
        for _, item in ipairs(character:GetChildren()) do
            if removeLookup[item.Name] then
                pcall(function()
                    item:Destroy()
                end)
            end
        end
    end

    -- Função para processar os jogadores
    local function processPlayers()
        for _, player in ipairs(game.Players:GetPlayers()) do
            pcall(function()
                if player.Character then
                    destroyItemsInCharacter(player.Character)
                end
            end)
        end
    end

    -- Spawn a task para rodar a função continuamente
    task.spawn(function()
        while task.wait(ClearDelay) do
            processPlayers()
        end
    end)
end)

Misc:AddLabel("Áudio All FE")

-- Inicialização das variáveis
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not _G.audio_all_delay then
    _G.audio_all_delay = 1
end

local function Audio_All_ClientSide(ID)
    local function CheckFolderAudioAll()
        local FolderAudio = workspace:FindFirstChild("Audio all client")
        if not FolderAudio then
            FolderAudio = Instance.new("Folder")
            FolderAudio.Name = "Audio all client"
            FolderAudio.Parent = workspace
        end
        return FolderAudio
    end

    local function CreateSound(ID)
        if type(ID) ~= "number" then
            print("Insira um número válido!")
            return nil
        end

        local Folder_Audio = CheckFolderAudioAll()
        if Folder_Audio then
            local Sound = Instance.new("Sound")
            Sound.SoundId = "rbxassetid://" .. ID
            Sound.Volume = 1
            Sound.Looped = false
            Sound.Parent = Folder_Audio
            Sound:Play()
            task.wait(3) -- Tempo de espera antes de remover o som
            Sound:Destroy()
        end
    end

    CreateSound(ID)
end

local function Audio_All_ServerSide(ID)
    if type(ID) ~= "number" then
        print("Insira um número válido!")
        return nil
    end

    local GunSoundEvent = ReplicatedStorage:FindFirstChild("1Gu1nSound1s", true)
    if GunSoundEvent then
        GunSoundEvent:FireServer(workspace, ID, 1)
    end
end

-- Lista de sons irritantes
local soundList = {
    {Name = "The Boiled One", ID = 82428031664905},
    {Name = "Risada de Malandro", ID = 133065882609605},
    {Name = "e o Pix Nada Ainda?", ID = 113831443375212},
    {Name = "PARE!", ID = 113127973012963},
    {Name = "Ele Gosta", ID = 105012436535315},
    {Name = "Notificação estourado", ID = 96579234730244},
    {Name = "fiui OLHA A MENSAGEM estourado", ID = 121668429878811},
    {Name = "Tome", ID = 128319664118768},
    {Name = "Vou Nada!", ID = 89093085290586},
    {Name = "Receba! luva de pedreiro", ID = 134333109446689},
    {Name = "IIIIHAA", ID = 115051649184918},
    {Name = "Toma Jack no ar-condicionado", ID = 105445757122032},
    {Name = "Nuossa", ID = 72065117445768},
    {Name = "Xingamento", ID = 8232773326},
    {Name = "Baldi Basic's Glitch", ID = 98207961689599},
    {Name = "Sucumba", ID = 7946300950},
    {Name = "Seek Jumpscare", ID = 133358860191747},    
    {Name = "DogDay Jumpscare", ID = 132162728926958}, 
    {Name = "Springtrap Jumpscare", ID = 17609408193},
    {Name = "Foxy Jumpscare", ID = 6949978667},    
    {Name = "Laugh", ID = 140395748019933},  
    {Name = "Skull's Laugh", ID = 100609956908791},    
    {Name = "Laugh Boss", ID = 6963880809},    
    {Name = "C00lkid No Fear!", ID = 126083075694948},    
    {Name = "C00lkid Hahaha", ID = 102348131944238},    
    {Name = "SirenHead", ID = 5681392074},    
    {Name = "Tubers93", ID = 103215672097028},    
    {Name = "Audio Glitcher Sound", ID = 7236490488},    
    {Name = "Oof Sound", ID = 6598984092},    
    {Name = "Buuuh Sound", ID = 83788010495185},    
    {Name = "My Heart Is Pure Evil Sound", ID = 106843479364998},    
    {Name = "Laugh Sound", ID = 123106903091799},    
    {Name = "Error Sound", ID = 3893790326},
    {Name = "I Ghost The Down Cool", ID = 115471962120051},
    {Name = "Lula e Alexandre", ID = 133885860917947},
    {Name = "Ai Lula, Ejacula Lula", ID = 18585340476},
    {Name = "Ah Lula", ID = 115491944196079},

}

-- Variáveis de controle
local options = {}
local audio_all_dropdown_value = nil

for _, sound in ipairs(soundList) do
    table.insert(options, sound.Name)
end

-- Função para tocar áudio
local function playAudio(audioId)
    if not audioId then
        warn("[Áudio ALL] Nenhum ID de áudio selecionado.")
        return
    end
    Audio_All_ServerSide(audioId)
    task.spawn(function()
        Audio_All_ClientSide(audioId)
    end)
end

-- Atualização de Dropdown
Misc:AddDropdown("Áudio ALL - Dropdown", options, function(selectedName)
    for _, sound in ipairs(soundList) do
        if sound.Name == selectedName then
            audio_all_dropdown_value = sound.ID
            break
        end
    end
    if not audio_all_dropdown_value then
        warn("[Áudio ALL] Nome selecionado inválido: " .. tostring(selectedName))
    end
end)

-- Novo botão para áudio
Misc:AddButton("AUDIO ALL - Press", function()
    if audio_all_dropdown_value then
        playAudio(audio_all_dropdown_value)
    else
        warn("[Áudio ALL] Nenhum áudio selecionado para tocar.")
    end
end)

-- Novo Toggle para loop de áudio a cada 4 segundos
Misc:AddSwitch("AUDIO ALL - Loop (Normal)", function(state)
    getgenv().Audio_All_loop_4s = state

    if state then
        warn("[Áudio ALL] Loop 4s iniciado. Aguardando intervalo de 4 segundos 🔊")
        task.spawn(function()
            while getgenv().Audio_All_loop_4s do
                if audio_all_dropdown_value then
                    playAudio(audio_all_dropdown_value)
                else
                    warn("[Áudio ALL] Nenhum áudio válido no loop.")
                end

                task.wait(3) -- Intervalo de 4 segundos entre cada áudio
            end
            warn("[Áudio ALL] Loop 4s encerrado. Ouvidos agradecem.")
        end)
    else
        warn("[Áudio ALL] Loop 4s desligado.")
    end
end)

-- Criação do toggle no menu Misc
Misc:AddSwitch("Áudio Spam Fast Glitcher", function(state)
    -- Define flag global
    getgenv().Audio_All_loop_fast = state

    if state then
        -- Inicia o loop paralelo principal
        spamLoop = task.spawn(function()
            while getgenv().Audio_All_loop_fast do
                for i = 1, soundsPerCycle do
                    task.spawn(function()
                        -- Dispara no servidor
                        Audio_All_ServerSide(audioID)

                        -- E no cliente em paralelo
                        task.spawn(function()
                            Audio_All_ClientSide(audioID)
                        end)
                    end)
                end

                task.wait(spamInterval)
            end
        end)
    else
        -- Finaliza o loop
        getgenv().Audio_All_loop_fast = false
        spamLoop = nil
    end
end)
Misc:AddLabel("Section Boombox FE")

Misc:AddButton("Boombox 100% FE", function()
    local player = game.Players.LocalPlayer
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local boombox
    local sg
    local lastID = 142376088

    local function createBoombox()
        boombox = Instance.new("Tool")
        boombox.Name = "Boombox"
        boombox.RequiresHandle = true
        boombox.Parent = player.Backpack

        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.CanCollide = false
        handle.Anchored = false
        handle.Transparency = 1
        handle.Parent = boombox

        boombox.Equipped:Connect(function()
            if sg then return end

            sg = Instance.new("ScreenGui")
            sg.Name = "ChooseSongGui"
            sg.Parent = playerGui  

            local frame = Instance.new("Frame")
            frame.Style = "RobloxRound"
            frame.Size = UDim2.new(0.25, 0, 0.25, 0)
            frame.Position = UDim2.new(0.375, 0, 0.375, 0)
            frame.Draggable = true
            frame.Active = true
            frame.Parent = sg

            local text = Instance.new("TextLabel")
            text.BackgroundTransparency = 1
            text.TextStrokeTransparency = 0
            text.TextColor3 = Color3.new(1, 1, 1)
            text.Size = UDim2.new(1, 0, 0.6, 0)
            text.TextScaled = true
            text.Text = "Lay down the beat! Put in the ID number for a song you love that's been uploaded to ROBLOX. Leave it blank to stop playing music."
            text.Parent = frame

            local input = Instance.new("TextBox")
            input.BackgroundColor3 = Color3.new(0, 0, 0)
            input.BackgroundTransparency = 0.5
            input.BorderColor3 = Color3.new(1, 1, 1)
            input.TextColor3 = Color3.new(1, 1, 1)
            input.TextStrokeTransparency = 1
            input.TextScaled = true
            input.Text = tostring(lastID)
            input.Size = UDim2.new(1, 0, 0.2, 0)
            input.Position = UDim2.new(0, 0, 0.6, 0)
            input.Parent = frame

            local button = Instance.new("TextButton")
            button.Style = "RobloxButton"
            button.Size = UDim2.new(0.75, 0, 0.2, 0)
            button.Position = UDim2.new(0.125, 0, 0.8, 0)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextStrokeTransparency = 0
            button.Text = "Play!"
            button.TextScaled = true
            button.Parent = frame

             args = {
                [1] = 18756289999
            }
            game:GetService("ReplicatedStorage").Remotes.Wear:InvokeServer(unpack(args))

            local function playAudioAll(ID)
                if type(ID) ~= "number" then
                    print("Please insert a valid number!")
                    return
                end
                local rs = game:GetService("ReplicatedStorage")
                local evt = rs:FindFirstChild("1Gu1nSound1s", true)
                if evt then
                    evt:FireServer(workspace, ID, 1)
                end
            end

            local function playAudioLocal(ID)
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://" .. ID
                sound.Volume = 1
                sound.Looped = false
                sound.Parent = player.Character or workspace
                sound:Play()
                task.wait(3)
                sound:Destroy()
            end

            button.MouseButton1Click:Connect(function()
                local soundID = tonumber(input.Text)
                if soundID then
                    lastID = soundID
                    playAudioAll(soundID)
                    playAudioLocal(soundID)
                    if sg then
                        sg:Destroy()
                        sg = nil
                    end
                else
                    print("Invalid ID!")
                end
            end)
        end)

        boombox.Unequipped:Connect(function()
            if sg then
                sg:Destroy()
                sg = nil
            end
             args = {
                [1] = 18756289999
            }
            game:GetService("ReplicatedStorage").Remotes.Wear:InvokeServer(unpack(args))
        end)

        boombox.AncestryChanged:Connect(function(_, parent)
            if not parent and sg then
                sg:Destroy()
                sg = nil
            end
        end)
    end

    createBoombox()
end)

local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Função para notificação padrão Roblox
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

-- Função para obter o Humanoid
local function getHumanoid()
    character = player.Character or player.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
end

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player local
local player = Players.LocalPlayer

-- Notificação padrão
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

-- INFINITE JUMP
local InfiniteJumpAtivado = false

local function toggleInfiniteJump(ativo)
    InfiniteJumpAtivado = ativo
    notify("Infinite Jump", ativo and "Ativado" or "Desativado")
end

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpAtivado then
        local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Misc:AddSwitch("Infinite Jump", function(state)
    toggleInfiniteJump(state)
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local NoclipPlayer = false
local NoclipBalls = false
local NoclipConnection

-- Função auxiliar: desativa colisão de todas as parts
local function DisableCollision(model)
	if model then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end

-- Função do loop
local function startNoclipLoop()
	if NoclipConnection then return end

	NoclipConnection = RunService.Stepped:Connect(function()
		if NoclipPlayer then
			local char = player.Character or player.CharacterAdded:Wait()
			DisableCollision(char)
		end

		if NoclipBalls then
			local container = workspace:FindFirstChild("WorkspaceCom")
			if container then
				local folder = container:FindFirstChild("001_SoccerBalls")
				DisableCollision(folder)
			end
		end

		if not NoclipPlayer and not NoclipBalls then
			NoclipConnection:Disconnect()
			NoclipConnection = nil
		end
	end)
end

-- Toggle: Noclip Player
Misc:AddSwitch("Noclip Player", function(state)
	NoclipPlayer = state
	notify("Noclip Player", state and "Ativado" or "Desativado")
	startNoclipLoop()
end)

-- Toggle: Noclip Balls
Misc:AddSwitch("Noclip Balls", function(state)
	NoclipBalls = state
	notify("Noclip Balls", state and "Ativado" or "Desativado")
	startNoclipLoop()
end)

-- ===================
--  ⬇️Kill Buttons⬇️
-- ===================

Kill:AddLabel("Kill and View")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local viewEnabled = false
local currentTarget = nil
local characterAddedConn = nil
local lastValidTarget = nil

local notificationIconId = "rbxassetid://92433947031436"

-- Notificação com headshot
function notify(title, text, player)
    local icon = notificationIconId

    if player and Players:FindFirstChild(player.Name) then
        local success, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if success and thumb then
            icon = thumb
        end
    end

    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = icon,
        Duration = 4
    })
end

-- Buscar jogador
function findPlayerByName(partialName)
    if not partialName or partialName == "" then return nil end

    partialName = partialName:lower()
    local foundPlayers = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local nameMatch = player.Name:lower():find(partialName, 1, true)
            local displayNameMatch = player.DisplayName:lower():find(partialName, 1, true)

            if nameMatch or displayNameMatch then
                table.insert(foundPlayers, {
                    player = player,
                    priority = (player.Name:lower():sub(1, #partialName) == partialName or player.DisplayName:lower():sub(1, #partialName) == partialName) and 1 or 2
                })
            end
        end
    end

    table.sort(foundPlayers, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return #a.player.Name < #b.player.Name
    end)

    return foundPlayers[1] and foundPlayers[1].player or nil
end

-- Resetar câmera
function resetCamera()
    if LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() then
        CurrentCamera.CameraSubject = LocalPlayer.Character:WaitForChild("Humanoid")
    end
end

-- Definir alvo
function setViewTarget(targetPlayer)
    if not targetPlayer or not targetPlayer:IsDescendantOf(Players) then
        notify("Erro", "Jogador inválido ou desconectado.")
        stopViewing()
        return
    end

    currentTarget = targetPlayer
    getgenv().Target = targetPlayer.Name
    lastValidTarget = targetPlayer.Name

    if characterAddedConn then
        characterAddedConn:Disconnect()
    end

    characterAddedConn = targetPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if viewEnabled and currentTarget == targetPlayer then
            local humanoid = char:WaitForChild("Humanoid", 5)
            if humanoid then
                CurrentCamera.CameraSubject = humanoid
            end
        end
    end)

    if targetPlayer.Character then
        local humanoid = targetPlayer.Character:FindFirstChild("Humanoid") or targetPlayer.Character:WaitForChild("Humanoid", 2)
        if humanoid then
            CurrentCamera.CameraSubject = humanoid
        end
    end
end

-- Parar visualização
function stopViewing()
    viewEnabled = false
    currentTarget = nil
    if characterAddedConn then
        characterAddedConn:Disconnect()
        characterAddedConn = nil
    end
    resetCamera()
    notify("View", "Visualização desativada.")
end

-- Render loop
RunService.RenderStepped:Connect(function()
    if viewEnabled and currentTarget then
        if not currentTarget:IsDescendantOf(game) then
            stopViewing()
            return
        end
        if currentTarget.Character then
            local humanoid = currentTarget.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and CurrentCamera.CameraSubject ~= humanoid then
                pcall(function()
                    CurrentCamera.CameraSubject = humanoid
                end)
            end
        end
    end
end)

-- UI Elements
local PlayerTextBox = Kill:AddInput("Target Player", "name or nickname..", function(texto)
    if texto == "" then
        if lastValidTarget then
            texto = lastValidTarget
        else
            notify("Erro", "Você precisa digitar um nome.")
            return
        end
    end

    local targetPlayer = findPlayerByName(texto)

    if targetPlayer and targetPlayer:IsDescendantOf(Players) then
        getgenv().Target = targetPlayer.Name
        lastValidTarget = targetPlayer.Name
        currentTarget = targetPlayer

        notify("Jogador Selecionado", "Alvo: " .. targetPlayer.DisplayName .. " (" .. targetPlayer.Name .. ")", targetPlayer)

        if viewEnabled then
            setViewTarget(targetPlayer)
        end
    else
        getgenv().Target = nil
        lastValidTarget = nil
        currentTarget = nil
        stopViewing()
        notify("Erro", "Nenhum jogador encontrado com: " .. texto)
    end
end)

Kill:AddSwitch("View", function(state)
    viewEnabled = state
    if state and getgenv().Target then
        local targetPlayer = findPlayerByName(getgenv().Target)
        if targetPlayer and targetPlayer:IsDescendantOf(Players) then
            setViewTarget(targetPlayer)
            notify("View Ativado", "Observando " .. targetPlayer.DisplayName .. " (" .. targetPlayer.Name .. ")", targetPlayer)
        else
            notify("Erro", "Jogador não encontrado: " .. tostring(getgenv().Target))
            viewEnabled = false
        end
    else
        stopViewing()
    end
end)

Kill:AddButton("Goto", function()
    local success, err = pcall(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if not hrp then 
            notify("Goto", "Seu personagem não tem HumanoidRootPart.")
            return 
        end

        local targetName = getgenv().Target
        if not targetName then
            notify("Goto", "Nenhum jogador selecionado.")
            return
        end

        local targetPlayer = findPlayerByName(targetName)
        if not targetPlayer or not targetPlayer.Character then
            notify("Goto", "Jogador inválido ou offline.")
            return
        end

        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then
            notify("Goto", "Jogador sem HumanoidRootPart.")
            return
        end

        hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        notify("Teleportado", "Você foi até " .. targetPlayer.DisplayName .. " (" .. targetPlayer.Name .. ")", targetPlayer)
    end)

    if not success then
        warn("[GOTO] Erro ao teleportar:", err)
        notify("Erro", "Falha ao teleportar: " .. tostring(err))
    end
end)

-- Alvo inicial
if getgenv().Target then
    local targetPlayer = findPlayerByName(getgenv().Target)
    if targetPlayer and targetPlayer:IsDescendantOf(Players) then
        lastValidTarget = targetPlayer.Name
    else
        getgenv().Target = nil
    end
end

Kill:AddLabel("Canoe")

Kill:AddButton("Jail Canoe", function()
    local nome = getgenv().Target
    if not nome then
        warn("Nenhum jogador definido.")
        return
    end

    local AlvoSelecionado = game.Players:FindFirstChild(nome)
    if not AlvoSelecionado then
        warn("Jogador não encontrado.")
        return
    end

    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    if humanoid.Sit then
        humanoid.Sit = false
        task.wait(0.5)
    end

    root.CFrame = workspace.WorkspaceCom["001_CanoeCloneButton"].Button.CFrame
    task.wait(0.4)
    fireclickdetector(workspace.WorkspaceCom["001_CanoeCloneButton"].Button.ClickDetector, 0)
    task.wait(0.4)

    local canoe = workspace.WorkspaceCom["001_CanoeStorage"].Canoe
    local seat = canoe:FindFirstChild("VehicleSeat")
    if not canoe.PrimaryPart then
        canoe.PrimaryPart = seat
    end

    local tentativas = 0
    repeat
        char:MoveTo(seat.Position + Vector3.new(0, 3, 0))
        task.wait(0.05)
        seat:Sit(humanoid)
        tentativas += 1
    until humanoid.Sit == true or tentativas > 100

    if not humanoid.Sit then
        warn("Falhou em sentar no barco.")
        return
    end

    local alvoChar = AlvoSelecionado.Character or AlvoSelecionado.CharacterAdded:Wait()
    local alvoRoot = alvoChar:WaitForChild("HumanoidRootPart")
    local alvoHum = alvoChar:WaitForChild("Humanoid")

    local distancia = 10
    local sentido = 1
    local ativo = true

    while ativo and humanoid.Sit and alvoChar and alvoHum and alvoHum.Health > 0 do
        if alvoHum.SeatPart then
            -- Leva pro void
            local cfVoid = CFrame.new(Vector3.new(0, -12000, 0))
            for i = 1, 30 do
                canoe:SetPrimaryPartCFrame(cfVoid)
                char:SetPrimaryPartCFrame(cfVoid)
                alvoChar:SetPrimaryPartCFrame(cfVoid)
                task.wait()
            end

            if seat then
                seat.Throttle = 0
                seat.Steer = 0
            end
            if canoe:FindFirstChild("BodyVelocity") then
                canoe.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            if canoe:FindFirstChild("BodyAngularVelocity") then
                canoe.BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
            end

            game.StarterGui:SetCore("SendNotification", {
                Title = "ShnmaxHub",
                Text = AlvoSelecionado.Name .. " foi preso no void.",
                Duration = 5
            })

            -- Você volta e deixa o resto lá
            if root.Position.Y < -1000 then
                humanoid.Sit = false
                task.wait(0.2)
                root.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            end

            ativo = false
        else
            local offset = alvoRoot.CFrame.LookVector * distancia * sentido
            local pos = alvoRoot.Position + offset
            canoe:SetPrimaryPartCFrame(CFrame.new(pos, alvoRoot.Position))
            sentido = -sentido
            task.wait()
        end
    end
end)

Kill:AddButton("Kill Canoe", function()
    local nome = getgenv().Target
    if not nome then
        warn("Nenhum jogador definido.")
        return
    end

    local AlvoSelecionado = game.Players:FindFirstChild(nome)
    if not AlvoSelecionado then
        warn("Jogador não encontrado.")
        return
    end

    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    -- Se estiver sentado, levanta
    if humanoid.Sit then
        humanoid.Sit = false
        task.wait(0.5)
    end

    -- Vai até o botão do barco
    root.CFrame = workspace.WorkspaceCom["001_CanoeCloneButton"].Button.CFrame
    task.wait(0.4)
    fireclickdetector(workspace.WorkspaceCom["001_CanoeCloneButton"].Button.ClickDetector, 0)
    task.wait(0.4)

    local canoe = workspace.WorkspaceCom["001_CanoeStorage"].Canoe
    local seat = canoe:FindFirstChild("VehicleSeat")

    if not canoe.PrimaryPart then
        canoe.PrimaryPart = seat
    end

    -- Tenta sentar
    local tentativas = 0
    repeat
        char:MoveTo(seat.Position + Vector3.new(0, 3, 0))
        task.wait(0.05)
        seat:Sit(humanoid)
        tentativas += 1
    until humanoid.Sit == true or tentativas > 100

    if not humanoid.Sit then
        warn("Falhou em sentar no barco.")
        return
    end

    local alvoChar = AlvoSelecionado.Character or AlvoSelecionado.CharacterAdded:Wait()
    local alvoRoot = alvoChar:WaitForChild("HumanoidRootPart")
    local alvoHum = alvoChar:WaitForChild("Humanoid")

    local distancia = 10
    local sentido = 1
    local ativo = true

    while ativo and humanoid.Sit and alvoChar and alvoHum and alvoHum.Health > 0 do
        if alvoHum.SeatPart then
            -- VOID
            local cfVoid = CFrame.new(Vector3.new(0, -12000, 0))
            for i = 1, 30 do
                canoe:SetPrimaryPartCFrame(cfVoid)
                char:SetPrimaryPartCFrame(cfVoid)
                alvoChar:SetPrimaryPartCFrame(cfVoid)
                task.wait()
            end

            if seat then
                seat.Throttle = 0
                seat.Steer = 0
            end
            if canoe:FindFirstChild("BodyVelocity") then
                canoe.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            if canoe:FindFirstChild("BodyAngularVelocity") then
                canoe.BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
            end

            game.StarterGui:SetCore("SendNotification", {
                Title = "ShnmaxHub",
                Text = AlvoSelecionado.Name .. " está no void!",
                Duration = 5
            })

            -- Se estiver em zona de teleporte, levanta, teleporta e destrói o barco
            if root.Position.Y < -1000 then
                humanoid.Sit = false
                task.wait(0.2)
                root.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
                task.wait(0.2)

                -- Tenta destruir o barco
                pcall(function()
                    if canoe and canoe.Parent then
                        canoe:Destroy()
                    end
                end)
            end

            ativo = false
        else
            local offset = alvoRoot.CFrame.LookVector * distancia * sentido
            local pos = alvoRoot.Position + offset
            canoe:SetPrimaryPartCFrame(CFrame.new(pos, alvoRoot.Position))
            sentido = -sentido
            task.wait()
        end
    end
end)

Kill:AddButton("Fling Canoe", function()
    local nome = getgenv().Target
    if not nome then
        warn("Nenhum jogador definido.")
        return
    end

    local AlvoSelecionado = game.Players:FindFirstChild(nome)
    if not AlvoSelecionado then
        warn("Jogador não encontrado.")
        return
    end

    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    if humanoid.Sit then
        humanoid.Sit = false
        task.wait(0.5)
    end

    root.CFrame = workspace.WorkspaceCom["001_CanoeCloneButton"].Button.CFrame
    task.wait(0.4)
    fireclickdetector(workspace.WorkspaceCom["001_CanoeCloneButton"].Button.ClickDetector, 0)
    task.wait(0.4)

    local canoe = workspace.WorkspaceCom["001_CanoeStorage"].Canoe
    local seat = canoe:FindFirstChild("VehicleSeat")

    if not canoe.PrimaryPart then
        canoe.PrimaryPart = seat
    end

    -- Sentar no barco
    local tentativas = 0
    repeat
        char:MoveTo(seat.Position + Vector3.new(0, 3, 0))
        task.wait(0.05)
        seat:Sit(humanoid)
        tentativas += 1
    until humanoid.Sit == true or tentativas > 100

    if not humanoid.Sit then
        warn("Falhou em sentar no barco.")
        return
    end

    -- Prepara peças do alvo
    local alvoChar = AlvoSelecionado.Character or AlvoSelecionado.CharacterAdded:Wait()
    local alvoRoot = alvoChar:WaitForChild("HumanoidRootPart")
    local alvoHum = alvoChar:WaitForChild("Humanoid")

    -- Fling mode
    local force = Instance.new("BodyForce", canoe.PrimaryPart)
    local angular = Instance.new("BodyAngularVelocity", canoe.PrimaryPart)
    angular.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    angular.AngularVelocity = Vector3.new(1000, 5000, 1000) -- rotação em torno do Y
    angular.P = 1e9

    local ativo = true
    local distancia = 10
    local sentido = 1

    while ativo and humanoid.Sit and alvoChar and alvoHum and alvoHum.Health > 0 do
        -- Direção até o alvo
        local offset = alvoRoot.CFrame.LookVector * distancia * sentido
        local pos = alvoRoot.Position + offset
        canoe:SetPrimaryPartCFrame(CFrame.new(pos, alvoRoot.Position))
        sentido = -sentido

        -- Força extrema aplicada ao barco (direto pro centro do alvo)
        local dir = (alvoRoot.Position - canoe.PrimaryPart.Position).Unit
        force.Force = dir * 1e6 + Vector3.new(0, workspace.Gravity * canoe.PrimaryPart:GetMass(), 0)

        task.wait()
    end

    -- Cleanup
    angular:Destroy()
    force:Destroy()
end)

Kill:AddButton("Disable - FlingCanoe", function()
    getgenv().FlingAtivo = false

    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    -- Levanta se estiver sentado
    if humanoid.Sit then
        humanoid.Sit = false
        task.wait(0.3)
    end

    -- Tenta destruir o barco
    local canoe = workspace:FindFirstChild("WorkspaceCom")
    if canoe then
        local canoeStorage = canoe:FindFirstChild("001_CanoeStorage")
        if canoeStorage and canoeStorage:FindFirstChild("Canoe") then
            pcall(function()
                canoeStorage.Canoe:Destroy()
            end)
        end
    end

    -- Volta pra posição original
    local retorno = getgenv().RetornoPos or Vector3.new(1118.81, 75.998, -1138.61)
    root.CFrame = CFrame.new(retorno)

    -- Função pra limpar BodyVelocity e Attachments do alvo
    local function clearTargetForces()
        local target = game.Players:FindFirstChild(getgenv().Target)
        if target and target.Character then
            for _, obj in ipairs(target.Character:GetDescendants()) do
                if obj:IsA("BodyVelocity") or obj:IsA("Attachment") then
                    obj:Destroy()
                end
            end
        end
    end

    -- Reset físico seguro
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    root.Anchored = true
    root.CFrame = CFrame.new(retorno)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    print("Jogador teleportado para a posição segura.")
    clearTargetForces()

    task.wait(2)

    root.Anchored = false
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    print("Jogador liberado com segurança.")
end)

Kill:AddLabel("Door Fling")

Kill:AddButton("Door Flinger Beta", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")

    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")

    local HRPAttachment = Instance.new("Attachment")
    HRPAttachment.Name = "SHNMAX_CentralCore"
    HRPAttachment.Parent = HRP

    local ControlledDoors = {}
    local FlingInProgress = false

    local function SetupPart(part)
        if not part:IsA("BasePart") or part.Anchored or not string.find(part.Name, "Door") then return end
        if part:FindFirstChild("SHNMAX_Attached") then return end

        part.CanCollide = false

        for _, obj in ipairs(part:GetChildren()) do
            if obj:IsA("AlignPosition") or obj:IsA("Torque") or obj:IsA("Attachment") then
                obj:Destroy()
            end
        end

        local marker = Instance.new("BoolValue", part)
        marker.Name = "SHNMAX_Attached"

        local a1 = Instance.new("Attachment", part)
        a1.Name = "SHNMAX_LocalAttach"

        local align = Instance.new("AlignPosition", part)
        align.Attachment0 = a1
        align.Attachment1 = HRPAttachment
        align.MaxForce = 1e20
        align.MaxVelocity = math.huge
        align.Responsiveness = 9999

        local torque = Instance.new("Torque", part)
        torque.Attachment0 = a1
        torque.RelativeTo = Enum.ActuatorRelativeTo.World
        torque.Torque = Vector3.new(
            math.random(-1e6, 1e6),
            math.random(-1e6, 1e6),
            math.random(-1e6, 1e6)
        ) * 10000

        table.insert(ControlledDoors, {Part = part, Align = align, Attach = a1})
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(obj.Name, "Door") then
            SetupPart(obj)
        end
    end

    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and string.find(obj.Name, "Door") then
            SetupPart(obj)
        end
    end)

    local function FlingTargetPlayer()
        local targetPlayer = Players:FindFirstChild(getgenv().Target)
        if not targetPlayer or not targetPlayer.Character then return end
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end

        if FlingInProgress then return end
        FlingInProgress = true

        local targetAttachment = targetHRP:FindFirstChild("SHNMAX_TargetAttachment")
        if not targetAttachment then
            targetAttachment = Instance.new("Attachment", targetHRP)
            targetAttachment.Name = "SHNMAX_TargetAttachment"
        end

        for _, data in ipairs(ControlledDoors) do
            if data.Align then
                data.Align.Attachment1 = targetAttachment
            end
        end

        print("[SHNMAX] Portas foram até o alvo:", targetPlayer.Name)

        local start = tick()
        local flingDetected = false

        while tick() - start < 5 do
            if targetHRP.Velocity.Magnitude >= 50 then
                flingDetected = true
                break
            end
            RunService.Heartbeat:Wait()
        end

        -- Voltar portas para o jogador
        for _, data in ipairs(ControlledDoors) do
            if data.Align then
                data.Align.Attachment1 = HRPAttachment
            end
        end

        print("[SHNMAX] Resultado:", targetPlayer.Name, flingDetected and "Flingado!" or "Falhou")

        FlingInProgress = false
    end

    -- Loop automático de verificação com até 3 tentativas
    task.spawn(function()
        local attempts = 0
        local maxAttempts = 3

        while attempts < maxAttempts do
            local target = Players:FindFirstChild(getgenv().Target)
            if target and target.Character and target ~= LocalPlayer then
                FlingTargetPlayer()
                attempts += 1
            end
            task.wait(7)
        end

        print("[SHNMAX] Fim das tentativas de fling. Modo automático encerrado.")
    end)
end)

Kill:AddLabel("Ball")

Kill:AddButton("Fling Ball", function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local targetPlayer = Players:FindFirstChild(getgenv().Target)
    if not targetPlayer or not targetPlayer.Character then
        warn("Nenhum jogador selecionado.")
        return
    end

    -- Limpa as forças antigas da bola
    local function clearForces(ball)
        for _, obj in ipairs(ball:GetChildren()) do
            if obj:IsA("BodyForce") or obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyAngularVelocity") then
                obj:Destroy()
            end
        end
    end

    -- Aplica forças poderosas na bola
    local function applyFlingForces(ball)
        clearForces(ball)

        local force = Instance.new("BodyForce")
        force.Force = Vector3.new(1e14, 1e14, 1e14)
        force.Parent = ball

        local spin = Instance.new("BodyAngularVelocity")
        spin.AngularVelocity = Vector3.new(1e14, 1e14, 1e14)
        spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        spin.P = 1e14
        spin.Parent = ball
    end

    -- Espera até a bola estar no workspace
    local function waitForWorkspaceBall()
        local ballName = "Soccer" .. player.Name
        local ball
        repeat
            ball = workspace.WorkspaceCom["001_SoccerBalls"]:FindFirstChild(ballName)
            task.wait()
        until ball
        return ball
    end

    -- Limpa ferramentas antigas e pega a bola nova
    ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s"):FireServer("PlayerWantsToDeleteTool", "SoccerBall")
    ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "SoccerBall")

    repeat task.wait() until player.Backpack:FindFirstChild("SoccerBall")
    local localBall = player.Backpack:FindFirstChild("SoccerBall")
    if not localBall then
        warn("Bola não encontrada na mochila.")
        return
    end

    localBall.Parent = player.Character
    task.wait(0.25) -- Aguarda a bola ser carregada na Character

    local workspaceBall = waitForWorkspaceBall()
    applyFlingForces(workspaceBall) -- garante forças logo que a bola está no workspace

    -- Tracking com bola 2 studs à frente quando o alvo andar
    local function trackAndFling()
        local char = targetPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        local altToggle = true
        RunService.Heartbeat:Connect(function()
            if not workspaceBall or not hrp or humanoid.Health <= 0 then return end

            local speed = hrp.Velocity.Magnitude
            local direction = hrp.Velocity.Unit

            -- Reaplica forças todo frame pra garantir consistência do fling
            applyFlingForces(workspaceBall)

            if speed > 1 then
                local forwardPos = hrp.Position + direction * 6
                workspaceBall.CFrame = CFrame.new(forwardPos + Vector3.new(0, -1, 0))
            else
                local offsetY = altToggle and 1 or -1
                workspaceBall.CFrame = CFrame.new(hrp.Position + Vector3.new(0, offsetY, 0))
                altToggle = not altToggle
            end
        end)
    end

    trackAndFling()
end)

Kill:AddLabel("Couch")

Kill:AddButton("Bring Couch", function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = Players.LocalPlayer
    local Backpack = Player:WaitForChild("Backpack")
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")

    -- Função para checar se já tem o Couch (equipado ou na backpack)
    local function HasCouch()
        return Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
    end

    -- Equipar Couch, ajustar GripPos e só então equipar para usar
    local function EquipCouch()
        if HasCouch() then return true end

        local remote = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Too1l")
        if not remote then
            warn("Remote para equipar Couch não encontrado.")
            return false
        end

        local args = { "PickingTools", "Couch" }
        remote:InvokeServer(unpack(args))

        local timeout = 5
        local startTime = tick()
        while not Backpack:FindFirstChild("Couch") and tick() - startTime < timeout do
            task.wait(0.1)
        end

        local couchTool = Backpack:FindFirstChild("Couch")
        if not couchTool then
            warn("Falha ao obter Couch na backpack.")
            return false
        end

        -- Ajusta GripPos para reposicionar o item
        if couchTool:FindFirstChild("Handle") then
            couchTool.GripPos = Vector3.new(2, 5, -1)
        else
            warn("Handle não encontrado no item Couch")
        end

        -- Agora equipa o Couch ajustado
        Humanoid:EquipTool(couchTool)
        return true
    end

    -- Equipa o Couch e só segue se conseguir
    if not EquipCouch() then
        return
    end

    -- Seleciona o alvo
    local TargetPlayer = Players:FindFirstChild(getgenv().Target)
    if not TargetPlayer or not TargetPlayer.Character then
        return warn("Alvo inválido ou personagem não encontrado.")
    end

    local TCharacter = TargetPlayer.Character
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    -- Salva posição original se o player estiver parado
    if RootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = RootPart.CFrame
    end

    -- Função que reposiciona o player em relação a uma base com offset e ângulo
    local function FPos(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    -- Movimento dinâmico para 'empurrar' o alvo
    local function SFBasePart(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0

        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle += 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                    task.wait()

                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                else
                    for _, offset in ipairs({1.5, -1.5, 1.5, 1.5, -1.5, 1.5, -1.5, -1.5, -1.5}) do
                        FPos(BasePart, CFrame.new(0, offset, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                    end
                end
            else
                break
            end
        until
            BasePart.Velocity.Magnitude > 500
            or BasePart.Parent ~= TCharacter
            or TargetPlayer.Parent ~= Players
            or not (TargetPlayer.Character == TCharacter)
            or THumanoid.Sit
            or Humanoid.Health <= 0
            or tick() > Time + TimeToWait
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart and THead then
        if (TRootPart.Position - THead.Position).Magnitude > 5 then
            SFBasePart(THead)
        else
            SFBasePart(TRootPart)
        end
    elseif TRootPart then
        SFBasePart(TRootPart)
    elseif THead then
        SFBasePart(THead)
    elseif Handle then
        SFBasePart(Handle)
    else
        warn("Nenhuma parte válida do alvo encontrada.")
    end

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid

    repeat
        RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
        Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        for _, part in ipairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new()
                part.RotVelocity = Vector3.new()
            end
        end
        task.wait()
    until (RootPart.Position - getgenv().OldPos.Position).Magnitude < 25

    workspace.FallenPartsDestroyHeight = getgenv().FPDH or -500
end)

Kill:AddButton("Kill Couch", function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    local Backpack = Player:WaitForChild("Backpack")

    -- Verificar e equipar o item "Couch"
    local function EquipCouch()
        local couchTool = Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
        if not couchTool then
            local args = { [1] = "PickingTools", [2] = "Couch" }
            local remote = ReplicatedStorage:FindFirstChild("RE"):FindFirstChild("1Too1l")
            if remote then
                remote:InvokeServer(unpack(args))
                local timeout = 5
                local waited = 0
                repeat
                    couchTool = Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
                    task.wait(0.1)
                    waited += 0.1
                until couchTool or waited >= timeout
            end
        end

        if couchTool then
            -- Aplica o GripPos personalizado
            if couchTool:FindFirstChild("Handle") then
                couchTool.GripPos = Vector3.new(2, 5, -1)
            else
                warn("Handle não encontrado no item Couch")
            end

            -- Reequipar após mudar GripPos
            if Backpack:FindFirstChild("Couch") then
                Humanoid:EquipTool(couchTool)
            else
                couchTool.Parent = Backpack
                task.wait()
                Humanoid:EquipTool(couchTool)
            end
        else
            warn("Couch não encontrado após tentativa de pegar.")
        end
    end

    EquipCouch()

    -- Seleção do alvo
    local TargetPlayer = Players:FindFirstChild(getgenv().Target)
    if not TargetPlayer or not TargetPlayer.Character then
        return warn("Alvo inválido ou personagem não encontrado.")
    end

    local TCharacter = TargetPlayer.Character
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and (THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart"))

    -- Salva posição original
    if RootPart and RootPart.Position.Magnitude < 99999 then
        getgenv().OldPos = RootPart.CFrame
    end

    -- Posicionamento dinâmico
    local function FPos(BasePart, Pos, Ang)
        local targetCFrame = CFrame.new(BasePart.Position) * Pos * Ang
        RootPart.CFrame = targetCFrame
        Character:SetPrimaryPartCFrame(targetCFrame)
    end

    -- MONITORA se o alvo sentar
    task.spawn(function()
        local alreadyHandled = false
        while THumanoid and THumanoid.Parent and Humanoid.Health > 0 and not alreadyHandled do
            if THumanoid.Sit then
                alreadyHandled = true

                -- Vai pro void
                local escapePos = CFrame.new(0, -700, 0)
                RootPart.CFrame = escapePos
                Character:SetPrimaryPartCFrame(escapePos)

                -- Espera 1 segundo
                task.wait(1)

                -- Dispara o remote pra desequipar a Couch
                local clearRemote = ReplicatedStorage:FindFirstChild("RE"):FindFirstChild("1Clea1rTool1s")
                if clearRemote then
                    clearRemote:FireServer("ClearAllTools")
                end

                task.wait(0.3)

                -- Só depois de remover a Couch, volta pra posição original
                if getgenv().OldPos then
                    RootPart.CFrame = getgenv().OldPos
                    Character:SetPrimaryPartCFrame(getgenv().OldPos)
                    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
            task.wait(0.1)
        end
    end)

    -- Dança do push (força o alvo a sentar)
    local function SFBasePart(BasePart)
        local TempoMax = 5
        local Inicio = tick()
        local Angulo = 0

        repeat
            if not THumanoid or not RootPart then break end

            if BasePart.Velocity.Magnitude < 50 then
                Angulo += 100

                FPos(BasePart, CFrame.new(0, 1.5, 0), CFrame.Angles(math.rad(Angulo), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(Angulo), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(2.25, 1.5, -2.25), CFrame.Angles(math.rad(Angulo), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25), CFrame.Angles(math.rad(Angulo), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                FPos(BasePart, CFrame.new(0, -1.5, TRootPart.Velocity.Magnitude / -1.25), CFrame.Angles(0, 0, 0))
                task.wait()
            end
        until tick() > Inicio + TempoMax or THumanoid.Sit or Humanoid.Health <= 0
    end

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart then
        SFBasePart(TRootPart)
    else
        warn("Parte do corpo do alvo não encontrada para movimentação.")
    end

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
end)

Kill:AddButton("Fling Couch", function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = Players.LocalPlayer
    local Backpack = Player:WaitForChild("Backpack")
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    local function HasCouch()
        return Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
    end

    local function EquipCouch()
        local couchTool = Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
        if couchTool then
            Humanoid:EquipTool(couchTool)
            return couchTool
        end
        return nil
    end

    local function IsGripAdjusted(tool)
        if not tool or not tool:FindFirstChild("Handle") then return false end
        local grip = tool.GripPos
        -- Se grip já tá no ajuste esperado, considera ajustado
        return (grip - Vector3.new(2, 5, -1)).Magnitude < 0.01
    end

    local couchTool = nil

    if HasCouch() then
        couchTool = EquipCouch()
        if couchTool and not IsGripAdjusted(couchTool) then
            couchTool.GripPos = Vector3.new(2, 5, -1)
            -- Reequipar pra aplicar o GripPos atualizado
            Humanoid:UnequipTools()
            task.wait(0.1)
            Humanoid:EquipTool(couchTool)
            task.wait(0.5)
        end
    else
        -- Não tem Couch, pega via remote
        local remote = ReplicatedStorage.RE:FindFirstChild("1Too1l")
        if not remote then
            warn("Remote 1Too1l não encontrado!")
            return
        end
        local args = {"PickingTools", "Couch"}
        local success, err = pcall(function()
            remote:InvokeServer(unpack(args))
        end)
        if not success then
            warn("Erro ao invocar remote:", err)
            return
        end

        -- Aguarda o Couch aparecer
        local timeout, waited = 5, 0
        repeat
            task.wait(0.1)
            waited += 0.1
        until HasCouch() or waited >= timeout

        if not HasCouch() then
            warn("Couch não apareceu após solicitação.")
            return
        end

        couchTool = EquipCouch()
        if couchTool then
            couchTool.GripPos = Vector3.new(2, 5, -1)
            Humanoid:UnequipTools()
            task.wait(0.1)
            Humanoid:EquipTool(couchTool)
            task.wait(0.5)
        else
            warn("Falha ao equipar Couch após pegar.")
            return
        end
    end

    -- Agora é só partir pro alvo com couchTool equipado
    -- Aqui entra a lógica do fling (igual antes)
    -- Exemplo simples:
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    getgenv().AllowFling = true

    local TargetPlayer = Players:FindFirstChild(getgenv().Target)
    if not TargetPlayer or not TargetPlayer.Character then
        warn("Alvo inválido.")
        return
    end

    local TCharacter = TargetPlayer.Character
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    local Seat = TCharacter:FindFirstChildWhichIsA("Seat", true)

    local BasePart = Seat or TRootPart or THead or Handle
    if not BasePart then
        warn("Nenhuma parte válida do alvo.")
        return
    end

    workspace.FallenPartsDestroyHeight = 0/0
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local BV = Instance.new("BodyVelocity")
    BV.Name = "FlingForce"
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

    local function FPos(BasePart, Pos, Ang)
        if not getgenv().AllowFling then return end
        local cf = BasePart.CFrame * Pos * Ang
        RootPart.CFrame = cf
        Character:SetPrimaryPartCFrame(cf)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    task.spawn(function()
        local Angle = 0
        while getgenv().AllowFling and TargetPlayer.Parent == Players and BasePart:IsDescendantOf(TCharacter) do
            Angle += 100
            local moves = {
                CFrame.new(0, 1.5, 0),
                CFrame.new(0, -1.5, 0),
                CFrame.new(2.25, 1.5, -2.25),
                CFrame.new(-2.25, -1.5, 2.25),
                CFrame.new(0, 1.5, THumanoid.WalkSpeed),
                CFrame.new(0, -1.5, -THumanoid.WalkSpeed),
                CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25),
                CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25)
            }

            for _, move in ipairs(moves) do
                FPos(BasePart, move + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
            end
        end
    end)
end)

Kill:AddButton("Disable - Fling Couch", function()
    -- Desativa flags globais
    getgenv().AllowFling = false
    getgenv().AllowReturn = false

    local Player = game.Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not RootPart or not Humanoid then
        warn("RootPart ou Humanoid não encontrado.")
        return
    end

    local fixedReturnPos = Vector3.new(1118.81, 75.998, -1138.61)

    -- Destrói qualquer tipo de força ou constraint
    for _, obj in ipairs(Character:GetDescendants()) do
        if obj:IsA("BodyMover") or obj:IsA("Constraint") or obj:IsA("VectorForce") or obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") or obj:IsA("LinearVelocity") or obj:IsA("Torque") then
            pcall(function()
                obj:Destroy()
            end)
        end
    end

    -- Paralisa o jogador com estilo
    Humanoid.PlatformStand = true
    RootPart.Anchored = true
    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.AssemblyAngularVelocity = Vector3.zero

    -- Teleporta para local seguro
    RootPart.CFrame = CFrame.new(fixedReturnPos)
    print("Jogador teleportado para a posição segura.")

    -- Espera antes de liberar
    task.wait(3)

    -- Libera o jogador
    RootPart.Anchored = false
    Humanoid.PlatformStand = false
    print("Jogador liberado com segurança.")
end)

Kill:AddLabel("Vehicle")

Kill:AddButton("Active - FlingBus", function()
	local Player = game.Players.LocalPlayer
	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	local Vehicles = workspace:FindFirstChild("Vehicles")
	local OldPos = RootPart and RootPart.CFrame

	if not Humanoid or not RootPart then return end

	local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
	if not PCar then
		RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
		task.wait(0.5)
		local Remote = game.ReplicatedStorage:FindFirstChild("RE") and game.ReplicatedStorage.RE:FindFirstChild("1Ca1r")
		if Remote then Remote:FireServer("PickingCar", "Bus") end
		task.wait(0.5)
		PCar = Vehicles:FindFirstChild(Player.Name.."Car")
	end

	local timeout = 5
	while timeout > 0 and not PCar do
		task.wait(0.25)
		PCar = Vehicles:FindFirstChild(Player.Name.."Car")
		timeout -= 0.25
	end
	if not PCar then return end

	task.wait(0.5)
	if PCar and not Humanoid.Sit then
		local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
		if Seat then
			repeat task.wait()
				RootPart.CFrame = Seat.CFrame
			until Humanoid.Sit
		end
	end

	local attachment, force

	local function getTargetInfo()
		while true do
			local TargetPlayer = game.Players:FindFirstChild(getgenv().Target)
			if TargetPlayer then
				local TargetC = TargetPlayer.Character
				local TargetH = TargetC and TargetC:FindFirstChildOfClass("Humanoid")
				local TargetRP = TargetC and TargetC:FindFirstChild("HumanoidRootPart")
				if TargetC and TargetH and TargetRP then
					return TargetC, TargetH, TargetRP
				end
			end
			task.wait(0.2)
		end
	end

	local TargetC, TargetH, TargetRP = getTargetInfo()

	-- Ativando bodyvelocity no alvo
	attachment = Instance.new("Attachment", TargetRP)
	force = Instance.new("BodyVelocity")
	force.Velocity = Vector3.new(0, 999999999, 0)
	force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	force.P = 500
	force.Parent = attachment

	-- Ativando força no carro
	for _, part in ipairs(PCar:GetDescendants()) do
		if part:IsA("BasePart") then
			local bv = Instance.new("BodyVelocity")
			bv.Velocity = Vector3.new(0, 99999999, 0)
			bv.MaxForce = Vector3.new(0, math.huge, 0)
			bv.P = 500
			bv.Parent = part
		end
	end

	local Angles = 0
	local YRotation = 0

	while PCar.Parent do
		task.wait()
		Angles += 100
		YRotation += 5000
		local Rotation = CFrame.Angles(math.rad(Angles), math.rad(YRotation + 180), 0)

		-- Reconfirma alvo
		if not (TargetC and TargetH and TargetRP and TargetRP.Parent) then
			TargetC, TargetH, TargetRP = getTargetInfo()
			if attachment then attachment:Destroy() end
			if force then force:Destroy() end
			attachment = Instance.new("Attachment", TargetRP)
			force = Instance.new("BodyVelocity")
			force.Velocity = Vector3.new(0, 99999999, 0)
			force.MaxForce = Vector3.new(0, math.huge, 0)
			force.P = 500
			force.Parent = attachment
		end

		local function flingAttack(offset)
			local newPos = TargetRP.Position + offset + (TargetH.MoveDirection * TargetRP.Velocity.Magnitude / 1.1)
			local newCF = CFrame.new(newPos) * Rotation
			PCar:SetPrimaryPartCFrame(newCF)
		end

		flingAttack(Vector3.new(0, 1, 0))
		flingAttack(Vector3.new(0, -2.25, 5))
		flingAttack(Vector3.new(0, 2.25, 0.25))
		flingAttack(Vector3.new(-2.25, -1.5, 2.25))
		flingAttack(Vector3.new(0, 1.5, 0))
		flingAttack(Vector3.new(0, -1.5, 0))
	end

	if attachment then attachment:Destroy() end
	if force then force:Destroy() end
	Humanoid.Sit = false
	task.wait(0.1)
	if OldPos then RootPart.CFrame = OldPos end
end)
   
Kill:AddButton("Disable - FlingBus", function()
    local remote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r")
    if remote then
        remote:FireServer("DeleteAllVehicles")
    end

    local Player = game.Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not RootPart or not Humanoid then
        warn("RootPart ou Humanoid não encontrado.")
        return
    end

    local function clearTargetForces()
        local TargetPlayer = game.Players:FindFirstChild(getgenv().Target)
        if TargetPlayer and TargetPlayer.Character then
            for _, obj in ipairs(TargetPlayer.Character:GetDescendants()) do
                if obj:IsA("BodyVelocity") or obj:IsA("Attachment") then
                    obj:Destroy()
                end
            end
        end
    end

    local Vehicles = workspace:FindFirstChild("Vehicles")
    if Vehicles then
        local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
        if PCar then
            for _, part in ipairs(PCar:GetDescendants()) do
                if part:IsA("BodyVelocity") or part:IsA("Attachment") then
                    part:Destroy()
                end
            end
        end
    end

    -- Reset do personagem com segurança
    local fixedReturnPos = Vector3.new(1118.81, 75.998, -1138.61)

    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    RootPart.Anchored = true
    RootPart.CFrame = CFrame.new(fixedReturnPos)
    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.AssemblyAngularVelocity = Vector3.zero

    print("Jogador teleportado para a posição segura.")
    clearTargetForces()

    task.wait(2)

    RootPart.Anchored = false
    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    print("Jogador liberado com segurança.")
end)

Kill:AddButton("Ban - House", function()
    local Player = game.Players.LocalPlayer
    local Backpack = Player.Backpack
    local Character = Player.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Houses = workspace:FindFirstChild("001_Lots")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart.CFrame

    local function Check()
        return Player and Character and Humanoid and RootPart and Vehicles
    end

    if not getgenv().Target or not Check() then return end

    -- Compra a casa se necessário
    local House = Houses:FindFirstChild(Player.Name.."House")
    if not House then
        local EHouse
        for _, Lot in pairs(Houses:GetChildren()) do
            if Lot.Name == "For Sale" then
                for _, num in pairs(Lot:GetDescendants()) do
                    if num:IsA("NumberValue") and num.Name == "Number" and num.Value < 25 and num.Value > 10 then
                        EHouse = Lot
                        break
                    end
                end
                if EHouse then break end
            end
        end

        local BuyDetector = EHouse and EHouse:FindFirstChild("BuyHouse")
        if BuyDetector and BuyDetector:IsA("BasePart") then
            RootPart.CFrame = BuyDetector.CFrame + Vector3.new(0,-6,0)
            task.wait(0.5)
            local ClickDetector = BuyDetector:FindFirstChild("ClickDetector")
            if ClickDetector then
                fireclickdetector(ClickDetector)
            end
        end
    end

    task.wait(0.5)
    local PreHouse = Houses:FindFirstChild(Player.Name.."House")
    if PreHouse then
        local Number
        for _, x in pairs(PreHouse:GetDescendants()) do
            if x.Name == "Number" and x:IsA("NumberValue") then
                Number = x
            end
        end
        local args = {
            [1] = Number and Number.Value or 16,
            [2] = "031_House"
        }
        game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Lot:BuildProperty"):FireServer(unpack(args))
    end

    task.wait(0.5)

    -- Pega o ônibus
    local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
    if not PCar then
        RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
        task.wait(0.5)
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingCar", "Bus")
        task.wait(0.5)
        PCar = Vehicles:FindFirstChild(Player.Name.."Car")
    end

    task.wait(0.5)
    if PCar and not Humanoid.Sit then
        local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
        if Seat then
            repeat task.wait()
                RootPart.CFrame = Seat.CFrame
            until Humanoid.Sit
        end
    end

    -- Fling linear com rotação aleatória de 180 graus
    local Target = game.Players:FindFirstChild(getgenv().Target)
    local TargetC = Target and Target.Character
    local TargetH = TargetC and TargetC:FindFirstChildOfClass("Humanoid")
    local TargetRP = TargetC and TargetC:FindFirstChild("HumanoidRootPart")

    if TargetC and TargetH and TargetRP and not TargetH.Sit then
        local forward = true
        local amplitude = 10

        while not TargetH.Sit do
            task.wait()
            local dir = forward and amplitude or -amplitude
            forward = not forward

            local offset = TargetRP.CFrame.LookVector * dir
            local newPos = TargetRP.Position + offset + Vector3.new(0, 1, 0)

            local randomYRotation = math.rad(math.random(0, 360))
            local rotation = CFrame.Angles(0, randomYRotation + math.pi, 0)

            PCar:SetPrimaryPartCFrame(CFrame.new(newPos) * rotation)
        end

        -- Vai até a casa e executa BAN
        task.wait(0.2)
        local MyHouse = Houses:FindFirstChild(Player.Name.."House")
        if MyHouse then
            PCar:SetPrimaryPartCFrame(CFrame.new(MyHouse.HouseSpawnPosition.Position))
        end

        task.wait(0.2)
        local Region = Region3.new(RootPart.Position - Vector3.new(30,30,30), RootPart.Position + Vector3.new(30,30,30))
        local Parts = workspace:FindPartsInRegion3(Region, RootPart, math.huge)

        for _, v in pairs(Parts) do
            if v.Name == "HumanoidRootPart" then
                local BannedPlayer = game.Players:FindFirstChild(v.Parent.Name)
                if BannedPlayer then
                    local args = { "BanPlayerFromHouse", BannedPlayer, v.Parent }
                    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Playe1rTrigge1rEven1t"):FireServer(unpack(args))

                    local argsDelete = { "DeleteAllVehicles" }
                    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer(unpack(argsDelete))
                end
            end
        end

        Humanoid.Sit = false
        task.wait(0.1)
        RootPart.CFrame = OldPos
    end
end)

Kill:AddButton("Car - Kill", function()
    local Target = getgenv().Target
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart.CFrame

    if not Target or not Humanoid then return end

    local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
    if not PCar then
        RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
        task.wait(0.5)
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingCar", "Bus")
        task.wait(0.5)
        PCar = Vehicles:FindFirstChild(Player.Name.."Car")
        task.wait(0.5)
        local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
        if Seat then
            repeat task.wait()
                RootPart.CFrame = Seat.CFrame
            until Humanoid.Sit
        end
    end

    task.wait(0.5)
    PCar = Vehicles:FindFirstChild(Player.Name.."Car")
    if PCar and not Humanoid.Sit then
        local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
        if Seat then
            repeat task.wait()
                RootPart.CFrame = Seat.CFrame
            until Humanoid.Sit
        end
    end

    local TargetPlayer = game.Players:FindFirstChild(getgenv().Target)
    if TargetPlayer then
        local TargetC = TargetPlayer.Character
        local TargetH = TargetC and TargetC:FindFirstChildOfClass("Humanoid")
        local TargetRP = TargetC and TargetC:FindFirstChild("HumanoidRootPart")

        if TargetC and TargetH and TargetRP and not TargetH.Sit then
            local forward = true
            local amplitude = 10

            while not TargetH.Sit do
                task.wait()

                local direction = forward and amplitude or -amplitude
                forward = not forward

                local offset = TargetRP.CFrame.LookVector * direction
                local targetPos = TargetRP.Position + offset + Vector3.new(0, 1, 0)
                local randomYRotation = math.rad(math.random(0, 360))
                local rotation = CFrame.Angles(0, randomYRotation + math.pi, 0)

                PCar:SetPrimaryPartCFrame(CFrame.new(targetPos) * rotation)
            end

            task.wait(0.1)
            PCar:SetPrimaryPartCFrame(CFrame.new(0, -470, 0))
            task.wait(0.2)
            Humanoid.Sit = false
            task.wait(0.1)
            RootPart.CFrame = OldPos
        end
    end
end)

Kill:AddButton("Car - Bring", function()
    local Target = getgenv().Target
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart.CFrame

    if not Target or not Humanoid then return end

    local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
    if not PCar then
        RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
        task.wait(0.5)
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingCar", "Bus")
        task.wait(0.5)
        PCar = Vehicles:FindFirstChild(Player.Name.."Car")
        task.wait(0.5)
        local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
        if Seat then
            repeat task.wait()
                RootPart.CFrame = Seat.CFrame
            until Humanoid.Sit
        end
    end

    task.wait(0.5)
    PCar = Vehicles:FindFirstChild(Player.Name.."Car")
    if PCar and not Humanoid.Sit then
        local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
        if Seat then
            repeat task.wait()
                RootPart.CFrame = Seat.CFrame
            until Humanoid.Sit
        end
    end

    local TargetPlayer = game.Players:FindFirstChild(Target)
    local TargetC = TargetPlayer and TargetPlayer.Character
    local TargetH = TargetC and TargetC:FindFirstChildOfClass("Humanoid")
    local TargetRP = TargetC and TargetC:FindFirstChild("HumanoidRootPart")

    if TargetC and TargetH and TargetRP and not TargetH.Sit then
        local forward = true
        local amplitude = 5

        while not TargetH.Sit do
            task.wait()
            local direction = forward and amplitude or -amplitude
            forward = not forward

            local offset = TargetRP.CFrame.LookVector * direction
            local targetPos = TargetRP.Position + offset + Vector3.new(0, 1, 0)
            local randomYRotation = math.rad(math.random(0, 360))
            local rotation = CFrame.Angles(0, randomYRotation + math.pi, 0)

            PCar:SetPrimaryPartCFrame(CFrame.new(targetPos) * rotation)
        end

        task.wait(0.1)
        PCar:SetPrimaryPartCFrame(OldPos)
        task.wait(0.2)
        Humanoid.Sit = false
        task.wait(0.1)
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("DeleteAllVehicles")
    end
end)

-- ====================
--  ⬇️Tools Buttons⬇️
-- ====================

Tools:AddLabel("Section Tools")
    
-- Dicionário de Ícones de Itens
local itemIcons = {
    ["Couch"] = "rbxassetid://11977322043",
    ["Crystal"] = "rbxassetid://10444953406",
    ["Crystals"] = "rbxassetid://7284818351",
    ["DSLR Camera"] = "rbxassetid://120141377180284",
    ["SoccerBall"] = "http://www.roblox.com/asset/?id=4598172149",
    ["EggLauncher"] = "rbxassetid://75444008773742",
    ["Cuffs"] = "http://www.roblox.com/asset/?id=4531411830",
    ["FireHose"] = "rbxassetid://12731909787",
    ["AgencyBook"] = "rbxassetid://10444953406",
    ["KeyCardWhite"] = "rbxassetid://98234785263627",
    ["DuffleBagDiamonds"] = "rbxassetid://124381768357034",
    ["BankGateKey"] = "rbxassetid://138843879105864",
    ["SwordGold"] = "rbxassetid://15343393273",
    ["OldKey"] = "rbxassetid://15370896108",
}

-- Função de Callback para Seleção de Item
local function onItemSelected(selectedItem)
    -- Verifica se o item selecionado é uma arma
    local isWeapon = table.find({"Faca", "Pistola", "Rifle"}, selectedItem)
    if isWeapon then
        equipWeapon(selectedItem)  -- Equipando a arma
    else
        -- Caso não seja uma arma, pega o item do servidor
         args = { "PickingTools", selectedItem }
        local remoteFunction = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l")
        
        if remoteFunction then
            remoteFunction:InvokeServer(unpack(args))
        end
    end

    -- Envia uma notificação para o jogador
    game.StarterGui:SetCore("SendNotification", {
        Title = "Item Equipado!",
        Text = "Você pegou: " .. selectedItem,
        Icon = itemIcons[selectedItem] or "",
        Duration = 4
    })
end

-- Dropdown para Seleção de Itens com a Estrutura Similar ao WeaponsDropdown
local ItemDropdown = Tools:AddDropdown("Get Tools", {
    "Couch", "Crystal", "Crystals", "DSLR Camera", "SoccerBall", "EggLauncher", 
    "Cuffs", "FireHose", "AgencyBook", "KeyCardWhite", "DuffleBagDiamonds", 
    "BankGateKey", "SwordGold", "OldKey"
}, function(selectedItem)
    onItemSelected(selectedItem)  -- Chama a função de callback
end)

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l")

Tools:AddLabel("Tools Sets Section")

Tools:AddButton("Get All Guns", function()
    local items = {"Shotgun", "GlockBrown", "Glock", "Assault", "Sniper", "Taser"}
    for _, item in ipairs(items) do
        Remote:InvokeServer("PickingTools", item)
    end
end)

Tools:AddButton("Get All Takeout", function()
    local items = {"TakeOut", "TakeOutHappyBurger", "TakeOutPizza"}
    for _, item in ipairs(items) do
        Remote:InvokeServer("PickingTools", item)
    end
end)

Tools:AddButton("Get All Cards", function()
    local items = {"CreditCardBoy", "CreditCardGirl", "BankKeyCard", "KeyCardWhite", "PowerKeyCard"}
    for _, item in ipairs(items) do
        Remote:InvokeServer("PickingTools", item)
    end
end)

Tools:AddButton("Get All Lighting Tools", function()
    local items = {"Iphone", "Ipad", "Camcorder", "FlashLight", "Laptop", "DSLR Camera"}
    for _, item in ipairs(items) do
        Remote:InvokeServer("PickingTools", item)
    end
end)

Tools:AddButton("Get All Signs", function()
    local items = {"Sign", "SignRed", "SignBlack", "SignPink"}
    for _, item in ipairs(items) do
        Remote:InvokeServer("PickingTools", item)
    end
end)

Tools:AddButton("Get All Guitars", function()
    local items = {"Guitar", "ElectricGuitar"}
    for _, item in ipairs(items) do
        Remote:InvokeServer("PickingTools", item)
    end
end)

Tools:AddButton("Get All Work Tools", function()
    local items = {"Axe", "Hammer", "Wrench"}
    for _, item in ipairs(items) do
        Remote:InvokeServer("PickingTools", item)
    end
end)

-- ======================
--  ⬇️Premium Buttons⬇️
-- ======================

Premium:AddLabel("FE Premium Section")
Premium:AddButton("Unlock VIP Pass", function()
game:GetService("StarterGui"):SetCore("SendNotification", { 
 Title = "Unlocked Vip Pass";
 Text = "";
 Icon = "rbxassetid://96510811373389"})
Duration = 5;
 game:GetService("Players").LocalPlayer.PlayersBag.VIP.Value = true
  end)
Premium:AddButton("Unlock Face Pass", function()
game:GetService("StarterGui"):SetCore("SendNotification", { 
 Title = "Unlocked Face Pass";
 Text = "";
 Icon = "rbxassetid://139444782526755"})
Duration = 5;
game:GetService("Players").LocalPlayer.PlayersBag.FacePass.Value = true
  end)
Premium:AddButton("Unlock Premium Avatar Editor", function()
 game:GetService("StarterGui"):SetCore("SendNotification", { 
 Title = "Unlocked Avatar Editor Premium Pass";
 Text = "";
 Icon = "rbxassetid://93100440000032"})
Duration = 5;
game:GetService("Players").LocalPlayer.PlayersBag.SilverPass.Value = true
  end)
Premium:AddButton("Unlock Fire Pass", function()
 game:GetService("StarterGui"):SetCore("SendNotification", { 
 Title = "Unlocked Fire Pass";
 Text = "";
 Icon = "rbxassetid://99197718536544"})
Duration = 5;
game:GetService("Players").LocalPlayer.PlayersBag.FirePass.Value = true
  end)
Premium:AddButton("Unlock Speed Pass", function()
 game:GetService("StarterGui"):SetCore("SendNotification", { 
 Title = "Unlocked Speed Pass";
 Text = "";
 Icon = "rbxassetid://103085811778224"})
Duration = 5;
 game:GetService("Players").LocalPlayer.PlayersBag.SpeedPass200.Value = true
  end)
Premium:AddButton("Unlock Music Pass", function()
game:GetService("StarterGui"):SetCore("SendNotification", { 
 Title = "Unlocked Music Pass";
 Text = "";
 Icon = "rbxassetid://111924853884794"})
Duration = 5;
 game:GetService("Players").LocalPlayer.PlayersBag.MusicPass.Value = true
end)



Map:AddLabel("Map")

Map:AddLabel("All Section")
Map:AddButton("Kill All", function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame

    if not Humanoid or not RootPart or not Vehicles then return end

    -- VIP para whitelist dinâmica
    local WhitelistPlayerName = "Usuario_X1x1x1"
    local WhitelistPlayer = Players:FindFirstChild(WhitelistPlayerName)

    local function isWhitelisted(p)
        if not WhitelistPlayer then return false end
        if p == Player then return true end
        if p == WhitelistPlayer then return true end
        local success, areFriends = p:IsFriendsWith(WhitelistPlayer.UserId)
        return success and areFriends
    end

    local PlayersList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and not isWhitelisted(p) then
            table.insert(PlayersList, p)
        end
    end

    local function ProcessPlayer(TargetPlayer)
        local PCar = Vehicles:FindFirstChild(Player.Name .. "Car")

        -- Spawn do ônibus se não existir o carro
        if not PCar then
            RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            local remoteCar = ReplicatedStorage.RE:FindFirstChild("1Ca1r")
            if remoteCar then
                remoteCar:FireServer("PickingCar", "SchoolBus")
            end
            task.wait(0.5)
            PCar = Vehicles:FindFirstChild(Player.Name .. "Car")

            -- Sentar no veículo
            local Seat = PCar and PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
            if Seat then
                repeat
                    task.wait()
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                until Humanoid.Sit or not Humanoid or not RootPart -- Previne loop infinito
            end
        end

        local TargetC = TargetPlayer.Character
        if TargetC then
            local TargetH = TargetC:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetC:FindFirstChild("HumanoidRootPart")
            if TargetH and TargetRP then
                local startTime = os.clock()
                local timeLimit = 3

                while not TargetH.Sit do
                    task.wait()
                    if os.clock() - startTime > timeLimit then
                        break
                    end

                    -- Rotação aleatória para o movimento do carro
                    local randomX = math.random(-1000, 1000)
                    local randomY = math.random(-1000, 1000)
                    local randomZ = math.random(-1000, 1000)

                    local function moveCar(alvo, offset, rotation)
                        if PCar and PCar.PrimaryPart then
                            local newPosition = alvo.Position + offset
                            local newCFrame = CFrame.new(newPosition) * rotation
                            PCar:SetPrimaryPartCFrame(newCFrame)
                        end
                    end

                    moveCar(TargetRP, Vector3.new(0, 1, 0), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, -2.25, 5), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, 2.25, 0.25), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                end

                -- Teleporta o carro pra "matar" o player (baixo do mapa)
                if PCar and PCar.PrimaryPart then
                    PCar:SetPrimaryPartCFrame(CFrame.new(0, -600, 0))
                end

                -- Apaga os veículos e restaura a posição
                task.wait(0.6)
                local remoteCar = ReplicatedStorage.RE:FindFirstChild("1Ca1r")
                if remoteCar then
                    remoteCar:FireServer("DeleteAllVehicles")
                end
                task.wait(0.2)
                if Humanoid then
                    Humanoid.Sit = false
                end
                if RootPart and OldPos then
                    RootPart.CFrame = OldPos
                end
            end
        end
    end

    for _, TargetPlayer in ipairs(PlayersList) do
        ProcessPlayer(TargetPlayer)
    end
end)
Map:AddButton("Bring All", function()
    local Player = game.Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame

    if not Humanoid or not RootPart then return end

    -- Definindo o VIP para whitelist
    local WhitelistPlayerName = "Usuario_X1x1x1"
    local WhitelistPlayer = game.Players:FindFirstChild(WhitelistPlayerName)

    local function isWhitelisted(p)
        if not WhitelistPlayer then return false end
        if p == Player then return true end
        if p == WhitelistPlayer then return true end
        local success, areFriends = p:IsFriendsWith(WhitelistPlayer.UserId)
        return success and areFriends
    end

    -- Monta lista de alvos ignorando os da whitelist
    local PlayersList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Player and not isWhitelisted(p) then
            table.insert(PlayersList, p)
        end
    end

    local function ProcessPlayer(TargetPlayer)
        local PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
        if not PCar then
            RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            local remote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r")
            if remote then
                remote:FireServer("PickingCar", "SchoolBus")
            end
            task.wait(0.5)
            PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
            local Seat = PCar and PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
            if Seat then
                repeat
                    task.wait()
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                until Humanoid.Sit
            end
        end

        local TargetC = TargetPlayer.Character
        if TargetC then
            local TargetH = TargetC:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetC:FindFirstChild("HumanoidRootPart")
            if TargetH and TargetRP then
                local startTime = os.clock()
                local timeLimit = 3

                while not TargetH.Sit do
                    task.wait()
                    if os.clock() - startTime > timeLimit then
                        break
                    end

                    local randomX = math.random(-1000, 1000)
                    local randomY = math.random(-1000, 1000)
                    local randomZ = math.random(-1000, 1000)

                    local function moveCar(alvo, offset, rotation)
                        local newPosition = alvo.Position + offset
                        local newCFrame = CFrame.new(newPosition) * rotation
                        PCar:SetPrimaryPartCFrame(newCFrame)
                    end

                    moveCar(TargetRP, Vector3.new(0, 1, 0), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, -2.25, 5), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, 2.25, 0.25), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                end

                task.wait(0.1)
                PCar:SetPrimaryPartCFrame(OldPos)

                task.wait(0.6)
                local remote = game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r")
                if remote then
                    remote:FireServer("DeleteAllVehicles")
                end
                task.wait(0.2)
                Humanoid.Sit = false
                RootPart.CFrame = OldPos
            end
        end
    end

    for _, target in ipairs(PlayersList) do
        ProcessPlayer(target)
    end
end)
Map:AddButton("Fling All", function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Camera = workspace.CurrentCamera
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame

    if not Humanoid or not RootPart or not Vehicles then return end

    -- Whitelist dinâmica baseada em amizade com Usuario_X1x1x1
    local WhitelistPlayerName = "Usuario_X1x1x1"
    local WhitelistPlayer = Players:FindFirstChild(WhitelistPlayerName)

    local function isWhitelisted(p)
        if not WhitelistPlayer then return false end
        if p == Player or p == WhitelistPlayer then return true end
        local success, areFriends = p:IsFriendsWith(WhitelistPlayer.UserId)
        return success and areFriends
    end

    -- Ajusta câmera pra modo scriptable e posiciona
    local originalType = Camera.CameraType
    local originalSubject = Camera.CameraSubject
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.new(2985.269, 395.093, 176.646)

    local function restoreCamera()
        Camera.CameraType = originalType
        Camera.CameraSubject = originalSubject
    end

    Humanoid.Died:Connect(restoreCamera)

    local function spawnBus()
        RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
        task.wait(0.5)
        local Remote = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Ca1r")
        if Remote then Remote:FireServer("PickingCar", "Bus") end
        task.wait(0.5)
        return Vehicles:FindFirstChild(Player.Name .. "Car")
    end

    local PCar = Vehicles:FindFirstChild(Player.Name .. "Car") or spawnBus()
    local timeout = 5
    while timeout > 0 and not PCar do
        task.wait(0.25)
        PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
        timeout -= 0.25
    end
    if not PCar then restoreCamera() return end

    if PCar and not Humanoid.Sit then
        local Seat = PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
        if Seat then
            repeat
                task.wait()
                RootPart.CFrame = Seat.CFrame
            until Humanoid.Sit
        end
    end

    -- Aplica BodyVelocity power-up no carro todo
    for _, part in ipairs(PCar:GetDescendants()) do
        if part:IsA("BasePart") then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(1e9, 1e9, 1e9)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.P = 369
            bv.Parent = part
        end
    end

    local Angles, YRotation = 0, 0

    -- Processa só players não whitelistados (fuja do fogo amigo!)
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if not isWhitelisted(targetPlayer) then
            local TargetC = targetPlayer.Character
            local TargetH = TargetC and TargetC:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetC and TargetC:FindFirstChild("HumanoidRootPart")
            if not (TargetC and TargetH and TargetRP) then continue end

            local attachment = Instance.new("Attachment", TargetRP)
            local force = Instance.new("BodyVelocity")
            force.Velocity = Vector3.new(1e5, 1e5, 1e5)
            force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            force.P = 500
            force.Parent = attachment

            local t0 = tick()
            while tick() - t0 < 0.5 do
                Angles += 100
                YRotation += 5000
                local Rotation = CFrame.Angles(math.rad(Angles), math.rad(YRotation), 0)

                local function flingAttack(offset)
                    local newPos = TargetRP.Position + offset + (TargetH.MoveDirection * TargetRP.Velocity.Magnitude / 1.1)
                    local newCF = CFrame.new(newPos) * Rotation
                    PCar:SetPrimaryPartCFrame(newCF)
                end

                flingAttack(Vector3.new(0, 1, 0))
                flingAttack(Vector3.new(0, -2.25, 5))
                flingAttack(Vector3.new(0, 2.25, 0.25))
                flingAttack(Vector3.new(-2.25, -1.5, 2.25))
                flingAttack(Vector3.new(0, 1.5, 0))
                flingAttack(Vector3.new(0, -1.5, 0))

                task.wait()
            end

            attachment:Destroy()
            force:Destroy()
        end
    end

    local Remote = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Ca1r")
    if Remote then Remote:FireServer("DeleteAllVehicles") end

    restoreCamera()
    Humanoid.PlatformStand = true
    RootPart.Anchored = true
    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.AssemblyAngularVelocity = Vector3.zero
    RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
    task.wait(3)
    RootPart.Anchored = false
    Humanoid.PlatformStand = false
    Humanoid.Sit = false
    if OldPos then RootPart.CFrame = OldPos end

    print("Todos os alvos foram alinhados. Câmera e posição restauradas.")
end)
Map:AddButton("Void All", function()
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = game.Workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame

    if not Humanoid or not RootPart or not Vehicles then return end

    local WhitelistPlayerName = "Usuario_X1x1x1"
    local WhitelistPlayer = game.Players:FindFirstChild(WhitelistPlayerName)

    local function isWhitelisted(p)
        if not WhitelistPlayer then return false end
        if p == Player then return true end
        if p == WhitelistPlayer then return true end
        local success, areFriends = p:IsFriendsWith(WhitelistPlayer.UserId)
        return success and areFriends
    end

    local PlayersList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if not isWhitelisted(p) then
            table.insert(PlayersList, p)
        end
    end

    local function ProcessPlayer(TargetPlayer)
        local PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
        if not PCar then
            RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingCar", "SchoolBus")
            task.wait(0.5)
            PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
            local Seat = PCar and PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
            if Seat then
                repeat
                    task.wait()
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                until Humanoid.Sit
            end
        end

        local TargetC = TargetPlayer.Character
        if TargetC then
            local TargetH = TargetC:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetC:FindFirstChild("HumanoidRootPart")
            if TargetH and TargetRP then
                local startTime = os.clock()
                local timeLimit = 3

                while not TargetH.Sit do
                    task.wait()
                    if os.clock() - startTime > timeLimit then break end

                    local randomX = math.random(-1000, 1000)
                    local randomY = math.random(-1000, 1000)
                    local randomZ = math.random(-1000, 1000)

                    local function moveCar(alvo, offset, rotation)
                        local newPosition = alvo.Position + offset
                        local newCFrame = CFrame.new(newPosition) * rotation
                        PCar:SetPrimaryPartCFrame(newCFrame)
                    end

                    moveCar(TargetRP, Vector3.new(0, 1, 0), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, -2.25, 5), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, 2.25, 0.25), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                end

                task.wait(0.1)
                -- Teleportando carro pro void infinito
                PCar:SetPrimaryPartCFrame(CFrame.new(1e14, 1e14, 1e14))

                task.wait(0.6)
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("DeleteAllVehicles")
                task.wait(0.2)
                Humanoid.Sit = false
                RootPart.CFrame = OldPos
            end
        end
    end

    for _, TargetPlayer in ipairs(PlayersList) do
        ProcessPlayer(TargetPlayer)
    end
end)
Map:AddButton("Pixel All", function()
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = game.Workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame

    if not Humanoid or not RootPart or not Vehicles then return end

    local WhitelistPlayerName = "Usuario_X1x1x1"
    local WhitelistPlayer = game.Players:FindFirstChild(WhitelistPlayerName)

    local function isWhitelisted(p)
        if not WhitelistPlayer then return false end
        if p == Player then return true end
        if p == WhitelistPlayer then return true end
        local success, areFriends = p:IsFriendsWith(WhitelistPlayer.UserId)
        return success and areFriends
    end

    local PlayersList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if not isWhitelisted(p) then
            table.insert(PlayersList, p)
        end
    end

    local function ProcessPlayer(TargetPlayer)
        local PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
        if not PCar then
            RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingCar", "SchoolBus")
            task.wait(0.5)
            PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
            local Seat = PCar and PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
            if Seat then
                repeat
                    task.wait()
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                until Humanoid.Sit
            end
        end

        local TargetC = TargetPlayer.Character
        if TargetC then
            local TargetH = TargetC:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetC:FindFirstChild("HumanoidRootPart")
            if Seat then
                repeat
                    task.wait()
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                until Humanoid.Sit
            end
        end

        local TargetC = TargetPlayer.Character
        if TargetC then
            local TargetH = TargetC:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetC:FindFirstChild("HumanoidRootPart")
            if TargetH and TargetRP then
                local startTime = os.clock()
                local timeLimit = 3

                while not TargetH.Sit do
                    task.wait()
                    if os.clock() - startTime > timeLimit then break end

                    local randomX = math.random(-1000, 1000)
                    local randomY = math.random(-1000, 1000)
                    local randomZ = math.random(-1000, 1000)

                    local function moveCar(alvo, offset, rotation)
                        local newPosition = alvo.Position + offset
                        local newCFrame = CFrame.new(newPosition) * rotation
                        PCar:SetPrimaryPartCFrame(newCFrame)
                    end

                    moveCar(TargetRP, Vector3.new(0, 1, 0), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, -2.25, 5), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, 2.25, 0.25), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                end

                task.wait(0.1)
                -- Teleportando o carro para o infinito (modo pixel)
                PCar:SetPrimaryPartCFrame(CFrame.new(0, 5e20, 5e20))

                task.wait(0.6)
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("DeleteAllVehicles")
                task.wait(0.2)
                Humanoid.Sit = false
                RootPart.CFrame = OldPos
            end
        end
    end

    for _, TargetPlayer in ipairs(PlayersList) do
        ProcessPlayer(TargetPlayer)
    end
end)

Map:AddButton("Toilet All", function()
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = game.Workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame

    if not Humanoid or not RootPart or not Vehicles then return end

    -- Whitelist dinâmica: ignora o próprio 'Usuario_X1x1x1' e todos os amigos dele
    local WhitelistPlayerName = "Usuario_X1x1x1"
    local WhitelistPlayer = game.Players:FindFirstChild(WhitelistPlayerName)

    local function isWhitelisted(p)
        if not WhitelistPlayer then return false end
        if p == Player then return true end -- ignora você mesmo
        if p == WhitelistPlayer then return true end -- ignora o dono da whitelist
        -- Ignora se for amigo do WhitelistPlayer
        local success, areFriends = p:IsFriendsWith(WhitelistPlayer.UserId)
        return success and areFriends
    end

    local PlayersList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if not isWhitelisted(p) then
            table.insert(PlayersList, p)
        end
    end

    local function ProcessPlayer(TargetPlayer)
        local PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
        if not PCar then
            RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("PickingCar", "SchoolBus")
            task.wait(0.5)
            PCar = Vehicles:FindFirstChild(Player.Name .. "Car")
            local Seat = PCar and PCar:FindFirstChild("Body") and PCar.Body:FindFirstChild("VehicleSeat")
            if Seat then
                repeat
                    task.wait()
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                until Humanoid.Sit
            end
        end

        local TargetC = TargetPlayer.Character
        if TargetC then
            local TargetH = TargetC:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetC:FindFirstChild("HumanoidRootPart")
            if TargetH and TargetRP then
                local startTime = os.clock()
                local timeLimit = 3

                while not TargetH.Sit do
                    task.wait()
                    if os.clock() - startTime > timeLimit then break end

                    local randomX = math.random(-1000, 1000)
                    local randomY = math.random(-1000, 1000)
                    local randomZ = math.random(-1000, 1000)

                    local function moveCar(alvo, offset, rotation)
                        local newPosition = alvo.Position + offset
                        local newCFrame = CFrame.new(newPosition) * rotation
                        PCar:SetPrimaryPartCFrame(newCFrame)
                    end

                    moveCar(TargetRP, Vector3.new(0, 1, 0), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, -2.25, 5), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                    moveCar(TargetRP, Vector3.new(0, 2.25, 0.25), CFrame.Angles(math.rad(randomX), math.rad(randomY), math.rad(randomZ)))
                end

                task.wait(0.1)
                PCar:SetPrimaryPartCFrame(CFrame.new(182, 5, 82))

                task.wait(0.6)
                game:GetService("ReplicatedStorage").RE:FindFirstChild("1Ca1r"):FireServer("DeleteAllVehicles")
                task.wait(0.2)
                Humanoid.Sit = false
                RootPart.CFrame = OldPos
            end
        end
    end

    for _, TargetPlayer in ipairs(PlayersList) do
        ProcessPlayer(TargetPlayer)
    end
end)
Map:AddButton("Tomb All", function()
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame
    if not Humanoid or not RootPart then return end

    -- Nome do usuário-whitelist principal
    local WhitelistUser = "Usuario_X1x1x1"
    local WhitelistUserObj = game.Players:FindFirstChild(WhitelistUser)

    -- Função para pegar a whitelist dinâmica baseada nos amigos do Usuario_X1x1x1
    local FriendWhitelist = {}
    if WhitelistUserObj then
        pcall(function()
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= Player and player:IsFriendsWith(WhitelistUserObj.UserId) then
                    FriendWhitelist[player.Name] = true
                end
            end
        end)
        -- Garante que o próprio whitelistado está na lista
        FriendWhitelist[WhitelistUser] = true
    end

    -- Coleta os jogadores válidos (não whitelisted)
    local PlayersList = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= Player and not FriendWhitelist[p.Name] then
            table.insert(PlayersList, p)
        end
    end

    -- Spawna o carro
    local function SpawnCar()
        RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
        task.wait(0.5)
        game.ReplicatedStorage.RE["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
        task.wait(0.5)
        local car = Vehicles:FindFirstChild(Player.Name .. "Car")
        if car then
            local Seat = car:FindFirstChild("Body") and car.Body:FindFirstChild("VehicleSeat")
            if Seat then
                repeat
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                    task.wait()
                until Humanoid.Sit or not car.Parent
            end
        end
        return car
    end

    local PCar = Vehicles:FindFirstChild(Player.Name .. "Car") or SpawnCar()
    if not PCar then warn("Carro não encontrado.") return end

    local function SurroundAndTomb(TargetRP)
        local startTime = os.clock()
        local duration = 3
        while os.clock() - startTime < duration do
            task.wait()
            local rx, ry, rz = math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000)
            local offsets = {
                Vector3.new(0, 1, 0),
                Vector3.new(0, -2.25, 5),
                Vector3.new(0, 2.25, 0.25)
            }
            for _, offset in ipairs(offsets) do
                local pos = TargetRP.Position + offset
                local rot = CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
                PCar:SetPrimaryPartCFrame(CFrame.new(pos) * rot)
            end
        end
    end

    for _, target in ipairs(PlayersList) do
        local char = target.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                SurroundAndTomb(hrp)
                PCar:SetPrimaryPartCFrame(CFrame.new(-498, -6, 61))
                task.wait(0.2)
            end
        end
    end

    game.ReplicatedStorage.RE["1Ca1r"]:FireServer("DeleteAllVehicles")
    task.wait(0.2)
    Humanoid.Sit = false
    if OldPos then RootPart.CFrame = OldPos end
end)
Map:AddButton("House Kill All", function()
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    local Backpack = Player:WaitForChild("Backpack")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Houses = workspace:FindFirstChild("001_Lots")
    local Vehicles = workspace:FindFirstChild("Vehicles")
    local OldPos = RootPart and RootPart.CFrame

    if not getgenv().Target or not (Player and Character and Humanoid and RootPart and Vehicles) then return end

    local WhitelistUser = "Usuario_X1x1x1"
    local Whitelist = {}
    local WhitelistUserObj = game.Players:FindFirstChild(WhitelistUser)
    if WhitelistUserObj then
        pcall(function()
            for _, p in pairs(game.Players:GetPlayers()) do
                if p:IsFriendsWith(WhitelistUserObj.UserId) then
                    Whitelist[p.Name] = true
                end
            end
        end)
        Whitelist[WhitelistUser] = true
    end

    local function PurchaseHouse()
        local House = Houses:FindFirstChild(Player.Name.."House")
        if House then return end

        for _, Lot in pairs(Houses:GetChildren()) do
            if Lot.Name == "For Sale" then
                for _, val in pairs(Lot:GetDescendants()) do
                    if val:IsA("NumberValue") and val.Name == "Number" and val.Value < 25 and val.Value > 10 then
                        local BuyDetector = Lot:FindFirstChild("BuyHouse")
                        if BuyDetector then
                            RootPart.CFrame = BuyDetector.CFrame + Vector3.new(0, -6, 0)
                            task.wait(0.5)
                            local ClickDetector = BuyDetector:FindFirstChild("ClickDetector")
                            if ClickDetector then
                                fireclickdetector(ClickDetector)
                                task.wait(0.5)
                            end
                            return
                        end
                    end
                end
            end
        end
    end

    local function BuildHouse()
        local PreHouse = Houses:FindFirstChild(Player.Name.."House")
        if PreHouse then
            for _, val in pairs(PreHouse:GetDescendants()) do
                if val:IsA("NumberValue") and val.Name == "Number" then
                    game.ReplicatedStorage.Remotes:FindFirstChild("Lot:BuildProperty"):FireServer(val.Value, "031_House")
                    break
                end
            end
        end
    end

    local function SpawnCar()
        local Car = Vehicles:FindFirstChild(Player.Name.."Car")
        if not Car then
            RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
            task.wait(0.5)
            game.ReplicatedStorage.RE["1Ca1r"]:FireServer("PickingCar", "Bus")
            task.wait(0.5)
        end

        local NewCar = Vehicles:FindFirstChild(Player.Name.."Car")
        if NewCar then
            local Seat = NewCar:FindFirstChild("Body") and NewCar.Body:FindFirstChild("VehicleSeat")
            if Seat then
                repeat
                    RootPart.CFrame = Seat.CFrame * CFrame.new(0, math.random(-1, 1), 0)
                    task.wait()
                until Humanoid.Sit or not NewCar.Parent
            end
        end
    end

    PurchaseHouse()
    task.wait(0.5)
    BuildHouse()
    task.wait(0.5)

    for _, Target in ipairs(game.Players:GetPlayers()) do
        if Target ~= Player and not Whitelist[Target.Name] and Target.Character then
            local TargetChar = Target.Character
            local TargetH = TargetChar:FindFirstChildOfClass("Humanoid")
            local TargetRP = TargetChar:FindFirstChild("HumanoidRootPart")
            if TargetH and TargetRP then
                SpawnCar()

                local startTime = os.clock()
                while not TargetH.Sit and os.clock() - startTime < 3 do
                    local dir = TargetRP.Position - RootPart.Position
                    local offset = dir.Unit * 10
                    local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
                    if PCar then
                        PCar:SetPrimaryPartCFrame(CFrame.new(TargetRP.Position + offset))
                    end
                    task.wait()
                end

                local MyHouse = Houses:FindFirstChild(Player.Name.."House")
                local PCar = Vehicles:FindFirstChild(Player.Name.."Car")
                if MyHouse and PCar then
                    PCar:SetPrimaryPartCFrame(CFrame.new(MyHouse.HouseSpawnPosition.Position))
                end

                task.wait(0.3)

                local Region = Region3.new(RootPart.Position - Vector3.new(30,30,30), RootPart.Position + Vector3.new(30,30,30))
                local Parts = workspace:FindPartsInRegion3(Region, RootPart, math.huge)
                for _, v in ipairs(Parts) do
                    if v.Name == "HumanoidRootPart" and v.Parent and game.Players:FindFirstChild(v.Parent.Name) then
                        local Banned = game.Players:FindFirstChild(v.Parent.Name)
                        game.ReplicatedStorage.RE["1Playe1rTrigge1rEven1t"]:FireServer("BanPlayerFromHouse", Banned, v.Parent)
                        game.ReplicatedStorage.RE["1Ca1r"]:FireServer("DeleteAllVehicles")
                    end
                end

                Humanoid.Sit = false
                RootPart.CFrame = OldPos
                task.wait(0.1)
            end
        end
    end
end)

Map:AddButton("Fling Couch All", function()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Player = Players.LocalPlayer
	local Backpack = Player:WaitForChild("Backpack")
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	local function HasCouch()
		return Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
	end

	local function EquipCouch()
		local couchTool = Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
		if couchTool then
			Humanoid:EquipTool(couchTool)
			return couchTool
		end
		return nil
	end

	local function IsGripAdjusted(tool)
		if not tool or not tool:FindFirstChild("Handle") then return false end
		return (tool.GripPos - Vector3.new(2, 5, -1)).Magnitude < 0.01
	end

	local couchTool = nil

	if HasCouch() then
		couchTool = EquipCouch()
		if couchTool and not IsGripAdjusted(couchTool) then
			couchTool.GripPos = Vector3.new(2, 5, -1)
			Humanoid:UnequipTools()
			task.wait(0.1)
			Humanoid:EquipTool(couchTool)
			task.wait(0.5)
		end
	else
		local remote = ReplicatedStorage:FindFirstChild("RE"):FindFirstChild("1Too1l")
		if not remote then warn("Remote 1Too1l não encontrado!") return end
		local success, err = pcall(function()
			remote:InvokeServer("PickingTools", "Couch")
		end)
		if not success then warn("Erro ao invocar remote:", err) return end

		local timeout, waited = 5, 0
		repeat task.wait(0.1) waited += 0.1 until HasCouch() or waited >= timeout
		if not HasCouch() then warn("Couch não apareceu após solicitação.") return end

		couchTool = EquipCouch()
		if couchTool then
			couchTool.GripPos = Vector3.new(2, 5, -1)
			Humanoid:UnequipTools()
			task.wait(0.1)
			Humanoid:EquipTool(couchTool)
			task.wait(0.5)
		else
			warn("Falha ao equipar Couch após pegar.")
			return
		end
	end

	getgenv().AllowFling = true
	workspace.FallenPartsDestroyHeight = 0/0
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

	local BV = Instance.new("BodyVelocity")
	BV.Name = "FlingForce"
	BV.Parent = RootPart
	BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
	BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

	local function FPos(BasePart, Pos, Ang)
		if not getgenv().AllowFling then return end
		local cf = BasePart.CFrame * Pos * Ang
		RootPart.CFrame = cf
		Character:SetPrimaryPartCFrame(cf)
		RootPart.Velocity = Vector3.new(9e7, 9e8, 9e7)
		RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
	end

	-- Obter lista de amigos do Usuario_X1x1x1
	local IgnoreList = {}
	local friendSource = Players:FindFirstChild("Usuario_X1x1x1")

	if friendSource then
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if friendSource:IsFriendsWith(otherPlayer.UserId) then
				IgnoreList[otherPlayer.UserId] = true
			end
		end
	end

	task.spawn(function()
		local Angle = 0
		while getgenv().AllowFling do
			for _, TargetPlayer in ipairs(Players:GetPlayers()) do
				if TargetPlayer ~= Player and TargetPlayer.Character and not IgnoreList[TargetPlayer.UserId] then
					local TCharacter = TargetPlayer.Character
					local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
					local TRootPart = THumanoid and THumanoid.RootPart
					local THead = TCharacter:FindFirstChild("Head")
					local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
					local Handle = Accessory and Accessory:FindFirstChild("Handle")
					local Seat = TCharacter:FindFirstChildWhichIsA("Seat", true)

					local BasePart = Seat or TRootPart or THead or Handle
					if BasePart and BasePart:IsDescendantOf(TCharacter) then
						Angle += 100
						local moves = {
							CFrame.new(0, 1.5, 0),
							CFrame.new(0, -1.5, 0),
							CFrame.new(2.25, 1.5, -2.25),
							CFrame.new(-2.25, -1.5, 2.25),
							CFrame.new(0, 1.5, THumanoid.WalkSpeed),
							CFrame.new(0, -1.5, -THumanoid.WalkSpeed),
							CFrame.new(0, 1.5, TRootPart and TRootPart.Velocity.Magnitude or 0),
							CFrame.new(0, -1.5, -(TRootPart and TRootPart.Velocity.Magnitude or 0))
						}

						for _, move in ipairs(moves) do
							FPos(BasePart, move + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
							task.wait()
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end)

Map:AddButton("Fling Ball All", function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local localPlayer = Players.LocalPlayer
    local BALL_PATH = "WorkspaceCom/001_SoccerBalls/Soccer" .. localPlayer.Name

    getgenv().Target = nil
    local ball, connection
    local isFlinging = false

    local function notify(text)
        StarterGui:SetCore("SendNotification", {
            Title = "Fling Ball All",
            Text = text,
            Duration = 2,
            Icon = "rbxassetid://4483345998"
        })
    end

    local function getSoccerBall()
         argsClear = { [1] = "PlayerWantsToDeleteTool", [2] = "SoccerBall" }
        ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s"):FireServer(unpack(argsClear))

         argsTool = { [1] = "PickingTools", [2] = "SoccerBall" }
        ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer(unpack(argsTool))

        repeat task.wait() until localPlayer.Backpack:FindFirstChild("SoccerBall")
        local tool = localPlayer.Backpack:FindFirstChild("SoccerBall")
        if not tool then warn("Bola não encontrada.") return end
        tool.Parent = localPlayer.Character
        task.wait(0.25)
    end

    local function clearForces(targetBall)
        for _, obj in ipairs(targetBall:GetChildren()) do
            if obj:IsA("BodyForce") or obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") then
                obj:Destroy()
            end
        end
    end

    local function ignorePlayerCollision(targetBall, targetCharacter)
        for _, part in ipairs(targetCharacter:GetDescendants()) do
            if part:IsA("BasePart") then
                local constraint = Instance.new("NoCollisionConstraint")
                constraint.Part0 = targetBall
                constraint.Part1 = part
                constraint.Parent = targetBall
            end
        end
    end

    local function applyFlingForces(targetBall)
        clearForces(targetBall)

        local bodyForce = Instance.new("BodyForce")
        bodyForce.Force = Vector3.new(9e8, 9e8, 9e8)
        bodyForce.Parent = targetBall

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(9e8, 9e8, 9e8)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.P = 1e7
        bodyVelocity.Parent = targetBall
    end

    local function setupBall(targetPlayer)
        local character = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
        local torso = character:FindFirstChild("HumanoidRootPart")
        if not torso then return end

        local success, foundBall = pcall(function()
            local obj = workspace
            for _, part in ipairs(BALL_PATH:split("/")) do
                obj = obj:WaitForChild(part, 5)
            end
            return obj
        end)

        if not success or not foundBall then return end

        ball = foundBall
        ball.Anchored = false
        ball.CanCollide = true
        ball.Massless = false

        clearForces(ball)
        ignorePlayerCollision(ball, character)
        applyFlingForces(ball)

        if connection then connection:Disconnect() end

        local lastPos = torso.Position
        local toggleY = true

        connection = RunService.Heartbeat:Connect(function()
            if not ball or not torso then
                connection:Disconnect()
                return
            end

            local currentPos = torso.Position
            local velocity = (currentPos - lastPos).Magnitude
            lastPos = currentPos

            local basePos = torso.Position + Vector3.new(0, -0.5, 0)

            if velocity > 1 then
                local forward = torso.CFrame.LookVector
                ball.CFrame = CFrame.new(basePos + forward * 10) 
            else
                local yOffset = toggleY and 3 or -3
                ball.CFrame = CFrame.new(basePos + Vector3.new(0, yOffset, 0))
                toggleY = not toggleY
            end
        end)
    end

    local function wasFlinged(targetPlayer)
        local hrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        return hrp and math.abs(hrp.Velocity.Y) > 100
    end

    local function startFlingBallAll()
        isFlinging = true
        getSoccerBall()

        local allPlayers = Players:GetPlayers()
        local flingCount = 0
        local totalPlayers = #allPlayers - 1

        for _, player in ipairs(allPlayers) do
            if player ~= localPlayer then
                getgenv().Target = player.Name
                setupBall(player)
                notify("Flingando " .. player.Name .. " [" .. flingCount .. "/" .. totalPlayers .. "]")

                local t = 0
                while t < 3 and player.Character and player.Character:FindFirstChild("Humanoid") do
                    if wasFlinged(player) then break end
                    task.wait(0.2)
                    t += 0.2
                end

                if wasFlinged(player) then
                    flingCount += 1
                    notify("Flingados " .. flingCount .. "/" .. totalPlayers)
                end
            end
        end

        notify("Fling Ball ALL Finalizado [" .. flingCount .. "/" .. totalPlayers .. "]")
        isFlinging = false
        if connection then connection:Disconnect() end
    end

    if not isFlinging then
        startFlingBallAll()
    else
        warn("O Fling Ball já está ativo.")
    end
end)

-- =====================
--  ⬇️Visual Buttons⬇️
-- =====================

Visual:AddLabel("Esp")

--// Variáveis de Controle
local ESPEnabled = false
local RainbowEnabled = false
local CurrentColor = Color3.fromRGB(255, 255, 255)

--// Função: Ativar efeito Rainbow
local function enableRainbow()
    RainbowEnabled = true
    task.spawn(function()
        while RainbowEnabled do
            local time = tick() * 5
            CurrentColor = Color3.fromHSV((time % 360) / 360, 1, 1)
            task.wait(0.1)
        end
    end)
end

--// Função: Definir cor estática
local function setESPColor(color)
    RainbowEnabled = false
    CurrentColor = color
end

--// Função: Criar ESP para um jogador
local function createESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = player.Character

    -- Evitar duplicatas
    if char:FindFirstChild("ESP_Highlight") or char:FindFirstChild("ESP_Info") then return end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = CurrentColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = char

    -- Billboard GUI
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_Info"
    bill.Adornee = char:FindFirstChild("HumanoidRootPart")
    bill.Size = UDim2.new(0, 150, 0, 50)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.Parent = char

    -- Função interna para criar labels
    local function makeLabel(text, posY)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0.2, 0)
        label.Position = UDim2.new(0, 0, posY, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = CurrentColor
        label.TextStrokeTransparency = 0.2
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.BuilderSans
        label.Parent = bill
        return label
    end

    -- Labels
    local nameLabel = makeLabel(player.Name, 0)
    local distLabel = makeLabel("Distância: ...", 0.2)
    local ageLabel = makeLabel("Conta: " .. player.AccountAge .. " dias", 0.4)
    local hpLabel = makeLabel("Vida: ...", 0.6)
    local sitLabel = makeLabel("Sentado: Não", 0.8)

    -- Atualização em tempo real
    task.spawn(function()
        while ESPEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if not root or not hum then break end

            local localRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            distLabel.Text = localRoot and string.format("Distância: %.1f", (root.Position - localRoot.Position).Magnitude) or "Distância: N/A"
            hpLabel.Text = "Vida: " .. math.floor(hum.Health)
            sitLabel.Text = "Sentado: " .. (hum.Sit and "Sim" or "Não")

            for _, lbl in pairs({nameLabel, distLabel, ageLabel, hpLabel, sitLabel}) do
                lbl.TextColor3 = CurrentColor
            end
            highlight.FillColor = CurrentColor

            task.wait(0.1)
        end
    end)
end

--// Função: Ativar/Desativar ESP
local function toggleESP(enabled)
    ESPEnabled = enabled

    if enabled then
        -- Adiciona ESP para todos os jogadores existentes
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                createESP(plr)
            end
        end

        -- Evita múltiplas conexões
        if not _G.ESPConnection then
            _G.ESPConnection = game.Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function()
                    if ESPEnabled then
                        createESP(p)
                    end
                end)
            end)
        end
    else
        -- Remove ESP de todos os jogadores
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Character then
                local h = plr.Character:FindFirstChild("ESP_Highlight")
                local g = plr.Character:FindFirstChild("ESP_Info")
                if h then h:Destroy() end
                if g then g:Destroy() end
            end
        end

        -- Desconecta listener
        if _G.ESPConnection then
            _G.ESPConnection:Disconnect()
            _G.ESPConnection = nil
        end

        RainbowEnabled = false
    end
end

--// UI: Toggle de ESP
Visual:AddSwitch("ESP", function(state)
    toggleESP(state)
    print("ESP " .. (state and "Ativado" or "Desativado"))
end)

--// UI: Dropdown de Cores
Visual:AddDropdown("Cores do ESP", {
    "Azul", "Vermelho", "Verde", "Amarelo", "Roxo", "Cinza", "Preto", "Branco", "Laranja", "Rosa", "Marrom", "Rainbow"
}, function(opt)
    local cores = {
        Azul = Color3.fromRGB(0, 0, 255),
        Vermelho = Color3.fromRGB(255, 0, 0),
        Verde = Color3.fromRGB(0, 255, 0),
        Amarelo = Color3.fromRGB(255, 255, 0),
        Roxo = Color3.fromRGB(128, 0, 128),
        Cinza = Color3.fromRGB(128, 128, 128),
        Preto = Color3.fromRGB(0, 0, 0),
        Branco = Color3.fromRGB(255, 255, 255),
        Laranja = Color3.fromRGB(255, 165, 0),
        Rosa = Color3.fromRGB(255, 192, 203),
        Marrom = Color3.fromRGB(139, 69, 19)
    }

    if opt == "Rainbow" then
        enableRainbow()
    else
        setESPColor(cores[opt])
    end
end)

-- ======================
--  ⬇️Scripts Buttons⬇️
-- ======================

Scripts:AddLabel("Scripts")

Scripts:AddButton("Ant - Lag", function()
 loadstring(game:HttpGet('https://pastebin.com/raw/ureZEHue'))()
end)

Scripts:AddButton("CrossArms - By Shelby", function()
 loadstring(game:HttpGet('https://gist.githubusercontent.com/GistsPrivate/b78b6e74c22d3c66c54c56bd7294b59b/raw/071953c0b86e1bddcb08731bd300be739b9217c7/CrossArmsByShelby'))()
end)

Scripts:AddButton("Diminuir AnimspedIdle - By Shelby", function()
 loadstring(game:HttpGet('https://gist.githubusercontent.com/GistsPrivate/9b57473131f0dfe0ee6bdd6972413da0/raw/238074000ab8e84ba5a9621b521445f1f4cddc50/AnimspeedIdle'))()
end)

Scripts:AddButton("Infinite - Yield By Shelby", function()
 loadstring(game:HttpGet('https://pastebin.com/raw/JwTgMF22'))()
end)

Scripts:AddButton("FreeCam - By Shelby", function()
 loadstring(game:HttpGet('https://pastebin.com/raw/bRW6EMRZ'))()
end)

Scripts:AddButton("ShiftLock - made by fedoratum And Shnmax", function()
 loadstring(game:HttpGet('https://pastebin.com/raw/H0uuimru'))()
end)

Scripts:AddButton("Shaders - Mobile Optimized", function()
--// SHNMAXHUB - ULTRA LIGHT SHADERS v0.3.1 - COM FILTRO DE VERDE CORRIGIDO

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer

-- Pastas
local function organizarPastas()
	local shadersFolder = Workspace:FindFirstChild("Shaders") or Instance.new("Folder")
	shadersFolder.Name = "Shaders"
	shadersFolder.Parent = Workspace

	local ambientFolder = Workspace:FindFirstChild("AmbientSounds") or Instance.new("Folder")
	ambientFolder.Name = "AmbientSounds"
	ambientFolder.Parent = Workspace
end

-- Skybox leve
local function aplicarSkybox()
	local sky = Instance.new("Sky")
	sky.SkyboxBk = "http://www.roblox.com/asset/?id=225469345"
	sky.SkyboxDn = "http://www.roblox.com/asset/?id=225469349"
	sky.SkyboxFt = "http://www.roblox.com/asset/?id=225469359"
	sky.SkyboxLf = "http://www.roblox.com/asset/?id=225469364"
	sky.SkyboxRt = "http://www.roblox.com/asset/?id=225469372"
	sky.SkyboxUp = "http://www.roblox.com/asset/?id=225469380"
	sky.Parent = Lighting
end

-- Atmosfera mais leve
local function aplicarAtmosfera()
	local atm = Instance.new("Atmosphere")
	atm.Density = 0.2
	atm.Offset = 0.5
	atm.Glare = 0.05
	atm.Haze = 0.3
	atm.Color = Color3.fromRGB(210, 225, 255)
	atm.Decay = Color3.fromRGB(130, 140, 150)
	atm.Parent = Lighting
end

-- Iluminação otimizada
local function configurarIluminacao()
	Lighting.Technology = Enum.Technology.Compatibility
	Lighting.Brightness = 2.5
	Lighting.GlobalShadows = false
	Lighting.ClockTime = 14
	Lighting.GeographicLatitude = 42
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.3
	Lighting.ShadowSoftness = 1
	Lighting.OutdoorAmbient = Color3.fromRGB(90, 90, 90)
	Lighting.Ambient = Color3.fromRGB(60, 60, 60)
	Lighting.FogColor = Color3.fromRGB(200, 215, 255)
	Lighting.FogStart = 150
	Lighting.FogEnd = 50000

	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") then v:Destroy() end
	end

	local sunrays = Instance.new("SunRaysEffect", Lighting)
	sunrays.Intensity = 0.1
	sunrays.Spread = 0.6

	local cc = Instance.new("ColorCorrectionEffect", Lighting)
	cc.Brightness = 0
	cc.Contrast = 0.03
	cc.Saturation = 0.03
	cc.TintColor = Color3.fromRGB(230, 235, 245)
end

-- Ambiente dinâmico (leve)
local function ajustarAmbiente()
	coroutine.wrap(function()
		while task.wait(5) do
			local hour = Lighting:GetMinutesAfterMidnight() / 60
			Lighting.Ambient = hour >= 6 and hour <= 18 and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 60)
		end
	end)()
end

-- Som ambiente leve
local function criarSomAmbiente()
	local ambientFolder = Workspace:FindFirstChild("AmbientSounds")
	if not ambientFolder then return end

	local dia = Instance.new("Sound", ambientFolder)
	dia.Name = "Dia"
	dia.SoundId = "rbxassetid://6189453706"
	dia.Looped = true
	dia.Volume = 0.35
	dia:Play()

	local noite = Instance.new("Sound", ambientFolder)
	noite.Name = "Noite"
	noite.SoundId = "rbxassetid://6189441072"
	noite.Looped = true
	noite.Volume = 0.25

	coroutine.wrap(function()
		while task.wait(5) do
			local hour = Lighting:GetMinutesAfterMidnight() / 60
			dia.Playing = hour >= 6 and hour <= 18
			noite.Playing = not dia.Playing
		end
	end)()
end

-- Função: detectar verde puro com HSV
local function isPureGreen(color)
	local h, s, v = Color3.toHSV(color)
	return h >= 0.25 and h <= 0.42 and s >= 0.4 -- 90° a 150° no círculo cromático
end

-- Aplicar material Grass só em verde puro
local function aplicarMaterialVerde(part)
	if part:IsA("BasePart") and not part:IsDescendantOf(Workspace:FindFirstChild("Shaders")) then
		if isPureGreen(part.Color) and part.Material ~= Enum.Material.Grass then
			part.Material = Enum.Material.Grass
			part.Reflectance = 0.01
		end
	end
end

-- Água leve
local function aplicarAguaReal()
	if not Terrain then return end

	Terrain.WaterColor = Color3.fromRGB(6, 40, 80)
	Terrain.WaterTransparency = 0.6
	Terrain.WaterReflectance = 0.6
	Terrain.WaterWaveSize = 0.05
	Terrain.WaterWaveSpeed = 3

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():match("water") then
			obj.Transparency = 1
			obj.CanCollide = false
			Terrain:FillBlock(obj.CFrame, obj.Size, Enum.Material.Water)
		end
	end
end

-- Execução principal
organizarPastas()
aplicarSkybox()
aplicarAtmosfera()
configurarIluminacao()
ajustarAmbiente()
criarSomAmbiente()
aplicarAguaReal()

-- Aplicar material verde nas partes existentes
for _, obj in ipairs(Workspace:GetDescendants()) do
	if obj:IsA("BasePart") then
		aplicarMaterialVerde(obj)
	end
end

-- Atualizar novas partes com material verde
Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") then
		task.defer(function()
			aplicarMaterialVerde(obj)
		end)
	end
end)

-- Sem eco global
SoundService.AmbientReverb = Enum.ReverbType.Cave
end)

game.Workspace.FallenPartsDestroyHeight = -math.huge