local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TARGET_COLORS = {
    Disk = Color3.fromRGB(255, 80, 80),
    Stack = Color3.fromRGB(170, 100, 255),
    Cash = Color3.fromRGB(80, 255, 120),
    Briefcase = Color3.fromRGB(255, 200, 60)
}

local OUTFITS = {
    Alamont = {
        Color = Color3.fromRGB(255, 90, 90),
        Parts = {
            "Glove.L", "Glove.R", "LooseShirt",
            "ShirtAlamont", "SuitJacketAlamont",
            "SuitPantsL", "SuitPantsR",
            "SuitSleeveL", "SuitSleeveR"
        }
    },

    Bergmann = {
        Color = Color3.fromRGB(80, 170, 255),
        Parts = {
            "After8Shirt", "Glove.L", "Glove.R",
            "Shirt", "SuitJacketBergmann",
            "SuitPantsL", "SuitPantsR",
            "SuitSleeveL", "SuitSleeveR"
        }
    },

    Halfwell = {
        Color = Color3.fromRGB(180, 100, 255),
        Parts = {
            "After8Shirt", "Glove.L", "Glove.R",
            "Shirt", "SuitJacket", "SuitPantsL",
            "SuitPantsR", "SuitSleeveL",
            "SuitSleeveR", "Vest"
        }
    },

    None = {
        Color = Color3.fromRGB(200, 200, 200),
        Parts = {
            "Glove.L", "Glove.R", "LooseShirt",
            "Shirt", "Sleeve.L", "Sleeve.R",
            "SuitPantsL", "SuitPantsR"
        }
    },

    Renetti = {
        Color = Color3.fromRGB(255, 190, 65),
        Parts = {
            "Glove.L", "Glove.R", "LooseShirt",
            "Shirt", "Sleeve.L", "Sleeve.R",
            "SuitPantsL", "SuitPantsR", "Vest"
        }
    },

    Yoromoto = {
        Color = Color3.fromRGB(80, 255, 200),
        Parts = {
            "Accessory", "Glove.L", "Glove.R",
            "Sleeve.R", "SuitPantsL",
            "SuitPantsR", "YoroShirt2"
        }
    }
}

local SETTINGS = {
    ESPEnabled = true,
    HighlightsEnabled = true,
    NamesEnabled = true,
    OutfitESPEnabled = true,
    MenuKey = Enum.KeyCode.RightShift,
    ESPKey = Enum.KeyCode.H,
    WaitingFor = nil
}

local HIGHLIGHT_NAME = "TargetHighlight"
local LABEL_NAME = "TargetNameLabel"
local PLAYER_HIGHLIGHT = "OutfitPlayerHighlight"
local PLAYER_LABEL = "OutfitPlayerLabel"

local GUI = Instance.new("ScreenGui")
GUI.Name = "TargetESP"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AutomaticSize = Enum.AutomaticSize.Y
Main.Size = UDim2.fromOffset(260, 0)
Main.Position = UDim2.new(0, 20, 1, -20)
Main.AnchorPoint = Vector2.new(0, 1)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 25)
Main.BorderSizePixel = 0
Main.Parent = GUI

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(55, 60, 75)
Stroke.Thickness = 1
Stroke.Parent = Main

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 8)
Padding.PaddingBottom = UDim.new(0, 8)
Padding.PaddingLeft = UDim.new(0, 10)
Padding.PaddingRight = UDim.new(0, 10)
Padding.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Main

local function createButton(name, order, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(29, 33, 43)
    Button.BorderSizePixel = 0
    Button.TextColor3 = Color3.fromRGB(220, 225, 235)
    Button.Font = Enum.Font.BuilderSans
    Button.TextSize = 12
    Button.LayoutOrder = order
    Button.AutoButtonColor = false
    Button.Parent = Main

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(40, 45, 58)
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(29, 33, 43)
    end)

    Button.MouseButton1Click:Connect(callback)

    return Button
end

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundTransparency = 1
Title.Text = "TARGET ESP"
Title.TextColor3 = Color3.fromRGB(235, 238, 245)
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.LayoutOrder = 0
Title.Parent = Main

local ESPButton
local HighlightButton
local NamesButton
local OutfitButton
local MenuKeyButton
local ESPKeyButton

local function keyName(key)
    return key.Name:gsub("(%u)", " %1"):gsub("^ ", "")
end

local function updateButtons()
    ESPButton.Text = "ESP: " .. (SETTINGS.ESPEnabled and "ON" or "OFF")
    HighlightButton.Text = "Highlights: " .. (SETTINGS.HighlightsEnabled and "ON" or "OFF")
    NamesButton.Text = "Names: " .. (SETTINGS.NamesEnabled and "ON" or "OFF")
    OutfitButton.Text = "Outfit ESP: " .. (SETTINGS.OutfitESPEnabled and "ON" or "OFF")
    MenuKeyButton.Text = "Menu Key: " .. keyName(SETTINGS.MenuKey)
    ESPKeyButton.Text = "ESP Key: " .. keyName(SETTINGS.ESPKey)
end

local function removeTargetObjects(target)
    local highlight = target:FindFirstChild(HIGHLIGHT_NAME)
    local label = target:FindFirstChild(LABEL_NAME)

    if highlight then
        highlight:Destroy()
    end

    if label then
        label:Destroy()
    end
end

local function updateTarget(target)
    if not target or not target:IsDescendantOf(Workspace) then
        return
    end

    local color = TARGET_COLORS[target.Name]

    if not color then
        return
    end

    if not SETTINGS.ESPEnabled then
        removeTargetObjects(target)
        return
    end

    if SETTINGS.HighlightsEnabled then
        local highlight = target:FindFirstChild(HIGHLIGHT_NAME)

        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = HIGHLIGHT_NAME
            highlight.Adornee = target
            highlight.Parent = target
        end

        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        local highlight = target:FindFirstChild(HIGHLIGHT_NAME)

        if highlight then
            highlight:Destroy()
        end
    end

    if SETTINGS.NamesEnabled then
        local label = target:FindFirstChild(LABEL_NAME)
        local adornee

        if target:IsA("Model") then
            adornee = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
        elseif target:IsA("BasePart") then
            adornee = target
        end

        if adornee then
            if not label then
                label = Instance.new("BillboardGui")
                label.Name = LABEL_NAME
                label.Size = UDim2.fromOffset(120, 30)
                label.StudsOffset = Vector3.new(0, 2.5, 0)
                label.AlwaysOnTop = true
                label.Parent = target

                local Text = Instance.new("TextLabel")
                Text.Name = "LabelText"
                Text.Size = UDim2.fromScale(1, 1)
                Text.BackgroundTransparency = 1
                Text.TextStrokeColor3 = Color3.new(0, 0, 0)
                Text.TextStrokeTransparency = 0
                Text.TextSize = 14
                Text.Font = Enum.Font.BuilderSansBold
                Text.Parent = label
            end

            label.Adornee = adornee

            local Text = label:FindFirstChild("LabelText")

            if Text then
                Text.Text = target.Name
                Text.TextColor3 = color
            end
        end
    else
        local label = target:FindFirstChild(LABEL_NAME)

        if label then
            label:Destroy()
        end
    end
end

local function detectOutfit(character)
    local found = {}

    for _, object in ipairs(character:GetDescendants()) do
        found[object.Name] = true
    end

    local bestOutfit
    local bestScore = 0

    for outfitName, data in pairs(OUTFITS) do
        local score = 0

        for _, partName in ipairs(data.Parts) do
            if found[partName] then
                score += 1
            end
        end

        if score > bestScore then
            bestScore = score
            bestOutfit = outfitName
        end
    end

    if bestScore >= 4 then
        return bestOutfit
    end

    return nil
end

local function removePlayerESP(character)
    if not character then
        return
    end

    local highlight = character:FindFirstChild(PLAYER_HIGHLIGHT)
    local label = character:FindFirstChild(PLAYER_LABEL)

    if highlight then
        highlight:Destroy()
    end

    if label then
        label:Destroy()
    end
end

local function updatePlayerESP(player)
    if player == Player then
        return
    end

    local character = player.Character

    if not character then
        return
    end

    if not SETTINGS.ESPEnabled or not SETTINGS.OutfitESPEnabled then
        removePlayerESP(character)
        return
    end

    local outfitName = detectOutfit(character)

    if not outfitName then
        removePlayerESP(character)
        return
    end

    local outfit = OUTFITS[outfitName]
    local color = outfit.Color

    if SETTINGS.HighlightsEnabled then
        local highlight = character:FindFirstChild(PLAYER_HIGHLIGHT)

        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = PLAYER_HIGHLIGHT
            highlight.Adornee = character
            highlight.Parent = character
        end

        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        local highlight = character:FindFirstChild(PLAYER_HIGHLIGHT)

        if highlight then
            highlight:Destroy()
        end
    end

    if SETTINGS.NamesEnabled then
        local root = character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChildWhichIsA("BasePart")

        if not root then
            return
        end

        local label = character:FindFirstChild(PLAYER_LABEL)

        if not label then
            label = Instance.new("BillboardGui")
            label.Name = PLAYER_LABEL
            label.Size = UDim2.fromOffset(220, 48)
            label.StudsOffset = Vector3.new(0, 3.2, 0)
            label.AlwaysOnTop = true
            label.Parent = character

            local text = Instance.new("TextLabel")
            text.Name = "LabelText"
            text.Size = UDim2.fromScale(1, 1)
            text.BackgroundTransparency = 1
            text.TextStrokeColor3 = Color3.new(0, 0, 0)
            text.TextStrokeTransparency = 0
            text.TextSize = 13
            text.Font = Enum.Font.BuilderSansBold
            text.TextWrapped = true
            text.Parent = label
        end

        label.Adornee = root

        local text = label:FindFirstChild("LabelText")

        if text then
            local teamName = player.Team and player.Team.Name or "No Team"

            text.Text = player.Name .. "\n" .. outfitName .. " | " .. teamName
            text.TextColor3 = color
        end
    else
        local label = character:FindFirstChild(PLAYER_LABEL)

        if label then
            label:Destroy()
        end
    end
end

local refreshQueued = {}

local function queuePlayerUpdate(player)
    if refreshQueued[player] then
        return
    end

    refreshQueued[player] = true

    task.delay(0.25, function()
        refreshQueued[player] = nil

        if player.Parent == Players then
            updatePlayerESP(player)
        end
    end)
end

local function refreshPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerESP(player)
    end
end

local function refreshAll()
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if TARGET_COLORS[instance.Name] then
            updateTarget(instance)
        end
    end

    refreshPlayers()
end

ESPButton = createButton("ESP", 1, function()
    SETTINGS.ESPEnabled = not SETTINGS.ESPEnabled
    updateButtons()
    refreshAll()
end)

HighlightButton = createButton("Highlights", 2, function()
    SETTINGS.HighlightsEnabled = not SETTINGS.HighlightsEnabled
    updateButtons()
    refreshAll()
end)

NamesButton = createButton("Names", 3, function()
    SETTINGS.NamesEnabled = not SETTINGS.NamesEnabled
    updateButtons()
    refreshAll()
end)

OutfitButton = createButton("OutfitESP", 4, function()
    SETTINGS.OutfitESPEnabled = not SETTINGS.OutfitESPEnabled
    updateButtons()
    refreshPlayers()
end)

MenuKeyButton = createButton("MenuKey", 5, function()
    SETTINGS.WaitingFor = "MenuKey"
    MenuKeyButton.Text = "Press a key..."
end)

ESPKeyButton = createButton("ESPKey", 6, function()
    SETTINGS.WaitingFor = "ESPKey"
    ESPKeyButton.Text = "Press a key..."
end)

updateButtons()

Workspace.DescendantAdded:Connect(function(instance)
    if TARGET_COLORS[instance.Name] then
        task.defer(updateTarget, instance)
    end
end)

local function setupPlayer(player)
    if player == Player then
        return
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        updatePlayerESP(player)

        character.DescendantAdded:Connect(function()
            queuePlayerUpdate(player)
        end)
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        queuePlayerUpdate(player)
    end)

    if player.Character then
        player.Character.DescendantAdded:Connect(function()
            queuePlayerUpdate(player)
        end)

        task.defer(updatePlayerESP, player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
    refreshQueued[player] = nil
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if SETTINGS.WaitingFor then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            SETTINGS[SETTINGS.WaitingFor] = input.KeyCode
        end

        SETTINGS.WaitingFor = nil
        updateButtons()
        return
    end

    if UserInputService:GetFocusedTextBox() then
        return
    end

    if input.KeyCode == SETTINGS.MenuKey then
        Main.Visible = not Main.Visible

    elseif input.KeyCode == SETTINGS.ESPKey then
        SETTINGS.ESPEnabled = not SETTINGS.ESPEnabled
        updateButtons()
        refreshAll()
    end
end)

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

refreshAll()
