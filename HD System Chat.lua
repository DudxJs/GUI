-- Serviços Roblox
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- Variáveis principais
local LocalPlayer = Players.LocalPlayer
local ChatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local SystemVersion = "BETA(Teste)"
local CommandPrefix = "/"
local CommandModeActive = false
local MessageLoopThread = nil

-- Controle de permissões e pontos
local PlayerClasses = {}
local PlayerPoints = {}

local Classes = {
    ["Membro"] = { "fps", "tempo", "info", "msg", "rank", "versao", "comandos", "comandos2" },
    ["ADM"] = { "zoar", "kill", "fps", "tempo", "info", "msg", "rank", "versao", "comandos", "comandos2" },
    ["✨DEV✨"] = { "mudarprefixo", "quest", "zoar", "kill", "fps", "tempo", "info", "msg", "rank", "versao", "comandos", "comandos2" }
}

-- Função para enviar mensagens no chat
local function SendChatMessage(message)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if textChannel then
            textChannel:SendAsync(message)
        end
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
    end
end

-- Notificação de cooldown
local function ShowBadge()
    StarterGui:SetCore("SendNotification", {
        Title = "Aguarde!",
        Text = "Voltando em 16 segundos!",
        Duration = 16
    })
end

-- Loop de mensagem automática
local function StartCommandMessageLoop()
    if MessageLoopThread then
        task.cancel(MessageLoopThread)
    end
    MessageLoopThread = task.spawn(function()
        while CommandModeActive do
            task.wait(180)
            if CommandModeActive then
                SendChatMessage("Oi\r[System]: Comandos liberados! Digite " .. CommandPrefix .. "comandos para ver a lista de comandos")
            end
        end
    end)
end

-- Alternar modo comandos
local function ToggleCommandMode()
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
    if CommandModeActive then
        SendChatMessage("Oi\r[System]: Comandos Desativados!")
        ShowBadge()
        task.spawn(StartCommandMessageLoop)
        task.wait(16)
        CommandModeActive = false
    else
        CommandModeActive = true
        SendChatMessage("Oi\r[System]: Comandos liberados! Digite " .. CommandPrefix .. "comandos para ver a lista de comandos")
        task.spawn(StartCommandMessageLoop)
    end
end

-- Botão na tela para alternar modo comandos
local function CreateToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(1, -210, 0, 10)
    button.Text = "Ativar Modo Comandos"
    button.AutoButtonColor = false
    button:SetAttribute("Cooldown", false)
    button.Parent = screenGui

    task.spawn(function()
        while button do
            for i = 0, 1, 0.01 do
                button.BackgroundColor3 = Color3.fromHSV(i, 1, 1)
                task.wait(0.05)
            end
        end
    end)

    button.MouseButton1Click:Connect(function()
        if not button:GetAttribute("Cooldown") then
            button:SetAttribute("Cooldown", true)
            ToggleCommandMode()
            button.Text = CommandModeActive and "Desativar Modo Comandos" or "Ativar Modo Comandos"
            task.wait(16)
            button:SetAttribute("Cooldown", false)
        end
    end)
end

task.spawn(function()
    while not Players.LocalPlayer do task.wait() end
    LocalPlayer = Players.LocalPlayer
    CreateToggleButton()
end)

-- Função para verificar permissão do jogador
local function HasPermission(player, command)
    local class = PlayerClasses[player.UserId] or "Membro"
    for _, cmd in ipairs(Classes[class]) do
        if cmd == command then
            return true
        end
    end
    return false
end

-- Mensagem de erro de permissão
local function SendPermissionError(player, command, requiredClass)
    SendChatMessage("Oi\r[Erro]: O comando '" .. command .. "' pertence à classe '" .. requiredClass .. "'")
end

-- Sistema de perguntas e pontuação para o comando "quest"
local Questions = {
    {"Quem escreveu 'Dom Casmurro'?", "machado de assis"},
    {"Qual é o maior planeta do Sistema Solar?", "júpiter"},
    {"Quanto é 7 + 8?", "15"},
    {"Quem pintou a Mona Lisa?", "leonardo da vinci"},
    {"Qual o metal líquido à temperatura ambiente?", "mercúrio"},
    {"Qual a capital do Japão?", "tóquio"},
    {"Quem foi o primeiro homem a pisar na Lua?", "neil armstrong"},
    {"Quantos lados tem um triângulo?", "3"},
    {"Em que ano terminou a Segunda Guerra Mundial?", "1945"},
    {"Qual o maior mamífero do mundo?", "baleia azul"},
    {"Quem descobriu o Brasil?", "pedro álvares cabral"},
    {"Qual é o símbolo químico do ouro?", "au"},
    {"Qual é o rio mais extenso do mundo?", "amazonas"},
    {"Quantos estados tem o Brasil?", "26"},
    {"Quem é conhecido como o 'Rei do Futebol'?", "pelé"},
    {"Quantos segundos tem um minuto?", "60"},
    {"Qual o menor país do mundo?", "vaticano"},
    {"Quem escreveu 'Romeu e Julieta'?", "william shakespeare"},
    {"Quantos dentes tem um adulto humano?", "32"},
    {"Qual o animal símbolo da Austrália?", "canguru"},
    {"Quem inventou a lâmpada?", "thomas edison"},
    {"Qual a montanha mais alta do mundo?", "everest"},
    {"Quantos continentes existem?", "7"},
    {"Quem foi o primeiro presidente do Brasil?", "deodoro da fonseca"},
    {"Quantos ossos tem o corpo humano?", "206"},
    {"Qual é o maior oceano do mundo?", "pacífico"},
    {"Quem pintou 'O Grito'?", "edvard munch"},
    {"Qual é a cor da esmeralda?", "verde"},
    {"Quem é o autor de 'Harry Potter'?", "j.k. rowling"},
    {"Qual é a fórmula química da água?", "h2o"}
}

local function verificarClasse(player)
    local userId = player.UserId
    if PlayerPoints[userId] and PlayerPoints[userId] >= 3 then
        local classeAtual = player:GetAttribute("Classe")
        if classeAtual ~= "ADM" then
            player:SetAttribute("Classe", "ADM")
            PlayerClasses[userId] = "ADM"
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats and leaderstats:FindFirstChild("Classe") then
                leaderstats.Classe.Value = "ADM"
            end
            SendChatMessage("Oi\r[System]: " .. player.DisplayName .. " agora é ADM!")
        end
    end
end

local function adicionarPonto(player)
    local userId = player.UserId
    PlayerPoints[userId] = (PlayerPoints[userId] or 0) + 1
    verificarClasse(player)
    SendChatMessage("Oi\r[System]: " .. player.DisplayName .. " acertou! Pontos: " .. PlayerPoints[userId])
end

local function StartQuest()
    local index = math.random(#Questions)
    local CurrentQuestion = Questions[index][1]
    local CurrentAnswer = string.lower(Questions[index][2])
    SendChatMessage("Oi\r[System]: " .. CurrentQuestion)

    local connection
    connection = TextChatService.MessageReceived:Connect(function(messageObject)
        local player = Players:GetPlayerByUserId(messageObject.TextSource.UserId)
        if not player then return end
        if string.lower(messageObject.Text) == CurrentAnswer then
            if PlayerClasses[player.UserId] == "✨DEV✨" then
                SendChatMessage("Oi\r[System]: Você não pode responder sua própria pergunta.")
                return
            end
            adicionarPonto(player)
            connection:Disconnect()
        end
    end)

    task.wait(30)
    if connection.Connected then
        connection:Disconnect()
        SendChatMessage("Oi\r[System]: Tempo Esgotado! Ninguém respondeu Corretamente!")
    end
end

-- Definir DEV automaticamente
PlayerClasses[LocalPlayer.UserId] = "✨DEV✨"

-- Comandos do chat
TextChatService.MessageReceived:Connect(function(messageObject)
    local message = messageObject.Text
    local player = Players:GetPlayerByUserId(messageObject.TextSource.UserId)
    if not player then return end

    -- Verifica se modo comandos está ativo
if not CommandModeActive and PlayerClasses[player.UserId] ~= "✨DEV✨" then
    return
end

    -- Captura comando
    local cmd = message:match("^" .. CommandPrefix .. "(%S+)")
    if not cmd then return end

    -- Verifica permissão
    local found = false
    for class, commands in pairs(Classes) do
        for _, c in ipairs(commands) do
            if c == cmd then
                found = true
                if not HasPermission(player, cmd) then
                    SendPermissionError(player, cmd, class)
                    return
                end
            end
        end
    end
    if not found then return end

    -- Lógica dos comandos
    if cmd == "comandos" then
        SendChatMessage("Oi\r[System]: Comandos disponíveis: " ..
            CommandPrefix .. "fps, " ..
            CommandPrefix .. "tempo, " ..
            CommandPrefix .. "info, " ..
            CommandPrefix .. "msg [texto], " ..
            CommandPrefix .. "rank, " ..
            CommandPrefix .. "versao. Digite /comandos2 para mais!"
        )

    elseif cmd == "comandos2" then
        SendChatMessage("Oi\r[System]: Comandos adicionais: " ..
            CommandPrefix .. "zoar [jogador] [texto], " ..
            CommandPrefix .. "kill, " ..
            CommandPrefix .. "quest, " ..
            CommandPrefix .. "mudarprefixo"
        )

    elseif cmd == "fps" then
        local fps = math.max(1, math.floor(workspace:GetRealPhysicsFPS()))
        SendChatMessage("Oi\r[System]: Seu FPS atual: " .. tostring(fps))

    elseif cmd == "tempo" then
        SendChatMessage("Oi\r[System]: Horário do servidor: " .. os.date("%H:%M:%S"))

    elseif cmd == "info" then
        SendChatMessage("Oi\r[System]: Servidor ativo há " .. math.floor(workspace.DistributedGameTime) .. " segundos.")

    elseif cmd == "msg" then
        local customMessage = message:match("^" .. CommandPrefix .. "msg%s(.+)")
        if customMessage then
            SendChatMessage("Oi\r[System]: " .. customMessage)
        else
            SendChatMessage("Oi\r[Erro]: Experimente: '" .. CommandPrefix .. "msg System Bot'.")
        end

    elseif cmd == "rank" then
        SendChatMessage("Oi\r[System]: Seu rank atual é: " .. (PlayerClasses[player.UserId] or "Membro"))

    elseif cmd == "versao" then
        SendChatMessage("Oi\r[System]: Versão atual: " .. SystemVersion)

    elseif cmd == "zoar" then
        local args = message:split(" ")
        if #args < 3 then
            SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "zoar [jogador] [mensagem]")
            return
        end
        local targetName = args[2]:lower()
        local prankMessage = table.concat(args, " ", 3)
        for _, target in pairs(Players:GetPlayers()) do
            if target.Name:lower() == targetName or target.DisplayName:lower() == targetName then
                SendChatMessage("Oi\r" .. target.DisplayName .. ": " .. prankMessage)
                return
            end
        end
        SendChatMessage("Oi\r[Erro]: Jogador não encontrado.")

-- Novo comando /kill <NomeDoAlvo> (ou prefixo desejado)

elseif cmd == "kill" then
    local args = message:split(" ")
    local targetName = args[2]
    if not targetName then
        SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "kill [NomeDoJogador]")
        return
    end

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = Players.LocalPlayer
    local Backpack = Player:WaitForChild("Backpack")
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    -- Funções utilitárias
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
        return (grip - Vector3.new(2, 5, -1)).Magnitude < 0.01
    end

    -- Pega ou equipa Couch
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
        local remote = ReplicatedStorage.RE:FindFirstChild("1Too1l")
        if not remote then
            SendChatMessage("Oi\r[Erro]: Remote 1Too1l não encontrado!")
            return
        end
        local argsRemote = {"PickingTools", "Couch"}
        local success, err = pcall(function()
            remote:InvokeServer(unpack(argsRemote))
        end)
        if not success then
            SendChatMessage("Oi\r[Erro]: Falha ao solicitar Couch!")
            return
        end
        local timeout, waited = 5, 0
        repeat
            task.wait(0.1)
            waited += 0.1
        until HasCouch() or waited >= timeout
        if not HasCouch() then
            SendChatMessage("Oi\r[Erro]: Couch não apareceu após solicitação.")
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
            SendChatMessage("Oi\r[Erro]: Falha ao equipar Couch após pegar.")
            return
        end
    end

    -- Preparação para o FLING
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    getgenv().AllowFling = true
    getgenv().AllowReturn = true
    getgenv().Target = targetName

    local TargetPlayer = Players:FindFirstChild(targetName)
    if not TargetPlayer or not TargetPlayer.Character then
        SendChatMessage("Oi\r[Erro]: Jogador '" .. targetName .. "' não encontrado ou sem personagem.")
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
        SendChatMessage("Oi\r[Erro]: Nenhuma parte válida do alvo.")
        return
    end

    -- Salva posição original
    local StartPos = RootPart.Position
    local TargetStartPos = BasePart.Position
    local killDone = false

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

    -- Fling Loop
    local startTime = tick()
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
                if not getgenv().AllowFling then break end
                FPos(BasePart, move + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                task.wait()
            end

            -- Checa distância: se o alvo foi "abatido"
            local dist = (BasePart.Position - TargetStartPos).Magnitude
            if dist > 2600 and not killDone then
                killDone = true
                getgenv().AllowFling = false
                getgenv().AllowReturn = false
                SendChatMessage("Oi\r[System]: O Jogador(a) " .. targetName .. " foi Abatido(a) com Sucesso!")
                break
            end

            -- Timeout: mais de 5 segundos tentando matar
            if tick() - startTime > 5 and not killDone then
                killDone = true
                getgenv().AllowFling = false
                getgenv().AllowReturn = false
                -- Parar, limpar forças e retornar player
                local fixedReturnPos = Vector3.new(1118.81, 75.998, -1138.61)
                for _, obj in ipairs(Character:GetDescendants()) do
                    if obj:IsA("BodyMover") or obj:IsA("Constraint") or obj:IsA("VectorForce") or obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") or obj:IsA("LinearVelocity") or obj:IsA("Torque") then
                        pcall(function() obj:Destroy() end)
                    end
                end
                Humanoid.PlatformStand = true
                RootPart.Anchored = true
                RootPart.AssemblyLinearVelocity = Vector3.zero
                RootPart.AssemblyAngularVelocity = Vector3.zero
                RootPart.CFrame = CFrame.new(fixedReturnPos)
                task.wait(3)
                RootPart.Anchored = false
                Humanoid.PlatformStand = false
                SendChatMessage("Oi\r[Erro]: Falha ao abater o alvo! Tente novamente.")
                break
            end
        end
    end)
    
    function string:split(sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end
    
    -- Comando: /levar [Alvo] ate [Destino]
    elseif cmd == "levar" then
        local args = message:split(" ")
        -- Exemplo: /levar JogadorA ate JogadorB
        if #args < 4 or args[3]:lower() ~= "ate" then
            SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "levar [Alvo] ate [Destino]")
            return
        end

        local alvoName = args[2]
        local destinoName = args[4]

        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Player = Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        local RootPart = Character:WaitForChild("HumanoidRootPart")
        local Backpack = Player:WaitForChild("Backpack")

        -- Função para equipar a Couch
        local function EquipCouch()
            local couchTool = Backpack:FindFirstChild("Couch") or Character:FindFirstChild("Couch")
            if not couchTool then
                local args = { [1] = "PickingTools", [2] = "Couch" }
                local remote = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Too1l")
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
                if couchTool:FindFirstChild("Handle") then
                    couchTool.GripPos = Vector3.new(2, 5, -1)
                end
                if Backpack:FindFirstChild("Couch") then
                    Humanoid:EquipTool(couchTool)
                else
                    couchTool.Parent = Backpack
                    task.wait()
                    Humanoid:EquipTool(couchTool)
                end
            else
                SendChatMessage("Oi\r[Erro]: Couch não encontrado após tentativa de pegar.")
            end
        end

        EquipCouch()

        -- Seleção do alvo e do destino
        local TargetPlayer = Players:FindFirstChild(alvoName)
        if not TargetPlayer or not TargetPlayer.Character then
            SendChatMessage("Oi\r[Erro]: Alvo '"..alvoName.."' não encontrado ou sem personagem.")
            return
        end

        local TCharacter = TargetPlayer.Character
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and (THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart"))

        local DestinoPlayer = Players:FindFirstChild(destinoName)
        local DestinoRootPart = DestinoPlayer and DestinoPlayer.Character and DestinoPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not DestinoPlayer or not DestinoRootPart then
            SendChatMessage("Oi\r[Erro]: Destino '"..destinoName.."' não encontrado ou sem personagem.")
            return
        end

        -- Salva posição original
        if RootPart and RootPart.Position.Magnitude < 99999 then
            getgenv().OldPos = RootPart.CFrame
        end

        -- Função para posicionar
        local function FPos(BasePart, Pos, Ang)
            local targetCFrame = CFrame.new(BasePart.Position) * Pos * Ang
            RootPart.CFrame = targetCFrame
            Character:SetPrimaryPartCFrame(targetCFrame)
        end

        -- Monitorar se o alvo sentou e teleportar
        task.spawn(function()
            local alreadyHandled = false
            while THumanoid and THumanoid.Parent and Humanoid.Health > 0 and not alreadyHandled do
                if THumanoid.Sit then
                    alreadyHandled = true
                    -- Teleporta o executor (e o alvo junto) para o destino
                    if DestinoRootPart then
                        RootPart.CFrame = DestinoRootPart.CFrame
                        Character:SetPrimaryPartCFrame(DestinoRootPart.CFrame)
                    else
                        local escapePos = CFrame.new(0, -700, 0)
                        RootPart.CFrame = escapePos
                        Character:SetPrimaryPartCFrame(escapePos)
                    end
                    task.wait(1)
                    -- Limpa Couch
                    local clearRemote = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s")
                    if clearRemote then
                        clearRemote:FireServer("ClearAllTools")
                    end
                    task.wait(0.3)
                    -- Retorna executor para a posição original
                    if getgenv().OldPos then
                        RootPart.CFrame = getgenv().OldPos
                        Character:SetPrimaryPartCFrame(getgenv().OldPos)
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                task.wait(0.1)
            end
        end)

        -- Força o alvo a sentar ("dança do push")
        local function SFBasePart(BasePart)
            local TempoMax = 5
            local Inicio = tick()
            local Angulo = 0
            repeat
                if not THumanoid or not RootPart then break end
                if BasePart.Velocity.Magnitude < 50 then
                    Angulo += 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0), CFrame.Angles(math.rad(Angulo), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(Angulo), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25), CFrame.Angles(math.rad(Angulo), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25), CFrame.Angles(math.rad(Angulo), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, TRootPart.Velocity.Magnitude / -1.25), CFrame.Angles(0, 0, 0)); task.wait()
                end
            until tick() > Inicio + TempoMax or THumanoid.Sit or Humanoid.Health <= 0
        end

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart then
            SFBasePart(TRootPart)
        else
            SendChatMessage("Oi\r[Erro]: Parte do corpo do alvo não encontrada para movimentação.")
        end
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

        SendChatMessage("Oi\r[System]: O jogador '"..alvoName.."' foi levado até '"..destinoName.."' com sucesso!")

    elseif cmd == "mudarprefixo" and PlayerClasses[player.UserId] == "✨DEV✨" then
        local newPrefix = message:match("^" .. CommandPrefix .. "mudarprefixo%s(.+)")
        if newPrefix and #newPrefix == 1 then
            CommandPrefix = newPrefix
            SendChatMessage("Oi\r[System]: Prefixo alterado para: " .. newPrefix)
        else
            SendChatMessage("Oi\r[Erro]: Use apenas um caractere como prefixo.")
        end

    elseif cmd == "quest" and PlayerClasses[player.UserId] == "✨DEV✨" then
        if not _G.QuestCommandRegistered then
            _G.QuestCommandRegistered = true
            StartQuest()
        end
    end
end)