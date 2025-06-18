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
local gui = _G.DudxJsGUI:New("Título do Meu Painel")
```

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
