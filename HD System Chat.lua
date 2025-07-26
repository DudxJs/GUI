-- Bloqueio de execução múltipla universal para Roblox
local scriptId = "HDSystemChat" -- Troque esse nome para um identificador único se quiser permitir múltiplos scripts distintos

if _G["executou_"..scriptId] then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Erro";
            Text = "Este script já foi executado e não pode ser executado novamente!";
            Duration = 5;
        })
    end)
    return -- Para o script aqui
else
    _G["executou_"..scriptId] = true
end

-- Serviços Roblox
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

-- Variáveis principais
local LocalPlayer = Players.LocalPlayer
local ChatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local SystemVersion = "BETA(Teste)"
local CommandPrefix = "/"
local CommandModeActive = false
local MessageLoopThread = nil
local BannedPlayers = {} -- [userId] = true

-- Controle de permissões e pontos
local PlayerClasses = {}
local PlayerPoints = {}

-- É obrigatório colocar o comando aqui, após criar um "elseif cmd" novo
local Classes = {
    ["Membro"] = { "fps", "tempo", "info", "msg", "rank", "versao", "comandos", "comandos2" },
    ["ADM"] = { "zoar", "kill", "fps", "tempo", "info", "msg", "rank", "versao", "comandos", "comandos2", "tp", "clear" },
    ["✨DEV✨"] = { "mudarprefixo", "quest", "zoar", "kill", "fps", "tempo", "info", "msg", "rank", "versao", "comandos", "comandos2", "tp", "setrank", "ban", "unban", "clear", "audios", "playsound" }
}

-- Variáveis e funções para o sistema de áudio
local SoundsPerPage = 10 -- Quantos áudios por página
local SoundList = { -- Sua lista de sons
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

-- Função auxiliar para dividir strings (para substituir string:split)
local function splitString(inputString, separator)
    local fields = {}
    local pattern = string.format("([^%s]+)", separator)
    inputString:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

-- Função para enviar mensagens no chat
local function SendChatMessage(message)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if textChannel then
            textChannel:SendAsync(message)
        end
    else
        -- Substituindo \r por \n para compatibilidade ou tratando como espaço
        local formattedMessage = message:gsub("\r", "\n")
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(formattedMessage, "All")
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

-- Funções do sistema de perguntas e pontuação para o comando "quest"
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
        -- Verificar se TextSource e UserId existem antes de tentar obter o jogador
        if not messageObject.TextSource or not messageObject.TextSource.UserId then return end
        local player = Players:GetPlayerByUserId(messageObject.TextSource.UserId)
        if not player then return end

        if BannedPlayers[player.UserId] then
            SendChatMessage("Oi\r[Erro]: Você está banido do uso de comandos.")
            return
        end

        if string.lower(messageObject.Text) == CurrentAnswer then
            if PlayerClasses[player.UserId] == "✨DEV✨" then
                SendChatMessage("Oi\r[System]: Você não pode responder sua própria pergunta.")
                return
            end
            adicionarPonto(player)
            connection:Disconnect()
            _G.QuestCommandRegistered = false
        end
    end)

    task.wait(15)
    if connection.Connected then
        connection:Disconnect()
        SendChatMessage("Oi\r[System]: Tempo Esgotado! Ninguém respondeu Corretamente!")
    end
    _G.QuestCommandRegistered = false
end

-- Funções de áudio
local function Audio_All_ClientSide(ID)
    local function CheckFolderAudioAll()
        local FolderAudio = Workspace:FindFirstChild("Audio all client")
        if not FolderAudio then
            FolderAudio = Instance.new("Folder")
            FolderAudio.Name = "Audio all client"
            FolderAudio.Parent = Workspace
        end
        return FolderAudio
    end

    local function CreateSound(ID)
        if type(ID) ~= "number" then
            print("[Audio_All_ClientSide] Insira um número válido para o ID.")
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
        print("[Audio_All_ServerSide] Insira um número válido para o ID.")
        return nil
    end

    local GunSoundEvent = ReplicatedStorage:FindFirstChild("1Gu1nSound1s", true)
    if GunSoundEvent and GunSoundEvent:IsA("RemoteEvent") then
        GunSoundEvent:FireServer(Workspace, ID, 1)
    else
        warn("[Audio_All_ServerSide] RemoteEvent '1Gu1nSound1s' não encontrado ou não é um RemoteEvent. O áudio pode não ser reproduzido para outros jogadores.")
    end
end

-- A função PlaySoundForAll agora recebe o ID e o NOME do áudio
local function PlaySoundForAll(audioId, audioName)
    if not audioId then
        SendChatMessage("Oi\r[Erro]: Nenhum ID de áudio válido fornecido para reprodução.")
        return
    end
    -- Converte audioId para número para garantir compatibilidade
    audioId = tonumber(audioId)
    if not audioId then
        SendChatMessage("Oi\r[Erro]: ID de áudio inválido: '" .. tostring(audioId) .. "'.")
        return
    end

    Audio_All_ServerSide(audioId)
    task.spawn(function()
        Audio_All_ClientSide(audioId)
    end)
    -- Agora exibe o nome do áudio
    SendChatMessage("Oi\r[System]: Áudio '" .. audioName .. "' sendo reproduzido!")
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

-- Definir DEV automaticamente
PlayerClasses[LocalPlayer.UserId] = "✨DEV✨"

-- Comandos do chat
TextChatService.MessageReceived:Connect(function(messageObject)
    -- Verificar se TextSource e UserId existem antes de tentar obter o jogador
    if not messageObject.TextSource or not messageObject.TextSource.UserId then return end
    local message = messageObject.Text
    local player = Players:GetPlayerByUserId(messageObject.TextSource.UserId)
    if not player then return end

    if BannedPlayers[player.UserId] then
        SendChatMessage("Oi\r[Erro]: Você está banido do uso de comandos.")
        return
    end

    if not CommandModeActive and PlayerClasses[player.UserId] ~= "✨DEV✨" then
        return
    end

    local cmd = message:match("^" .. CommandPrefix .. "([a-zA-Z]+)")
    local cmdNumber = message:match("^" .. CommandPrefix .. "[a-zA-Z]+(%d+)")
    cmdNumber = tonumber(cmdNumber) or 1

    if not cmd then return end

    local found = false
    local baseCmd = cmd
    if baseCmd:match("^audios") then
        baseCmd = "audios"
    end

    for class, commands in pairs(Classes) do
        for _, c in ipairs(commands) do
            if c == baseCmd then
                found = true
                if not HasPermission(player, baseCmd) then
                    SendPermissionError(player, baseCmd, class)
                    return
                end
            end
        end
    end
    if not found then return end

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
            CommandPrefix .. "kill [jogador], " ..
            CommandPrefix .. "quest, " ..
            CommandPrefix .. "mudarprefixo, " ..
            CommandPrefix .. "setrank, " ..
            CommandPrefix .. "ban, " ..
            CommandPrefix .. "unban, " ..
            CommandPrefix .. "audios[página], " ..
            CommandPrefix .. "playsound [número]. "
        )

    elseif cmd == "fps" then
        local fps = math.max(1, math.floor(Workspace:GetRealPhysicsFPS()))
        SendChatMessage("Oi\r[System]: O FPS atual de " .. player.DisplayName .. " é: " .. tostring(fps))

    elseif cmd == "tempo" then
        SendChatMessage("Oi\r[System]: Horário do servidor: " .. os.date("%H:%M:%S"))

    elseif cmd == "info" then
        SendChatMessage("Oi\r[System]: Servidor ativo há " .. math.floor(Workspace.DistributedGameTime) .. " segundos.\r[System]: Script Criado Por: Dudx_js")

    elseif cmd == "msg" then
        local customMessage = message:match("^" .. CommandPrefix .. "msg%s(.+)")
        if customMessage then
            SendChatMessage("Oi\r[System]: " .. customMessage)
        else
            SendChatMessage("Oi\r[Erro]: Experimente: '" .. CommandPrefix .. "msg System Bot'.")
        end

    elseif cmd == "rank" then
        SendChatMessage("Oi\r[System]: O rank atual de " .. player.DisplayName .. " é: " .. (PlayerClasses[player.UserId] or "Membro"))

    elseif cmd == "versao" then
        SendChatMessage("Oi\r[System]: Versão atual: " .. SystemVersion)

    elseif cmd == "zoar" then
        local args = splitString(message, " ") -- Usando a nova função splitString
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

    elseif cmd == "kill" then
        local args = splitString(message, " ") -- Usando a nova função splitString
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

        local StartPos = RootPart.Position
        local TargetStartPos = BasePart.Position
        local killDone = false

        Workspace.FallenPartsDestroyHeight = 0/0
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
                    if not getgenv().AllowFling then break end
                    FPos(BasePart, move + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                end

                local dist = (BasePart.Position - TargetStartPos).Magnitude
                if dist > 2600 and not killDone then
                    killDone = true
                    getgenv().AllowFling = false
                    getgenv().AllowReturn = false
                    SendChatMessage("Oi\r[System]: O Jogador(a) " .. targetName .. " foi Abatido(a) com Sucesso!")
                    break
                end

                if tick() - startTime > 5 and not killDone then
                    killDone = true
                    getgenv().AllowFling = false
                    getgenv().AllowReturn = false
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
    elseif cmd == "tp" then
        local args = splitString(message, " ") -- Usando a nova função splitString
        if #args < 4 or args[3]:lower() ~= "to" then
            SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "tp [Alvo] to [Destino]")
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

        if RootPart and RootPart.Position.Magnitude < 99999 then
            getgenv().OldPos = RootPart.CFrame
        end

        local function FPos(BasePart, Pos, Ang)
            local targetCFrame = CFrame.new(BasePart.Position) * Pos * Ang
            RootPart.CFrame = targetCFrame
            Character:SetPrimaryPartCFrame(targetCFrame)
        end

        task.spawn(function()
            local alreadyHandled = false
            while THumanoid and THumanoid.Parent and Humanoid.Health > 0 and not alreadyHandled do
                if THumanoid.Sit then
                    alreadyHandled = true
                    if DestinoRootPart then
                        RootPart.CFrame = DestinoRootPart.CFrame
                        Character:SetPrimaryPartCFrame(DestinoRootPart.CFrame)
                    else
                        local escapePos = CFrame.new(0, -700, 0)
                        RootPart.CFrame = escapePos
                        Character:SetPrimaryPartCFrame(escapePos)
                    end
                    task.wait(1)
                    local clearRemote = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s")
                    if clearRemote then
                        clearRemote:FireServer("ClearAllTools")
                    end
                    task.wait(0.3)
                    if getgenv().OldPos then
                        RootPart.CFrame = getgenv().OldPos
                        Character:SetPrimaryPartCFrame(getgenv().OldPos)
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                task.wait(0.1)
            end
        end)

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

    elseif cmd == "setrank" and PlayerClasses[player.UserId] == "✨DEV✨" then
        local args = splitString(message, " ") -- Usando a nova função splitString
        local targetName = args[2]
        local newClass = args[3]
        if not targetName or not newClass then
            SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "setrank [NomeDoJogador] [Membro/ADM]")
            return
        end

        if newClass == "✨DEV✨" then
            SendChatMessage("Oi\r[Erro]: Apenas você pode ser ✨DEV✨. Não é possível promover outros jogadores para DEV!")
            return
        end

        local validClasses = { ["Membro"] = true, ["ADM"] = true }
        if not validClasses[newClass] then
            SendChatMessage("Oi\r[Erro]: Rank inválida! Use apenas: Membro ou ADM")
            return
        end

        local targetPlayer = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == targetName:lower() or p.DisplayName:lower() == targetName:lower() then
                targetPlayer = p
                break
            end
        end

        if not targetPlayer then
            SendChatMessage("Oi\r[Erro]: Jogador '" .. targetName .. "' não encontrado.")
            return
        end

        PlayerClasses[targetPlayer.UserId] = newClass
        targetPlayer:SetAttribute("Classe", newClass)
        local leaderstats = targetPlayer:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Classe") then
            leaderstats.Classe.Value = newClass
        end

        SendChatMessage("Oi\r[System]: Ranking de " .. targetPlayer.DisplayName .. " atualizada para '" .. newClass .. "' com sucesso!")

    elseif cmd == "ban" then
        local args = splitString(message, " ") -- Usando a nova função splitString
        local targetName = args[2]
        if not targetName then
            SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "ban [NomeDoJogador]")
            return
        end
        local targetPlayer = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == targetName:lower() or p.DisplayName:lower() == targetName:lower() then
                targetPlayer = p
                break
            end
        end
        if not targetPlayer then
            SendChatMessage("Oi\r[Erro]: Jogador '" .. targetName .. "' não encontrado.")
            return
        end
        BannedPlayers[targetPlayer.UserId] = true
        SendChatMessage("Oi\r[System]: " .. targetPlayer.DisplayName .. " foi banido do uso de comandos!")

    elseif cmd == "unban" then
        local args = splitString(message, " ") -- Usando a nova função splitString
        local targetName = args[2]
        if not targetName then
            SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "unban [NomeDoJogador]")
            return
        end
        local targetPlayer = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == targetName:lower() or p.DisplayName:lower() == targetName:lower() then
                targetPlayer = p
                break
            end
        end
        if not targetPlayer then
            SendChatMessage("Oi\r[Erro]: Jogador '" .. targetName .. "' não encontrado.")
            return
        end
        BannedPlayers[targetPlayer.UserId] = nil
        SendChatMessage("Oi\r[System]: " .. targetPlayer.DisplayName .. " foi desbanido e pode usar comandos novamente!")

    elseif cmd == "clear" then
        SendChatMessage("Dudx_js Script Developer".. string.rep("\r", 97) .. "Chat Limpo!")

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

    elseif cmd:match("^audios") and PlayerClasses[player.UserId] == "✨DEV✨" then
        local totalPages = math.ceil(#SoundList / SoundsPerPage)
        
        if cmdNumber < 1 or cmdNumber > totalPages then
            SendChatMessage("Oi\r[Erro]: Página inválida. Use " .. CommandPrefix .. "audios[número da página] (ex: " .. CommandPrefix .. "audios1). Total de páginas: " .. totalPages .. ".")
            return
        end

        local startIndex = (cmdNumber - 1) * SoundsPerPage + 1
        local endIndex = math.min(startIndex + SoundsPerPage - 1, #SoundList)

        local audioListMessage = "Oi\r[System]: Áudios disponíveis (Página " .. cmdNumber .. "/" .. totalPages .. "):\n"
        for i = startIndex, endIndex do
            audioListMessage = audioListMessage .. (i) .. "- " .. SoundList[i].Name .. "\n"
        end
        audioListMessage = audioListMessage .. "Oi\r[System]: Use " .. CommandPrefix .. "playsound [número] para tocar um áudio."
        SendChatMessage(audioListMessage)

    elseif cmd == "playsound" and PlayerClasses[player.UserId] == "✨DEV✨" then
        local args = splitString(message, " ") -- Usando a nova função splitString
        local chosenNumber = tonumber(args[2])

        if not chosenNumber then
            SendChatMessage("Oi\r[Erro]: Use " .. CommandPrefix .. "playsound [número do áudio]. Ex: " .. CommandPrefix .. "playsound 1")
            return
        end

        if chosenNumber < 1 or chosenNumber > #SoundList then
            SendChatMessage("Oi\r[Erro]: Número do áudio inválido. O número deve estar entre 1 e " .. #SoundList .. ".")
            return
        end

        local audioData = SoundList[chosenNumber] -- Obtém a tabela {Name = ..., ID = ...}
        PlaySoundForAll(audioData.ID, audioData.Name) -- Passa o ID e o NOME
    end
end)