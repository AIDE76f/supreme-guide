local player = game.Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- تنظيف أي واجهة سابقة
if guiParent:FindFirstChild("PhysicalRadar") then
    guiParent.PhysicalRadar:Destroy()
end

--------------------------------------------------
-- 1. تصميم الواجهة (رادار الواقع)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PhysicalRadar"
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 240)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "🏪 رادار الشريطية والمعرض"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 80)
infoLabel.Position = UDim2.new(0, 10, 0, 50)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "سيتم البحث فقط عن السيارات المعروضة في الشارع (يتجاهل تطبيق الجوال)"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 14
infoLabel.TextWrapped = true
infoLabel.Parent = mainFrame

local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0, 220, 0, 45)
teleportBtn.Position = UDim2.new(0.5, -110, 0, 130)
teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
teleportBtn.Text = "انقلني لأغلى سيارة معروضة ⚡"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 15
teleportBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = teleportBtn

--------------------------------------------------
-- 2. معالجة الأرقام والمسح الفيزيائي
--------------------------------------------------
local function cleanAndParse(str)
    local map = {["٠"]="0", ["١"]="1", ["٢"]="2", ["٣"]="3", ["٤"]="4", ["٥"]="5", ["٦"]="6", ["٧"]="7", ["٨"]="8", ["٩"]="9", [","]="", [" "]="", ["\n"]=""}
    local res = str
    for ar, en in pairs(map) do res = string.gsub(res, ar, en) end
    return tonumber(string.match(res, "%d+"))
end

teleportBtn.MouseButton1Click:Connect(function()
    infoLabel.Text = "جاري مسح حي الشريطية والمعرض..."
    task.wait(0.2)
    
    local highestPrice = 0
    local targetModel = nil
    
    -- المسح سيعتمد فقط على الـ Workspace (الأجسام الملموسة)
    for _, obj in pairs(workspace:GetDescendants()) do
        -- نبحث عن اللوحات التي تظهر فوق السيارات في الشارع (BillboardGui)
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            -- نتأكد أن اللوحة موجودة في العالم وليس في قائمة الجوال
            for _, textObj in pairs(obj:GetDescendants()) do
                if textObj:IsA("TextLabel") and string.find(textObj.Text, "ريال") then
                    local price = cleanAndParse(textObj.Text)
                    
                    -- فلتر: تجاهل أي سعر أقل من 60 ألف (لتجنب لوحات المواقف)
                    if price and price > 60000 and price > highestPrice then
                        -- إيجاد مجسم السيارة المرتبط باللوحة
                        local model = obj:FindFirstAncestorWhichIsA("Model")
                        if model and model ~= workspace then
                            highestPrice = price
                            targetModel = model
                        end
                    end
                end
            end
        end
    end
    
    --------------------------------------------------
    -- 3. تنفيذ النقل
    --------------------------------------------------
    if targetModel then
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            -- النقل فوق السيارة بـ 10 خطوات
            root.CFrame = targetModel:GetPivot() * CFrame.new(0, 10, 0)
            infoLabel.Text = "✅ تم العثور على سيارة بـ " .. highestPrice .. " ريال في السيرفر!\nالاسم: " .. targetModel.Name
        end
    else
        infoLabel.Text = "❌ لم أجد سيارات غالية (+60 ألف) معروضة حالياً في الشارع.\n(ربما لا يوجد لاعبون عارضين سياراتهم الآن)."
    end
end)
