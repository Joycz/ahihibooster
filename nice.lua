if not _G.Ignore then
    _G.Ignore = {} -- Add Instances to this table to ignore them (e.g. _G.Ignore = {workspace.Map, workspace.Map2})
end
if not _G.WaitPerAmount then
    _G.WaitPerAmount = 500 -- Set Higher or Lower depending on your computer's performance
end
if _G.SendNotifications == nil then
    _G.SendNotifications = false -- Set to false if you don't want notifications
end
if _G.ConsoleLogs == nil then
    _G.ConsoleLogs = false -- Set to true if you want console logs (mainly for debugging)
end

if not game:IsLoaded() then
    repeat
        task.wait()
    until game:IsLoaded()
end
if not _G.Settings then
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true,
            ["Ignore Tools"] = true
        },
        Meshes = {
            NoMesh = true,
            NoTexture = true,
            Destroy = false
        },
        Images = {
            Invisible = true,
            Destroy = false
        },
        Explosions = {
            Smaller = true,
            Invisible = false, -- Not recommended for PVP games
            Destroy = false -- Not recommended for PVP games
        },
        Particles = {
            Invisible = true,
            Destroy = false
        },
        TextLabels = {
            LowerQuality = true,
            Invisible = true,
            Destroy = false
        },
        MeshParts = {
            LowerQuality = true,
            Invisible = false,
            NoTexture = true,
            NoMesh = true,
            Destroy = false
        },
        Other = {
            ["FPS Cap"] = 20, -- Set this true to uncap FPS
            ["No Camera Effects"] = true,
            ["No Clothes"] = true,
            ["Low Water Graphics"] = true,
            ["No Shadows"] = true,
            ["Low Rendering"] = true,
            ["Low Quality Parts"] = true,
            ["Low Quality Models"] = true,
            ["Reset Materials"] = true,
            ["Lower Quality MeshParts"] = true
        }
    }
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local MaterialService = game:GetService("MaterialService")
local ME = Players.LocalPlayer
local CanBeEnabled = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function PartOfCharacter(Instance)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= ME and player.Character and Instance:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function DescendantOfIgnore(Instance)
    for _, ignoreInstance in pairs(_G.Ignore) do
        if Instance:IsDescendantOf(ignoreInstance) then
            return true
        end
    end
    return false
end

local function ProcessInstance(Instance)
    local settings = _G.Settings
    local others = settings.Other or {}

    if not Instance:IsDescendantOf(Players) and
       (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Instance) or not _G.Settings.Players["Ignore Others"]) and
       (_G.Settings.Players["Ignore Me"] and ME.Character and not Instance:IsDescendantOf(ME.Character) or not _G.Settings.Players["Ignore Me"]) and
       (_G.Settings.Players["Ignore Tools"] and not Instance:IsA("BackpackItem") and not Instance:FindFirstAncestorWhichIsA("BackpackItem") or not _G.Settings.Players["Ignore Tools"]) and
       (_G.Ignore and not table.find(_G.Ignore, Instance) and not DescendantOfIgnore(Instance) or not _G.Ignore or type(_G.Ignore) ~= "table" or #_G.Ignore <= 0) then

        -- Optimize instance handling based on type
        if Instance:IsA("DataModelMesh") then
            if settings.Meshes.NoMesh and Instance:IsA("SpecialMesh") then
                Instance.MeshId = ""
            end
            if settings.Meshes.NoTexture and Instance:IsA("SpecialMesh") then
                Instance.TextureId = ""
            end
            if settings.Meshes.Destroy or others["No Meshes"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("FaceInstance") then
            if settings.Images.Invisible then
                Instance.Transparency = 1
                Instance.Shiny = 1
            end
            if settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("ShirtGraphic") then
            if settings.Images.Invisible then
                Instance.Graphic = ""
            end
            if settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif table.find(CanBeEnabled, Instance.ClassName) then
            if settings.Particles.Invisible or others["Invisible Particles"] or others["No Particles"] then
                Instance.Enabled = false
            end
            if others["No Particles"] or settings.Particles.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("PostEffect") and (settings["No Camera Effects"] or others["No Camera Effects"]) then
            Instance.Enabled = false
        elseif Instance:IsA("Explosion") then
            if settings.Explosions.Smaller or others["Smaller Explosions"] then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
            end
            if settings.Explosions.Invisible or others["Invisible Explosions"] then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
                Instance.Visible = false
            end
            if settings.Explosions.Destroy or others["No Explosions"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("Clothing") or Instance:IsA("SurfaceAppearance") or Instance:IsA("BaseWrap") then
            if settings["No Clothes"] or others["No Clothes"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("BasePart") and not Instance:IsA("MeshPart") then
            if settings["Low Quality Parts"] or others["Low Quality Parts"] then
                Instance.Material = Enum.Material.Plastic
                Instance.Reflectance = 0
            end
        elseif Instance:IsA("TextLabel") and Instance:IsDescendantOf(workspace) then
            if settings.TextLabels.LowerQuality or others["Lower Quality TextLabels"] then
                Instance.Font = Enum.Font.SourceSans
                Instance.TextScaled = false
                Instance.RichText = false
                Instance.TextSize = 14
            end
            if settings.TextLabels.Invisible or others["Invisible TextLabels"] then
                Instance.Visible = false
            end
            if settings.TextLabels.Destroy or others["No TextLabels"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("Model") then
            if settings["Low Quality Models"] or others["Low Quality Models"] then
                Instance.LevelOfDetail = 1
            end
        elseif Instance:IsA("MeshPart") then
            if settings.MeshParts.LowerQuality or others["Lower Quality MeshParts"] then
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if settings.MeshParts.Invisible or others["Invisible MeshParts"] then
                Instance.Transparency = 1
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if settings.MeshParts.NoTexture then
                Instance.TextureID = ""
            end
            if settings.MeshParts.NoMesh then
                Instance.MeshId = ""
            end
            if settings.MeshParts.Destroy or others["No MeshParts"] then
                Instance:Destroy()
            end
        end
    end
end

if _G.SendNotifications then
    StarterGui:SetCore("SendNotification", {
        Title = "Cre : Le Phat Dat",
        Text = "Loading FPS Booster...",
        Duration = math.huge,
        Button1 = "Okay"
    })
end

coroutine.wrap(pcall)(function()
    if _G.Settings["Low Water Graphics"] or (_G.Settings.Other and _G.Settings.Other["Low Water Graphics"]) then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            if sethiddenproperty then
                sethiddenproperty(terrain, "Decoration", false)
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Cre : Le Phat Dat",
                    Text = "Your exploit does not support sethiddenproperty, please use a different exploit.",
                    Duration = 5,
                    Button1 = "Okay"
                })
                warn("Your exploit does not support sethiddenproperty, please use a different exploit.")
            end
            if _G.SendNotifications then
                StarterGui:SetCore("SendNotification", {
                    Title = "Cre : Le Phat Dat",
                    Text = "Low Water Graphics Enabled",
                    Duration = 5,
                    Button1 = "Okay"
                })
            end
            if _G.ConsoleLogs then
                warn("Low Water Graphics Enabled")
            end
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings["Low Rendering"] or (_G.Settings.Other and _G.Settings.Other["Low Rendering"]) then
        if sethiddenproperty then
            sethiddenproperty(Lighting, "Technology", Enum.Technology.Legacy)
        else
            warn("Your exploit does not support sethiddenproperty.")
        end
        if _G.SendNotifications then
            StarterGui:SetCore("SendNotification", {
                Title = "Cre : Le Phat Dat",
                Text = "Low Rendering Enabled",
                Duration = 5,
                Button1 = "Okay"
            })
        end
        if _G.ConsoleLogs then
            warn("Low Rendering Enabled")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings["No Shadows"] or (_G.Settings.Other and _G.Settings.Other["No Shadows"]) then
        Lighting.ShadowSoftness = 0
        if _G.SendNotifications then
            StarterGui:SetCore("SendNotification", {
                Title = "Cre : Le Phat Dat",
                Text = "No Shadows Enabled",
                Duration = 5,
                Button1 = "Okay"
            })
        end
        if _G.ConsoleLogs then
            warn("No Shadows Enabled")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings["Reset Materials"] or (_G.Settings.Other and _G.Settings.Other["Reset Materials"]) then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
            end
        end
        if _G.SendNotifications then
            StarterGui:SetCore("SendNotification", {
                Title = "Cre : Le Phat Dat",
                Text = "Reset Materials Enabled",
                Duration = 5,
                Button1 = "Okay"
            })
        end
        if _G.ConsoleLogs then
            warn("Reset Materials Enabled")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings["FPS Cap"] or (_G.Settings.Other and _G.Settings.Other["FPS Cap"]) then
        if setfpscap then
            setfpscap(20)
        else
            warn("Your exploit does not support setfpscap.")
        end
        if _G.SendNotifications then
            StarterGui:SetCore("SendNotification", {
                Title = "Cre : Le Phat Dat",
                Text = "FPS Cap Enabled",
                Duration = 5,
                Button1 = "Okay"
            })
        end
        if _G.ConsoleLogs then
            warn("FPS Cap Enabled")
        end
    end
end)

if _G.ConsoleLogs then
    warn("Script loaded. Processing instances...")
end

local function ProcessInstance(Instance)
    local settings = _G.Settings
    local others = settings.Other or {}

    if not Instance:IsDescendantOf(Players) and
       (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Instance) or not _G.Settings.Players["Ignore Others"]) and
       (_G.Settings.Players["Ignore Me"] and ME.Character and not Instance:IsDescendantOf(ME.Character) or not _G.Settings.Players["Ignore Me"]) and
       (_G.Settings.Players["Ignore Tools"] and not Instance:IsA("BackpackItem") and not Instance:FindFirstAncestorWhichIsA("BackpackItem") or not _G.Settings.Players["Ignore Tools"]) and
       (_G.Ignore and not table.find(_G.Ignore, Instance) and not DescendantOfIgnore(Instance) or not _G.Ignore or type(_G.Ignore) ~= "table" or #_G.Ignore <= 0) then

        -- Optimize instance handling based on type
        if Instance:IsA("DataModelMesh") then
            if settings.Meshes.NoMesh and Instance:IsA("SpecialMesh") then
                Instance.MeshId = ""
            end
            if settings.Meshes.NoTexture and Instance:IsA("SpecialMesh") then
                Instance.TextureId = ""
            end
            if settings.Meshes.Destroy or others["No Meshes"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("FaceInstance") then
            if settings.Images.Invisible then
                Instance.Transparency = 1
                Instance.Shiny = 1
            end
            if settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("ShirtGraphic") then
            if settings.Images.Invisible then
                Instance.Graphic = ""
            end
            if settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif table.find(CanBeEnabled, Instance.ClassName) then
            if settings.Particles.Invisible or others["Invisible Particles"] or others["No Particles"] then
                Instance.Enabled = false
            end
            if others["No Particles"] or settings.Particles.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("PostEffect") and (settings["No Camera Effects"] or others["No Camera Effects"]) then
            Instance.Enabled = false
        elseif Instance:IsA("Explosion") then
            if settings.Explosions.Smaller or others["Smaller Explosions"] then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
            end
            if settings.Explosions.Invisible or others["Invisible Explosions"] then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
                Instance.Visible = false
            end
            if settings.Explosions.Destroy or others["No Explosions"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("Clothing") or Instance:IsA("SurfaceAppearance") or Instance:IsA("BaseWrap") then
            if settings["No Clothes"] or others["No Clothes"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("BasePart") and not Instance:IsA("MeshPart") then
            if settings["Low Quality Parts"] or others["Low Quality Parts"] then
                Instance.Material = Enum.Material.Plastic
                Instance.Reflectance = 0
            end
        elseif Instance:IsA("TextLabel") and Instance:IsDescendantOf(workspace) then
            if settings.TextLabels.LowerQuality or others["Lower Quality TextLabels"] then
                Instance.Font = Enum.Font.SourceSans
                Instance.TextScaled = false
                Instance.RichText = false
                Instance.TextSize = 14
            end
            if settings.TextLabels.Invisible or others["Invisible TextLabels"] then
                Instance.Visible = false
            end
            if settings.TextLabels.Destroy or others["No TextLabels"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("Model") then
            if settings["Low Quality Models"] or others["Low Quality Models"] then
                Instance.LevelOfDetail = 1
            end
        elseif Instance:IsA("MeshPart") then
            if settings.MeshParts.LowerQuality or others["Lower Quality MeshParts"] then
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if settings.MeshParts.Invisible or others["Invisible MeshParts"] then
                Instance.Transparency = 1
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if settings.MeshParts.NoTexture then
                Instance.TextureID = ""
            end
            if settings.MeshParts.NoMesh then
                Instance.MeshId = ""
            end
            if settings.MeshParts.Destroy or others["No MeshParts"] then
                Instance:Destroy()
            end
        end
    end
end

game.DescendantAdded:Connect(function(value)
    task.spawn(function()
        task.wait(_G.LoadedWait or 1)
        ProcessInstance(value)
    end)
end)

local Descendants = game:GetDescendants()
for i, v in pairs(Descendants) do
    ProcessInstance(v)
    if i % (_G.WaitPerAmount or 500) == 0 then
        task.wait()
        if _G.ConsoleLogs then
            print("Loaded " .. i .. "/" .. #Descendants)
        end
    end
end

if _G.SendNotifications then
    StarterGui:SetCore("SendNotification", {
        Title = "Cre : Le Phat Dat",
        Text = "FPS Booster Loaded",
        Duration = 5,
        Button1 = "Okay"
    })
end
