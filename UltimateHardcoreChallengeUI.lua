local ADDON_NAME = ...

local UHCC = {}
_G.UHCC = UHCC

local DEFAULTS = {
  minimap = {
    angle = 225, -- degrees
    radius = 55, -- pixels from minimap center
  },
}

-- Content horizontal insets 12+12; options scroll frame edges 10+30 → inner width for 3 columns.
local MAIN_FRAME_WIDTH, MAIN_FRAME_HEIGHT = 900, 500

UHCC.TABS = {
  { tab = "gear_quality", label = "Gear & Quality" },
  { tab = "weapons_services", label = "Weapons & Services" },
  { tab = "professions_talents", label = "Professions & Talents" },
  { tab = "zones_dungeons", label = "Zones & Dungeons" },
  { tab = "settings", label = "Settings" },
}

-- Classic Era world areas: { mapID, displayName, csvType, continent } (from wow-zones.csv).
UHCC.WORLD_ZONES = {
  { 1411, "Durotar", "zone", "Kalimdor" },
  { 1412, "Mulgore", "zone", "Kalimdor" },
  { 1413, "The Barrens", "zone", "Kalimdor" },
  { 1416, "Alterac Mountains", "zone", "Eastern Kingdoms" },
  { 1417, "Arathi Highlands", "zone", "Eastern Kingdoms" },
  { 1418, "Badlands", "zone", "Eastern Kingdoms" },
  { 1419, "Blasted Lands", "zone", "Eastern Kingdoms" },
  { 1420, "Tirisfal Glades", "zone", "Eastern Kingdoms" },
  { 1421, "Silverpine Forest", "zone", "Eastern Kingdoms" },
  { 1422, "Western Plaguelands", "zone", "Eastern Kingdoms" },
  { 1423, "Eastern Plaguelands", "zone", "Eastern Kingdoms" },
  { 1424, "Hillsbrad Foothills", "zone", "Eastern Kingdoms" },
  { 1425, "The Hinterlands", "zone", "Eastern Kingdoms" },
  { 1426, "Dun Morogh", "zone", "Eastern Kingdoms" },
  { 1427, "Searing Gorge", "zone", "Eastern Kingdoms" },
  { 1428, "Burning Steppes", "zone", "Eastern Kingdoms" },
  { 1429, "Elwynn Forest", "zone", "Eastern Kingdoms" },
  { 1430, "Deadwind Pass", "zone", "Eastern Kingdoms" },
  { 1431, "Duskwood", "zone", "Eastern Kingdoms" },
  { 1432, "Loch Modan", "zone", "Eastern Kingdoms" },
  { 1433, "Redridge Mountains", "zone", "Eastern Kingdoms" },
  { 1434, "Stranglethorn Vale", "zone", "Eastern Kingdoms" },
  { 1435, "Swamp of Sorrows", "zone", "Eastern Kingdoms" },
  { 1436, "Westfall", "zone", "Eastern Kingdoms" },
  { 1437, "Wetlands", "zone", "Eastern Kingdoms" },
  { 1438, "Teldrassil", "zone", "Kalimdor" },
  { 1439, "Darkshore", "zone", "Kalimdor" },
  { 1440, "Ashenvale", "zone", "Kalimdor" },
  { 1441, "Thousand Needles", "zone", "Kalimdor" },
  { 1442, "Stonetalon Mountains", "zone", "Kalimdor" },
  { 1443, "Desolace", "zone", "Kalimdor" },
  { 1444, "Feralas", "zone", "Kalimdor" },
  { 1445, "Dustwallow Marsh", "zone", "Kalimdor" },
  { 1446, "Tanaris", "zone", "Kalimdor" },
  { 1447, "Azshara", "zone", "Kalimdor" },
  { 1448, "Felwood", "zone", "Kalimdor" },
  { 1449, "Un'Goro Crater", "zone", "Kalimdor" },
  { 1450, "Moonglade", "zone", "Kalimdor" },
  { 1451, "Silithus", "zone", "Kalimdor" },
  { 1452, "Winterspring", "zone", "Kalimdor" },
  { 1453, "Stormwind City", "city", "Eastern Kingdoms" },
  { 1454, "Orgrimmar", "city", "Kalimdor" },
  { 1455, "Ironforge", "city", "Eastern Kingdoms" },
  { 1456, "Thunder Bluff", "city", "Kalimdor" },
  { 1457, "Darnassus", "city", "Kalimdor" },
  { 1458, "Undercity", "city", "Eastern Kingdoms" },
  { 1459, "Alterac Valley", "battleground", "Azeroth" },
  { 1460, "Warsong Gulch", "battleground", "Azeroth" },
  { 1461, "Arathi Basin", "battleground", "Azeroth" },
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
      checkboxId = "QUALITY-EPIC",
      label = "Quality Tier 6 - Epic Gear",
      cost = 20000,
      category = "gear_quality",
      term = "epic",
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
      category = "gear_quest",
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
    {
      checkboxId = "PROF-PRIMARY1",
      label = "Primary Profession 1",
      cost = 0,
      noFreeLock = true,
      category = "professions",
      term = "primary1",
      tab = "professions_talents",
      inputType = "checkbox",
    },
    { checkboxId = "PROF-PRIMARY2", label = "Primary Profession 2", cost = 500, category = "professions", term = "primary2", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "PROF-SECONDARY1", label = "Secondary Profession 1", cost = 1000, category = "professions", term = "secondary1", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "PROF-SECONDARY2", label = "Secondary Profession 2", cost = 2500, category = "professions", term = "secondary2", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "PROF-SECONDARY3", label = "Secondary Profession 3", cost = 5000, category = "professions", term = "secondary3", tab = "professions_talents", inputType = "checkbox" },
    { checkboxId = "TALENT-POINTS", label = "Talent points", cost = 100, category = "talents", term = "points", tab = "professions_talents", inputType = "range", min = 0, max = 50, step = 1 },

    -- Settings (no prices; descriptions shown in a simple layout on the Settings tab)
    {
      checkboxId = "SETTINGS-ANNOY",
      label = "Annoy me",
      description = "The addon will try to prevent you from doing things you shouldn't by annoying you to the max.",
      cost = 0,
      category = "settings",
      term = "annoy",
      tab = "settings",
      inputType = "checkbox",
    },
  }

  -- Zones & Dungeons: one checkbox per map from UHCC.WORLD_ZONES; 3 gold each (UHCC cost unit: floor(cost/100) = gold).
  -- Per continent: zones section then Cities section; Azeroth CSV rows → Battlegrounds column only.
  do
    local ZONE_OPTION_COST = 300
    local buckets = {
      kalimdor_zones = {},
      kalimdor_cities = {},
      ek_zones = {},
      ek_cities = {},
      battlegrounds = {},
    }
    for _, row in ipairs(UHCC.WORLD_ZONES) do
      local ztype, cont = row[3], row[4]
      local b
      if cont == "Azeroth" or ztype == "battleground" then
        b = buckets.battlegrounds
      elseif cont == "Kalimdor" then
        b = (ztype == "city") and buckets.kalimdor_cities or buckets.kalimdor_zones
      elseif cont == "Eastern Kingdoms" then
        b = (ztype == "city") and buckets.ek_cities or buckets.ek_zones
      end
      if b then
        b[#b + 1] = row
      end
    end
    local emitOrder = {
      "kalimdor_zones",
      "kalimdor_cities",
      "ek_zones",
      "ek_cities",
      "battlegrounds",
    }
    for _, catKey in ipairs(emitOrder) do
      for _, row in ipairs(buckets[catKey]) do
        t[#t + 1] = {
          checkboxId = ("ZONE-%d"):format(row[1]),
          label = row[2],
          cost = ZONE_OPTION_COST,
          category = catKey,
          term = tostring(row[1]),
          tab = "zones_dungeons",
          inputType = "checkbox",
        }
      end
    end
  end

  return t
end)()

-- UI map ID → zone purchase checkbox (term stores map id as string).
local UHCC_ZONE_OPTION_BY_MAP_ID = {}
do
  for _, opt in ipairs(UHCC.OPTIONS) do
    if opt.tab == "zones_dungeons" and opt.inputType == "checkbox" then
      local mid = tonumber(opt.term)
      if mid then
        UHCC_ZONE_OPTION_BY_MAP_ID[mid] = opt
      end
    end
  end
end

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

-- Forward declaration: set after ensureCharDB (used by welcome + level-advice popups).
local uhccShowWelcomePopup

-- Session guard: /reload clears this so onboarding can run again until welcome is saved.
local uhccOnboardingTimerScheduled = false

local function ensureCharDB()
  if type(UHCC_CharDB) ~= "table" then UHCC_CharDB = {} end
  if type(UHCC_CharDB.options) ~= "table" then UHCC_CharDB.options = {} end
  if UHCC_CharDB._uhccFirstAddonLoad == nil then
    UHCC_CharDB._uhccFirstAddonLoad = true
  end
end

uhccShowWelcomePopup = function()
  ensureCharDB()
  if UHCC_CharDB._uhccWelcomeSeen then return end
  UHCC_CharDB._uhccWelcomeSeen = true
  uhccOnboardingTimerScheduled = false
  if StaticPopupDialogs and StaticPopupDialogs["UHCC_WELCOME"] then
    StaticPopup_Show("UHCC_WELCOME")
  end
end

-- Run after PLAYER_ENTERING_WORLD so UnitLevel is valid; not tied to _uhccFirstAddonLoad (/reload would skip otherwise).
local function uhccScheduleOnboardingIfNeeded()
  ensureCharDB()
  if UHCC_CharDB._uhccWelcomeSeen then return end
  local virginOptions = true
  for _ in pairs(UHCC_CharDB.options) do
    virginOptions = false
    break
  end
  if not virginOptions then return end
  if uhccOnboardingTimerScheduled then return end
  uhccOnboardingTimerScheduled = true
  C_Timer.After(1.5, function()
    ensureCharDB()
    if UHCC_CharDB._uhccWelcomeSeen then
      uhccOnboardingTimerScheduled = false
      return
    end
    local lvl = UnitLevel("player")
    if lvl and lvl > 1 and not UHCC_CharDB._uhccNonLevel1AdviceSeen then
      if StaticPopupDialogs and StaticPopupDialogs["UHCC_NON_LEVEL1_ADVICE"] then
        StaticPopup_Show("UHCC_NON_LEVEL1_ADVICE")
      else
        uhccShowWelcomePopup()
      end
    else
      uhccShowWelcomePopup()
    end
  end)
end

-- isFree = forced checked + disabled; noFreeLock = never lock (e.g. cost 0 but still a normal checkbox).
local function optionLocksFreeChoice(opt)
  if not opt or opt.noFreeLock then return false end
  return opt.isFree
end

-- Armor weight tiers each class can equip (Classic Era). classFile = 2nd return of UnitClass("player").
local CLASS_ARMOR_ALLOWED = {
  WARRIOR = { cloth = true, leather = true, mail = true, plate = true },
  PALADIN = { cloth = true, leather = true, mail = true, plate = true },
  DEATHKNIGHT = { cloth = true, leather = true, mail = true, plate = true },
  HUNTER = { cloth = true, leather = true, mail = true, plate = false },
  ROGUE = { cloth = true, leather = true, mail = false, plate = false },
  PRIEST = { cloth = true, leather = false, mail = false, plate = false },
  SHAMAN = { cloth = true, leather = true, mail = true, plate = false },
  MAGE = { cloth = true, leather = false, mail = false, plate = false },
  WARLOCK = { cloth = true, leather = false, mail = false, plate = false },
  DRUID = { cloth = true, leather = true, mail = false, plate = false },
}

local function playerCanUseGearArmorTerm(term)
  if term == "none" or term == nil or term == "" then return true end
  local _, classFile = UnitClass("player")
  if not classFile then return true end
  local allowed = CLASS_ARMOR_ALLOWED[classFile]
  if not allowed then return true end
  return not not allowed[term]
end

local function isGearArmorTierOption(opt)
  return opt
    and opt.tab == "gear_quality"
    and opt.category == "gear_type"
    and opt.inputType == "checkbox"
    and opt.term
    and opt.term ~= "none"
end

local function pruneInvalidGearArmorSelections()
  ensureCharDB()
  for _, opt in ipairs(UHCC.OPTIONS) do
    if isGearArmorTierOption(opt) and not playerCanUseGearArmorTerm(opt.term) then
      UHCC_CharDB.options[opt.checkboxId] = false
    end
  end
end

-- UHCC cost: gold = floor(cost/100) display silver = cost%100 (see formatCostSilver) → WoW copper.
local function uhccCostToCopper(displayCost)
  displayCost = tonumber(displayCost) or 0
  if displayCost < 0 then displayCost = 0 end
  return math.floor(displayCost / 100) * 10000 + (displayCost % 100) * 100
end

local function getCharCheckboxState(opt)
  ensureCharDB()
  if not opt or not opt.checkboxId then return false end
  if isGearArmorTierOption(opt) and not playerCanUseGearArmorTerm(opt.term) then
    return false
  end
  local v = UHCC_CharDB.options[opt.checkboxId]
  if v == nil then return false end
  return not not v
end

local function computeTotalSpentCopperFromCharDB()
  ensureCharDB()
  local total = 0
  for _, opt in ipairs(UHCC.OPTIONS) do
    if opt.tab ~= "settings" then
      if opt.inputType == "checkbox" then
        if not optionLocksFreeChoice(opt) then
          if isGearArmorTierOption(opt) and not playerCanUseGearArmorTerm(opt.term) then
            -- cannot equip: never counts toward Spent
          elseif UHCC_CharDB.options[opt.checkboxId] then
            total = total + uhccCostToCopper(opt.cost)
          end
        end
      elseif opt.inputType == "range" then
        local mn, mx = opt.min or 0, opt.max or 100
        local v = tonumber(UHCC_CharDB.options[opt.checkboxId])
        if v == nil then v = mn end
        v = clamp(math.floor(v + 0.5), mn, mx)
        local per = tonumber(opt.cost) or 0
        total = total + uhccCostToCopper(per * v)
      end
    end
  end
  return total
end

-- Zone restriction overlay: unpurchased zone → dark screen (mouse passes through).
local uhccZoneRestrictionOverlayFrame = nil
local uhccZoneOverlayViolationStart = nil
local uhccZoneOverlayFadeOutStart = nil
local uhccZoneOverlayFadeOutAlpha0 = 0
local uhccZoneOverlayCurrentAlpha = 0
local UHCC_ZONE_OVERLAY_MAX_ALPHA = 0.9
local UHCC_ZONE_FADE_IN_SEC = 10
local UHCC_ZONE_FADE_OUT_SEC = 3

local function uhccFindZoneOptionForPlayerMap()
  if not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetMapInfo then
    return nil
  end
  local mapID = C_Map.GetBestMapForUnit("player")
  if not mapID or mapID == 0 then
    return nil
  end
  local seen = {}
  while mapID and mapID ~= 0 and not seen[mapID] do
    seen[mapID] = true
    local opt = UHCC_ZONE_OPTION_BY_MAP_ID[mapID]
    if opt then
      return opt
    end
    local info = C_Map.GetMapInfo(mapID)
    if not info then
      break
    end
    local parent = info.parentMapID
    if not parent or parent == 0 then
      break
    end
    mapID = parent
  end
  return nil
end

local function uhccZonePurchaseViolationActive()
  local opt = uhccFindZoneOptionForPlayerMap()
  if not opt then
    return false, nil
  end
  ensureCharDB()
  if getCharCheckboxState(opt) then
    return false, nil
  end
  return true, opt
end

local function uhccZoneRestrictionOverlayUpdate()
  local f = uhccZoneRestrictionOverlayFrame
  if not f then
    return
  end
  local now = GetTime()
  local inViol, opt = uhccZonePurchaseViolationActive()

  if inViol and opt then
    f.uhccLastZoneLabel = opt.label
    uhccZoneOverlayFadeOutStart = nil
    if not uhccZoneOverlayViolationStart then
      uhccZoneOverlayViolationStart = now
    end
    local elapsedIn = now - uhccZoneOverlayViolationStart
    uhccZoneOverlayCurrentAlpha = math.min(
      UHCC_ZONE_OVERLAY_MAX_ALPHA,
      (elapsedIn / UHCC_ZONE_FADE_IN_SEC) * UHCC_ZONE_OVERLAY_MAX_ALPHA
    )
  else
    uhccZoneOverlayViolationStart = nil
    if uhccZoneOverlayCurrentAlpha > 0.001 then
      if not uhccZoneOverlayFadeOutStart then
        uhccZoneOverlayFadeOutStart = now
        uhccZoneOverlayFadeOutAlpha0 = uhccZoneOverlayCurrentAlpha
      end
      local te = now - uhccZoneOverlayFadeOutStart
      if te >= UHCC_ZONE_FADE_OUT_SEC then
        uhccZoneOverlayFadeOutStart = nil
        uhccZoneOverlayCurrentAlpha = 0
        f.uhccLastZoneLabel = nil
      else
        uhccZoneOverlayCurrentAlpha = uhccZoneOverlayFadeOutAlpha0 * (1 - te / UHCC_ZONE_FADE_OUT_SEC)
      end
    else
      uhccZoneOverlayFadeOutStart = nil
      uhccZoneOverlayCurrentAlpha = 0
      f.uhccLastZoneLabel = nil
    end
  end

  local a = uhccZoneOverlayCurrentAlpha
  if f.bg then
    f.bg:SetAlpha(a)
  end
  if a > 0.02 and f.uhccLastZoneLabel then
    local w = math.min(900, (GetScreenWidth and GetScreenWidth() or UIParent:GetWidth()) * 0.88)
    f.msg:SetWidth(w)
    f.msg:SetText(
      ("You haven't purchased this zone: '%s'. Get out or purchase now."):format(f.uhccLastZoneLabel)
    )
    f.msg:SetAlpha(math.min(1, a / UHCC_ZONE_OVERLAY_MAX_ALPHA))
    f.msg:Show()
  else
    f.msg:Hide()
  end
  if a > 0.001 then
    f:Show()
  else
    f:Hide()
  end
end

local function createUhccZoneRestrictionOverlay()
  if uhccZoneRestrictionOverlayFrame then
    return
  end
  local f = CreateFrame("Frame", "UHCC_ZoneRestrictionOverlay", UIParent)
  f:SetFrameStrata("FULLSCREEN")
  f:SetFrameLevel(5000)
  f:SetAllPoints(UIParent)
  f:SetDontSavePosition(true)
  f:EnableMouse(false)
  f:EnableKeyboard(false)

  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 1)
  bg:SetAlpha(0)
  f.bg = bg

  local msg = f:CreateFontString(nil, "OVERLAY")
  msg:SetFontObject("GameFontNormalHuge")
  msg:SetPoint("CENTER", 0, 0)
  msg:SetJustifyH("CENTER")
  msg:SetTextColor(1, 0.12, 0.12, 1)
  msg:SetShadowOffset(2, -2)
  msg:SetShadowColor(0, 0, 0, 1)
  msg:SetWordWrap(true)
  msg:Hide()
  f.msg = msg

  f:SetScript("OnUpdate", function()
    uhccZoneRestrictionOverlayUpdate()
  end)
  f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  f:RegisterEvent("ZONE_CHANGED")
  f:RegisterEvent("PLAYER_ENTERING_WORLD")
  f:SetScript("OnEvent", function()
    uhccZoneRestrictionOverlayUpdate()
  end)

  uhccZoneRestrictionOverlayFrame = f
  f:Hide()
end

local function recalcSpentDisplay()
  local copper = computeTotalSpentCopperFromCharDB()
  local mf = UHCC.mainFrame
  if mf and mf.SetSpentCopper then
    mf:SetSpentCopper(copper)
  end
  uhccZoneRestrictionOverlayUpdate()
end

UHCC.RecalculateSpent = recalcSpentDisplay

local function resetCharChallengeData()
  ensureCharDB()
  for k in pairs(UHCC_CharDB) do
    UHCC_CharDB[k] = nil
  end
  UHCC_CharDB.options = {}
  uhccOnboardingTimerScheduled = false
  ensureCharDB()
  if UHCC.mainFrame then
    UHCC.mainFrame:Hide()
    UHCC.mainFrame:SetParent(nil)
    UHCC.mainFrame = nil
  end
  recalcSpentDisplay()
  print("|cffffcc00UHCC|r: All character data for this addon was reset. Reopen the window to apply.")
  C_Timer.After(0.75, uhccScheduleOnboardingIfNeeded)
end

UHCC.ResetCharacterData = resetCharChallengeData

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

  local innerScrollW = MAIN_FRAME_WIDTH - 64
  local colPitch = math.floor((innerScrollW - 16) / 3)
  local colX = { 8, 8 + colPitch, 8 + colPitch * 2 }
  local rowH = 24
  -- Zones tab: up to ~25 rows per continent in one column; default 15 is enough for other tabs.
  local maxRows = (tabName == "Zones & Dungeons") and 30 or 15
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
  local settingsCursorY = 12 -- distance from top of scroll child (downward) for Settings layout

  local function setColumnStart(targetCol)
    targetCol = tonumber(targetCol)
    if not targetCol then return end
    if targetCol < 0 then targetCol = 0 end
    if targetCol > (maxCols - 1) then targetCol = maxCols - 1 end

    local currentBlock = math.floor(line / perBlock)
    local candidate = (currentBlock * perBlock) + (targetCol * maxRows)
    local within = line % perBlock
    local currentCol = math.floor(within / maxRows)

    -- Same column as requested: keep stacking in this column instead of jumping to the next block.
    if line > candidate and currentCol == targetCol then
      return
    end

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
      if cb.checkboxId and cb:IsEnabled() then
        cb:HookScript("OnClick", function(self)
          ensureCharDB()
          UHCC_CharDB.options[self.checkboxId] = self:GetChecked() and true or false
          recalcSpentDisplay()
        end)
      end
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
      local startVal = item.min or 0
      if item.option and item.option.checkboxId then
        ensureCharDB()
        local sv = tonumber(UHCC_CharDB.options[item.option.checkboxId])
        if sv ~= nil then
          startVal = clamp(math.floor(sv + 0.5), item.min, item.max)
        end
      end

      local low = _G[sliderName .. "Low"]
      local high = _G[sliderName .. "High"]
      local text = _G[sliderName .. "Text"]
      if low then low:SetText(tostring(item.min)) end
      if high then high:SetText(tostring(item.max)) end
      if text then text:SetText("") end

      local valueText = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
      valueText:SetText(tostring(math.floor(startVal + 0.5)))
      -- Avoid persisting on SetValue() so "virgin" onboarding still runs after PLAYER_ENTERING_WORLD.
      slider.UHCC_readyForPersist = false
      slider:SetScript("OnValueChanged", function(_, value)
        local iv = math.floor(value + 0.5)
        valueText:SetText(tostring(iv))
        if not slider.UHCC_readyForPersist then return end
        if item.option and item.option.checkboxId then
          ensureCharDB()
          UHCC_CharDB.options[item.option.checkboxId] = iv
          recalcSpentDisplay()
        end
      end)
      slider:SetValue(startVal)
      slider.UHCC_readyForPersist = true

      -- Slider consumes ~3 lines of height in our grid.
      line = line + 3
    elseif item.kind == "settings_checkbox" then
      local padX = 16
      local y = -settingsCursorY
      local cb = CreateFrame("CheckButton", nil, child, "UICheckButtonTemplate")
      cb:SetPoint("TOPLEFT", child, "TOPLEFT", padX, y)
      cb.Text:SetText(item.label)
      cb.Text:SetFontObject("GameFontNormalLarge")
      cb.Text:SetTextColor(1, 1, 1, 1)

      if item.opts and item.opts.checked then cb:SetChecked(true) end
      if item.opts and item.opts.disabled then
        cb:SetEnabled(false)
        cb.Text:SetTextColor(0.7, 0.7, 0.7, 1)
      end

      cb.UHCC_option = item.option
      cb.checkboxId = item.option and item.option.checkboxId or nil
      cb.cost = item.option and item.option.cost or nil

      local desc = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      desc:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 28, -8)
      desc:SetWidth(math.max(200, innerScrollW - 48))
      desc:SetJustifyH("LEFT")
      desc:SetNonSpaceWrap(false)
      desc:SetText(item.description or "")

      local descH = desc:GetStringHeight() or 0
      settingsCursorY = settingsCursorY + 26 + 8 + math.max(descH, 14) + 24
    end
  end

  local gridHeight = math.max(1, math.ceil(line / (maxRows * maxCols)) * (maxRows * rowH + blockGap) + 60)
  local height = math.max(gridHeight, settingsCursorY + 36)
  child:SetSize(1, height)
  scroll:SetVerticalScroll(0)
end

-- Custom tab strip: Blizzard CharacterFrameTabButtonTemplate + PanelTemplates fights custom widths
-- (clipped on load, all tabs resize on click, hover layout shift). We use plain Buttons + fixed width.

local tabMeasureFontString
local function measureFontObjectTextWidth(text, fontObject)
  if not tabMeasureFontString then
    tabMeasureFontString = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    tabMeasureFontString:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -4000, -4000)
  end
  tabMeasureFontString:SetFontObject(fontObject)
  tabMeasureFontString:SetText(text or "")
  tabMeasureFontString:SetWidth(0)
  tabMeasureFontString:SetNonSpaceWrap(false)
  local w = tabMeasureFontString:GetStringWidth() or 0
  return math.ceil(math.max(w, 0))
end

local function computeUniformTabWidthForLabels(labels)
  local w = 0
  for _, lab in ipairs(labels) do
    w = math.max(w, measureFontObjectTextWidth(lab, GameFontNormalSmall))
    w = math.max(w, measureFontObjectTextWidth(lab, GameFontHighlightSmall))
  end
  return math.max(w + 28, 100)
end

local function applyCustomTabLook(tab, selected)
  local bg = tab.UHCC_bg
  local fs = tab:GetFontString()
  if not bg or not fs then return end
  fs:SetJustifyH("CENTER")
  fs:SetWidth(0)
  fs:SetNonSpaceWrap(false)
  if selected then
    bg:SetColorTexture(0.42, 0.34, 0.14, 1)
    fs:SetFontObject(GameFontHighlightSmall)
    fs:SetTextColor(1, 1, 0.85, 1)
  else
    bg:SetColorTexture(0.12, 0.12, 0.12, 0.98)
    fs:SetFontObject(GameFontNormalSmall)
    fs:SetTextColor(0.82, 0.82, 0.82, 1)
  end
end

local function setTabSelected(tabId)
  local f = UHCC.mainFrame
  if not f then return end
  f.UHCC_selectedTabId = tabId
  for i = 1, (f.numTabs or 0) do
    local tbtn = _G[("UHCC_MainFrameTab%d"):format(i)]
    if tbtn then
      applyCustomTabLook(tbtn, i == tabId)
    end
    local panel = f.tabPanels and f.tabPanels[i]
    if panel then
      if i == tabId then panel:Show() else panel:Hide() end
    end
  end
end

local function createMainWindow()
  if UHCC.mainFrame then return UHCC.mainFrame end

  ensureCharDB()
  pruneInvalidGearArmorSelections()

  local f = CreateFrame("Frame", "UHCC_MainFrame", UIParent, "BasicFrameTemplateWithInset")
  UHCC.mainFrame = f

  f:SetSize(MAIN_FRAME_WIDTH, MAIN_FRAME_HEIGHT)
  f:SetPoint("CENTER")
  -- Stay above most UI (incl. autres addons); juste sous TOOLTIP pour ne pas masquer les bulles utiles.
  f:SetFrameStrata("FULLSCREEN_DIALOG")
  f:SetFrameLevel(500)
  f:SetToplevel(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  f:SetScript("OnShow", function(self)
    self:SetFrameStrata("FULLSCREEN_DIALOG")
    self:SetFrameLevel(500)
    self:Raise()
  end)
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
    if tabKey == "settings" then
      local spec = {}
      for _, opt in ipairs(UHCC.OPTIONS) do
        if opt.tab == "settings" and opt.inputType == "checkbox" then
          local annoyOn = getCharCheckboxState(opt)
          spec[#spec + 1] = {
            kind = "settings_checkbox",
            label = (opt.label or "") .. " - Under dev",
            description = opt.description or "",
            opts = { checked = annoyOn, disabled = true },
            option = opt,
          }
        end
      end
      return spec
    end

    local spec = {}

    local sectionTitles = nil
    local sectionColumns = nil
    if tabKey == "gear_quality" then
      sectionTitles = {
        gear_type = "Gear",
        gear_quality = "Quality",
        gear_slots = "Accessories",
        gear_quest = "Quest Gear",
      }
      sectionColumns = { -- // 0 to 2 max columns
        gear_type = 0,
        gear_quality = 1,
        gear_slots = 2,
        gear_quest = 2,
      }
    elseif tabKey == "weapons_services" then
      sectionTitles = {
        weapons = "Weapons",
        bags = "Bags",
        services = "Services",
      }
      sectionColumns = { -- // 0 to 2 max columns
        weapons = 0,
        bags = 1,
        services = 2,
      }
    elseif tabKey == "professions_talents" then
      sectionTitles = {
        professions = "Professions",
        talents = "Talents",
      }
    elseif tabKey == "zones_dungeons" then
      sectionTitles = {
        kalimdor_zones = "Kalimdor",
        kalimdor_cities = "Cities",
        ek_zones = "Eastern Kingdoms",
        ek_cities = "Cities",
        battlegrounds = "Battlegrounds",
      }
      sectionColumns = {
        kalimdor_zones = 0,
        kalimdor_cities = 0,
        ek_zones = 1,
        ek_cities = 1,
        battlegrounds = 2,
      }
    end

    local lastSection = nil
    for _, opt in ipairs(UHCC.OPTIONS) do
      if opt.tab == tabKey then
        if sectionTitles and sectionTitles[opt.category] and lastSection ~= opt.category then
          if opt.inputType == "checkbox" or opt.inputType == "range" then
            if #spec > 0 then spec[#spec + 1] = { kind = "spacer" } end
            spec[#spec + 1] = {
              kind = "section",
              text = sectionTitles[opt.category],
              column = sectionColumns and sectionColumns[opt.category] or nil,
            }
            lastSection = opt.category
          end
        end

        if opt.inputType == "checkbox" then
          local text = opt.label .. formatCostSilver(opt.cost)
          local armorDenied = isGearArmorTierOption(opt) and not playerCanUseGearArmorTerm(opt.term)
          local chkOpts = nil
          if armorDenied then
            chkOpts = { checked = false, disabled = true }
          elseif optionLocksFreeChoice(opt) then
            chkOpts = { checked = true, disabled = true }
          elseif getCharCheckboxState(opt) then
            chkOpts = { checked = true }
          end
          spec[#spec + 1] = {
            kind = "checkbox",
            text = text,
            opts = chkOpts,
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

  local tabUniformWidth = computeUniformTabWidthForLabels(tabNames)

  for i = 1, #tabNames do
    local tab = CreateFrame("Button", ("UHCC_MainFrameTab%d"):format(i), f)
    tab:SetSize(tabUniformWidth, 26)
    tab:SetID(i)
    tab:SetText(tabNames[i])
    tab:SetNormalFontObject(GameFontNormalSmall)
    tab:SetHighlightFontObject(GameFontNormalSmall)
    tab:SetDisabledFontObject(GameFontDisableSmall)
    tab:SetPushedTextOffset(0, 0)

    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    tab.UHCC_bg = bg

    local hi = tab:CreateTexture(nil, "HIGHLIGHT")
    hi:SetAllPoints()
    hi:SetColorTexture(1, 1, 1, 0.08)
    hi:SetBlendMode("ADD")

    tab:SetScript("OnClick", function(self) setTabSelected(self:GetID()) end)

    if i == 1 then
      tab:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    else
      tab:SetPoint("LEFT", _G[("UHCC_MainFrameTab%d"):format(i - 1)], "RIGHT", 3, 0)
    end

    local panel = CreateFrame("Frame", nil, content)
    panel:SetAllPoints(true)
    f.tabPanels[i] = panel

    buildTabPage(panel, tabNames[i], TAB_SPECS[tabNames[i]] or {})
  end

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
    spentValue:SetText(("%02d %s %02d %s"):format(g, goldIcon, s, silverIcon))
  end
  recalcSpentDisplay()

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
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(500)
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
    GameTooltip:AddLine("/uhcc reset — clear this character's options", 0.75, 0.75, 0.75)
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

StaticPopupDialogs["UHCC_WELCOME"] = {
  text = "|cffffcc00Ultimate Hardcore Challenge|r\n\n|cffffcc00Ultimate Hardcore|r mode is |cff00ff00enabled|r for this character.\n\nUse the minimap button to choose your rules. Good luck!",
  button1 = OKAY,
  OnAccept = function() end,
  timeout = 0,
  whileDead = true,
  interruptCinematic = false,
  hideOnEscape = true,
}

StaticPopupDialogs["UHCC_NON_LEVEL1_ADVICE"] = {
  text = "|cffffcc00UHCC|r — Recommendation\n\nYour character is not |cffffcc00level 1|r. For this challenge, it is strongly recommended to |cffffcc00start at level 1|r.\n\nWhen the option is available in the |cffffcc00Settings|r tab, you will need to |cffffcc00check|r the intended checkbox to avoid constant reminders.",
  button1 = OKAY,
  OnAccept = function()
    ensureCharDB()
    UHCC_CharDB._uhccNonLevel1AdviceSeen = true
    C_Timer.After(0.2, uhccShowWelcomePopup)
  end,
  OnCancel = function()
    ensureCharDB()
    UHCC_CharDB._uhccNonLevel1AdviceSeen = true
    C_Timer.After(0.2, uhccShowWelcomePopup)
  end,
  timeout = 0,
  whileDead = true,
  interruptCinematic = false,
  hideOnEscape = true,
}

StaticPopupDialogs["UHCC_RESET_CHARACTER"] = {
  text = "|cffffcc00UltimateHardcoreChallengeUI|r\n\nErase |cffffcc00all|r saved addon data for this character (options, welcome / level tips, flags)?\n\nLocked UI choices stay the same when you reopen the window.",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
    resetCharChallengeData()
  end,
  timeout = 0,
  whileDead = true,
  interruptCinematic = false,
  hideOnEscape = true,
}

local function slashTrim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function slashUHCC(msg)
  local m = string.lower(slashTrim(msg))
  if m == "reset" then
    StaticPopup_Show("UHCC_RESET_CHARACTER")
  elseif m == "" then
    print("|cffffcc00UHCC|r: |cff00ff00/uhcc reset|r — erase this character's saved options (confirmation).")
  else
    print("|cffffcc00UHCC|r: Unknown command. Use |cff00ff00/uhcc reset|r.")
  end
end

SLASH_UHCC1 = "/uhcc"
SLASH_UHCC2 = "/UHCC"
SlashCmdList["UHCC"] = slashUHCC

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, name)
  if event == "ADDON_LOADED" and name == ADDON_NAME then
    ensureDB()
    ensureCharDB()
    createUhccZoneRestrictionOverlay()
    createMainWindow()
    createMinimapButton()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
  elseif event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(1.25, uhccScheduleOnboardingIfNeeded)
  end
end)
