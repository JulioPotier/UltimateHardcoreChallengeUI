local ADDON_NAME = ...

local UHCC = {}
_G.UHCC = UHCC

-- Keybind strings (shown in WoW Key Bindings UI).
_G.BINDING_HEADER_UHCC = "Ultimate Hardcore Challenge"
_G.BINDING_NAME_UHCC_TOGGLE_MAINFRAME = "Toggle UHCC window"

function _G.UHCC_ToggleMainFrame()
  if _G.UHCC and _G.UHCC.ToggleMainFrame then
    _G.UHCC:ToggleMainFrame()
  end
end

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

-- Dungeon map IDs (used for Zones & Dungeons tab + zone restriction overlay).
UHCC.DUNGEONS = {
  { 2437, "Ragefire Chasm" },
  { 718, "Wailing Caverns" },
  { 1581, "The Deadmines" },
  { 209, "Shadowfang Keep" },
  { 717, "The Stockade" },
  { 719, "Blackfathom Deeps" },
  { 721, "Gnomeregan" },
  { 491, "Razorfen Kraul" },
  { 796, "Scarlet Monastery" },
  { 722, "Razorfen Downs" },
  { 1337, "Uldaman" },
  { 1176, "Zul'Farrak" },
  { 2100, "Maraudon" },
  { 1477, "The Temple of Atal'Hakkar" },
  { 1584, "Blackrock Depths" },
  { 1583, "Blackrock Spire" },
  { 2057, "Scholomance" },
  { 2017, "Stratholme" },
  { 2557, "Dire Maul" },
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
    { checkboxId = "TALENT-POINTS", label = "Talent points", cost = 100, category = "talents", term = "points", tab = "professions_talents", inputType = "range", min = 0, max = 50, step = 1, minPlayerLevel = 10 },

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
    {
      checkboxId = "SETTINGS-BANKNAME",
      label = "Bank name",
      description = "Allowed mailbox recipient when Mail is locked (temporarily suppresses the warning if you mail to this name).",
      cost = 0,
      category = "settings",
      term = "bank_name",
      tab = "settings",
      inputType = "text",
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

    -- Dungeons: column 3 (under Battlegrounds)
    for _, d in ipairs(UHCC.DUNGEONS) do
      t[#t + 1] = {
        checkboxId = ("DUNGEON-%d"):format(d[1]),
        label = d[2],
        cost = ZONE_OPTION_COST,
        category = "dungeons",
        term = tostring(d[1]),
        tab = "zones_dungeons",
        inputType = "checkbox",
      }
    end
  end

  return t
end)()

-- checkboxId → option lookup
local UHCC_OPTION_BY_ID = {}
do
  for _, opt in ipairs(UHCC.OPTIONS) do
    if opt and opt.checkboxId then
      UHCC_OPTION_BY_ID[opt.checkboxId] = opt
    end
  end
end

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
  -- Starting zones must be free per-character to avoid immediate darkness overlay.
  if opt.tab == "zones_dungeons" and opt.inputType == "checkbox" then
    local raceName, raceFile, raceId = UnitRace and UnitRace("player")
    local rf = raceFile and string.lower(tostring(raceFile)) or nil
    local rn = raceName and string.lower(tostring(raceName)) or nil
    local RACE_STARTING_ZONE_MAP_ID = {
      human = 1429, -- Elwynn Forest
      dwarf = 1426, -- Dun Morogh
      gnome = 1426, -- Dun Morogh
      nightelf = 1438, -- Teldrassil
      orc = 1411, -- Durotar
      troll = 1411, -- Durotar
      tauren = 1412, -- Mulgore
      scourge = 1420, -- Tirisfal Glades (Undead)
      undead = 1420, -- some clients may return "Undead"
      -- frFR (just in case raceFile isn't stable on Classic)
      ["humain"] = 1429,
      ["nain"] = 1426,
      ["gnome"] = 1426,
      ["elfe de la nuit"] = 1438,
      ["orc"] = 1411,
      ["troll"] = 1411,
      ["tauren"] = 1412,
      ["mort-vivant"] = 1420,
    }
    local startMid = nil
    if type(raceId) == "number" then
      local RACE_ID_STARTING_ZONE_MAP_ID = {
        [1] = 1429, -- Human
        [3] = 1426, -- Dwarf
        [7] = 1426, -- Gnome
        [4] = 1438, -- Night Elf
        [2] = 1411, -- Orc
        [8] = 1411, -- Troll
        [6] = 1412, -- Tauren
        [5] = 1420, -- Undead
      }
      startMid = RACE_ID_STARTING_ZONE_MAP_ID[raceId]
    end
    if not startMid then
      startMid = (rf and RACE_STARTING_ZONE_MAP_ID[rf]) or (rn and RACE_STARTING_ZONE_MAP_ID[rn]) or nil
    end
    if startMid then
      local mid = tonumber(opt.term)
      if mid and mid == startMid then
        return true
      end
    end
  end
  return opt.isFree
end

local function uhccGetDisplayCostForOption(opt)
  -- Starting zone purchases are treated as free for this character (locked).
  if optionLocksFreeChoice(opt) and opt and opt.tab == "zones_dungeons" and opt.inputType == "checkbox" then
    return 0
  end
  return (opt and opt.cost) or 0
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

-- Weapon types per class (Classic Era). We only care about the weapon "terms" we expose as purchases.
-- Terms used by UHCC.OPTIONS (weapons): one_handed, two_handed, daggers, bows, guns, crossbows, throwing.
local CLASS_WEAPON_ALLOWED = {
  WARRIOR = { one_handed = true, two_handed = true, daggers = true, bows = true, guns = true, crossbows = true, throwing = true },
  PALADIN = { one_handed = true, two_handed = true, daggers = false, bows = false, guns = false, crossbows = false, throwing = false },
  DEATHKNIGHT = { one_handed = true, two_handed = true, daggers = true, bows = false, guns = false, crossbows = false, throwing = false },
  HUNTER = { one_handed = true, two_handed = true, daggers = true, bows = true, guns = true, crossbows = true, throwing = true },
  ROGUE = { one_handed = true, two_handed = false, daggers = true, bows = true, guns = true, crossbows = true, throwing = true },
  PRIEST = { one_handed = true, two_handed = true, daggers = true, bows = false, guns = false, crossbows = false, throwing = false },
  SHAMAN = { one_handed = true, two_handed = true, daggers = true, bows = false, guns = false, crossbows = false, throwing = false },
  MAGE = { one_handed = true, two_handed = true, daggers = true, bows = false, guns = false, crossbows = false, throwing = false },
  WARLOCK = { one_handed = true, two_handed = true, daggers = true, bows = false, guns = false, crossbows = false, throwing = false },
  DRUID = { one_handed = true, two_handed = true, daggers = true, bows = false, guns = false, crossbows = false, throwing = false },
}

local function playerCanUseGearArmorTerm(term)
  if term == "none" or term == nil or term == "" then return true end
  local _, classFile = UnitClass("player")
  if not classFile then return true end
  local allowed = CLASS_ARMOR_ALLOWED[classFile]
  if not allowed then return true end
  return not not allowed[term]
end

local function playerCanUseWeaponTerm(term)
  if term == "none" or term == nil or term == "" then return true end
  local _, classFile = UnitClass("player")
  if not classFile then return true end
  local allowed = CLASS_WEAPON_ALLOWED[classFile]
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

local function isWeaponPurchaseOption(opt)
  return opt
    and opt.tab == "weapons_services"
    and opt.category == "weapons"
    and opt.inputType == "checkbox"
    and opt.term
    and opt.term ~= "none"
end

local function pruneInvalidGearArmorSelections()
  ensureCharDB()
  for _, opt in ipairs(UHCC.OPTIONS) do
    if isGearArmorTierOption(opt) and not playerCanUseGearArmorTerm(opt.term) then
      -- Only prune if the player previously saved a selection.
      -- Writing defaults here would make `options` non-empty and break "virgin" onboarding detection.
      if UHCC_CharDB.options and UHCC_CharDB.options[opt.checkboxId] ~= nil then
        UHCC_CharDB.options[opt.checkboxId] = false
      end
    end
  end
end

local function pruneInvalidWeaponSelections()
  ensureCharDB()
  for _, opt in ipairs(UHCC.OPTIONS) do
    if isWeaponPurchaseOption(opt) and not playerCanUseWeaponTerm(opt.term) then
      -- Same onboarding constraint: don't write defaults into a virgin options table.
      if UHCC_CharDB.options and UHCC_CharDB.options[opt.checkboxId] ~= nil then
        UHCC_CharDB.options[opt.checkboxId] = false
      end
    end
  end
end

local function uhccPlayerIsSelfFound()
  -- Classic Hardcore Self-Found shows as a player aura (e.g. "Self-Found Adventurer").
  -- We keep this detection tolerant to localization/wording changes by checking common fragments.
  if not UnitAura then return false end
  for i = 1, 80 do
    local name = UnitAura("player", i, "HELPFUL")
    if not name then break end
    if
      name == "Self-Found Adventurer"
      or name == "Self-Found"
      or name == "Self Found"
      or name == "Iron Will"
    then
      return true
    end
    if type(name) == "string" then
      local low = string.lower(name)
      if string.find(low, "self%-found", 1, true) or string.find(low, "self found", 1, true) then
        return true
      end
      if string.find(low, "iron will", 1, true) then
        return true
      end
    end
  end
  return false
end

local function uhccOptionDeniedInSelfFound(opt)
  return opt
    and opt.tab == "weapons_services"
    and opt.inputType == "checkbox"
    and (opt.checkboxId == "SERVICE-AH" or opt.checkboxId == "SERVICE-TRADING")
    and uhccPlayerIsSelfFound()
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
  if optionLocksFreeChoice(opt) then
    return true
  end
  if uhccOptionDeniedInSelfFound(opt) then
    return false
  end
  if isGearArmorTierOption(opt) and not playerCanUseGearArmorTerm(opt.term) then
    return false
  end
  local v = UHCC_CharDB.options[opt.checkboxId]
  if v == nil then return false end
  return not not v
end

local function uhccIsPurchasedById(checkboxId)
  local opt = checkboxId and UHCC_OPTION_BY_ID[checkboxId] or nil
  if not opt then return false end
  return getCharCheckboxState(opt)
end

local function uhccIsAnyPurchasedById(ids)
  if type(ids) ~= "table" then return false end
  for _, id in ipairs(ids) do
    if uhccIsPurchasedById(id) then return true end
  end
  return false
end

local function uhccAnnoyEnabled()
  ensureCharDB()
  return UHCC_CharDB.options and UHCC_CharDB.options["SETTINGS-ANNOY"] == true
end

local function uhccIsOptionCheckedById(id)
  local opt = id and UHCC_OPTION_BY_ID[id] or nil
  if not opt then return false end
  return getCharCheckboxState(opt)
end

local function uhccNormalizeNameForCompare(s)
  s = tostring(s or "")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  if s == "" then return "" end
  return string.lower(s)
end

local function uhccGetBankNameSetting()
  ensureCharDB()
  local v = UHCC_CharDB.options and UHCC_CharDB.options["SETTINGS-BANKNAME"]
  return tostring(v or "")
end

local function uhccCountUnlockedPrimaryProfSlots()
  local n = 0
  if uhccIsOptionCheckedById("PROF-PRIMARY1") then n = n + 1 end
  if uhccIsOptionCheckedById("PROF-PRIMARY2") then n = n + 1 end
  return n
end

local function uhccCountUnlockedSecondaryProfSlots()
  local n = 0
  if uhccIsOptionCheckedById("PROF-SECONDARY1") then n = n + 1 end
  if uhccIsOptionCheckedById("PROF-SECONDARY2") then n = n + 1 end
  if uhccIsOptionCheckedById("PROF-SECONDARY3") then n = n + 1 end
  return n
end

local function uhccGetKnownProfessionNames()
  local names = {}
  if GetProfessions and GetProfessionInfo then
    local p1, p2, a, f, c = GetProfessions()
    local ids = { p1, p2, a, f, c }
    for _, pid in ipairs(ids) do
      if pid then
        local name = GetProfessionInfo(pid)
        if name and name ~= "" then
          names[name] = true
        end
      end
    end
  end

  -- Fallback for Classic builds where GetProfessions doesn't populate early (or at all):
  -- scan the Skill list (GetNumSkillLines / GetSkillLineInfo).
  if next(names) == nil and GetNumSkillLines and GetSkillLineInfo then
    local profSet = {
      -- Primary
      Alchemy = true, Blacksmithing = true, Enchanting = true, Engineering = true, Herbalism = true,
      Leatherworking = true, Mining = true, Skinning = true, Tailoring = true,
      -- Secondary
      Cooking = true, Fishing = true, ["First Aid"] = true,
    }
    for i = 1, GetNumSkillLines() do
      local name, isHeader, _, rank = GetSkillLineInfo(i)
      if (not isHeader) and name and profSet[name] and (tonumber(rank) or 0) > 0 then
        names[name] = true
      end
    end
  end
  return names
end

local function uhccCountKnownPrimaryProfessions()
  if GetProfessions then
    local p1, p2 = GetProfessions()
    local n = 0
    if p1 then n = n + 1 end
    if p2 then n = n + 1 end
    if n > 0 then return n end
  end

  if GetNumSkillLines and GetSkillLineInfo then
    local profSet = {
      Alchemy = true, Blacksmithing = true, Enchanting = true, Engineering = true, Herbalism = true,
      Leatherworking = true, Mining = true, Skinning = true, Tailoring = true,
    }
    local n = 0
    for i = 1, GetNumSkillLines() do
      local name, isHeader, _, rank = GetSkillLineInfo(i)
      if (not isHeader) and name and profSet[name] and (tonumber(rank) or 0) > 0 then
        n = n + 1
      end
    end
    return n
  end

  return 0
end

local function uhccCountKnownSecondaryProfessions()
  if GetProfessions then
    local _, _, a, f, c = GetProfessions()
    local n = 0
    if a then n = n + 1 end
    if f then n = n + 1 end
    if c then n = n + 1 end
    if n > 0 then return n end
  end

  if GetNumSkillLines and GetSkillLineInfo then
    local sec = { Cooking = true, Fishing = true, ["First Aid"] = true }
    local n = 0
    for i = 1, GetNumSkillLines() do
      local name, isHeader, _, rank = GetSkillLineInfo(i)
      if (not isHeader) and name and sec[name] and (tonumber(rank) or 0) > 0 then
        n = n + 1
      end
    end
    return n
  end

  return 0
end

local function uhccProfessionIsSecondaryByName(name)
  if not name or name == "" then return false end
  local sec = {
    ["Cooking"] = true,
    ["Fishing"] = true,
    ["First Aid"] = true,
  }
  return sec[name] == true
end

local function uhccNormalizeTrainerProfessionToken(token)
  token = tostring(token or "")
  token = token:gsub("^%s+", ""):gsub("%s+$", "")
  token = token:gsub("%s+Training$", "")
  -- Remove WoW formatting (colors/textures) that can appear in service texts.
  token = token:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  token = token:gsub("|T.-|t", "")
  token = token:gsub("^%s+", ""):gsub("%s+$", "")
  if token == "" then return nil end

  -- Trainer services often use profession nouns (e.g. "Apprentice Herbalist") instead of the spellbook name.
  local map = {
    Herbalist = "Herbalism",
    Miner = "Mining",
    Skinner = "Skinning",
    Tailor = "Tailoring",
    Engineer = "Engineering",
    Alchemist = "Alchemy",
    Enchanter = "Enchanting",
    Blacksmith = "Blacksmithing",
    Leatherworker = "Leatherworking",
    Cook = "Cooking",
    Fisherman = "Fishing",
  }
  if map[token] then return map[token] end

  -- Contained match fallback (some clients add extra words).
  for k, v in pairs(map) do
    if string.find(token, k, 1, true) then
      return v
    end
  end

  -- Already canonical?
  local canon = {
    "Alchemy", "Blacksmithing", "Enchanting", "Engineering", "Herbalism", "Leatherworking",
    "Mining", "Skinning", "Tailoring", "Cooking", "Fishing", "First Aid",
  }
  for _, p in ipairs(canon) do
    if token == p then return p end
  end

  return nil
end

local function uhccGetGossipOptionsList()
  local out = {}
  if C_GossipInfo and C_GossipInfo.GetOptions then
    local opts = C_GossipInfo.GetOptions()
    if type(opts) == "table" then
      for _, o in ipairs(opts) do
        local text = o and (o.name or o.text)
        local otype = o and (o.type or o.optionType)
        if type(text) == "string" and type(otype) == "string" then
          out[#out + 1] = { text = text, type = otype }
        end
      end
      return out
    end
  end
  -- Fallback for Classic builds where C_GossipInfo.GetOptions() returns {}:
  -- read the visible GossipTitleButton<i> texts.
  if GossipFrame and GossipFrame:IsShown() then
    for i = 1, 32 do
      local b = _G["GossipTitleButton" .. i]
      if not b then break end
      if b:IsShown() and b.GetText then
        local t = b:GetText()
        if type(t) == "string" and t ~= "" then
          out[#out + 1] = { text = t, type = "gossip" }
        end
      end
    end
  end
  return out
end

-- Forward declaration (used by profession gating).
local uhccPushExtraWarning

local function uhccCheckProfessionGateForName(profName)
  if not uhccAnnoyEnabled() then return end
  if not profName or profName == "" then return end

  local known = uhccGetKnownProfessionNames()
  if known[profName] then return end

  local isSecondary = uhccProfessionIsSecondaryByName(profName)
  if isSecondary then
    local knownSec = uhccCountKnownSecondaryProfessions()
    local unlockedSec = uhccCountUnlockedSecondaryProfSlots()
    if knownSec >= unlockedSec then
      local need = math.min(knownSec + 1, 3)
      local msg = (need == 1) and "Buy Secondary Profession 1 first"
        or (need == 2) and "Buy Secondary Profession 2 first"
        or "Buy Secondary Profession 3 first"
      uhccPushExtraWarning(("You should not learn %s yet. %s."):format(profName, msg))
    end
  else
    local knownPri = uhccCountKnownPrimaryProfessions()
    local unlockedPri = uhccCountUnlockedPrimaryProfSlots()
    if knownPri >= unlockedPri then
      local need = math.min(knownPri + 1, 2)
      local msg = (need == 1) and "Buy Primary Profession 1 first" or "Buy Primary Profession 2 first"
      uhccPushExtraWarning(("You should not learn %s yet. %s."):format(profName, msg))
    end
  end
end

-- Extra warnings (merged into the same red flash overlay).
local uhccExtraWarningMessages = {}
local uhccExtraWarningExpireAt = 0
local uhccTrainerWindowOpen = false
uhccPushExtraWarning = function(msg)
  if not msg or msg == "" then return end
  -- De-dupe identical warnings to avoid repeated flashing loops from retries/updates.
  for _, m in ipairs(uhccExtraWarningMessages) do
    if m == msg then
      return
    end
  end
  uhccExtraWarningMessages[#uhccExtraWarningMessages + 1] = msg
  local now = (GetTime and GetTime() or 0)
  -- If a trainer window is open, keep the warning visible until the window closes.
  uhccExtraWarningExpireAt = (uhccTrainerWindowOpen and (now + 3600)) or (now + 3.0)
end

-- Bag item highlighting (default Blizzard bags only): tint items red if not permitted by purchases.
-- Darker red (less pink).
local UHCC_BAG_FORBIDDEN_COLOR = { 1, 0.05, 0.05, 0.45 }

local function uhccUnlockedBagRanksCount()
  local n = 0
  if uhccIsPurchasedById("BAGS-BAG1") then n = n + 1 end
  if uhccIsPurchasedById("BAGS-BAG2") then n = n + 1 end
  if uhccIsPurchasedById("BAGS-BAG3") then n = n + 1 end
  if uhccIsPurchasedById("BAGS-BAG4") then n = n + 1 end
  return n
end

local function uhccEquippedBagCount()
  if not GetInventoryItemLink then return 0 end
  local c = 0
  for rank = 1, 4 do
    local slot = 19 + rank
    if GetInventorySlotInfo then
      local s2 = GetInventorySlotInfo(("Bag%dSlot"):format(rank - 1))
      if type(s2) == "number" and s2 > 0 then slot = s2 end
    end

    local link = GetInventoryItemLink("player", slot)
    if link and link ~= "" then
      c = c + 1
    else
      -- Some Classic builds can return nil links for equipped bags; ID is more reliable for counting.
      local id = GetInventoryItemID and GetInventoryItemID("player", slot) or nil
      if id then c = c + 1 end
    end
  end
  return c
end

local function uhccEmptyUnlockedBagSlotsCount()
  local unlocked = uhccUnlockedBagRanksCount()
  if unlocked <= 0 then return 0 end
  local empty = 0
  for rank = 1, unlocked do
    local slot = 19 + rank -- 20..23
    if GetInventorySlotInfo then
      local s2 = GetInventorySlotInfo(("Bag%dSlot"):format(rank - 1))
      if type(s2) == "number" and s2 > 0 then slot = s2 end
    end
    local id = GetInventoryItemID and GetInventoryItemID("player", slot) or nil
    local link = GetInventoryItemLink and GetInventoryItemLink("player", slot) or nil
    if (not id) and (not link or link == "") then
      empty = empty + 1
    end
  end
  return empty
end

local function uhccNextMissingBagRankMessage(nextRank)
  if nextRank == 1 then return "Buy Bag 1 first" end
  if nextRank == 2 then return "Buy Bag 2 first" end
  if nextRank == 3 then return "Buy Bag 3 first" end
  if nextRank == 4 then return "Buy Bag 4 first" end
  return "Buy the next Bag slot first"
end

local function uhccItemIsAllowedByPurchases(itemLink)
  if not itemLink or itemLink == "" then
    return true, nil
  end

  local reasons = {}
  local function addReason(r)
    if r and r ~= "" then reasons[#reasons + 1] = r end
  end

  local equipLoc, classID, subclassID
  if GetItemInfoInstant then
    local _, _, _, iloc, _, cid, scid = GetItemInfoInstant(itemLink)
    equipLoc, classID, subclassID = iloc, cid, scid
  end

  local itemType, itemSubType, itemRarity
  if GetItemInfo then
    local _, _, rarity, _, _, it, ist, iloc = GetItemInfo(itemLink)
    itemRarity = rarity
    itemType, itemSubType, equipLoc = it, ist, equipLoc or iloc
    -- If item info isn't cached yet, don't flag it; we'll refresh on GET_ITEM_INFO_RECEIVED.
    if not itemType and not classID then
      return true, nil
    end
  end

  -- Only consider items that can go in a player equipment slot (or ammo/projectiles).
  -- This excludes consumables, quest items, crafting mats, etc. even if they are "white".
  local function isRelevantEquippable()
    if classID == 1 or classID == 2 or classID == 4 or classID == 6 then return true end -- container/weapon/armor/projectile
    if itemType == (ITEM_CLASS_WEAPON or "Weapon") then return true end
    if itemType == (ITEM_CLASS_ARMOR or "Armor") then return true end
    if itemType == (ITEM_CLASS_CONTAINER or "Container") then return true end
    if itemType == (ITEM_CLASS_PROJECTILE or "Projectile") then return true end
    if equipLoc == "INVTYPE_CLOAK"
      or equipLoc == "INVTYPE_NECK"
      or equipLoc == "INVTYPE_FINGER"
      or equipLoc == "INVTYPE_TRINKET"
      or equipLoc == "INVTYPE_BAG"
      or equipLoc == "INVTYPE_SHIELD"
      or equipLoc == "INVTYPE_2HWEAPON"
      or equipLoc == "INVTYPE_WEAPON"
      or equipLoc == "INVTYPE_WEAPONMAINHAND"
      or equipLoc == "INVTYPE_WEAPONOFFHAND"
      or equipLoc == "INVTYPE_RANGED"
      or equipLoc == "INVTYPE_RANGEDRIGHT"
    then
      return true
    end
    if IsEquippableItem then
      return IsEquippableItem(itemLink) == true
    end
    return false
  end

  if not isRelevantEquippable() then
    return true, nil
  end

  -- "Wear Quest Gear" proxy: any equippable Bind-on-Equip item is treated as Quest Gear.
  -- (We can't reliably detect actual quest rewards; BoE is a broad, enforceable proxy.)
  do
    local isContainer = (equipLoc == "INVTYPE_BAG" or classID == 1 or itemType == (ITEM_CLASS_CONTAINER or "Container"))
    local isProjectile = (classID == 6 or itemType == (ITEM_CLASS_PROJECTILE or "Projectile"))
    if not isContainer and not isProjectile and GetItemInfo then
      local bindType = select(14, GetItemInfo(itemLink))
      if bindType == 2 then -- 2 = Binds when equipped
        if not uhccIsPurchasedById("GEAR-QUEST") then
          addReason("Buy Quest Gear first")
        end
      end
    end
  end

  local function qualityCheck()
    -- Only for equippable gear; ignore consumables/quest items.
    if not equipLoc or equipLoc == "" then return end
    if type(itemRarity) ~= "number" then return end
    local qId, label
    if itemRarity <= 0 then qId, label = "QUALITY-GREY", "Grey"
    elseif itemRarity == 1 then qId, label = "QUALITY-WHITE", "White"
    elseif itemRarity == 2 then qId, label = "QUALITY-GREEN", "Green"
    elseif itemRarity == 3 then qId, label = "QUALITY-BLUE", "Blue"
    elseif itemRarity == 4 then qId, label = "QUALITY-PURPLE", "Purple"
    else qId, label = "QUALITY-EPIC", "Epic"
    end
    if not uhccIsPurchasedById(qId) then
      addReason(("Buy %s Gear first"):format(label))
    end
  end

  local function armorWeightAllowedFromSubTypeString(subType)
    if type(subType) ~= "string" or subType == "" then return nil end
    if ITEM_SUBCLASS_ARMOR_CLOTH and subType == ITEM_SUBCLASS_ARMOR_CLOTH then return uhccIsPurchasedById("GEAR-CLOTH") end
    if ITEM_SUBCLASS_ARMOR_LEATHER and subType == ITEM_SUBCLASS_ARMOR_LEATHER then return uhccIsPurchasedById("GEAR-LEATHER") end
    if ITEM_SUBCLASS_ARMOR_MAIL and subType == ITEM_SUBCLASS_ARMOR_MAIL then return uhccIsPurchasedById("GEAR-MAIL") end
    if ITEM_SUBCLASS_ARMOR_PLATE and subType == ITEM_SUBCLASS_ARMOR_PLATE then return uhccIsPurchasedById("GEAR-PLATE") end
    return nil
  end

  local function weaponAllowedFromSubTypeString(subType)
    if type(subType) ~= "string" or subType == "" then return nil end
    if ITEM_SUBCLASS_WEAPON_DAGGER and subType == ITEM_SUBCLASS_WEAPON_DAGGER then return uhccIsPurchasedById("WEAPON-DAGGERS") end
    if ITEM_SUBCLASS_WEAPON_BOWS and subType == ITEM_SUBCLASS_WEAPON_BOWS then return uhccIsPurchasedById("WEAPON-BOWS") end
    if ITEM_SUBCLASS_WEAPON_GUNS and subType == ITEM_SUBCLASS_WEAPON_GUNS then return uhccIsPurchasedById("WEAPON-GUNS") end
    if ITEM_SUBCLASS_WEAPON_CROSSBOW and subType == ITEM_SUBCLASS_WEAPON_CROSSBOW then return uhccIsPurchasedById("WEAPON-CROSSBOWS") end
    if ITEM_SUBCLASS_WEAPON_THROWN and subType == ITEM_SUBCLASS_WEAPON_THROWN then return uhccIsPurchasedById("WEAPON-THROWING") end
    if ITEM_SUBCLASS_WEAPON_STAVES and subType == ITEM_SUBCLASS_WEAPON_STAVES then return uhccIsPurchasedById("WEAPON-TWOHAND") end
    return nil
  end

  -- Containers (bags): enforce bag ranks, and still apply quality rules.
  local isBagItem = (equipLoc == "INVTYPE_BAG" or classID == 1 or itemType == (ITEM_CLASS_CONTAINER or "Container"))
  if (not isBagItem) and IsBagItem and IsBagItem(itemLink) then
    isBagItem = true
  end

  if isBagItem then
    -- Bag items are "allowed" only if you have a free unlocked bag slot to equip them.
    -- If you already wear N bags, the next bag you can equip needs rank (N+1).
    local unlocked = uhccUnlockedBagRanksCount()
    local equipped = uhccEquippedBagCount()
    local nextRank = math.min(equipped + 1, 4)
    if unlocked < nextRank then
      addReason(uhccNextMissingBagRankMessage(nextRank))
    else
      local emptyUnlocked = uhccEmptyUnlockedBagSlotsCount()
      if emptyUnlocked <= 0 then
        addReason("No bag slots available")
      end
    end
    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end

  -- Accessories.
  if equipLoc == "INVTYPE_CLOAK" then
    if not uhccIsPurchasedById("GEAR-CLOAKS") then addReason("Buy Cloaks first") end
    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end
  if equipLoc == "INVTYPE_NECK" then
    if not uhccIsPurchasedById("GEAR-NECKLACE") then addReason("Buy Necklace first") end
    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end
  if equipLoc == "INVTYPE_FINGER" then
    if not uhccIsPurchasedById("GEAR-RINGS") then addReason("Buy Rings first") end
    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end
  if equipLoc == "INVTYPE_TRINKET" then
    if not uhccIsPurchasedById("GEAR-TRINKETS") then addReason("Buy Trinkets first") end
    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end

  -- Armor.
  if classID == 4 or itemType == (ITEM_CLASS_ARMOR or "Armor") then
    if subclassID == 1 and not uhccIsPurchasedById("GEAR-CLOTH") then addReason("Buy Cloth gear first") end
    if subclassID == 2 and not uhccIsPurchasedById("GEAR-LEATHER") then addReason("Buy Leather gear first") end
    if subclassID == 3 and not uhccIsPurchasedById("GEAR-MAIL") then addReason("Buy Mail gear first") end
    if subclassID == 4 and not uhccIsPurchasedById("GEAR-PLATE") then addReason("Buy Plate gear first") end

    if equipLoc == "INVTYPE_SHIELD" and not uhccIsPurchasedById("WEAPON-ONEHAND") then
      addReason("Buy One Handed Weapons first")
    end

    local ok = armorWeightAllowedFromSubTypeString(itemSubType)
    if ok == false and #reasons == 0 then
      addReason("Buy the required gear tier first")
    end

    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end

  -- Weapons.
  if classID == 2 or itemType == (ITEM_CLASS_WEAPON or "Weapon") then
    if subclassID == 15 and not uhccIsPurchasedById("WEAPON-DAGGERS") then addReason("Buy Daggers first") end
    if subclassID == 2 and not uhccIsPurchasedById("WEAPON-BOWS") then addReason("Buy Bows first") end
    if subclassID == 3 and not uhccIsPurchasedById("WEAPON-GUNS") then addReason("Buy Guns first") end
    if subclassID == 18 and not uhccIsPurchasedById("WEAPON-CROSSBOWS") then addReason("Buy Crossbows first") end
    if subclassID == 16 and not uhccIsPurchasedById("WEAPON-THROWING") then addReason("Buy Throwing Weapons first") end
    if subclassID == 10 and not uhccIsPurchasedById("WEAPON-TWOHAND") then addReason("Buy Two Handed Weapons first") end

    local ok = weaponAllowedFromSubTypeString(itemSubType)
    if ok == false and #reasons == 0 then
      addReason("Buy the required weapon type first")
    end

    if equipLoc == "INVTYPE_2HWEAPON" or equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" then
      if not uhccIsPurchasedById("WEAPON-TWOHAND") then addReason("Buy Two Handed Weapons first") end
    end
    if equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONMAINHAND" or equipLoc == "INVTYPE_WEAPONOFFHAND" then
      if not uhccIsPurchasedById("WEAPON-ONEHAND") then addReason("Buy One Handed Weapons first") end
    end

    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end

  -- Ammo/projectiles.
  if classID == 6 or itemType == (ITEM_CLASS_PROJECTILE or "Projectile") then
    if not uhccIsAnyPurchasedById({ "WEAPON-BOWS", "WEAPON-GUNS", "WEAPON-CROSSBOWS", "WEAPON-THROWING" }) then
      addReason("Buy a ranged weapon first")
    end
    qualityCheck()
    if #reasons == 0 then return true, nil end
    return false, reasons
  end

  qualityCheck()
  if #reasons == 0 then return true, nil end
  return false, reasons
end

local function uhccGetContainerItemLink(bag, slot)
  if C_Container and C_Container.GetContainerItemLink then
    return C_Container.GetContainerItemLink(bag, slot)
  end
  if GetContainerItemLink then
    return GetContainerItemLink(bag, slot)
  end
  return nil
end

local function uhccGetContainerNumSlotsCompat(bag)
  if C_Container and C_Container.GetContainerNumSlots then
    return C_Container.GetContainerNumSlots(bag) or 0
  end
  if GetContainerNumSlots then
    return GetContainerNumSlots(bag) or 0
  end
  return 0
end

-- Forward declaration (used by early UI hooks).
local uhccUpdateEquipViolationOverlay

-- Bank scan (persisted per-character).
local uhccBankFrameOpen = false
local uhccAuctionHouseOpen = false
local uhccTradeWindowOpen = false
local uhccMailboxOpen = false
local uhccMailHooksInstalled = false
local uhccMailRecipientHooksInstalled = false

local function uhccInstallMailFrameHooks()
  if uhccMailHooksInstalled then return end
  if not _G.MailFrame or not _G.MailFrame.HookScript then return end
  uhccMailHooksInstalled = true

  _G.MailFrame:HookScript("OnShow", function()
    uhccMailboxOpen = true
    uhccUpdateEquipViolationOverlay()
  end)
  _G.MailFrame:HookScript("OnHide", function()
    uhccMailboxOpen = false
    uhccUpdateEquipViolationOverlay()
  end)
end

local function uhccInstallMailRecipientHooks()
  if uhccMailRecipientHooksInstalled then return end
  if not _G.SendMailNameEditBox or not _G.SendMailNameEditBox.HookScript then return end
  uhccMailRecipientHooksInstalled = true

  _G.SendMailNameEditBox:HookScript("OnTextChanged", function()
    -- Re-evaluate suppression condition live.
    if uhccMailboxOpen then
      uhccUpdateEquipViolationOverlay()
    end
  end)
end

local function uhccEnsureMailHooksInstalled()
  if uhccMailHooksInstalled then return end
  if not C_Timer or not C_Timer.After then
    uhccInstallMailFrameHooks()
    uhccInstallMailRecipientHooks()
    return
  end
  local tries = 0
  local function tick()
    tries = tries + 1
    uhccInstallMailFrameHooks()
    uhccInstallMailRecipientHooks()
    if uhccMailHooksInstalled then return end
    if tries < 20 then
      C_Timer.After(0.5, tick)
    end
  end
  tick()
end

local function uhccUpdateAuctionHouseLockUI()
  -- Optional visual hint: red veil on Bid/Buyout buttons.
  local locked = uhccAnnoyEnabled() and (not uhccIsPurchasedById("SERVICE-AH"))
  local function veil(btn)
    if not btn then return end
    if not btn.UHCC_forbiddenOverlay then
      local ov = btn:CreateTexture(nil, "OVERLAY")
      ov:SetAllPoints(btn)
      ov:SetColorTexture(UHCC_BAG_FORBIDDEN_COLOR[1], UHCC_BAG_FORBIDDEN_COLOR[2], UHCC_BAG_FORBIDDEN_COLOR[3], UHCC_BAG_FORBIDDEN_COLOR[4])
      ov:Hide()
      btn.UHCC_forbiddenOverlay = ov
    end
    if locked then btn.UHCC_forbiddenOverlay:Show() else btn.UHCC_forbiddenOverlay:Hide() end
  end

  veil(_G.BrowseBuyoutButton)
  veil(_G.BrowseBidButton)
  veil(_G.BidBuyoutButton)
  veil(_G.BidBidButton)
end

local function uhccUpdateTradeLockUI()
  local locked = uhccAnnoyEnabled() and (not uhccIsPurchasedById("SERVICE-TRADING"))
  local btn = _G.TradeFrameTradeButton
  if not btn then return end
  if not btn.UHCC_forbiddenOverlay then
    local ov = btn:CreateTexture(nil, "OVERLAY")
    ov:SetAllPoints(btn)
    ov:SetColorTexture(UHCC_BAG_FORBIDDEN_COLOR[1], UHCC_BAG_FORBIDDEN_COLOR[2], UHCC_BAG_FORBIDDEN_COLOR[3], UHCC_BAG_FORBIDDEN_COLOR[4])
    ov:Hide()
    btn.UHCC_forbiddenOverlay = ov
  end
  if locked then btn.UHCC_forbiddenOverlay:Show() else btn.UHCC_forbiddenOverlay:Hide() end
end

local function uhccSetBankItemCount(count)
  ensureCharDB()
  count = tonumber(count) or 0
  if count < 0 then count = 0 end
  UHCC_CharDB.bankItemCount = count
end

local function uhccGetBankItemCount()
  ensureCharDB()
  return tonumber(UHCC_CharDB.bankItemCount) or 0
end

local function uhccScanBankItemCount()
  -- Only reliable while the bank is open.
  local total = 0

  -- Main bank container.
  local bankBagId = (type(BANK_CONTAINER) == "number") and BANK_CONTAINER or -1
  local n = uhccGetContainerNumSlotsCompat(bankBagId)
  for slot = 1, n do
    local link = uhccGetContainerItemLink(bankBagId, slot)
    if link and link ~= "" then
      total = total + 1
    end
  end

  -- Bank bags (5..11 on Classic). GetContainerNumSlots returns 0 if not purchased/available.
  for bag = 5, 11 do
    local bn = uhccGetContainerNumSlotsCompat(bag)
    if bn and bn > 0 then
      for slot = 1, bn do
        local link = uhccGetContainerItemLink(bag, slot)
        if link and link ~= "" then
          total = total + 1
        end
      end
    end
  end

  uhccSetBankItemCount(total)
  return total
end

local function uhccUpdateBagSlotButtons()
  for i = 0, 3 do
    local btn = _G["CharacterBag" .. i .. "Slot"]
    if btn then
      if not uhccAnnoyEnabled() then
        if btn.UHCC_forbiddenOverlay then btn.UHCC_forbiddenOverlay:Hide() end
        btn.UHCC_forbiddenReason = nil
      else
        local rank = i + 1
        local unlocked = uhccUnlockedBagRanksCount()
        local allowed = rank <= unlocked
        if not btn.UHCC_forbiddenOverlay then
          local ov = btn:CreateTexture(nil, "OVERLAY")
          ov:SetAllPoints(btn)
          ov:SetColorTexture(UHCC_BAG_FORBIDDEN_COLOR[1], UHCC_BAG_FORBIDDEN_COLOR[2], UHCC_BAG_FORBIDDEN_COLOR[3], UHCC_BAG_FORBIDDEN_COLOR[4])
          ov:Hide()
          btn.UHCC_forbiddenOverlay = ov
        end
        if allowed then
          btn.UHCC_forbiddenOverlay:Hide()
          btn.UHCC_forbiddenReason = nil
        else
          btn.UHCC_forbiddenOverlay:Show()
          btn.UHCC_forbiddenReason = uhccNextMissingBagRankMessage(rank)
        end
      end
    end
  end
end

-- Equipped gear violation overlay: flash red + list messages.
local uhccEquipViolationOverlayFrame = nil
local uhccEquipViolationFlashStart = nil
local uhccEquipViolationLastKey = nil
local UHCC_EQUIP_VIOLATION_BASE_ALPHA = 0.18
local UHCC_EQUIP_VIOLATION_FLASH_ALPHA = 0.28
local UHCC_EQUIP_VIOLATION_FLASH_SEC = 1.1

local function uhccGetItemNameFast(itemLink)
  if not itemLink or itemLink == "" then return nil end
  if GetItemInfo then
    local name = GetItemInfo(itemLink)
    if name and name ~= "" then return name end
  end
  return itemLink
end

local function uhccComputeEquippedViolations()
  local msgs = {}
  local keyParts = {}

  -- Equipment slots: 1..19 (shirt/tabard are 4/19 but harmless; we'll just skip if no link).
  for slot = 1, 19 do
    local link = GetInventoryItemLink and GetInventoryItemLink("player", slot) or nil
    if link and link ~= "" then
      local allowed, reasons = uhccItemIsAllowedByPurchases(link)
      if not allowed then
        local name = uhccGetItemNameFast(link) or "this item"
        local r
        if type(reasons) == "table" then
          r = table.concat(reasons, " / ")
        else
          r = reasons or "buy the required option first"
        end
        msgs[#msgs + 1] = ("You should not wear %s. %s."):format(name, r)
        keyParts[#keyParts + 1] = ("%d:%s"):format(slot, r)
      end
    end
  end

  -- Equipped bags: each bag slot requires its corresponding rank purchase.
  for rank = 1, 4 do
    local slot = 19 + rank -- 20..23
    if GetInventorySlotInfo then
      local s2 = GetInventorySlotInfo(("Bag%dSlot"):format(rank - 1))
      if type(s2) == "number" and s2 > 0 then slot = s2 end
    end
    local link = GetInventoryItemLink and GetInventoryItemLink("player", slot) or nil
    local id = GetInventoryItemID and GetInventoryItemID("player", slot) or nil
    if (link and link ~= "") or id then
      local neededId = ("BAGS-BAG%d"):format(rank)
      local reasons = {}
      if not uhccIsPurchasedById(neededId) then
        reasons[#reasons + 1] = uhccNextMissingBagRankMessage(rank)
      end
      -- Keep the same quality rules for equipped bags.
      local _, _, rarity = GetItemInfo and GetItemInfo(link or id) or nil
      if type(rarity) == "number" then
        local qId, label
        if rarity <= 0 then qId, label = "QUALITY-GREY", "Grey"
        elseif rarity == 1 then qId, label = "QUALITY-WHITE", "White"
        elseif rarity == 2 then qId, label = "QUALITY-GREEN", "Green"
        elseif rarity == 3 then qId, label = "QUALITY-BLUE", "Blue"
        elseif rarity == 4 then qId, label = "QUALITY-PURPLE", "Purple"
        else qId, label = "QUALITY-EPIC", "Epic"
        end
        if not uhccIsPurchasedById(qId) then
          reasons[#reasons + 1] = ("Buy %s Gear first"):format(label)
        end
      end

      if #reasons > 0 then
        local name = uhccGetItemNameFast(link) or ("Bag slot %d"):format(rank)
        local r = table.concat(reasons, " / ")
        msgs[#msgs + 1] = ("You should not wear %s. %s."):format(name, r)
        keyParts[#keyParts + 1] = ("%d:%s"):format(slot, r)
      end
    end
  end

  -- Bank restrictions (persisted): warn if bank was used and contains items without purchase.
  if uhccAnnoyEnabled() and (not uhccIsPurchasedById("SERVICE-BANK")) then
    local cnt = uhccGetBankItemCount()
    if uhccBankFrameOpen then
      if cnt > 0 then
        msgs[#msgs + 1] = ("You should not use the bank yet. You have %d forbidden item(s) in your bank. Buy Bank first."):format(cnt)
        keyParts[#keyParts + 1] = ("BANKOPEN:%d"):format(cnt)
      else
        msgs[#msgs + 1] = "You should not use the bank yet. Buy Bank first."
        keyParts[#keyParts + 1] = "BANKOPEN:0"
      end
    elseif cnt > 0 then
      msgs[#msgs + 1] = ("You have %d forbidden item(s) in your bank. Buy Bank first."):format(cnt)
      keyParts[#keyParts + 1] = ("BANK:%d"):format(cnt)
    end
  end

  -- Professions restrictions (persisted/live): if you already know more professions than you unlocked, warn.
  if uhccAnnoyEnabled() then
    local knownPri = uhccCountKnownPrimaryProfessions()
    local unlockedPri = uhccCountUnlockedPrimaryProfSlots()
    if knownPri > unlockedPri then
      msgs[#msgs + 1] = ("You have %d primary profession(s) but only unlocked %d. Buy Primary Profession %d first."):format(
        knownPri,
        unlockedPri,
        math.min(knownPri, 2)
      )
      keyParts[#keyParts + 1] = ("PROFPRI:%d:%d"):format(knownPri, unlockedPri)
    end

    local knownSec = uhccCountKnownSecondaryProfessions()
    local unlockedSec = uhccCountUnlockedSecondaryProfSlots()
    if knownSec > unlockedSec then
      msgs[#msgs + 1] = ("You have %d secondary profession(s) but only unlocked %d. Buy Secondary Profession %d first."):format(
        knownSec,
        unlockedSec,
        math.min(knownSec, 3)
      )
      keyParts[#keyParts + 1] = ("PROFSEC:%d:%d"):format(knownSec, unlockedSec)
    end
  end

  -- Auction House restriction: warn while AH is open without purchase.
  if uhccAnnoyEnabled() and uhccAuctionHouseOpen and (not uhccIsPurchasedById("SERVICE-AH")) then
    msgs[#msgs + 1] = "You should not use the Auction House yet. Buy Auction House first."
    keyParts[#keyParts + 1] = "AHOPEN"
  end

  -- Trading restriction: warn while Trade window is open without purchase.
  if uhccAnnoyEnabled() and uhccTradeWindowOpen and (not uhccIsPurchasedById("SERVICE-TRADING")) then
    msgs[#msgs + 1] = "You should not trade yet. Buy Trading first."
    keyParts[#keyParts + 1] = "TRADEOPEN"
  end

  -- Mail restriction: warn while mailbox is open without purchase.
  if uhccAnnoyEnabled() and uhccMailboxOpen and (not uhccIsPurchasedById("SERVICE-MAIL")) then
    local recipient = nil
    if SendMailNameEditBox and SendMailNameEditBox.GetText then
      recipient = SendMailNameEditBox:GetText()
    end
    local allow = uhccGetBankNameSetting()
    local rlow = uhccNormalizeNameForCompare(recipient)
    local alow = uhccNormalizeNameForCompare(allow)
    -- Suppress the flash/message if recipient matches the allowed bank name (case-insensitive).
    if alow ~= "" and rlow == alow then
      keyParts[#keyParts + 1] = "MAILOPEN_SUPPRESSED"
    else
      msgs[#msgs + 1] = "You should not use the mailbox yet. Buy Mail first."
      keyParts[#keyParts + 1] = "MAILOPEN:" .. rlow
    end
  end

  -- Merge short-lived extra warnings (e.g. professions gating).
  local now = GetTime and GetTime() or 0
  if uhccExtraWarningExpireAt and now <= (uhccExtraWarningExpireAt or 0) then
    for _, m in ipairs(uhccExtraWarningMessages) do
      msgs[#msgs + 1] = m
      keyParts[#keyParts + 1] = "W:" .. m
    end
  else
    uhccExtraWarningMessages = {}
    uhccExtraWarningExpireAt = 0
  end

  return msgs, table.concat(keyParts, "|")
end

uhccUpdateEquipViolationOverlay = function()
  if not uhccEquipViolationOverlayFrame then return end
  local f = uhccEquipViolationOverlayFrame

  if not uhccAnnoyEnabled() then
    uhccEquipViolationFlashStart = nil
    uhccEquipViolationLastKey = nil
    f:Hide()
    return
  end

  local msgs, key = uhccComputeEquippedViolations()
  local now = GetTime and GetTime() or 0

  if #msgs == 0 then
    uhccEquipViolationFlashStart = nil
    uhccEquipViolationLastKey = nil
    f:Hide()
    return
  end

  if key ~= uhccEquipViolationLastKey then
    uhccEquipViolationLastKey = key
    uhccEquipViolationFlashStart = now
  end

  -- Layout messages (stacked).
  for i = 1, math.max(#msgs, #(f.lines or {})) do
    if i <= #msgs then
      local fs = f.lines[i]
      if not fs then
        fs = f:CreateFontString(nil, "OVERLAY")
        fs:SetFontObject("GameFontNormalHuge")
        fs:SetJustifyH("CENTER")
        fs:SetTextColor(1, 0.1, 0.1, 1)
        fs:SetShadowOffset(2, -2)
        fs:SetShadowColor(0, 0, 0, 1)
        fs:SetWordWrap(true)
        f.lines[i] = fs
      end
      local w = math.min(950, (GetScreenWidth and GetScreenWidth() or UIParent:GetWidth()) * 0.9)
      fs:ClearAllPoints()
      fs:SetPoint("CENTER", 0, 30 - (i - 1) * 30)
      fs:SetWidth(w)
      fs:SetText(msgs[i])
      fs:Show()
    else
      if f.lines[i] then f.lines[i]:Hide() end
    end
  end

  -- Flash effect: base red tint + a pulse on change.
  local alpha = UHCC_EQUIP_VIOLATION_BASE_ALPHA
  if uhccEquipViolationFlashStart and now then
    local t = now - uhccEquipViolationFlashStart
    if t < 0 then t = 0 end
    if t <= UHCC_EQUIP_VIOLATION_FLASH_SEC then
      -- Quick pulse (triangle wave).
      local p = 1 - math.abs((t / UHCC_EQUIP_VIOLATION_FLASH_SEC) * 2 - 1)
      alpha = alpha + UHCC_EQUIP_VIOLATION_FLASH_ALPHA * p
    end
  end

  f.bg:SetAlpha(alpha)
  if not f:IsShown() then f:Show() end
end

local function createUhccEquipViolationOverlay()
  if uhccEquipViolationOverlayFrame then return end
  local f = CreateFrame("Frame", "UHCC_EquipViolationOverlay", UIParent)
  f:SetFrameStrata("FULLSCREEN")
  f:SetFrameLevel(5001)
  f:SetAllPoints(UIParent)
  f:EnableMouse(false)
  f:EnableKeyboard(false)

  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(1, 0, 0, 1)
  bg:SetAlpha(0)
  f.bg = bg

  f.lines = {}

  f:SetScript("OnUpdate", function()
    uhccUpdateEquipViolationOverlay()
  end)

  uhccEquipViolationOverlayFrame = f
  f:Hide()
end

local function uhccUpdateBagButtonHighlight(button)
  if not button or not button.GetID or not button.GetParent then return end
  local parent = button:GetParent()
  if not parent or not parent.GetID then return end
  local bag = parent:GetID()
  local slot = button:GetID()
  if type(bag) ~= "number" or type(slot) ~= "number" then return end

  local link = uhccGetContainerItemLink(bag, slot)
  if not uhccAnnoyEnabled() then
    if button.UHCC_forbiddenOverlay then button.UHCC_forbiddenOverlay:Hide() end
    button.UHCC_forbiddenReason = nil
    button.UHCC_forbiddenReasons = nil
    return
  end
  local allowed, reasons = uhccItemIsAllowedByPurchases(link)

  local icon = button.icon
    or button.IconTexture
    or button.Icon
    or (button.Icon and button.Icon)
    or (button.GetName and _G[button:GetName() .. "IconTexture"])

  if not button.UHCC_forbiddenOverlay then
    local ov = button:CreateTexture(nil, "OVERLAY")
    -- Prefer icon bounds (cleaner); fallback to the whole button if icon region differs.
    ov:SetAllPoints(icon or button)
    ov:SetColorTexture(UHCC_BAG_FORBIDDEN_COLOR[1], UHCC_BAG_FORBIDDEN_COLOR[2], UHCC_BAG_FORBIDDEN_COLOR[3], UHCC_BAG_FORBIDDEN_COLOR[4])
    ov:Hide()
    button.UHCC_forbiddenOverlay = ov
  end

  if allowed then
    button.UHCC_forbiddenOverlay:Hide()
    button.UHCC_forbiddenReason = nil
    button.UHCC_forbiddenReasons = nil
  else
    button.UHCC_forbiddenOverlay:Show()
    button.UHCC_forbiddenReasons = (type(reasons) == "table") and reasons or { reasons or "Buy the required option first" }
    button.UHCC_forbiddenReason = button.UHCC_forbiddenReasons[1]
  end

  if not button.UHCC_tooltipHooked then
    button.UHCC_tooltipHooked = true
    -- Replace tooltip handler (HookScript is not enough: Blizzard bag scripts overwrite it after our hook).
    button.UHCC_origOnEnter = button:GetScript("OnEnter")
    button.UHCC_origOnLeave = button:GetScript("OnLeave")
    button:SetScript("OnEnter", function(self, ...)
      if self.UHCC_forbiddenReason and GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("UHCC", 1, 0.2, 0.2, 1, true)
        GameTooltip:AddLine(self.UHCC_forbiddenReason, 1, 1, 1, true)
        GameTooltip:Show()
        return
      end
      if self.UHCC_origOnEnter then
        return self.UHCC_origOnEnter(self, ...)
      end
    end)
    button:SetScript("OnLeave", function(self, ...)
      if self.UHCC_forbiddenReason and GameTooltip then
        GameTooltip:Hide()
        return
      end
      if self.UHCC_origOnLeave then
        return self.UHCC_origOnLeave(self, ...)
      end
      if GameTooltip then GameTooltip:Hide() end
    end)
  end
end

local function uhccRefreshAllBagHighlights()
  -- Update visible buttons in currently opened Blizzard container frames.
  for i = 1, 20 do
    local frame = _G["ContainerFrame" .. i]
    if frame and frame.IsShown and frame:IsShown() then
      local bagId = frame.GetID and frame:GetID() or nil
      local n = frame.size
      if type(n) ~= "number" or n <= 0 then
        if type(bagId) == "number" then
          if C_Container and C_Container.GetContainerNumSlots then
            n = C_Container.GetContainerNumSlots(bagId)
          elseif GetContainerNumSlots then
            n = GetContainerNumSlots(bagId)
          end
        end
      end
      if type(n) ~= "number" or n <= 0 then
        n = 36
      end
      for j = 1, n do
        local btn = _G["ContainerFrame" .. i .. "Item" .. j]
        if btn then
          uhccUpdateBagButtonHighlight(btn)
        end
      end
    end
  end
end

local function uhccInstallBagHighlightHooks()
  if UHCC._bagHighlightHooksInstalled then return end
  if not hooksecurefunc or not ContainerFrameItemButton_Update then return end
  UHCC._bagHighlightHooksInstalled = true

  hooksecurefunc("ContainerFrameItemButton_Update", function(button)
    uhccUpdateBagButtonHighlight(button)
  end)

  -- Replace the default Blizzard tooltip handlers for bag item buttons.
  -- (Buttons get their scripts re-assigned by Blizzard; overriding the global handlers is reliable.)
  if type(_G.ContainerFrameItemButton_OnEnter) == "function" and not UHCC._origContainerFrameItemButton_OnEnter then
    UHCC._origContainerFrameItemButton_OnEnter = _G.ContainerFrameItemButton_OnEnter
    _G.ContainerFrameItemButton_OnEnter = function(self, ...)
      if self and self.UHCC_forbiddenReason and GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("UHCC", 1, 0.2, 0.2, 1, true)
        GameTooltip:AddLine(self.UHCC_forbiddenReason, 1, 1, 1, true)
        GameTooltip:Show()
        return
      end
      return UHCC._origContainerFrameItemButton_OnEnter(self, ...)
    end
  end
  if type(_G.ContainerFrameItemButton_OnLeave) == "function" and not UHCC._origContainerFrameItemButton_OnLeave then
    UHCC._origContainerFrameItemButton_OnLeave = _G.ContainerFrameItemButton_OnLeave
    _G.ContainerFrameItemButton_OnLeave = function(self, ...)
      if self and self.UHCC_forbiddenReason and GameTooltip then
        GameTooltip:Hide()
        return
      end
      return UHCC._origContainerFrameItemButton_OnLeave(self, ...)
    end
  end
end

local function uhccInstallTooltipRewriteHook()
  if UHCC._tooltipRewriteInstalled then return end
  if not GameTooltip or not GameTooltip.HookScript then return end
  UHCC._tooltipRewriteInstalled = true
  if not hooksecurefunc then return end

  local function rewriteTooltip(tt)
    if not tt or tt ~= GameTooltip then return end
    local focus = tt.UHCC_forceFocus
    local reason = tt.UHCC_forceReason
    if not focus or not reason then return end
    local startAt = tt.UHCC_forceStartAt
    if startAt and GetTime and GetTime() < startAt then
      return
    end
    -- Only keep forcing while we're still hovering the same button.
    if GetMouseFocus and GetMouseFocus() ~= focus then
      tt.UHCC_forceFocus = nil
      tt.UHCC_forceReason = nil
      tt.UHCC_forceStartAt = nil
      return
    end
    tt:ClearLines()
    tt:SetText("UHCC", 1, 0.2, 0.2, 1, true)
    tt:AddLine(reason, 1, 1, 1, true)
    tt:Show()
  end

  GameTooltip:HookScript("OnTooltipSetItem", function(tt)
    local focus = GetMouseFocus and GetMouseFocus() or nil
    if not focus or not focus.UHCC_forbiddenReason then return end
    if tt ~= GameTooltip then return end

    -- Blizzard can update the tooltip multiple times after this hook.
    -- Store intent and force-rewrite on next frame (and keep forcing via OnUpdate).
    tt.UHCC_forceFocus = focus
    tt.UHCC_forceReason = focus.UHCC_forbiddenReason
    local delay = 0.18 -- let Blizzard finish building its tooltip first
    if GetTime then
      tt.UHCC_forceStartAt = GetTime() + delay
    end
    if C_Timer and C_Timer.After then
      C_Timer.After(delay, function() rewriteTooltip(tt) end)
      C_Timer.After(delay + 0.05, function() rewriteTooltip(tt) end)
      C_Timer.After(delay + 0.12, function() rewriteTooltip(tt) end)
    end
  end)

  GameTooltip:HookScript("OnUpdate", function(tt, elapsed)
    if not tt.UHCC_forceReason then return end
    tt.UHCC_forceAcc = (tt.UHCC_forceAcc or 0) + (elapsed or 0)
    if tt.UHCC_forceAcc < 0.05 then return end
    tt.UHCC_forceAcc = 0
    rewriteTooltip(tt)
  end)

  GameTooltip:HookScript("OnHide", function(tt)
    tt.UHCC_forceFocus = nil
    tt.UHCC_forceReason = nil
    tt.UHCC_forceAcc = nil
    tt.UHCC_forceStartAt = nil
  end)

  -- The reliable way: hook the tooltip population method Blizzard uses for bags.
  -- This runs every time Blizzard refreshes the tooltip, so our rewrite persists.
  if GameTooltip.SetBagItem and not UHCC._hookedSetBagItem then
    UHCC._hookedSetBagItem = true
    hooksecurefunc(GameTooltip, "SetBagItem", function(tt, bag, slot)
      if tt ~= GameTooltip then return end
      if not uhccAnnoyEnabled() then return end
      local link = uhccGetContainerItemLink(bag, slot)
      local allowed, reasons = uhccItemIsAllowedByPurchases(link)
      if allowed then return end
      tt:ClearLines()
      tt:SetText("UHCC", 1, 0.2, 0.2, 1, true)
      if type(reasons) == "table" then
        for _, r in ipairs(reasons) do
          tt:AddLine(r, 1, 1, 1, true)
        end
      else
        tt:AddLine(reasons or "Buy the required option first", 1, 1, 1, true)
      end
      tt:Show()
    end)
  end
end

local function uhccEnsureBagHighlightHooksInstalled()
  if UHCC._bagHighlightHooksInstalled then return end
  if not C_Timer or not C_Timer.After then
    uhccInstallBagHighlightHooks()
    uhccInstallTooltipRewriteHook()
    return
  end
  local tries = 0
  local function tick()
    tries = tries + 1
    uhccInstallBagHighlightHooks()
    uhccInstallTooltipRewriteHook()
    if UHCC._bagHighlightHooksInstalled then
      uhccRefreshAllBagHighlights()
      return
    end
    if tries < 20 then
      C_Timer.After(0.5, tick)
    end
  end
  tick()
end

local function uhccStartBagHighlightTicker()
  if UHCC._bagHighlightTicker then return end
  local f = CreateFrame("Frame")
  local acc = 0
  f:SetScript("OnUpdate", function(_, dt)
    acc = acc + (dt or 0)
    if acc < 0.5 then return end
    acc = 0
    -- If any default bag frame is visible, keep refreshing.
    for i = 1, 20 do
      local frame = _G["ContainerFrame" .. i]
      if frame and frame.IsShown and frame:IsShown() then
        uhccEnsureBagHighlightHooksInstalled()
        uhccRefreshAllBagHighlights()
        break
      end
    end
  end)
  UHCC._bagHighlightTicker = f
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
local uhccZoneRestrictionOverlayOpenButton = nil
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
  if not uhccAnnoyEnabled() then
    return false, nil
  end
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
  if not uhccAnnoyEnabled() then
    uhccZoneOverlayViolationStart = nil
    uhccZoneOverlayFadeOutStart = nil
    uhccZoneOverlayCurrentAlpha = 0
    f.uhccLastZoneLabel = nil
    f.uhccLastAlertText = nil
    if f.bg then f.bg:SetAlpha(0) end
    if f.msg then f.msg:Hide() end
    if uhccZoneRestrictionOverlayOpenButton then
      uhccZoneRestrictionOverlayOpenButton:Hide()
    end
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
    -- Raid-style alert (sound + boom) once per violation message.
    local msgText = ("You haven't purchased this zone: '%s'. Get out or purchase now."):format(f.uhccLastZoneLabel)
    if f.uhccLastAlertText ~= msgText then
      f.uhccLastAlertText = msgText
      if RaidNotice_AddMessage and RaidWarningFrame then
        local ct = (ChatTypeInfo and ChatTypeInfo["RAID_WARNING"]) or { r = 1, g = 0.1, b = 0.1 }
        RaidNotice_AddMessage(RaidWarningFrame, msgText, ct)
      end
      if PlaySound then
        pcall(PlaySound, 8959, "Master") -- RaidWarning (tolerate missing in some builds)
      end
      if f.msgBoom then
        f.msgBoom:Stop()
        f.msgBoom:Play()
      end
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
        f.uhccLastAlertText = nil
      else
        uhccZoneOverlayCurrentAlpha = uhccZoneOverlayFadeOutAlpha0 * (1 - te / UHCC_ZONE_FADE_OUT_SEC)
      end
    else
      uhccZoneOverlayFadeOutStart = nil
      uhccZoneOverlayCurrentAlpha = 0
      f.uhccLastZoneLabel = nil
      f.uhccLastAlertText = nil
    end
  end

  local a = uhccZoneOverlayCurrentAlpha
  if f.bg then
    f.bg:SetAlpha(a)
  end
  -- The "Open UHCC" button should only exist while we are actively violating a zone rule,
  -- not during the fade-out.
  if uhccZoneRestrictionOverlayOpenButton then
    if inViol then
      uhccZoneRestrictionOverlayOpenButton:Show()
    else
      uhccZoneRestrictionOverlayOpenButton:Hide()
    end
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
  -- Keep the frame shown so OnUpdate keeps running even at alpha 0.
  -- (A hidden frame stops ticking; we'd miss re-entry into a forbidden zone.)
  if not f:IsShown() then
    f:Show()
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

  -- "Boom" animation for the red message (raid-alert feel).
  local ag = msg:CreateAnimationGroup()
  ag:SetToFinalAlpha(true)
  local s1 = ag:CreateAnimation("Scale")
  s1:SetOrder(1)
  s1:SetDuration(0.12)
  s1:SetScale(1.22, 1.22)
  s1:SetSmoothing("OUT")
  local s2 = ag:CreateAnimation("Scale")
  s2:SetOrder(2)
  s2:SetDuration(0.18)
  s2:SetScale(0.82, 0.82)
  s2:SetSmoothing("IN_OUT")
  f.msgBoom = ag

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
  f:Show()

  if not uhccZoneRestrictionOverlayOpenButton then
    local btn = CreateFrame("Button", "UHCC_ZoneRestrictionOpenButton", UIParent, "UIPanelButtonTemplate")
    btn:SetFrameStrata("FULLSCREEN_DIALOG")
    btn:SetFrameLevel(6000)
    btn:SetSize(160, 24)
    btn:SetText("Open UHCC")
    btn:SetPoint("CENTER", UIParent, "CENTER", 0, -70)
    btn:SetScript("OnClick", function()
      local mf = UHCC and UHCC.ToggleMainFrame and UHCC:ToggleMainFrame() or nil
      if mf and mf.Raise then mf:Raise() end
    end)
    btn:Hide()
    uhccZoneRestrictionOverlayOpenButton = btn
  end
end

local function recalcSpentDisplay()
  local copper = computeTotalSpentCopperFromCharDB()
  local mf = UHCC.mainFrame
  if mf and mf.SetSpentCopper then
    mf:SetSpentCopper(copper)
  end
  uhccRefreshAllBagHighlights()
  uhccUpdateBagSlotButtons()
  uhccUpdateEquipViolationOverlay()
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
  -- Make sure onboarding (welcome / level tip) can run again for this character.
  UHCC_CharDB._uhccWelcomeSeen = nil
  UHCC_CharDB._uhccNonLevel1AdviceSeen = nil
  uhccOnboardingTimerScheduled = false
  if UHCC.mainFrame then
    UHCC.mainFrame:Hide()
    UHCC.mainFrame:SetParent(nil)
    UHCC.mainFrame = nil
  end
  recalcSpentDisplay()
  print("|cffffcc00UHCC|r: All character data for this addon was reset. Please reload your UI.")
  if StaticPopupDialogs and StaticPopupDialogs["UHCC_RELOAD_UI"] then
    StaticPopup_Show("UHCC_RELOAD_UI")
  end
  -- Also re-run onboarding without requiring a reload (best effort).
  if C_Timer and C_Timer.After then
    C_Timer.After(0.8, uhccScheduleOnboardingIfNeeded)
  end
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

-- Level-locked controls registry (e.g. Talent points slider locked until level 10).
UHCC.levelLockControls = UHCC.levelLockControls or {}

local function uhccRegisterLevelLock(minLvl, slider, minusBtn, plusBtn, valueText, labelFs)
  minLvl = tonumber(minLvl)
  if not minLvl or minLvl <= 0 then return end
  UHCC.levelLockControls[#UHCC.levelLockControls + 1] = {
    minLevel = minLvl,
    slider = slider,
    minusBtn = minusBtn,
    plusBtn = plusBtn,
    valueText = valueText,
    labelFs = labelFs,
  }
end

local function uhccApplyLevelLocks()
  local lvl = UnitLevel and UnitLevel("player") or 0
  lvl = tonumber(lvl) or 0
  for _, e in ipairs(UHCC.levelLockControls) do
    local ok = lvl >= (e.minLevel or 0)
    if e.slider then
      if ok then e.slider:Enable() else e.slider:Disable() end
      e.slider:SetAlpha(ok and 1 or 0.55)
    end
    if e.minusBtn then
      if ok then e.minusBtn:Enable() else e.minusBtn:Disable() end
      e.minusBtn:SetAlpha(ok and 1 or 0.55)
    end
    if e.plusBtn then
      if ok then e.plusBtn:Enable() else e.plusBtn:Disable() end
      e.plusBtn:SetAlpha(ok and 1 or 0.55)
    end
    if e.valueText and e.valueText.SetTextColor then
      if ok then e.valueText:SetTextColor(1, 1, 1, 1) else e.valueText:SetTextColor(0.7, 0.7, 0.7, 1) end
    end
    if e.labelFs and e.labelFs.SetTextColor then
      if ok then e.labelFs:SetTextColor(1, 0.82, 0, 1) else e.labelFs:SetTextColor(0.7, 0.7, 0.7, 1) end
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

      -- +/- buttons for faster selection.
      local function nstep()
        local st = tonumber(item.step) or 1
        if st <= 0 then st = 1 end
        return st
      end
      local function setSliderTo(v)
        local mn, mx = item.min or 0, item.max or 100
        v = clamp(math.floor((tonumber(v) or 0) + 0.5), mn, mx)
        slider:SetValue(v)
      end

      local minusBtn = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
      minusBtn:SetSize(22, 18)
      minusBtn:SetText("-")
      minusBtn:SetPoint("RIGHT", slider, "LEFT", -6, 0)
      minusBtn:SetScript("OnClick", function()
        local cur = slider:GetValue()
        setSliderTo(cur - nstep())
      end)

      local plusBtn = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
      plusBtn:SetSize(22, 18)
      plusBtn:SetText("+")
      plusBtn:SetPoint("LEFT", valueText, "RIGHT", 8, 0)
      plusBtn:SetScript("OnClick", function()
        local cur = slider:GetValue()
        setSliderTo(cur + nstep())
      end)

      uhccRegisterLevelLock(item.option and item.option.minPlayerLevel, slider, minusBtn, plusBtn, valueText, fs)
      uhccApplyLevelLocks()

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

      if cb.checkboxId and cb:IsEnabled() then
        cb:HookScript("OnClick", function(self)
          ensureCharDB()
          UHCC_CharDB.options[self.checkboxId] = self:GetChecked() and true or false
          -- Apply immediately (zone overlay, bag highlights + tooltips, equip flash).
          recalcSpentDisplay()
        end)
      end

      local desc = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      desc:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 28, -8)
      desc:SetWidth(math.max(200, innerScrollW - 48))
      desc:SetJustifyH("LEFT")
      desc:SetNonSpaceWrap(false)
      desc:SetText(item.description or "")

      local descH = desc:GetStringHeight() or 0
      settingsCursorY = settingsCursorY + 26 + 8 + math.max(descH, 14) + 24
    elseif item.kind == "settings_text" then
      local padX = 16
      local y = -settingsCursorY

      local label = child:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
      label:SetPoint("TOPLEFT", child, "TOPLEFT", padX, y)
      label:SetText(item.label or "")

      local eb = CreateFrame("EditBox", nil, child, "InputBoxTemplate")
      eb:SetAutoFocus(false)
      eb:SetSize(220, 20)
      eb:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
      eb:SetText(item.value or "")
      eb:SetCursorPosition(0)

      eb:HookScript("OnEditFocusLost", function(self)
        if item.option and item.option.checkboxId then
          ensureCharDB()
          UHCC_CharDB.options[item.option.checkboxId] = tostring(self:GetText() or "")
          recalcSpentDisplay()
        end
      end)
      eb:HookScript("OnEnterPressed", function(self)
        self:ClearFocus()
      end)

      local desc = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      desc:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 4, -6)
      desc:SetWidth(math.max(200, innerScrollW - 48))
      desc:SetJustifyH("LEFT")
      desc:SetNonSpaceWrap(false)
      desc:SetText(item.description or "")

      local descH = desc:GetStringHeight() or 0
      settingsCursorY = settingsCursorY + 26 + 20 + 6 + 6 + math.max(descH, 14) + 18
    elseif item.kind == "settings_info" then
      local padX = 16
      local y = -settingsCursorY
      local fs = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      fs:SetPoint("TOPLEFT", child, "TOPLEFT", padX, y)
      fs:SetWidth(math.max(200, innerScrollW - 48))
      fs:SetJustifyH("LEFT")
      fs:SetNonSpaceWrap(false)
      fs:SetText(item.text or "")
      fs:SetTextColor(0.9, 0.9, 0.9, 1)
      local h = fs:GetStringHeight() or 0
      settingsCursorY = settingsCursorY + math.max(h, 14) + 16
    elseif item.kind == "settings_button" then
      local padX = 16
      local y = -settingsCursorY

      local btn = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
      btn:SetPoint("TOPLEFT", child, "TOPLEFT", padX, y)
      btn:SetSize(140, 22)
      btn:SetText(item.label or "Button")
      btn:SetEnabled(true)

      btn:SetScript("OnClick", function()
        if item.action == "reset_character" then
          if StaticPopup_Show then
            StaticPopup_Show("UHCC_RESET_CHARACTER")
          else
            resetCharChallengeData()
          end
        end
      end)

      settingsCursorY = settingsCursorY + 22 + 18
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
  ensureCharDB()
  UHCC_CharDB.lastSelectedTabId = tabId
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
  pruneInvalidWeaponSelections()

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

  -- Fresh registry (UI is constructed once per session).
  UHCC.levelLockControls = {}

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
  do
    local saved = tonumber(UHCC_CharDB.lastSelectedTabId)
    if saved and saved >= 1 and saved <= #tabNames then
      defaultTabId = saved
    end
  end

  local function buildSpecForTab(tabKey)
    if tabKey == "settings" then
      local spec = {}
      for _, opt in ipairs(UHCC.OPTIONS) do
        if opt.tab == "settings" and opt.inputType == "checkbox" then
          local annoyOn = uhccAnnoyEnabled()
          spec[#spec + 1] = {
            kind = "settings_checkbox",
            label = (opt.label or ""),
            description = opt.description or "",
            opts = { checked = annoyOn, disabled = false },
            option = opt,
          }
        elseif opt.tab == "settings" and opt.inputType == "text" then
          ensureCharDB()
          local v = UHCC_CharDB.options[opt.checkboxId]
          if v == nil then v = "" end
          spec[#spec + 1] = {
            kind = "settings_text",
            label = (opt.label or ""),
            description = opt.description or "",
            value = tostring(v),
            option = opt,
          }
        end
      end
      spec[#spec + 1] = {
        kind = "settings_info",
        text = "Tip: A keybinding is available in Options > Keybindings > Other.",
      }
      spec[#spec + 1] = { kind = "spacer" }
      spec[#spec + 1] = {
        kind = "settings_button",
        label = "Reset",
        action = "reset_character",
      }
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
        dungeons = "Dungeons",
      }
      sectionColumns = {
        kalimdor_zones = 0,
        kalimdor_cities = 0,
        ek_zones = 1,
        ek_cities = 1,
        battlegrounds = 2,
        dungeons = 2,
      }
    end

    local lastSection = nil
    for _, opt in ipairs(UHCC.OPTIONS) do
      if opt.tab == tabKey then
        local skip = false
        -- Faction-specific dungeon display:
        -- Horde shows Ragefire Chasm; Alliance shows The Stockade (only this difference).
        if tabKey == "zones_dungeons" and opt.category == "dungeons" then
          local faction = (UnitFactionGroup and UnitFactionGroup("player")) or nil
          local mid = tonumber(opt.term)
          if faction == "Horde" and mid == 717 then
            skip = true -- hide Stockade for Horde
          elseif faction == "Alliance" and mid == 2437 then
            skip = true -- hide Ragefire for Alliance
          end
        end

        if not skip then
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
            local text = opt.label .. formatCostSilver(uhccGetDisplayCostForOption(opt))
            local armorDenied = isGearArmorTierOption(opt) and not playerCanUseGearArmorTerm(opt.term)
            local weaponDenied = isWeaponPurchaseOption(opt) and not playerCanUseWeaponTerm(opt.term)
            local selfFoundDenied = uhccOptionDeniedInSelfFound(opt)
            local chkOpts = nil
            if selfFoundDenied then
              chkOpts = { checked = false, disabled = true }
            elseif armorDenied then
              chkOpts = { checked = false, disabled = true }
            elseif weaponDenied then
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
              text = opt.label .. formatCostSilver(uhccGetDisplayCostForOption(opt)),
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
  uhccApplyLevelLocks()

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
  text = "|cffffcc00Ultimate Hardcore Challenge|r\n\n|cffffcc00Ultimate Hardcore|r mode is |cff00ff00enabled|r for this character.\n\n|cffffcc00Important:|r newly created characters start with grey gear and a weapon/shield equipped. To start the challenge properly, first move everything you are wearing into your bags.\n\nUse the minimap button to choose your rules. Good luck!",
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

StaticPopupDialogs["UHCC_RELOAD_UI"] = {
  text = "|cffffcc00UHCC|r\n\nA UI reload is required to fully apply the reset.\n\nReload now?",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
    if ReloadUI then
      ReloadUI()
    end
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
local uhccAddonFullyLoadedPrinted = false
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("UNIT_INVENTORY_CHANGED")
events:RegisterEvent("TRAINER_SHOW")
events:RegisterEvent("TRAINER_CLOSED")
events:RegisterEvent("TRAINER_UPDATE")
events:RegisterEvent("GOSSIP_SHOW")
events:RegisterEvent("GOSSIP_CLOSED")
events:RegisterEvent("BANKFRAME_OPENED")
events:RegisterEvent("BANKFRAME_CLOSED")
events:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
events:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
events:RegisterEvent("AUCTION_HOUSE_SHOW")
events:RegisterEvent("AUCTION_HOUSE_CLOSED")
events:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
events:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE")
events:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
events:RegisterEvent("TRADE_SHOW")
events:RegisterEvent("TRADE_CLOSED")
events:RegisterEvent("SKILL_LINES_CHANGED")
events:RegisterEvent("MAIL_SHOW")
events:RegisterEvent("MAIL_CLOSED")
events:SetScript("OnEvent", function(self, event, name)
  if event == "ADDON_LOADED" and name == ADDON_NAME then
    ensureDB()
    ensureCharDB()
    createUhccZoneRestrictionOverlay()
    createUhccEquipViolationOverlay()
    uhccEnsureMailHooksInstalled()
    -- Bag UI code may not be loaded yet at ADDON_LOADED; retry later.
    uhccEnsureBagHighlightHooksInstalled()
    uhccStartBagHighlightTicker()
    createMainWindow()
    createMinimapButton()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    uhccApplyLevelLocks()
  elseif event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- Verify current zone purchase status once the world is ready (C_Map can be nil/unstable on ADDON_LOADED).
    C_Timer.After(0.3, function()
      createUhccZoneRestrictionOverlay()
      createUhccEquipViolationOverlay()
      uhccEnsureBagHighlightHooksInstalled()
      uhccRefreshAllBagHighlights()
      uhccUpdateEquipViolationOverlay()
      uhccZoneRestrictionOverlayUpdate()
      if not uhccAddonFullyLoadedPrinted then
        uhccAddonFullyLoadedPrinted = true
        print("|cffffcc00UHCC|r: Addon loaded.")
      end
    end)
    C_Timer.After(1.25, uhccScheduleOnboardingIfNeeded)
  elseif event == "PLAYER_LEVEL_UP" then
    uhccApplyLevelLocks()
  elseif event == "BAG_UPDATE_DELAYED" then
    uhccEnsureBagHighlightHooksInstalled()
    uhccRefreshAllBagHighlights()
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    uhccEnsureBagHighlightHooksInstalled()
    uhccRefreshAllBagHighlights()
    uhccUpdateEquipViolationOverlay()
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    uhccUpdateEquipViolationOverlay()
    uhccUpdateBagSlotButtons()
  elseif event == "UNIT_INVENTORY_CHANGED" then
    if name == "player" then
      uhccUpdateEquipViolationOverlay()
      uhccUpdateBagSlotButtons()
    end
  elseif event == "BANKFRAME_OPENED" then
    uhccBankFrameOpen = true
    -- Scan immediately and show warning if not purchased.
    uhccScanBankItemCount()
    uhccUpdateEquipViolationOverlay()
  elseif event == "PLAYERBANKSLOTS_CHANGED" or event == "PLAYERBANKBAGSLOTS_CHANGED" then
    if uhccBankFrameOpen then
      uhccScanBankItemCount()
      uhccUpdateEquipViolationOverlay()
    end
  elseif event == "BANKFRAME_CLOSED" then
    if uhccBankFrameOpen then
      -- Final scan while still closing (best effort).
      pcall(uhccScanBankItemCount)
    end
    uhccBankFrameOpen = false
    uhccUpdateEquipViolationOverlay()
  elseif event == "AUCTION_HOUSE_SHOW" then
    uhccAuctionHouseOpen = true
    uhccUpdateAuctionHouseLockUI()
    uhccUpdateEquipViolationOverlay()
  elseif event == "AUCTION_HOUSE_CLOSED" then
    uhccAuctionHouseOpen = false
    uhccUpdateAuctionHouseLockUI()
    uhccUpdateEquipViolationOverlay()
  elseif event == "AUCTION_ITEM_LIST_UPDATE" or event == "AUCTION_BIDDER_LIST_UPDATE" or event == "AUCTION_OWNED_LIST_UPDATE" then
    if uhccAuctionHouseOpen then
      uhccUpdateAuctionHouseLockUI()
    end
  elseif event == "TRADE_SHOW" then
    uhccTradeWindowOpen = true
    uhccUpdateTradeLockUI()
    uhccUpdateEquipViolationOverlay()
  elseif event == "TRADE_CLOSED" then
    uhccTradeWindowOpen = false
    uhccUpdateTradeLockUI()
    uhccUpdateEquipViolationOverlay()
  elseif event == "SKILL_LINES_CHANGED" then
    -- Professions learned/unlearned changed; refresh persistent gating warnings.
    uhccUpdateEquipViolationOverlay()
  elseif event == "MAIL_SHOW" then
    uhccMailboxOpen = true
    uhccEnsureMailHooksInstalled()
    -- Test: if Mail isn't purchased, auto-fill recipient.
    if uhccAnnoyEnabled() and (not uhccIsPurchasedById("SERVICE-MAIL")) then
      if SendMailNameEditBox and SendMailNameEditBox.SetText then
        local bankName = uhccGetBankNameSetting()
        if bankName == "" then bankName = "aaa" end
        SendMailNameEditBox:SetText(bankName)
      end
    end
    -- MailFrame can become visible slightly after MAIL_SHOW on some clients.
    if C_Timer and C_Timer.After then
      C_Timer.After(0.1, uhccUpdateEquipViolationOverlay)
    else
      uhccUpdateEquipViolationOverlay()
    end
  elseif event == "MAIL_CLOSED" then
    uhccMailboxOpen = false
    uhccUpdateEquipViolationOverlay()
  elseif event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
    if not uhccAnnoyEnabled() then return end
    if not GetNumTrainerServices or not GetTrainerServiceInfo then return end
    uhccTrainerWindowOpen = true

    local function tryTrainerScan(_)
      local known = uhccGetKnownProfessionNames()
      local taughtProf = nil
      local n = GetNumTrainerServices()
      if not n or n <= 0 then
        return false
      end
      for i = 1, n do
        local serviceName, serviceSubText, serviceType = GetTrainerServiceInfo(i)
        local s = (serviceSubText and serviceSubText ~= "" and serviceSubText) or serviceName
        if type(s) == "string" then
          local p = s:match("^Apprentice%s+(.+)$")
            or s:match("^Journeyman%s+(.+)$")
            or s:match("^Expert%s+(.+)$")
            or s:match("^Artisan%s+(.+)$")
            or s
          if p and p ~= "" then
            if serviceType == "available" or serviceType == "unavailable" then
              local norm = uhccNormalizeTrainerProfessionToken(p)
              if norm then taughtProf = norm break end
            end
          end
        end
      end

      if not taughtProf then
        return false
      end
      if known[taughtProf] then
        return true
      end
      uhccCheckProfessionGateForName(taughtProf)
      uhccUpdateEquipViolationOverlay()
      return true
    end

    -- Trainer data is often not ready on TRAINER_SHOW; retry shortly.
    if not tryTrainerScan(event) and C_Timer and C_Timer.After then
      C_Timer.After(0.1, function() tryTrainerScan("TRAINER_RETRY_0.1") end)
      C_Timer.After(0.35, function() tryTrainerScan("TRAINER_RETRY_0.35") end)
    end
  elseif event == "TRAINER_CLOSED" then
    uhccTrainerWindowOpen = false
    uhccExtraWarningMessages = {}
    uhccExtraWarningExpireAt = 0
  elseif event == "GOSSIP_SHOW" then
    if not uhccAnnoyEnabled() then return end
    -- Some Classic builds populate C_GossipInfo options one frame later.
    local profs = {
      "Alchemy", "Blacksmithing", "Enchanting", "Engineering", "Herbalism", "Leatherworking",
      "Mining", "Skinning", "Tailoring", "Cooking", "Fishing", "First Aid",
    }
    local function tryDetect()
      local opts = uhccGetGossipOptionsList()
      if #opts == 0 then return false end
      for _, o in ipairs(opts) do
        local text = o.text
        local otype = o.type
        if type(text) == "string" and type(otype) == "string" then
          if otype == "trainer" or otype == "gossip" then
            for _, p in ipairs(profs) do
              if string.find(text, p, 1, true) then
                uhccCheckProfessionGateForName(p)
                uhccUpdateEquipViolationOverlay()
                return true
              end
            end
          end
        end
      end
      return false
    end

    if not tryDetect() and C_Timer and C_Timer.After then
      C_Timer.After(0, function()
        if tryDetect() then return end
        C_Timer.After(0.15, function()
          tryDetect()
        end)
      end)
    end
  elseif event == "GOSSIP_CLOSED" then
    uhccTrainerWindowOpen = false
    uhccExtraWarningMessages = {}
    uhccExtraWarningExpireAt = 0
  end
end)
