-- DudxJsGUI - Interface Roblox

-- Dependências Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- CLASSE PRINCIPAL
local DudxJsGUI = {}
DudxJsGUI.__index = DudxJsGUI

-- Utilitário para criar UICorner
local function roundify(obj, rad)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, rad or 8)
    c.Parent = obj
    return obj
end

-- Cria a base inteira do GUI
function DudxJsGUI:New(title, toggleImageId)
    local self = setmetatable({}, DudxJsGUI)
    
    -- ScreenGui
    self._gui = Instance.new("ScreenGui")
    self._gui.Name = "DudxJsGUI"
    self._gui.ResetOnSpawn = false
    self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Botão móvel para abrir/fechar a GUI
    self.toggleBtn = Instance.new("ImageButton")
    print("Botão Móvel Criado!")
    self.toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    self.toggleBtn.Position = UDim2.new(0, 198, 0, 39)
    self.toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.toggleBtn.Image = toggleImageId or "rbxassetid://6031097225" -- Usa imagem customizada se informada
    self.toggleBtn.Parent = self._gui
    roundify(self.toggleBtn, 25)
    self.toggleBtn.ZIndex = 10
    self.toggleBtn.Visible = true

-- Alterna a visibilidade da GUI
function self:ToggleGUI()
    local isVisible = self.main.Visible
    self.main.Visible = not isVisible
    self.menu.Visible = not isVisible and not isMinimized
    self.content.Visible = not isVisible and not isMinimized
end

-- Clique no botão móvel alterna a GUI
self.toggleBtn.MouseButton1Click:Connect(function()
    self:ToggleGUI()
end)

-- (Opcional) Arrastar botão móvel
local draggingBtn, dragInputBtn, dragStartBtn, startPosBtn = false
self.toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragStartBtn = input.Position
        startPosBtn = self.toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingBtn = false end
        end)
    end
end)
self.toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputBtn = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputBtn and draggingBtn then
        local delta = input.Position - dragStartBtn
        self.toggleBtn.Position = UDim2.new(
            startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X,
            startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y
        )
    end
end)
    
    -- MainFrame
    self.main = Instance.new("Frame", self._gui)
    self.main.Size = UDim2.new(0, 530, 0, 300)
    self.main.Position = UDim2.new(0.5, -265, 0.5, -150)
    self.main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.main.BackgroundTransparency = 0.05
    self.main.BorderSizePixel = 0
    roundify(self.main, 12)
    local pad = Instance.new("UIPadding", self.main)
    pad.PaddingTop = UDim.new(0, 3)
    pad.PaddingBottom = UDim.new(0, 3)
    pad.PaddingLeft = UDim.new(0, 3)
    pad.PaddingRight = UDim.new(0, 3)
    -- TopBar
    local TopBar = Instance.new("Frame", self.main)
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.BorderSizePixel = 0
    TopBar.Active = true
    TopBar.Selectable = true
    -- Drag
    local dragging, dragInput, dragStart, startPos = false
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    -- Title
    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = title or "DudxJsGUI"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    -- Close Button
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
    -- Evita criar múltiplas confirmações
    if self._confirmationFrame and self._confirmationFrame.Parent then
        self._confirmationFrame.Visible = true
        return
    end

    -- Overlay escuro
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.ZIndex = 9999999999
    overlay.Parent = self._gui

    -- Quadro central de confirmação
    local confirmFrame = Instance.new("Frame", overlay)
    confirmFrame.Size = UDim2.new(0, 340, 0, 170)
    confirmFrame.Position = UDim2.new(0.5, -170, 0.5, -85)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    confirmFrame.BorderSizePixel = 0
    confirmFrame.ZIndex = 99999999999
    roundify(confirmFrame, 14)

    -- Borda vermelha estilizada
    local border = Instance.new("Frame", confirmFrame)
    border.Size = UDim2.new(1, 0, 1, 0)
    border.Position = UDim2.new(0, 0, 0, 0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 4
    border.BorderColor3 = Color3.fromRGB(200, 0, 0)
    border.ZIndex = 999999999999

    -- Título
    local title = Instance.new("TextLabel", confirmFrame)
    title.Size = UDim2.new(1, -30, 0, 44)
    title.Position = UDim2.new(0, 15, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Tem certeza que deseja fechar a GUI?"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 21
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 9999999999999

    -- Subtítulo/descrição
    local desc = Instance.new("TextLabel", confirmFrame)
    desc.Size = UDim2.new(1, -44, 0, 30)
    desc.Position = UDim2.new(0, 22, 0, 58)
    desc.BackgroundTransparency = 1
    desc.Text = "Você perderá todas as configurações não salvas."
    desc.TextColor3 = Color3.fromRGB(255, 0, 0)
    desc.Font = Enum.Font.SourceSans
    desc.TextSize = 16
    desc.TextXAlignment = Enum.TextXAlignment.Center
    desc.ZIndex = 9999999999999

    -- Botão Cancelar (vermelho, à direita)
    local cancelBtn = Instance.new("TextButton", confirmFrame)
    cancelBtn.Size = UDim2.new(0, 115, 0, 38)
    cancelBtn.Position = UDim2.new(1, -125, 1, -48)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    cancelBtn.Text = "Cancelar"
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Font = Enum.Font.SourceSansBold
    cancelBtn.TextSize = 18
    cancelBtn.ZIndex = 99999999999999
    cancelBtn.BorderSizePixel = 0
    roundify(cancelBtn, 10)

    -- Botão Confirmar (transparente, à esquerda, só borda vermelha)
    local confirmBtn = Instance.new("TextButton", confirmFrame)
    confirmBtn.Size = UDim2.new(0, 115, 0, 38)
    confirmBtn.Position = UDim2.new(0, 10, 1, -48)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    confirmBtn.Text = "Confirmar"
    confirmBtn.TextColor3 = Color3.fromRGB(200, 0, 0)
    confirmBtn.Font = Enum.Font.SourceSansBold
    confirmBtn.TextSize = 18
    confirmBtn.ZIndex = 99999999999999
    confirmBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    confirmBtn.BorderSizePixel = 2
    roundify(confirmBtn, 10)

    -- Efeito hover para o botão confirmar (opcional, deixa mais bonito)
    confirmBtn.MouseEnter:Connect(function()
        confirmBtn.BackgroundColor3 = Color3.fromRGB(35, 0, 0)
    end)
    confirmBtn.MouseLeave:Connect(function()
        confirmBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    end)

    -- Função dos botões
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        if self._gui then self._gui:Destroy() end
    end)

    -- Permite fechar apertando ESC (opcional)
    local escConn
    escConn = UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.Escape and not gp then
            overlay:Destroy()
            if escConn then escConn:Disconnect() end
        end
    end)

    -- Guarda referência para não duplicar
    self._confirmationFrame = overlay
end)
    -- Minimize Button
    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 0, 0)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Font = Enum.Font.SourceSansBold
    MinBtn.TextSize = 25

local isMinimized = false
local debounce = false

MinBtn.MouseButton1Click:Connect(function()
    if debounce then return end
    debounce = true
    isMinimized = not isMinimized

    -- Animação de tamanho
    local newSize = isMinimized and UDim2.new(0, 530, 0, 40) or UDim2.new(0, 530, 0, 300)
    TweenService:Create(self.main, TweenInfo.new(0.2), {Size = newSize}):Play()

    if isMinimized then
        self.menu.Visible = false
        self.content.Visible = false
        MinBtn.Text = "+"
    else
        self.menu.Visible = true
        self.content.Visible = true
        MinBtn.Text = "-"
    end

    wait(0.25)
    debounce = false
end)

    -- Menu lateral (Tabs)
    self.menu = Instance.new("ScrollingFrame", self.main)
    self.menu.Size = UDim2.new(0, 195, 1, -40)
    self.menu.Position = UDim2.new(0, 0, 0, 40)
    self.menu.BackgroundTransparency = 1
    self.menu.BorderSizePixel = 0
    self.menu.ScrollBarThickness = 8
    self.menu.ScrollingDirection = Enum.ScrollingDirection.Y
    self.menu.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.menu.CanvasSize = UDim2.new(0, 0, 0, 0)
    local menuPadding = Instance.new("UIPadding", self.menu)
    menuPadding.PaddingTop = UDim.new(0, 10)
    menuPadding.PaddingLeft = UDim.new(0, 10)
    menuPadding.PaddingRight = UDim.new(0, 10)
    local menuLayout = Instance.new("UIListLayout", self.menu)
    menuLayout.FillDirection = Enum.FillDirection.Vertical
    menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    menuLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    menuLayout.Padding = UDim.new(0, 8)
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    -- Área de conteúdo
    self.content = Instance.new("Frame", self.main)
    self.content.Size = UDim2.new(1, -195, 1, -40)
    self.content.Position = UDim2.new(0, 195, 0, 40)
    self.content.BackgroundTransparency = 1
    self.content.BorderSizePixel = 0
    -- Tabs
    self._tabOrder = 1
    self._tabs = {}
    return self
end

-- Cria uma Tab com página e rolagem
function DudxJsGUI:AddTab(tabName)
    local self = self
    local tab = {}
    -- Botão lateral
    local button = Instance.new("TextButton", self.menu)
    button.Size = UDim2.new(1, 0, 0, 32)
    button.LayoutOrder = self._tabOrder
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = tabName
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18
    button.Name = tabName:gsub("%s+", "") .. "Btn"
    button.BorderSizePixel = 0
    roundify(button)
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextWrapped = false
    local padding = Instance.new("UIPadding", button)
    padding.PaddingLeft = UDim.new(0, 12)
    -- Página
    local page = Instance.new("Frame", self.content)
    page.Name = tabName:gsub("%s+", "") .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (#self._tabs == 0)
    -- ScrollFrame na página
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
    -- Troca de páginas
    button.MouseButton1Click:Connect(function()
        for _, t in pairs(self._tabs) do
            t.page.Visible = false
        end
        page.Visible = true
    end)
    -- Métodos de Tab
    tab._order = 1
    tab.page = page
    tab.scroll = contentScroll
    tab.button = button
    function tab:AddButton(text, callback)
        local btn = Instance.new("TextButton", contentScroll)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.LayoutOrder = tab._order
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 18
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextWrapped = false
        btn.BorderSizePixel = 0
        roundify(btn)
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
            if callback then callback() end
        end)
        tab._order = tab._order + 1
        return btn
    end
    function tab:AddSwitch(text, callback)
        local btn = tab:AddButton(text, function() end)
        -- Switch visual
        local switch = Instance.new("Frame")
        switch.Size = UDim2.new(0, 40, 0, 20)
        switch.Position = UDim2.new(1, -50, 0.5, -10)
        switch.AnchorPoint = Vector2.new(0, 0)
        switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        switch.BackgroundTransparency = 0
        switch.Parent = btn
        roundify(switch, 10)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, 1, 0, 1)
        knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        knob.BackgroundTransparency = 0
        knob.Parent = switch
        roundify(knob, 9)
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
            if callback then callback(isOn) end
        end)
        return btn
    end
    function tab:AddInput(labelText, placeholder, callback)
        local inputContainer = Instance.new("Frame", contentScroll)
        inputContainer.Size = UDim2.new(1, 0, 0, 32)
        inputContainer.LayoutOrder = tab._order
        inputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        inputContainer.BorderSizePixel = 0
        roundify(inputContainer, 6)
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
        inputBox.Text = "" -- Certifica-se de que o TextBox inicializa vazio
        inputBox.Font = Enum.Font.SourceSans
        inputBox.TextSize = 16
        inputBox.TextXAlignment = Enum.TextXAlignment.Center
        inputBox.BorderSizePixel = 0
        inputBox.ClearTextOnFocus = false
        roundify(inputBox, 6)
            -- Eventos para alterar a cor do ícone
    inputBox.Focused:Connect(function()
        icon.TextColor3 = Color3.new(1, 0, 0) -- Muda para vermelho quando focado
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        icon.TextColor3 = Color3.new(1, 1, 1) -- Volta para branco quando perde o foco
        if enterPressed and callback then
            callback(inputBox.Text)
        end
    end)
    
    tab._order = tab._order + 1
    return inputContainer, inputBox
end
    
-- Coloque isso no topo do arquivo, após os requires:
local _GLOBAL_OPEN_DROPDOWN = nil
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if _GLOBAL_OPEN_DROPDOWN and input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
        local dropdownData = _GLOBAL_OPEN_DROPDOWN
        if dropdownData and dropdownData.isOpen and not dropdownData.container:IsAncestorOf(input.Target) and input.Target ~= dropdownData.list and not dropdownData.list:IsAncestorOf(input.Target) then
            dropdownData.close()
        end
    end
end)

-- Substitua sua função tab:AddDropdown por esta:
function tab:AddDropdown(text, items, callback)
    local TweenService = game:GetService("TweenService")

    local dropdownContainer = Instance.new("TextButton", contentScroll)
    dropdownContainer.Size = UDim2.new(1, 0, 0, 32)
    dropdownContainer.LayoutOrder = tab._order
    dropdownContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdownContainer.BorderSizePixel = 0
    dropdownContainer.AutoButtonColor = true
    dropdownContainer.Text = ""
    roundify(dropdownContainer, 6)
    local ddPadding = Instance.new("UIPadding", dropdownContainer)
    ddPadding.PaddingLeft = UDim.new(0, 8)
    ddPadding.PaddingRight = UDim.new(0, 8)

    -- Layout horizontal interno
    local ddLayout = Instance.new("UIListLayout", dropdownContainer)
    ddLayout.FillDirection = Enum.FillDirection.Horizontal
    ddLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ddLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ddLayout.Padding = UDim.new(0, 8)

    -- Grupo esquerda (seta e label)
    local leftGroup = Instance.new("Frame", dropdownContainer)
    leftGroup.BackgroundTransparency = 1
    leftGroup.Size = UDim2.new(0.55, 0, 1, 0)
    leftGroup.LayoutOrder = 1
    local leftLayout = Instance.new("UIListLayout", leftGroup)
    leftLayout.FillDirection = Enum.FillDirection.Horizontal
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    leftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    leftLayout.Padding = UDim.new(0, 4)

    -- Seta
    local arrowBtn = Instance.new("TextLabel", leftGroup)
    arrowBtn.Size = UDim2.new(0, 20, 1, 0)
    arrowBtn.BackgroundTransparency = 1
    arrowBtn.Text = "▽"
    arrowBtn.TextColor3 = Color3.new(1, 1, 1)
    arrowBtn.Font = Enum.Font.SourceSans
    arrowBtn.TextSize = 18
    arrowBtn.LayoutOrder = 1

    -- Texto
    local labelTitle = Instance.new("TextLabel", leftGroup)
    labelTitle.Size = UDim2.new(1, -20, 1, 0)
    labelTitle.BackgroundTransparency = 1
    labelTitle.Text = text or "Dropdown"
    labelTitle.TextColor3 = Color3.new(1, 1, 1)
    labelTitle.Font = Enum.Font.SourceSans
    labelTitle.TextSize = 16
    labelTitle.TextXAlignment = Enum.TextXAlignment.Left
    labelTitle.LayoutOrder = 2

    -- Caixa à direita (selecionado)
    local selectedBox = Instance.new("Frame", dropdownContainer)
    selectedBox.Size = UDim2.new(0.43, 0, 0.8, 0)
    selectedBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    selectedBox.BorderSizePixel = 0
    selectedBox.LayoutOrder = 2
    roundify(selectedBox, 4)
    local selectedLabel = Instance.new("TextLabel", selectedBox)
    selectedLabel.Size = UDim2.new(1, -10, 1, 0)
    selectedLabel.Position = UDim2.new(0, 5, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = ""
    selectedLabel.TextColor3 = Color3.new(1, 1, 1)
    selectedLabel.Font = Enum.Font.SourceSans
    selectedLabel.TextSize = 16
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Lista do Dropdown (agora ScrollingFrame!)
    local gui = dropdownContainer:FindFirstAncestorOfClass("ScreenGui")
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Visible = false
    listFrame.ZIndex = 200
    listFrame.Size = UDim2.new(0, 0, 0, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.ScrollBarThickness = 8
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    -- Borda só nas extremidades de baixo para efeito visual integrado:
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = listFrame
    corner.TopLeft = false
    corner.TopRight = false
    listFrame.Parent = gui

    local padTop = Instance.new("UIPadding", listFrame)
    padTop.PaddingTop = UDim.new(0, 8)
    local padBot = Instance.new("UIPadding", listFrame)
    padBot.PaddingBottom = UDim.new(0, 8)
    local lfLayout = Instance.new("UIListLayout", listFrame)
    lfLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lfLayout.Padding = UDim.new(0, 4)

    local listHeight = 32 * #items + 4 * #items + 16 -- altura ideal

    local function atualizarLista()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for idx, nome in ipairs(items) do
            local item = Instance.new("TextButton", listFrame)
            item.Size = UDim2.new(1, -16, 0, 32)
            item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            item.BorderSizePixel = 0
            item.Text = "   " .. tostring(nome)
            item.TextColor3 = Color3.new(1, 1, 1)
            item.Font = Enum.Font.SourceSans
            item.TextSize = 16
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.ZIndex = 201
            item.LayoutOrder = idx
            local icorner = Instance.new("UICorner")
            icorner.CornerRadius = UDim.new(0, 6)
            icorner.Parent = item
            item.MouseButton1Click:Connect(function()
                selectedLabel.Text = nome
                closeList()
                if callback then callback(nome) end
            end)
        end
        -- Atualiza o canvas para o tamanho do conteúdo
        local totalHeight = 0
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                totalHeight = totalHeight + child.AbsoluteSize.Y + 4
            end
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 16)
    end

    function closeList()
        local tween = TweenService:Create(listFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(listFrame.Size.X.Scale, listFrame.Size.X.Offset, 0, 0)})
        tween:Play()
        TweenService:Create(arrowBtn, TweenInfo.new(0.18), {Rotation = 0}):Play()
        tween.Completed:Connect(function()
            listFrame.Visible = false
        end)
        if _GLOBAL_OPEN_DROPDOWN and _GLOBAL_OPEN_DROPDOWN.list == listFrame then
            _GLOBAL_OPEN_DROPDOWN = nil
        end
    end

    local function openList()
        if _GLOBAL_OPEN_DROPDOWN and _GLOBAL_OPEN_DROPDOWN.close and _GLOBAL_OPEN_DROPDOWN.list ~= listFrame then
            _GLOBAL_OPEN_DROPDOWN.close()
        end
        atualizarLista()
        listFrame.Visible = true
        local absPos = dropdownContainer.AbsolutePosition
        local absSize = dropdownContainer.AbsoluteSize
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
        local maxHeight = math.min(150, listHeight)
        local yBelow = absPos.Y + absSize.Y
        local yAbove = absPos.Y - maxHeight
        local posY = (yBelow + maxHeight > viewport.Y) and yAbove or yBelow
        listFrame.Position = UDim2.new(0, absPos.X, 0, posY)
        listFrame.Size = UDim2.new(0, absSize.X, 0, maxHeight)
        TweenService:Create(arrowBtn, TweenInfo.new(0.23), {Rotation = 180}):Play()
        _GLOBAL_OPEN_DROPDOWN = {
            isOpen = true,
            container = dropdownContainer,
            list = listFrame,
            close = closeList
        }
    end

    dropdownContainer.MouseButton1Click:Connect(function()
        if listFrame.Visible then
            closeList()
        else
            openList()
        end
    end)

    tab.button.MouseButton1Click:Connect(closeList)
    tab.page:GetPropertyChangedSignal("Visible"):Connect(function()
        if not tab.page.Visible then
            closeList()
        end
    end)

    tab._order = tab._order + 1
    return dropdownContainer
end
    
    function tab:AddLabel(text)
    local label = Instance.new("TextLabel", contentScroll)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Size = UDim2.new(1, -40, 0, 0) -- Altura 0 pois é automática
    label.LayoutOrder = tab._order
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = text or ""
    label.Font = Enum.Font.SourceSans
    label.TextSize = 21.5
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top

    -- Padding igual em cima e embaixo
    local padding = Instance.new("UIPadding", label)
    padding.PaddingTop = UDim.new(0, 1)
    padding.PaddingBottom = UDim.new(0, 1)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)

    tab._order = tab._order + 1
    return label
end
    -- Adiciona tab na lista
    table.insert(self._tabs, tab)
    self._tabOrder = self._tabOrder + 1
    return tab
end

function DudxJsGUI:Destroy()
    if self._gui then self._gui:Destroy() end
end

-- Exporta
_G.DudxJsGUI = DudxJsGUI