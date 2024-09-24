local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Multi-Script Hub",
    LoadingTitle = "Anti-Sweats 4Ever",
    LoadingSubtitle = "by EuroMH",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "Example Hub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

-- Create a new tab called 'Rivals'
local RivalsTab = Window:CreateTab("Rivals", 4483362458)

-- Variables
local Player = game.Players.LocalPlayer
local Players = game.Players:GetPlayers()
local Camera = workspace.CurrentCamera

-- Options
local enableTeamCheck = true
local enableOcclusion = true
local tracersEnabled = false
local espEnabled = false
local highlightEnabled = false
local chamsEnabled = false

-- Toggle for Team Check
RivalsTab:CreateToggle({
    Name = "Enable Team Check",
    CurrentValue = enableTeamCheck,
    Callback = function(value)
        enableTeamCheck = value
    end,
})

-- Toggle for Occlusion
RivalsTab:CreateToggle({
    Name = "Enable Occlusion",
    CurrentValue = enableOcclusion,
    Callback = function(value)
        enableOcclusion = value
    end,
})

-- Function to check team
local function isSameTeam(player)
    return enableTeamCheck and Player.Team == player.Team
end

-- Function to draw 2D ESP (red rectangle)
local function drawESP(player)
    local espBox = Instance.new("Frame")
    espBox.Size = UDim2.new(0, 50, 0, 50)
    espBox.BackgroundColor3 = Color3.new(1, 0, 0) -- Red color
    espBox.AnchorPoint = Vector2.new(0.5, 0.5)
    espBox.Visible = false
    espBox.Parent = game.CoreGui
    return espBox
end

-- Function to update ESP and Tracers
local function updateESPAndTracers()
    for _, player in ipairs(Players) do
        if player ~= Player and not isSameTeam(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)

            if onScreen then
                if highlightEnabled then
                    local espBox = drawESP(player)
                    espBox.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 25)
                    espBox.Visible = true
                end

                if tracersEnabled then
                    local tracerLine = Instance.new("Line")
                    tracerLine.Color = Color3.new(1, 0, 0) -- Red color
                    tracerLine.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Point from middle of screen
                    tracerLine.EndPosition = screenPos
                    tracerLine.Parent = workspace
                end
            end
        end
    end
end

-- Function to apply chams
local function applyChams(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("MeshPart") then
                part.LocalTransparencyModifier = (chamsEnabled and 0) or 1 -- Make it visible only if chams are enabled
            end
        end
    end
end

-- Main update loop
game:GetService("RunService").RenderStepped:Connect(function()
    Players = game.Players:GetPlayers() -- Update Players list each frame based on new players
    updateESPAndTracers()

    for _, player in ipairs(Players) do
        if player ~= Player and not isSameTeam(player) then
            if chamsEnabled then
                applyChams(player)
            end
        end
    end
end)

-- Create buttons to toggle features
RivalsTab:CreateButton({
    Name = "Toggle ESP",
    Callback = function()
        espEnabled = not espEnabled
        print("ESP Enabled: " .. tostring(espEnabled))
    end,
})

RivalsTab:CreateButton({
    Name = "Toggle Tracers",
    Callback = function()
        tracersEnabled = not tracersEnabled
        print("Tracers Enabled: " .. tostring(tracersEnabled))
    end,
})

RivalsTab:CreateButton({
    Name = "Toggle Highlight",
    Callback = function()
        highlightEnabled = not highlightEnabled
        print("Highlight Enabled: " .. tostring(highlightEnabled))
    end,
})

RivalsTab:CreateButton({
    Name = "Toggle Chams",
    Callback = function()
        chamsEnabled = not chamsEnabled
        print("Chams Enabled: " .. tostring(chamsEnabled))
    end,
})

-- Cleanup function
function cleanup()
    for _, player in ipairs(Players) do
        if player ~= Player then
            -- Cleanup ESP and Tracers (set opacity back)
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("MeshPart") then
                        part.LocalTransparencyModifier = 1 -- Reset to original state
                    end
                end
            end
        end
    end
end

-- Optional: Cleanup connection on player leaving or other events
Player.AncestryChanged:Connect(function()
    cleanup()
end)
