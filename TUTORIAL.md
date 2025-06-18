# DudxJsGUI - Tutorial de Uso

DudxJsGUI é uma biblioteca de interface Roblox fácil, poderosa e inspirada em OrionLib. Permite criar GUIs sofisticadas com tabs, botões, switches, campos de texto, labels e dropdowns em poucas linhas!

---

## Como instalar e carregar

Basta executar em qualquer Script local:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DudxJs/GUI/main/GUI.lua"))()
```

---

## Como criar sua interface

### 1. Criando o GUI

```lua
local gui = _G.DudxJsGUI:New("Título do Meu Painel", 6031097225)
```

> **Nota:**  
> Agora você pode passar só o ID da imagem do botão móvel (sem o prefixo)
> Também funciona se passar como string: "6031097225"
> Se quiser, ainda pode passar o formato completo: "rbxassetid://6031097225"
---

### 2. Adicionando uma Tab (Aba)

```lua
local tab = gui:AddTab("Nome da Aba")
```

Você pode criar quantas abas quiser!

---

### 3. Adicionando Botões

```lua
tab:AddButton("Nome do Botão", function()
    print("Botão clicado!")
end)
```

---

### 4. Adicionando Switch (interruptor)

```lua
tab:AddSwitch("Ativar GodMode", function(on)
    print("GodMode:", on)
end)
```
O valor `on` é `true` quando ativado e `false` quando desligado.

---

### 5. Adicionando Input (campo de texto)

```lua
tab:AddInput("Nickname", "Digite seu nick", function(txt)
    print("Nickname digitado:", txt)
end)
```

---

### 6. Adicionando Label (texto informativo)

```lua
tab:AddLabel("Bem-vindo ao DudxJsGUI!")
```

---

### 7. Adicionando Dropdown (lista suspensa)

```lua
tab:AddDropdown("Escolha uma opção", {"Opção 1", "Opção 2", "Opção 3"}, function(selected)
    print("Selecionado:", selected)
end)
```

---

## Exemplo Completo

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DudxJs/GUI/main/GUI.lua"))()

local gui = _G.DudxJsGUI:New("Meu Painel Top")

local tabScripts = gui:AddTab("Scripts")
tabScripts:AddButton("Executar Script 1", function() print("Executado 1!") end)
tabScripts:AddSwitch("GodMode", function(on) print("GodMode:", on) end)
tabScripts:AddInput("Nickname", "Digite aqui", function(txt) print("Nick:", txt) end)
tabScripts:AddDropdown("Escolher", {"A", "B", "C"}, function(sel) print("Selecionou:", sel) end)

local tabInfo = gui:AddTab("Info")
tabInfo:AddLabel("Este painel foi criado usando DudxJsGUI!")

```

---

## Dicas

- Você pode adicionar quantas abas e componentes quiser.
- Cada componente pode executar funções diferentes.
- Ideal para menus de scripts, hubs, comandos e painéis de configuração.

---

## Suporte

Dúvidas ou sugestões? Abra uma issue no repositório!

---

## Como criar uma página customizada com `AddCustomPage`

O método `AddCustomPage` permite criar uma **página totalmente personalizada** dentro do seu painel, sem adicionar um botão no menu lateral. Use quando quiser exibir conteúdos especiais ou avançados, fora do padrão das abas tradicionais.

---

### Exemplo básico de uso

```lua
local gui = _G.DudxJsGUI:New("Meu Painel")

-- Cria uma página customizada (não aparece no menu lateral automaticamente)
local customPage = gui:AddCustomPage("MinhaPaginaEspecial")

-- Crie o conteúdo que quiser dentro de customPage:
local texto = Instance.new("TextLabel")
texto.Text = "Bem-vindo à minha página customizada!"
texto.Size = UDim2.new(1,0,0,50)
texto.BackgroundTransparency = 1
texto.TextColor3 = Color3.fromRGB(255,255,255)
texto.Font = Enum.Font.SourceSansBold
texto.TextSize = 25
texto.Parent = customPage
```

---

### Como mostrar ou esconder a página customizada

Como `AddCustomPage` não cria um botão de navegação, você deve **controlar a visibilidade manualmente**. Por exemplo, para mostrar sua página customizada e esconder todas as outras abas:

```lua
for _, tab in pairs(gui._tabs) do
    tab.page.Visible = false
end
customPage.Visible = true
```

Você pode conectar isso a um botão, evento ou lógica personalizada!

---

### Dicas

- Use `AddCustomPage` para painéis especiais, pop-ups, páginas secretas ou conteúdos que não devem ser acessados pelo menu lateral.
- Para uma aba padrão com botão no menu lateral, use `AddTab`.
- Para uma aba com botão e conteúdo 100% customizado, veja o método `AddCustomTab` (se disponível na sua versão).

---

### Exemplo avançado: Exibindo uma página customizada ao clicar em um botão

```lua
local gui = _G.DudxJsGUI:New("Meu Painel")

local customPage = gui:AddCustomPage("PopUp")

-- Crie um botão em alguma aba
local mainTab = gui:AddTab("Principal")
mainTab:AddButton("Abrir PopUp", function()
    -- Esconde todas as abas
    for _, tab in pairs(gui._tabs) do
        tab.page.Visible = false
    end
    customPage.Visible = true
end)

-- Botão para voltar
local fechar = Instance.new("TextButton")
fechar.Text = "Fechar"
fechar.Size = UDim2.new(0,100,0,40)
fechar.Position = UDim2.new(0.5, -50, 0.5, -20)
fechar.Parent = customPage
fechar.MouseButton1Click:Connect(function()
    customPage.Visible = false
    mainTab.page.Visible = true
end)
```

---

**Resumo:**  
`AddCustomPage` é ideal para páginas que você mesmo controla quando e como aparecem. Aproveite para criar experiências únicas na sua GUI!
