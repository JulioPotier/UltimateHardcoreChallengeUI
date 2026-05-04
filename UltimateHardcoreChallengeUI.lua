local ADDON_NAME = ...

local UHCC = {}
_G.UHCC = UHCC

local DEFAULTS = {
  minimap = {
    angle = 225, -- degrees
    radius = 55, -- pixels from minimap center
  },
}

UHCC.TABS = {
  { tab = "gear_quality", label = "Gear & Quality" },
  { tab = "weapons_services", label = "Weapons & Services" },
  { tab = "professions_talents", label = "Professions & Talents" },
  { tab = "zones_dungeons", label = "Zones & Dungeons" },
  { tab = "settings", label = "Settings" },
}

UHCC.OPTIONS = (function()
  local t = {
    -- Gear & Quality
    {
      checkboxId = "GEAR-NONE",
      label = "Gear Tier 0 - No Gear",
      cost = 0,
      isFree = true,
      category = "gear_type",
      term = "none",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-CLOTH",
      label = "Gear Tier 1 - Cloth Gear",
      cost = 30,
      category = "gear_type",
      term = "cloth",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-LEATHER",
      label = "Gear Tier 2 - Leather Gear",
      cost = 500,
      category = "gear_type",
      term = "leather",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-MAIL",
      label = "Gear Tier 3 - Mail Gear",
      cost = 2000,
      category = "gear_type",
      term = "mail",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-PLATE",
      label = "Gear Tier 4 - Plate Gear",
      cost = 5000,
      category = "gear_type",
      term = "plate",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "QUALITY-NONE",
      label = "Quality Tier 0 - No Gear",
      cost = 0,
      isFree = true,
      category = "gear_quality",
      term = "none",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "QUALITY-GREY",
      label = "Quality Tier 1 - Grey Gear",
      cost = 20,
      category = "gear_quality",
      term = "grey",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "QUALITY-WHITE",
      label = "Quality Tier 2 - White Gear",
      cost = 300,
      category = "gear_quality",
      term = "white",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "QUALITY-GREEN",
      label = "Quality Tier 3 - Green Gear",
      cost = 1000,
      category = "gear_quality",
      term = "green",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "QUALITY-BLUE",
      label = "Quality Tier 4 - Blue Gear",
      cost = 3000,
      category = "gear_quality",
      term = "blue",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "QUALITY-PURPLE",
      label = "Quality Tier 5 - Purple Gear",
      cost = 10000,
      category = "gear_quality",
      term = "purple",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-CLOAKS",
      label = "Cloaks",
      cost = 500,
      category = "gear_slots",
      term = "cloaks",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-RINGS",
      label = "Rings",
      cost = 1000,
      category = "gear_slots",
      term = "rings",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-NECKLACE",
      label = "Necklace",
      cost = 1000,
      category = "gear_slots",
      term = "necklace",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-TRINKETS",
      label = "Trinkets",
      cost = 1000,
      category = "gear_slots",
      term = "trinkets",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "GEAR-QUEST",
      label = "Wear Quest Gear",
      cost = 5000,
      category = "gear_rules",
      term = "quest_gear",
      tab = "gear_quality",
      inputType = "checkbox",
    },

    -- Weapons & Services
    {
      checkboxId = "WEAPON-ONEHAND",
      label = "One Handed Weapons",
      cost = 0,
      isFree = true,
      category = "weapons",
      term = "one_handed",
      tab = "weapons_services",
      inputType = "checkbox",
    },
    { checkboxId = "WEAPON-TWOHAND", label = "Two Handed Weapons", cost = 1000, category = "weapons", term = "two_handed", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "WEAPON-DAGGERS", label = "Daggers", cost = 1000, category = "weapons", term = "daggers", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "WEAPON-BOWS", label = "Bows", cost = 1000, category = "weapons", term = "bows", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "WEAPON-GUNS", label = "Guns", cost = 1000, category = "weapons", term = "guns", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "WEAPON-CROSSBOWS", label = "Crossbows", cost = 1000, category = "weapons", term = "crossbows", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "WEAPON-THROWING", label = "Throwing Weapons", cost = 1000, category = "weapons", term = "throwing", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "BAGS-BACKPACK", label = "Backpack", cost = 0, isFree = true, category = "bags", term = "backpack", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "BAGS-BAG1", label = "Bag 1", cost = 100, category = "bags", term = "bag1", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "BAGS-BAG2", label = "Bag 2", cost = 500, category = "bags", term = "bag2", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "BAGS-BAG3", label = "Bag 3", cost = 1000, category = "bags", term = "bag3", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "BAGS-BAG4", label = "Bag 4", cost = 2500, category = "bags", term = "bag4", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "SERVICE-AH", label = "Auction House", cost = 5000, category = "services", term = "auction_house", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "SERVICE-TRADING", label = "Trading", cost = 500, category = "services", term = "trading", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "SERVICE-MAIL", label = "Mail", cost = 1000, category = "services", term = "mail", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "SERVICE-BANK", label = "Bank", cost = 2000, category = "services", term = "bank", tab = "weapons_services", inputType = "checkbox" },

    -- Professions & Talents
    { checkboxId = "PROF-PRIMARY1", label = "Primary Profession 1", cost = 0, isFree = true, category = "professions", term = "primary1", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "PROF-PRIMARY2", label = "Primary Profession 2", cost = 500, category = "professions", term = "primary2", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "PROF-SECONDARY1", label = "Secondary Profession 1", cost = 1000, category = "professions", term = "secondary1", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "PROF-SECONDARY2", label = "Secondary Profession 2", cost = 2500, category = "professions", term = "secondary2", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "PROF-SECONDARY3", label = "Secondary Profession 3", cost = 5000, category = "professions", term = "secondary3", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "TALENT-POINTS", label = "Talent points", cost = 100, category = "talents", term = "points", tab = "professions_talents", inputType = "range", min = 0, max = 40, step = 1 },

    -- Settings
    { checkboxId = "SETTINGS-ANNOY", label = "Annoy me", cost = 0, category = "settings", term = "annoy", tab = "settings", inputType = "checkbox" },
  }

  -- Zones & Dungeons placeholders
  for i = 1, 30 do
    t[#t + 1] = { checkboxId = ("ZONE-%02d"):format(i), label = ("Zone %d"):format(i), cost = 0, category = "zones", term = tostring(i), tab = "zones_dungeons", inputType = "checkbox" }
  end
  for i = 1, 8 do
    t[#t + 1] = { checkboxId = ("CITY-%02d"):format(i), label = ("City %d"):format(i), cost = 0, category = "cities", term = tostring(i), tab = "zones_dungeons", inputType = "checkbox" }
  end
  for i = 1, 15 do
    t[#t + 1] = { checkboxId = ("DUNGEON-%02d"):format(i), label = ("Dungeon %d"):format(i), cost = 0, category = "dungeons", term = tostring(i), tab = "zones_dungeons", inputType = "checkbox" }
  end
  for i = 1, 5 do
    t[#t + 1] = { checkboxId = ("RAID-%02d"):format(i), label = ("Raid %d"):format(i), cost = 0, category = "raids", term = tostring(i), tab = "zones_dungeons", inputType = "checkbox" }
  end

  return t
end)()

local function clamp(v, minV, maxV)
  if v < minV then return minV end
  if v > maxV then return maxV end
  return v
end

local function normalizeAngle(deg)
  deg = deg % 360
  if deg < 0 then deg = deg + 360 end
  return deg
end

local function ensureDB()
  if type(UHCC_DB) ~= "table" then UHCC_DB = {} end
  if type(UHCC_DB.minimap) ~= "table" then UHCC_DB.minimap = {} end

  if type(UHCC_DB.minimap.angle) ~= "number" then UHCC_DB.minimap.angle = DEFAULTS.minimap.angle end
  if type(UHCC_DB.minimap.radius) ~= "number" then UHCC_DB.minimap.radius = DEFAULTS.minimap.radius end

  UHCC_DB.minimap.radius = clamp(UHCC_DB.minimap.radius, 30, 110)
  UHCC_DB.minimap.angle = normalizeAngle(UHCC_DB.minimap.angle)
end

local function getAddonVersion()
  local v = GetAddOnMetadata(ADDON_NAME, "Version")
  if not v or v == "" then return "0.0.0" end
  return v
end

local function formatGoldSilverFromCopper(copper)
  copper = tonumber(copper) or 0
  if copper < 0 then copper = 0 end
  local gold = math.floor(copper / 10000)
  local silver = math.floor((copper % 10000) / 100)
  return gold, silver
end

local function goldSilverText(copper)
  local g, s = formatGoldSilverFromCopper(copper)
  return ("%02dG %02dS"):format(g, s)
end

-- =========================
-- Main Window
-- =========================

local function createScrollContent(parent)
  local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 10, -10)
  scroll:SetPoint("BOTTOMRIGHT", -30, 10)

  local child = CreateFrame("Frame", nil, scroll)
  child:SetSize(1, 1)
  scroll:SetScrollChild(child)

  parent.scrollFrame = scroll
  parent.scrollChild = child
  return scroll, child
end

local function addSectionTitle(parent, y, text)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  fs:SetPoint("TOPLEFT", 8, y)
  fs:SetText(text)
  return fs, y - 26
end

local function addSectionTitleAt(parent, x, y, text)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  fs:SetPoint("TOPLEFT", x, y)
  fs:SetText(text)
  return fs
end

local function addCheckboxAt(parent, x, y, label, opts)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", x, y)
  cb.Text:SetText(label)
  -- Use the larger font everywhere (matches the disabled/free look).
  cb.Text:SetFontObject("GameFontDisable")
  cb.Text:SetTextColor(1, 1, 1, 1)

  if opts and opts.checked then cb:SetChecked(true) end
  if opts and opts.disabled then
    cb:SetEnabled(false)
    cb.Text:SetTextColor(0.7, 0.7, 0.7, 1)
  end

  return cb
end

local function formatCostSilver(costSilver)
  costSilver = tonumber(costSilver) or 0
  if costSilver <= 0 then
    return " - Free"
  end

  local gold = math.floor(costSilver / 100)
  local silver = math.floor(costSilver % 100)
  local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:0:0|t"
  local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:14:14:0:0|t"

  if gold > 0 and silver > 0 then
    return (" - %d %s %d %s"):format(gold, goldIcon, silver, silverIcon)
  elseif gold > 0 then
    return (" - %d %s"):format(gold, goldIcon)
  else
    return (" - %d %s"):format(silver, silverIcon)
  end
end

local function addCheckbox(parent, y, label, opts)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", 6, y)
  cb.Text:SetText(label)

  if opts and opts.checked then cb:SetChecked(true) end
  if opts and opts.disabled then
    cb:SetEnabled(false)
    cb.Text:SetFontObject("GameFontDisable")
  end

  return cb, y - 24
end

local sliderSeq = 0

local function addSlider(parent, y, label, minV, maxV, step)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  fs:SetPoint("TOPLEFT", 8, y)
  fs:SetText(label)

  sliderSeq = sliderSeq + 1
  local sliderName = ("UHCC_OptionsSlider%d"):format(sliderSeq)
  local slider = CreateFrame("Slider", sliderName, parent, "OptionsSliderTemplate")
  slider:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -12)
  slider:SetMinMaxValues(minV, maxV)
  slider:SetValueStep(step or 1)
  slider:SetObeyStepOnDrag(true)
  slider:SetValue(minV)

  local low = _G[sliderName .. "Low"]
  local high = _G[sliderName .. "High"]
  local text = _G[sliderName .. "Text"]
  if low then low:SetText(tostring(minV)) end
  if high then high:SetText(tostring(maxV)) end
  if text then text:SetText("") end

  local valueText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
  valueText:SetText(tostring(minV))
  slider:SetScript("OnValueChanged", function(self, value)
    valueText:SetText(tostring(math.floor(value + 0.5)))
  end)

  return slider, y - 66
end

local function clearChildren(frame)
  local children = { frame:GetChildren() }
  for _, c in ipairs(children) do
    c:Hide()
    c:SetParent(nil)
  end
  local regions = { frame:GetRegions() }
  for _, r in ipairs(regions) do
    if r.GetObjectType and r:GetObjectType() == "FontString" then
      r:Hide()
    end
  end
end

local function buildTabPage(panel, tabName, spec)
  panel.tabName = tabName
  clearChildren(panel)

  local scroll, child = createScrollContent(panel)

  local colX = { 8, 300, 592 }
  local rowH = 24
  local maxRows = 15
  local maxCols = 3
  local blockGap = 12

  local function lineToPos(line)
    local perBlock = maxRows * maxCols
    local block = math.floor(line / perBlock)
    local within = line % perBlock
    local col = math.floor(within / maxRows)
    local row = within % maxRows

    local x = colX[col + 1] or colX[#colX]
    local y = -8 - (block * (maxRows * rowH + blockGap)) - (row * rowH)
    return x, y, col, row, block
  end

  local line = 0
  local perBlock = maxRows * maxCols

  local function setColumnStart(targetCol)
    targetCol = tonumber(targetCol)
    if not targetCol then return end
    if targetCol < 0 then targetCol = 0 end
    if targetCol > (maxCols - 1) then targetCol = maxCols - 1 end

    local currentBlock = math.floor(line / perBlock)
    local candidate = (currentBlock * perBlock) + (targetCol * maxRows)
    if line > candidate then
      currentBlock = currentBlock + 1
      candidate = (currentBlock * perBlock) + (targetCol * maxRows)
    end
    line = candidate
  end

  for _, item in ipairs(spec) do
    if item.kind == "spacer" then
      line = line + 1
    elseif item.kind == "section" then
      if item.column ~= nil then
        setColumnStart(item.column)
      end
      local x, y = lineToPos(line)
      addSectionTitleAt(child, x, y, item.text)
      line = line + 1
    elseif item.kind == "checkbox" then
      local x, y = lineToPos(line)
      local cb = addCheckboxAt(child, x, y, item.text, item.opts)
      cb.UHCC_option = item.option
      cb.checkboxId = item.option and item.option.checkboxId or nil
      cb.cost = item.option and item.option.cost or nil
      line = line + 1
    elseif item.kind == "slider" then
      local x, y = lineToPos(line)
      local fs = child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      fs:SetPoint("TOPLEFT", x + 2, y)
      fs:SetText(item.text)

      sliderSeq = sliderSeq + 1
      local sliderName = ("UHCC_OptionsSlider%d"):format(sliderSeq)
      local slider = CreateFrame("Slider", sliderName, child, "OptionsSliderTemplate")
      slider:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", -2, -12)
      slider:SetMinMaxValues(item.min, item.max)
      slider:SetValueStep(item.step or 1)
      slider:SetObeyStepOnDrag(true)
      slider:SetValue(item.min)

      local low = _G[sliderName .. "Low"]
      local high = _G[sliderName .. "High"]
      local text = _G[sliderName .. "Text"]
      if low then low:SetText(tostring(item.min)) end
      if high then high:SetText(tostring(item.max)) end
      if text then text:SetText("") end

      local valueText = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
      valueText:SetText(tostring(item.min))
      slider:SetScript("OnValueChanged", function(_, value)
        valueText:SetText(tostring(math.floor(value + 0.5)))
      end)

      -- Slider consumes ~3 lines of height in our grid.
      line = line + 3
    end
  end

  local height = math.max(1, math.ceil(line / (maxRows * maxCols)) * (maxRows * rowH + blockGap) + 60)
  child:SetSize(1, height)
  scroll:SetVerticalScroll(0)
end

local function setTabSelected(tabId)
  local f = UHCC.mainFrame
  if not f then return end

  PanelTemplates_SetTab(f, tabId)
  PanelTemplates_UpdateTabs(f)
  for i = 1, (f.numTabs or 0) do
    local panel = f.tabPanels and f.tabPanels[i]
    if panel then
      if i == tabId then panel:Show() else panel:Hide() end
    end
  end
end

local function createMainWindow()
  if UHCC.mainFrame then return UHCC.mainFrame end

  local f = CreateFrame("Frame", "UHCC_MainFrame", UIParent, "BasicFrameTemplateWithInset")
  UHCC.mainFrame = f

  f:SetSize(920, 560)
  f:SetPoint("CENTER")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  f:Hide()

  tinsert(UISpecialFrames, f:GetName())

  f.TitleText:SetText(("UltimateHardcoreChallengeUI v%s"):format(getAddonVersion()))

  -- Content inset
  local content = CreateFrame("Frame", nil, f, "InsetFrameTemplate3")
  content:SetPoint("TOPLEFT", 12, -60)
  content:SetPoint("BOTTOMRIGHT", -12, 50)
  f.content = content

  -- Tabs
  local tabNames = {}
  local tabKeyByLabel = {}
  for i = 1, #UHCC.TABS do
    tabNames[i] = UHCC.TABS[i].label
    tabKeyByLabel[UHCC.TABS[i].label] = UHCC.TABS[i].tab
  end
  f.tabPanels = {}
  f.numTabs = #tabNames

  local settingsTabId = #tabNames
  local defaultTabId = settingsTabId -- show Settings by default

  local function buildSpecForTab(tabKey)
    local spec = {}

    local sectionTitles = nil
    local sectionColumns = nil
    if tabKey == "gear_quality" then
      sectionTitles = {
        gear_type = "Gear",
        gear_quality = "Quality",
        gear_slots = "Accessories",
        gear_rules = "Quest Gear",
      }
    elseif tabKey == "weapons_services" then
      sectionTitles = {
        weapons = "Weapons",
        bags = "Bags",
        services = "Services",
      }
      sectionColumns = {
        weapons = 0,
        bags = 1,
        services = 2,
      }
    end

    local lastSection = nil
    for _, opt in ipairs(UHCC.OPTIONS) do
      if opt.tab == tabKey then
        if sectionTitles and opt.inputType == "checkbox" and sectionTitles[opt.category] and lastSection ~= opt.category then
          if #spec > 0 then spec[#spec + 1] = { kind = "spacer" } end
          spec[#spec + 1] = {
            kind = "section",
            text = sectionTitles[opt.category],
            column = sectionColumns and sectionColumns[opt.category] or nil,
          }
          lastSection = opt.category
        end

        if opt.inputType == "checkbox" then
          local text = opt.label .. formatCostSilver(opt.cost)
          spec[#spec + 1] = {
            kind = "checkbox",
            text = text,
            opts = opt.isFree and { checked = true, disabled = true } or nil,
            option = opt,
          }
        elseif opt.inputType == "range" then
          spec[#spec + 1] = {
            kind = "slider",
            text = opt.label .. formatCostSilver(opt.cost),
            min = opt.min or 0,
            max = opt.max or 100,
            step = opt.step or 1,
            option = opt,
          }
        elseif opt.inputType == "text" then
          -- reserved for later
        end
      end
    end

    return spec
  end

  local TAB_SPECS = {}
  for _, tabInfo in ipairs(UHCC.TABS) do
    TAB_SPECS[tabInfo.label] = buildSpecForTab(tabInfo.tab)
  end

  for i = 1, #tabNames do
    local tab = CreateFrame("Button", ("UHCC_MainFrameTab%d"):format(i), f, "CharacterFrameTabButtonTemplate")
    tab:SetID(i)
    tab:SetText(tabNames[i])
    tab:SetScript("OnClick", function(self) setTabSelected(self:GetID()) end)

    if i == 1 then
      tab:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    else
      tab:SetPoint("LEFT", _G[("UHCC_MainFrameTab%d"):format(i - 1)], "RIGHT", -15, 0)
    end

    PanelTemplates_TabResize(tab, 14)
    if tab.GetTextWidth and tab:GetTextWidth() then
      tab:SetWidth(tab:GetTextWidth() + 40)
    end

    local panel = CreateFrame("Frame", nil, content)
    panel:SetAllPoints(true)
    f.tabPanels[i] = panel

    buildTabPage(panel, tabNames[i], TAB_SPECS[tabNames[i]] or {})
  end

  PanelTemplates_SetNumTabs(f, f.numTabs)
  setTabSelected(defaultTabId)

  -- Spent counter (top-right)
  local spent = CreateFrame("Frame", nil, f)
  spent:SetPoint("TOPRIGHT", f, "TOPRIGHT", -120, -34)
  spent:SetSize(220, 20)
  f.spentFrame = spent

  local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:0:0|t"
  local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:14:14:0:0|t"

  local spentLabel = spent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  spentLabel:SetPoint("RIGHT", spent, "RIGHT", 0, 0)
  spentLabel:SetJustifyH("RIGHT")
  spentLabel:SetText("Spent:")

  local spentValue = spent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  spentValue:SetPoint("LEFT", spentLabel, "RIGHT", 30, 0)
  spentValue:SetJustifyH("LEFT")
  spentValue:SetText(("000 %s 00 %s"):format(goldIcon, silverIcon))
  spent.valueText = spentValue

  function f:SetSpentCopper(copper)
    local g, s = formatGoldSilverFromCopper(copper)
    s = 30
    spentValue:SetText(("%02d %s %02d %s"):format(g, goldIcon, s, silverIcon))
  end
  f:SetSpentCopper(0)

  -- Close button (bottom-right)
  local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  closeBtn:SetSize(120, 26)
  closeBtn:SetPoint("BOTTOMRIGHT", -14, 14)
  closeBtn:SetText("Close")
  closeBtn:SetScript("OnClick", function() f:Hide() end)

  return f
end

function UHCC:ToggleMainFrame()
  local f = createMainWindow()
  if f:IsShown() then
    f:Hide()
  else
    f:Show()
    f:Raise()
  end
end

-- =========================
-- Minimap Button
-- =========================

local function positionMinimapButton(btn)
  if not btn then return end
  ensureDB()

  local angle = math.rad(UHCC_DB.minimap.angle)
  local radius = UHCC_DB.minimap.radius

  local x = math.cos(angle) * radius
  local y = math.sin(angle) * radius

  btn:ClearAllPoints()
  btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function computeAngleFromCursor()
  local mx, my = Minimap:GetCenter()
  local cx, cy = GetCursorPosition()
  local scale = UIParent:GetEffectiveScale()
  cx, cy = cx / scale, cy / scale

  local dx = cx - mx
  local dy = cy - my
  local angle = math.deg(math.atan2(dy, dx))
  return normalizeAngle(angle)
end

local function applyMinimapIcon(tex)
  local customPath = "Interface\\AddOns\\UltimateHardcoreChallengeUI\\assets\\UHCC_MinimapIcon.tga"
  local ok = tex:SetTexture(customPath)
  if not ok then
    tex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
  end
end

local function getMinimapIconPath()
  -- We can't reliably check file existence at runtime; just try custom first then fallback.
  return "Interface\\AddOns\\UltimateHardcoreChallengeUI\\assets\\UHCC_MinimapIcon.tga", "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function createMinimapButton()
  if UHCC.minimapButton then
    positionMinimapButton(UHCC.minimapButton)
    return UHCC.minimapButton
  end

  local btn = CreateFrame("Button", "UHCC_MinimapButton", Minimap)
  UHCC.minimapButton = btn

  btn:SetSize(32, 32)
  btn:SetFrameStrata("HIGH")
  btn:SetFrameLevel(Minimap:GetFrameLevel() + 8)
  btn:SetMovable(true)
  btn:EnableMouse(true)
  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  btn:RegisterForDrag("LeftButton")

  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  bg:SetSize(54, 54)
  bg:SetPoint("CENTER", 10, -10)

  -- Clean look: no pressed texture swap, just a single icon.
  btn:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
  local nt = btn:GetNormalTexture()
  if nt then
    nt:SetAllPoints(btn)
    nt:SetVertexColor(1, 1, 1, 0)
  end

  btn:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
  local pt = btn:GetPushedTexture()
  if pt then
    pt:SetAllPoints(btn)
    pt:SetVertexColor(1, 1, 1, 0)
  end

  local icon = btn:CreateTexture(nil, "ARTWORK")
  icon:SetSize(20, 20)
  icon:SetPoint("CENTER", 0, 0)
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  icon:SetVertexColor(1, 1, 1, 1)
  applyMinimapIcon(icon)
  btn.icon = icon

  btn:SetAlpha(1)

  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("UltimateHardcoreChallengeUI", 1, 1, 1)
    GameTooltip:AddLine("Left-click: Toggle window", 0.9, 0.9, 0.9)
    GameTooltip:AddLine("Drag: Move icon", 0.9, 0.9, 0.9)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  btn:SetScript("OnClick", function(_, button)
    if button == "LeftButton" then
      UHCC:ToggleMainFrame()
    end
  end)

  btn:SetScript("OnDragStart", function(self)
    self.isDragging = true
  end)
  btn:SetScript("OnDragStop", function(self)
    self.isDragging = false
    positionMinimapButton(self)
  end)

  btn:SetScript("OnUpdate", function(self)
    if not self.isDragging then return end
    UHCC_DB.minimap.angle = computeAngleFromCursor()
    positionMinimapButton(self)
  end)

  positionMinimapButton(btn)
  return btn
end

-- =========================
-- Events
-- =========================

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, event, name)
  if event == "ADDON_LOADED" and name == ADDON_NAME then
    ensureDB()
    createMainWindow()
    createMinimapButton()
  end
end)
