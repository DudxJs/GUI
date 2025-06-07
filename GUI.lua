-- GUI com rolagem e ordem correta nos botões laterais e de conteúdo

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "CustomGUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 530, 0, 300)
MainFrame.Position = UDim2.new(0.5, -265, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
do
    local padding = Instance.new("UIPadding", MainFrame)
    padding.PaddingTop = UDim.new(0, 3)
    padding.PaddingBottom = UDim.new(0, 3)
    padding.PaddingLeft = UDim.new(0, 3)
    padding.PaddingRight = UDim.new(0, 3)
end

-- TopBar arrastável
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Selectable = true

local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Dudx_js scripts (GUI TESTE)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- MENU LATERAL COM ROLAGEM E ORDEM
local MenuFrame = Instance.new("ScrollingFrame", MainFrame)
MenuFrame.Size = UDim2.new(0, 195, 1, -40)
MenuFrame.Position = UDim2.new(0, 0, 0, 40)
MenuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuFrame.BackgroundTransparency = 1
MenuFrame.BorderSizePixel = 0
MenuFrame.ScrollBarThickness = 8
MenuFrame.ScrollingDirection = Enum.ScrollingDirection.Y
MenuFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
MenuFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
local menuPadding = Instance.new("UIPadding", MenuFrame)
menuPadding.PaddingTop = UDim.new(0, 10)
menuPadding.PaddingLeft = UDim.new(0, 10)
menuPadding.PaddingRight = UDim.new(0, 10)
local menuLayout = Instance.new("UIListLayout", MenuFrame)
menuLayout.FillDirection = Enum.FillDirection.Vertical
menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
menuLayout.VerticalAlignment = Enum.VerticalAlignment.Top
menuLayout.Padding = UDim.new(0, 8)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ÁREA DE CONTEÚDO
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -195, 1, -40)
ContentFrame.Position = UDim2.new(0, 195, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0

-- =========================
-- == FUNÇÕES REUTILIZÁVEIS
-- =========================

-- Cria botão lateral + página associada (com rolagem no conteúdo e ordem)
local function createMenuButton(name, order, menuParent, contentParent)
    local button = Instance.new("TextButton", menuParent)
    button.Size = UDim2.new(1, 0, 0, 32)
    button.LayoutOrder = order
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = name
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18
    button.Name = name:gsub("%s+", "") .. "Btn"
    button.BorderSizePixel = 0
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextWrapped = false
    local padding = Instance.new("UIPadding", button)
    padding.PaddingLeft = UDim.new(0, 12)

    local page = Instance.new("Frame", contentParent)
    page.Name = name:gsub("%s+", "") .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false

    local contentScroll = Instance.new("ScrollingFrame", page)
    contentScroll.Name = "ContentScroll"
    contentScroll.Size = UDim2.new(1, 0, 1, 0)
    contentScroll.Position = UDim2.new(0, 0, 0, 0)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 8
    contentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    local contentPadding = Instance.new("UIPadding", contentScroll)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    local contentLayout = Instance.new("UIListLayout", contentScroll)
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 7)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    button.MouseButton1Click:Connect(function()
        for _, v in pairs(contentParent:GetChildren()) do
            if v:IsA("Frame") then
                v.Visible = false
            end
        end
        page.Visible = true
    end)

    return button, page, contentScroll
end

local function createContentButton(name, order, parent, onClick)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextWrapped = false
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local textoAdicional = Instance.new("TextLabel", btn)
    textoAdicional.Text = "☞"
    textoAdicional.Size = UDim2.new(0, 20, 1, 0)
    textoAdicional.Position = UDim2.new(1, -35, 0, 0)
    textoAdicional.TextColor3 = Color3.fromRGB(255, 255, 255)
    textoAdicional.BackgroundTransparency = 1
    textoAdicional.TextXAlignment = Enum.TextXAlignment.Right
    textoAdicional.Font = Enum.Font.SourceSansBold
    textoAdicional.TextSize = 24
    btn.MouseButton1Click:Connect(function()
        textoAdicional.TextColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(0.05)
        textoAdicional.TextColor3 = Color3.fromRGB(255, 255, 255)
        if onClick then onClick() end
    end)
    return btn
end

local function createSwitchButton(name, order, parent, onSwitch)
    local btn = createContentButton(name, order, parent)
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -50, 0.5, -10)
    switch.AnchorPoint = Vector2.new(0, 0)
    switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    switch.BackgroundTransparency = 0
    switch.Parent = btn
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 1, 0, 1)
    knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    knob.BackgroundTransparency = 0
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local isOn = false
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            knob:TweenPosition(UDim2.new(1, -19, 0, 1), "Out", "Quad", 0.2, true)
            knob.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        else
            knob:TweenPosition(UDim2.new(0, 1, 0, 1), "Out", "Quad", 0.2, true)
            knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        end
        if onSwitch then onSwitch(isOn) end
    end)
    return btn
end

local function createInputField(order, parent, labelText, placeholder, onInput)
    local inputContainer = Instance.new("Frame", parent)
    inputContainer.Size = UDim2.new(1, 0, 0, 32)
    inputContainer.LayoutOrder = order
    inputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputContainer.BorderSizePixel = 0
    Instance.new("UICorner", inputContainer).CornerRadius = UDim.new(0, 6)
    local layout = Instance.new("UIListLayout", inputContainer)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    local padding = Instance.new("UIPadding", inputContainer)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    local label = Instance.new("TextLabel", inputContainer)
    label.Size = UDim2.new(0.5, -20, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText or "Input"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    local icon = Instance.new("TextLabel", inputContainer)
    icon.Size = UDim2.new(0, 20, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "✏️"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.Font = Enum.Font.SourceSans
    icon.TextSize = 18
    local inputHolder = Instance.new("Frame", inputContainer)
    inputHolder.Size = UDim2.new(0.45, 0, 1, 0)
    inputHolder.BackgroundTransparency = 1
    local inputBox = Instance.new("TextBox", inputHolder)
    inputBox.AnchorPoint = Vector2.new(0.5, 0.5)
    inputBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    inputBox.Size = UDim2.new(1, 0, 0.75, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.PlaceholderText = placeholder or "Digite aqui"
    inputBox.Font = Enum.Font.SourceSans
    inputBox.TextSize = 16
    inputBox.TextXAlignment = Enum.TextXAlignment.Center
    inputBox.BorderSizePixel = 0
    inputBox.ClearTextOnFocus = false
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and onInput then
            onInput(inputBox.Text)
        end
    end)
    return inputContainer, inputBox
end

-- Dropdown corrigido: lista aparece logo abaixo do botão (ou acima se não couber) e abre ao clicar em qualquer lugar do botão.

local function createDropdown(order, parent, title, itemList, onSelect)
    -- Use TextButton para detectar clicks em todo o botão!
    local dropdownContainer = Instance.new("TextButton", parent)
    dropdownContainer.Size = UDim2.new(1, 0, 0, 32)
    dropdownContainer.LayoutOrder = order
    dropdownContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdownContainer.BorderSizePixel = 0
    dropdownContainer.AutoButtonColor = true
    dropdownContainer.Text = ""
    Instance.new("UICorner", dropdownContainer).CornerRadius = UDim.new(0, 6)
    local ddPadding = Instance.new("UIPadding", dropdownContainer)
    ddPadding.PaddingLeft  = UDim.new(0, 8)
    ddPadding.PaddingRight = UDim.new(0, 8)

    -- Layout horizontal interno
    local ddLayout = Instance.new("UIListLayout", dropdownContainer)
    ddLayout.FillDirection = Enum.FillDirection.Horizontal
    ddLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ddLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ddLayout.Padding = UDim.new(0, 8)

   -- Container para setinha + label do texto
    local leftGroup = Instance.new("Frame", dropdownContainer)
    leftGroup.BackgroundTransparency = 1
    leftGroup.Size = UDim2.new(0.55, 0, 1, 0)
    leftGroup.LayoutOrder = 1
    local leftLayout = Instance.new("UIListLayout", leftGroup)
    leftLayout.FillDirection = Enum.FillDirection.Horizontal
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    leftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    leftLayout.Padding = UDim.new(0, 4)

    -- Setinha à esquerda
    local arrowBtn = Instance.new("TextLabel", leftGroup)
    arrowBtn.Size = UDim2.new(0, 20, 1, 0)
    arrowBtn.BackgroundTransparency = 1
    arrowBtn.Text = "V"
    arrowBtn.TextColor3 = Color3.new(1, 1, 1)
    arrowBtn.Font = Enum.Font.SourceSans
    arrowBtn.TextSize = 18
    arrowBtn.LayoutOrder = 1

    -- Texto "Selecionar jogador"
    local labelTitle = Instance.new("TextLabel", leftGroup)
    labelTitle.Size = UDim2.new(1, -20, 1, 0)
    labelTitle.BackgroundTransparency = 1
    labelTitle.Text = title or "Seu texto aqui"
    labelTitle.TextColor3 = Color3.new(1, 1, 1)
    labelTitle.Font = Enum.Font.SourceSans
    labelTitle.TextSize = 16
    labelTitle.TextXAlignment = Enum.TextXAlignment.Left
    labelTitle.LayoutOrder = 2

    -- Caixa à direita para o jogador selecionado
    local selectedBox = Instance.new("Frame", dropdownContainer)
    selectedBox.Size = UDim2.new(0.43, 0, 0.8, 0)
    selectedBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    selectedBox.BorderSizePixel = 0
    selectedBox.LayoutOrder = 2
    Instance.new("UICorner", selectedBox).CornerRadius = UDim.new(0, 4)
    local selectedLabel = Instance.new("TextLabel", selectedBox)
    selectedLabel.Size = UDim2.new(1, -10, 1, 0)
    selectedLabel.Position = UDim2.new(0, 5, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = ""
    selectedLabel.TextColor3 = Color3.new(1, 1, 1)
    selectedLabel.Font = Enum.Font.SourceSans
    selectedLabel.TextSize = 16
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Lista oculta, no ScreenGui para facilitar posicionamento absoluto
    local gui = parent:FindFirstAncestorOfClass("ScreenGui")
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Visible = false
    listFrame.ZIndex = 50
    listFrame.Size = UDim2.new(0, 150, 0, 150)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 6
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", listFrame).PaddingTop = UDim.new(0, 8)
    Instance.new("UIPadding", listFrame).PaddingBottom = UDim.new(0, 8)
    local lfLayout = Instance.new("UIListLayout", listFrame)
    lfLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lfLayout.Padding = UDim.new(0, 4)

    -- Função para atualizar lista
    local function atualizarLista()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local totalHeight = 0
        for idx, nome in ipairs(itemList) do
            local item = Instance.new("TextButton", listFrame)
            item.Size = UDim2.new(1, -16, 0, 32)
            item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            item.BorderSizePixel = 0
            item.Text = "   " .. tostring(nome)
            item.TextColor3 = Color3.new(1, 1, 1)
            item.Font = Enum.Font.SourceSans
            item.TextSize = 16
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.ZIndex = 51
            item.LayoutOrder = idx
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
            item.MouseButton1Click:Connect(function()
                selectedLabel.Text = nome
                listFrame.Visible = false
                arrowBtn.Text = "V"
                if onSelect then onSelect(nome) end
            end)
            totalHeight = totalHeight + 32 + 4
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        listFrame.Size = UDim2.new(0, dropdownContainer.AbsoluteSize.X, 0, math.min(150, totalHeight))
    end

    -- Função para posicionar a lista abaixo/acima do botão
    local function showList()
        if not listFrame.Parent then
            listFrame.Parent = gui
        end
        atualizarLista()
        local absPos = dropdownContainer.AbsolutePosition
        local absSize = dropdownContainer.AbsoluteSize
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
        local listHeight = listFrame.AbsoluteSize.Y > 0 and listFrame.AbsoluteSize.Y or 150
        local yBelow = absPos.Y + absSize.Y
        local yAbove = absPos.Y - listHeight
        local posY = (yBelow + listHeight > viewport.Y) and yAbove or yBelow
        listFrame.Position = UDim2.new(0, absPos.X, 0, posY)
        listFrame.Size = UDim2.new(0, absSize.X, 0, math.min(150, listFrame.CanvasSize.Y.Offset))
        listFrame.Visible = not listFrame.Visible
        arrowBtn.Text = listFrame.Visible and "∧" or "V"
    end

    -- Fecha a lista se clicar fora
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if listFrame.Visible and not dropdownContainer:IsAncestorOf(input.Target) and input.Target ~= listFrame and not listFrame:IsAncestorOf(input.Target) then
                listFrame.Visible = false
                arrowBtn.Text = "V"
            end
        end
    end)

    dropdownContainer.MouseButton1Click:Connect(function()
        showList()
    end)

    return dropdownContainer
end

local function createInfoLabel(text, parent, order)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -40, 0, 100)
    label.LayoutOrder = order
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = text or ""
    label.Font = Enum.Font.SourceSans
    label.TextSize = 21.5
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    return label
end