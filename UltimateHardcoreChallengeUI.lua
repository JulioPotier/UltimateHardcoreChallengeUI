local ADDON_NAME = ...

local UHCC = {}
_G.UHCC = UHCC

-- =========================
-- External Settings API
-- =========================
-- Other addons can inject controls into the Settings tab (intended for the right column).
UHCC.externalSettingsProviders = UHCC.externalSettingsProviders or {}
UHCC.externalSettingsProviderOrder = UHCC.externalSettingsProviderOrder or {}

-- Public: register a provider that returns Settings spec items.
-- providerFn signature:
--   providerFn() -> { { kind="checkbox"|"text"|"info"|"spacer"|"section"|"button", ... }, ... }
function UHCC:RegisterSettingsProvider(providerName, providerFn)
  if type(providerName) ~= "string" or providerName == "" then return end
  if type(providerFn) ~= "function" then return end

  if not self.externalSettingsProviders[providerName] then
    self.externalSettingsProviderOrder[#self.externalSettingsProviderOrder + 1] = providerName
  end
  self.externalSettingsProviders[providerName] = providerFn

  local f = self.mainFrame
  if f and f.UHCC_RebuildSettingsTab then
    pcall(function() f:UHCC_RebuildSettingsTab() end)
  end
end

function UHCC:UnregisterSettingsProvider(providerName)
  if type(providerName) ~= "string" or providerName == "" then return end
  if not self.externalSettingsProviders[providerName] then return end
  self.externalSettingsProviders[providerName] = nil
  for i = #self.externalSettingsProviderOrder, 1, -1 do
    if self.externalSettingsProviderOrder[i] == providerName then
      table.remove(self.externalSettingsProviderOrder, i)
    end
  end

  local f = self.mainFrame
  if f and f.UHCC_RebuildSettingsTab then
    pcall(function() f:UHCC_RebuildSettingsTab() end)
  end
end

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
    radius = 80, -- pixels from minimap center (slightly further out to hug the minimap rim)
  },
}

-- Content horizontal insets 12+12; options scroll frame edges 10+30 → inner width for 3 columns.
local MAIN_FRAME_WIDTH, MAIN_FRAME_HEIGHT = 900, 500

UHCC.TABS = {
  { tab = "gear_quality", label = "Equipment & Quality" },
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
-- Minimum player levels to enter (Classic Era).
UHCC.DUNGEON_MIN_LEVEL = {
  [2437] = 10, -- Ragefire Chasm
  [718] = 10, -- Wailing Caverns
  [1581] = 10, -- The Deadmines
  [209] = 14, -- Shadowfang Keep
  [719] = 15, -- Blackfathom Deeps
  [717] = 15, -- The Stockade
  [721] = 19, -- Gnomeregan
  [491] = 25, -- Razorfen Kraul
  [796] = 21, -- Scarlet Monastery
  [722] = 35, -- Razorfen Downs
  [1337] = 30, -- Uldaman
  [1176] = 39, -- Zul'Farrak
  [2100] = 30, -- Maraudon
  [1477] = 45, -- The Temple of Atal'Hakkar
  [1584] = 48, -- Blackrock Depths
  [1583] = 48, -- Blackrock Spire
  [2557] = 48, -- Dire Maul
  [2057] = 48, -- Scholomance
  [2017] = 48, -- Stratholme
}

-- Battleground minimum player levels (Classic Era).
UHCC.BATTLEGROUND_MIN_LEVEL = {
  [1460] = 10, -- Warsong Gulch
  [1461] = 20, -- Arathi Basin
  [1459] = 51, -- Alterac Valley
}

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
    -- Character equipment slots: order = price (free → most expensive), then quality tiers.
    -- Free: Main Hand, Off Hand | 20s: Shirt…Chest, Range weapon (if class can use ranged slot)
    -- 1g: Back, Shoulder, Head, Tabard | 5g: Neck, fingers, trinkets | 10g: Relic
    {
      checkboxId = "EQUIP-MAINHAND",
      label = "Main Hand",
      cost = 0,
      isFree = true,
      category = "equipment_slots_a",
      term = "mainhand",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-OFFHAND",
      label = "Off Hand",
      cost = 0,
      isFree = true,
      category = "equipment_slots_a",
      term = "offhand",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-SHIRT",
      label = "Shirt",
      cost = 20,
      category = "equipment_slots_a",
      term = "shirt",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-HANDS",
      label = "Hands",
      cost = 20,
      category = "equipment_slots_a",
      term = "hands",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-WRIST",
      label = "Wrist",
      cost = 20,
      category = "equipment_slots_a",
      term = "wrist",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-WAIST",
      label = "Waist",
      cost = 20,
      category = "equipment_slots_a",
      term = "waist",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-LEGS",
      label = "Legs",
      cost = 20,
      category = "equipment_slots_a",
      term = "legs",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-FEET",
      label = "Feet",
      cost = 20,
      category = "equipment_slots_a",
      term = "feet",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-CHEST",
      label = "Chest",
      cost = 20,
      category = "equipment_slots_a",
      term = "chest",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-RANGE",
      label = "Range weapon",
      cost = 20,
      category = "equipment_slots_a",
      term = "range_weapon",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-BACK",
      label = "Back",
      cost = 100,
      category = "equipment_slots_b",
      term = "back",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-SHOULDER",
      label = "Shoulder",
      cost = 100,
      category = "equipment_slots_b",
      term = "shoulder",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-HEAD",
      label = "Head",
      cost = 100,
      category = "equipment_slots_b",
      term = "head",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-TABARD",
      label = "Tabard",
      cost = 100,
      category = "equipment_slots_b",
      term = "tabard",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-NECK",
      label = "Neck",
      cost = 500,
      category = "equipment_slots_b",
      term = "neck",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-FINGER1",
      label = "Finger 1",
      cost = 500,
      category = "equipment_slots_b",
      term = "finger1",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-FINGER2",
      label = "Finger 2",
      cost = 500,
      category = "equipment_slots_b",
      term = "finger2",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-TRINKET1",
      label = "Trinket 1",
      cost = 500,
      category = "equipment_slots_b",
      term = "trinket1",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-TRINKET2",
      label = "Trinket 2",
      cost = 500,
      category = "equipment_slots_b",
      term = "trinket2",
      tab = "gear_quality",
      inputType = "checkbox",
    },
    {
      checkboxId = "EQUIP-RELIC",
      label = "Relic",
      cost = 1000,
      category = "equipment_slots_b",
      term = "relic",
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
    { checkboxId = "SERVICE-FLIGHTPATHS", label = "Flight Paths", cost = 500, category = "services", term = "flight_paths", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "SERVICE-WORLDBUFFS", label = "World Buffs", cost = 1000, category = "services", term = "world_buffs", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "SERVICE-WARLOCKSUMMON", label = "Warlock Summon", cost = 500, category = "services", term = "warlock_summon", tab = "weapons_services", inputType = "checkbox" },
    { checkboxId = "SERVICE-MAGEPORTAL", label = "Mage Portal", cost = 500, category = "services", term = "mage_portal", tab = "weapons_services", inputType = "checkbox" },

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
      description = "Try to stop you from doing forbidden actions (with extra warnings).",
      cost = 0,
      category = "settings",
      term = "annoy",
      tab = "settings",
      inputType = "checkbox",
    },
    {
      checkboxId = "SETTINGS-MONEYMGT",
      label = "Money Management",
      description = "Selections are staged until you click Purchase. This creates debt that reduces available gold until you pay your bank character.",
      cost = 0,
      category = "settings",
      term = "money_mgt",
      tab = "settings",
      inputType = "checkbox",
    },
    {
      checkboxId = "SETTINGS-BANKNAME",
      label = "Bank Name (required for Money Management)",
      description = "Allowed mailbox recipient when Mail is locked.",
      cost = 0,
      category = "settings",
      term = "bank_name",
      tab = "settings",
      inputType = "text",
    },
  }

  -- Zones & Dungeons: one checkbox per map from UHCC.WORLD_ZONES; 1 gold each (UHCC cost unit: floor(cost/100) = gold).
  -- Per continent: zones section then Cities section; Azeroth CSV rows → Battlegrounds column only.
  do
    local ZONE_OPTION_COST = 100
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

    -- Battleground ordering (requested): WSG, AB, AV.
    do
      local order = { [1460] = 1, [1461] = 2, [1459] = 3 }
      table.sort(buckets.battlegrounds, function(a, b)
        local ao = order[tonumber(a and a[1])] or 999
        local bo = order[tonumber(b and b[1])] or 999
        if ao ~= bo then return ao < bo end
        return tostring(a and a[2] or "") < tostring(b and b[2] or "")
      end)
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
        local mid = tonumber(row[1])
        local minLvl = (catKey == "battlegrounds" and mid and UHCC.BATTLEGROUND_MIN_LEVEL and UHCC.BATTLEGROUND_MIN_LEVEL[mid]) or nil
        t[#t + 1] = {
          checkboxId = ("ZONE-%d"):format(row[1]),
          label = row[2],
          cost = ZONE_OPTION_COST,
          category = catKey,
          term = tostring(row[1]),
          tab = "zones_dungeons",
          inputType = "checkbox",
          minPlayerLevel = minLvl,
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
        minPlayerLevel = (UHCC.DUNGEON_MIN_LEVEL and UHCC.DUNGEON_MIN_LEVEL[d[1]]) or nil,
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
  -- Legacy default radius was inset; migrate old value once (users can drag back if they prefer).
  if UHCC_DB.minimap.radius == 55 then
    UHCC_DB.minimap.radius = DEFAULTS.minimap.radius
  end

  UHCC_DB.minimap.radius = clamp(UHCC_DB.minimap.radius, 30, 110)
  UHCC_DB.minimap.angle = normalizeAngle(UHCC_DB.minimap.angle)
end

-- Forward declaration: set after ensureCharDB (used by welcome + level-advice popups).
local uhccShowWelcomePopup

-- Session guard: /reload clears this so onboarding can run again until welcome is saved.
local uhccOnboardingTimerScheduled = false

local function ensureCharDB()
  if type(UHCC_CharDB) ~= "table" then UHCC_CharDB = {} end
  -- Storage split:
  -- - purchases: things the player "bought" (used by all restriction logic)
  -- - settings: UI/settings toggles (Annoy me, Bank name, Money Management, etc.)
  if type(UHCC_CharDB.purchases) ~= "table" then UHCC_CharDB.purchases = {} end
  -- Purchases pending payment (Money Management ON): not effective until debt is paid.
  if type(UHCC_CharDB.pendingPurchases) ~= "table" then UHCC_CharDB.pendingPurchases = {} end
  if type(UHCC_CharDB.settings) ~= "table" then UHCC_CharDB.settings = {} end

  -- Migration from older versions (everything lived in `UHCC_CharDB.options`).
  if type(UHCC_CharDB.options) == "table" then
    for _, opt in ipairs(UHCC.OPTIONS or {}) do
      if opt and opt.checkboxId then
        local v = UHCC_CharDB.options[opt.checkboxId]
        if v ~= nil then
          if opt.tab == "settings" then
            if UHCC_CharDB.settings[opt.checkboxId] == nil then UHCC_CharDB.settings[opt.checkboxId] = v end
          else
            if UHCC_CharDB.purchases[opt.checkboxId] == nil then UHCC_CharDB.purchases[opt.checkboxId] = v end
          end
        end
      end
    end
    -- Keep `options` around for backward compatibility, but stop using it.
  end

  if type(UHCC_CharDB.moneyDueCopper) ~= "number" then UHCC_CharDB.moneyDueCopper = 0 end

  -- Money Management migration:
  -- If there is outstanding debt, purchases must not be effective until paid.
  -- Older sessions may have already written into `purchases`; move them to `pendingPurchases` once.
  if UHCC_CharDB._uhccMoneyMgtPendingMigrationDone ~= true then
    local mmOn = (type(UHCC_CharDB.settings) == "table") and (UHCC_CharDB.settings["SETTINGS-MONEYMGT"] == true)
    local due = tonumber(UHCC_CharDB.moneyDueCopper) or 0
    if mmOn and due > 0 then
      for k, v in pairs(UHCC_CharDB.purchases or {}) do
        if UHCC_CharDB.pendingPurchases[k] == nil then
          UHCC_CharDB.pendingPurchases[k] = v
        end
      end
      UHCC_CharDB.purchases = {}
    end
    UHCC_CharDB._uhccMoneyMgtPendingMigrationDone = true
  end

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
  for _ in pairs(UHCC_CharDB.purchases) do
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
    -- Faction capital should also be free (locked).
    local mid = tonumber(opt.term)
    if mid then
      local faction = (UnitFactionGroup and UnitFactionGroup("player")) or nil
      if faction == "Alliance" and mid == 1453 then -- Stormwind City
        return true
      elseif faction == "Horde" and mid == 1454 then -- Orgrimmar
        return true
      end
    end

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
      local mid2 = tonumber(opt.term)
      if mid2 and mid2 == startMid then
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

local function playerCanUseWeaponTerm(term)
  if term == "none" or term == nil or term == "" then return true end
  local _, classFile = UnitClass("player")
  if not classFile then return true end
  local allowed = CLASS_WEAPON_ALLOWED[classFile]
  if not allowed then return true end
  return not not allowed[term]
end

-- Relic-slot items (Classic Era librams / totems / idols): only relevant classes — hide UI for others.
local function uhccPlayerShowsRelicSlotOption()
  local _, cf = UnitClass("player")
  if not cf then return false end
  return cf == "PALADIN" or cf == "SHAMAN" or cf == "DRUID"
end

-- Ranged slot (~slot 18) for bows/guns/thrown/wands — matches weapon permissions + casters using wands.
local function uhccPlayerShowsRangeWeaponSlotOption()
  local _, cf = UnitClass("player")
  if not cf then return false end
  if cf == "PRIEST" or cf == "MAGE" or cf == "WARLOCK" or cf == "HUNTER" then return true end
  local allowed = CLASS_WEAPON_ALLOWED[cf]
  if allowed and (allowed.bows or allowed.guns or allowed.crossbows or allowed.throwing) then return true end
  return false
end

local function isWeaponPurchaseOption(opt)
  return opt
    and opt.tab == "weapons_services"
    and opt.category == "weapons"
    and opt.inputType == "checkbox"
    and opt.term
    and opt.term ~= "none"
end

local function pruneInvalidWeaponSelections()
  ensureCharDB()
  for _, opt in ipairs(UHCC.OPTIONS) do
    if isWeaponPurchaseOption(opt) and not playerCanUseWeaponTerm(opt.term) then
      if UHCC_CharDB.purchases and UHCC_CharDB.purchases[opt.checkboxId] ~= nil then
        UHCC_CharDB.purchases[opt.checkboxId] = false
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

local function uhccGetActiveForbiddenWorldBuffName()
  if not UnitAura then return nil end
  for i = 1, 80 do
    local name = UnitAura("player", i, "HELPFUL")
    if not name then break end
    if
      name == "Rallying Cry of the Dragonslayer"
      or name == "Spirit of Zandalar"
      or name == "Warchief's Blessing"
    then
      return name
    end
  end
  return nil
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
  local v = UHCC_CharDB.purchases[opt.checkboxId]
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
  return UHCC_CharDB.settings and UHCC_CharDB.settings["SETTINGS-ANNOY"] == true
end

local function uhccMoneyManagementEnabled()
  ensureCharDB()
  return UHCC_CharDB.settings and UHCC_CharDB.settings["SETTINGS-MONEYMGT"] == true
end

local function uhccGetMoneyDueCopper()
  ensureCharDB()
  return tonumber(UHCC_CharDB.moneyDueCopper) or 0
end

local function uhccSetMoneyDueCopper(v)
  ensureCharDB()
  v = tonumber(v) or 0
  if v < 0 then v = 0 end
  UHCC_CharDB.moneyDueCopper = v
end

local function uhccCommittedPurchasesView()
  -- For UI/draft purposes: show paid purchases + pending purchases.
  ensureCharDB()
  local t = {}
  for k, v in pairs(UHCC_CharDB.purchases) do t[k] = v end
  for k, v in pairs(UHCC_CharDB.pendingPurchases) do
    if t[k] == nil then t[k] = v end
  end
  return t
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
  local v = UHCC_CharDB.settings and UHCC_CharDB.settings["SETTINGS-BANKNAME"]
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

-- Character sheet slot purchases: all listed ids must be owned (rings/trinkets = both slots).
local function uhccEquipSlotPurchasesMet(ids)
  if not ids then return true end
  for _, cid in ipairs(ids) do
    if not uhccIsPurchasedById(cid) then return false end
  end
  return true
end

local function uhccEquipSlotPurchaseIdsForEquipLoc(equipLoc, itemClassID, itemSubClassID)
  if not equipLoc or equipLoc == "" then return nil end
  if equipLoc == "INVTYPE_HEAD" then return { "EQUIP-HEAD" } end
  if equipLoc == "INVTYPE_NECK" then return { "EQUIP-NECK" } end
  if equipLoc == "INVTYPE_SHOULDER" then return { "EQUIP-SHOULDER" } end
  if equipLoc == "INVTYPE_BODY" then return { "EQUIP-SHIRT" } end
  if equipLoc == "INVTYPE_CHEST" or equipLoc == "INVTYPE_ROBE" then return { "EQUIP-CHEST" } end
  if equipLoc == "INVTYPE_WAIST" then return { "EQUIP-WAIST" } end
  if equipLoc == "INVTYPE_LEGS" then return { "EQUIP-LEGS" } end
  if equipLoc == "INVTYPE_FEET" then return { "EQUIP-FEET" } end
  if equipLoc == "INVTYPE_WRIST" then return { "EQUIP-WRIST" } end
  if equipLoc == "INVTYPE_HAND" then return { "EQUIP-HANDS" } end
  if equipLoc == "INVTYPE_CLOAK" then return { "EQUIP-BACK" } end
  if equipLoc == "INVTYPE_TABARD" then return { "EQUIP-TABARD" } end
  if equipLoc == "INVTYPE_FINGER" then return { "EQUIP-FINGER1", "EQUIP-FINGER2" } end
  if equipLoc == "INVTYPE_TRINKET" then return { "EQUIP-TRINKET1", "EQUIP-TRINKET2" } end
  if equipLoc == "INVTYPE_WEAPONMAINHAND" or equipLoc == "INVTYPE_2HWEAPON" then return { "EQUIP-MAINHAND" } end
  if equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_SHIELD" or equipLoc == "INVTYPE_HOLDABLE" then
    return { "EQUIP-OFFHAND" }
  end
  -- Relic-slot items vs ranged weapons (bows, guns, thrown, wands share slot 18 in Classic).
  itemClassID = tonumber(itemClassID)
  itemSubClassID = tonumber(itemSubClassID)
  local relicWeaponSc = tonumber(_G.LE_ITEM_WEAPON_RELIC)
  local isWeaponRelic = (itemClassID == 2 and relicWeaponSc and itemSubClassID == relicWeaponSc)
  if equipLoc == "INVTYPE_RELIC" or isWeaponRelic then
    return { "EQUIP-RELIC" }
  end
  if equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_THROWN" then
    return { "EQUIP-RANGE" }
  end
  if equipLoc == "INVTYPE_WEAPON" then return { "EQUIP-MAINHAND" } end
  return nil
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
      or equipLoc == "INVTYPE_RELIC"
      or equipLoc == "INVTYPE_THROWN"
      or equipLoc == "INVTYPE_HOLDABLE"
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

  do
    local slotIds = uhccEquipSlotPurchaseIdsForEquipLoc(equipLoc, classID, subclassID)
    if slotIds and not uhccEquipSlotPurchasesMet(slotIds) then
      addReason("Buy the matching character slot first")
    end
  end

  -- Armor.
  if classID == 4 or itemType == (ITEM_CLASS_ARMOR or "Armor") then
    if equipLoc == "INVTYPE_SHIELD" and not uhccIsPurchasedById("WEAPON-ONEHAND") then
      addReason("Buy One Handed Weapons first")
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

    if equipLoc == "INVTYPE_2HWEAPON" or equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_THROWN" then
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
local uhccLastSendMailRecipient = nil
local uhccLastSendMailMoneyCopper = 0

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

  -- Capture outgoing mail payment details before Blizzard clears fields.
  if _G.SendMailMailButton and _G.SendMailMailButton.HookScript then
    _G.SendMailMailButton:HookScript("OnClick", function()
      local recip = nil
      if _G.SendMailNameEditBox and _G.SendMailNameEditBox.GetText then
        recip = _G.SendMailNameEditBox:GetText()
      end
      uhccLastSendMailRecipient = recip

      local m = 0
      if GetSendMailMoney then
        m = tonumber(GetSendMailMoney()) or 0
      else
        -- Fallback: read from money input boxes if present.
        local g = tonumber((_G.SendMailMoneyGold and _G.SendMailMoneyGold.GetText and _G.SendMailMoneyGold:GetText()) or 0) or 0
        local s = tonumber((_G.SendMailMoneySilver and _G.SendMailMoneySilver.GetText and _G.SendMailMoneySilver:GetText()) or 0) or 0
        local c = tonumber((_G.SendMailMoneyCopper and _G.SendMailMoneyCopper.GetText and _G.SendMailMoneyCopper:GetText()) or 0) or 0
        if g < 0 then g = 0 end
        if s < 0 then s = 0 end
        if c < 0 then c = 0 end
        m = g * 10000 + s * 100 + c
      end
      uhccLastSendMailMoneyCopper = m
    end)
  end
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

  -- Flight paths restriction: warn while the taxi map is open without purchase.
  if uhccAnnoyEnabled() and uhccTaxiMapOpen and (not uhccIsPurchasedById("SERVICE-FLIGHTPATHS")) then
    msgs[#msgs + 1] = "You should not use flight paths yet. Buy Flight Paths first."
    keyParts[#keyParts + 1] = "TAXIOPEN"
  end

  -- World buffs restriction: warn if player has a world buff without purchase.
  if uhccAnnoyEnabled() and (not uhccIsPurchasedById("SERVICE-WORLDBUFFS")) then
    local wb = uhccGetActiveForbiddenWorldBuffName()
    if wb then
      msgs[#msgs + 1] = ("You should not have %s yet. Buy World Buffs first."):format(wb)
      keyParts[#keyParts + 1] = "WORLDBUFF:" .. wb
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
          if UHCC_CharDB.purchases[opt.checkboxId] then
            total = total + uhccCostToCopper(opt.cost)
          end
        end
      elseif opt.inputType == "range" then
        local mn, mx = opt.min or 0, opt.max or 100
        local v = tonumber(UHCC_CharDB.purchases[opt.checkboxId])
        if v == nil then v = mn end
        v = clamp(math.floor(v + 0.5), mn, mx)
        local per = tonumber(opt.cost) or 0
        total = total + uhccCostToCopper(per * v)
      end
    end
  end
  return total
end

local function uhccComputeAdditionalCostCopperForDraft(draft, purchases)
  local add = 0
  draft = (type(draft) == "table") and draft or {}
  purchases = (type(purchases) == "table") and purchases or {}
  for _, opt in ipairs(UHCC.OPTIONS) do
    if opt and opt.tab ~= "settings" and not optionLocksFreeChoice(opt) then
      if opt.inputType == "checkbox" then
        local was = purchases[opt.checkboxId] and true or false
        local now = draft[opt.checkboxId] and true or false
        if isWeaponPurchaseOption(opt) and not playerCanUseWeaponTerm(opt.term) then
          -- cannot use: never counts
        elseif (not was) and now then
          add = add + uhccCostToCopper(opt.cost)
        end
      elseif opt.inputType == "range" then
        local mn, mx = opt.min or 0, opt.max or 100
        local wasV = tonumber(purchases[opt.checkboxId])
        if wasV == nil then wasV = mn end
        wasV = clamp(math.floor(wasV + 0.5), mn, mx)
        local nowV = tonumber(draft[opt.checkboxId])
        if nowV == nil then nowV = wasV end
        nowV = clamp(math.floor(nowV + 0.5), mn, mx)
        if nowV > wasV then
          local per = tonumber(opt.cost) or 0
          add = add + uhccCostToCopper(per * (nowV - wasV))
        end
      end
    end
  end
  return add
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
  UHCC_CharDB.purchases = {}
  UHCC_CharDB.settings = {}
  UHCC_CharDB.pendingPurchases = {}
  UHCC_CharDB.moneyDueCopper = 0
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

-- Gold/silver texture tokens, or "g"/"s" when colorblind mode UI is enabled.
local function uhccMoneyDisplayTokens()
  local colorblindOn = false
  if GetCVar then
    local v = GetCVar("colorblindMode")
    colorblindOn = (v == "1" or v == 1 or v == true)
  end
  local goldIcon = colorblindOn and "g" or "|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:0:0|t"
  local silverIcon = colorblindOn and "s" or "|TInterface\\MoneyFrame\\UI-SilverIcon:14:14:0:0|t"
  return goldIcon, silverIcon
end

local function formatCostSilver(costSilver)
  costSilver = tonumber(costSilver) or 0
  if costSilver <= 0 then
    return " - Free"
  end

  local gold = math.floor(costSilver / 100)
  local silver = math.floor(costSilver % 100)
  local goldIcon, silverIcon = uhccMoneyDisplayTokens()

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
  -- Settings tab is going to be split into two columns; keep existing controls on the left half.
  local settingsGutter = 24
  local settingsLeftW = math.max(260, math.floor((innerScrollW - settingsGutter) / 2))
  local settingsColX = { 0, settingsLeftW + settingsGutter }
  local colPitch = math.floor((innerScrollW - 16) / 3)
  local colX = { 8, 8 + colPitch, 8 + colPitch * 2 }
  local rowH = 24
  -- Zones tab: up to ~25 rows per continent in one column.
  -- Equipment tab: slots in columns 1–2, Gear Quality + Quest Gear in column 3.
  local maxRows = (tabName == "Zones & Dungeons") and 30 or (tabName == "Equipment & Quality") and 32 or 15
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
  -- Settings layout: 2 columns with independent cursors.
  local settingsCursorY = { 12, 12 } -- distance from top of scroll child (downward)
  local settingsColumn = 0 -- 0 = left, 1 = right

  local function curSettingsY()
    return settingsCursorY[settingsColumn + 1] or 12
  end

  local function bumpSettingsY(delta)
    settingsCursorY[settingsColumn + 1] = (settingsCursorY[settingsColumn + 1] or 12) + (tonumber(delta) or 0)
  end

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
    elseif item.kind == "settings_column" then
      local c = tonumber(item.column)
      if c == 1 then settingsColumn = 1 else settingsColumn = 0 end
    elseif item.kind == "section" then
      if item.column ~= nil then
        setColumnStart(item.column)
      end
      if item.text and item.text ~= "" then
        local x, y = lineToPos(line)
        addSectionTitleAt(child, x, y, item.text)
        line = line + 1
      end
    elseif item.kind == "checkbox" then
      local x, y = lineToPos(line)
      local cb = addCheckboxAt(child, x, y, item.text, item.opts)
      cb.UHCC_baseText = item.text
      cb.UHCC_option = item.option
      cb.checkboxId = item.option and item.option.checkboxId or nil
      cb.cost = item.option and item.option.cost or nil
      -- Register purchase checkboxes for Money Management dynamic enabling/disabling.
      do
        local mf = UHCC.mainFrame
        if mf and cb.checkboxId and item.option and item.option.tab ~= "settings" then
          mf.UHCC_purchaseControls = mf.UHCC_purchaseControls or {}
          mf.UHCC_purchaseControls[cb.checkboxId] = cb
        end
      end
      if cb.checkboxId and cb:IsEnabled() then
        cb:HookScript("OnClick", function(self)
          ensureCharDB()
          local checked = self:GetChecked() and true or false
          local mf = UHCC.mainFrame
          if uhccMoneyManagementEnabled() and mf then
            -- Money Management: allow cancelling already-committed due (pending) purchases with confirmation.
            if (not checked) and UHCC_CharDB.pendingPurchases and UHCC_CharDB.pendingPurchases[self.checkboxId] then
              -- Revert the visual toggle immediately; the popup will apply the change on accept.
              self:SetChecked(true)
              if StaticPopup_Show and self.UHCC_option and self.UHCC_option.label then
                StaticPopup_Show("UHCC_CANCEL_DUE_PURCHASE", self.UHCC_option.label, nil, { checkbox = self, option = self.UHCC_option })
              end
              return
            end
            -- Ensure we never fall back to direct persistence when MM is enabled.
            if type(mf.UHCC_draftPurchases) ~= "table" then
              mf.UHCC_draftPurchases = {}
              local base = uhccCommittedPurchasesView()
              for k, v in pairs(base) do mf.UHCC_draftPurchases[k] = v end
            end
            mf.UHCC_draftPurchases[self.checkboxId] = checked
            if mf.UHCC_UpdateMoneyUI then mf:UHCC_UpdateMoneyUI() end
          else
            UHCC_CharDB.purchases[self.checkboxId] = checked
            recalcSpentDisplay()
          end
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
        local sv = nil
        local mf = UHCC.mainFrame
        if uhccMoneyManagementEnabled() and mf and type(mf.UHCC_draftPurchases) == "table" then
          sv = tonumber(mf.UHCC_draftPurchases[item.option.checkboxId])
        end
        if sv == nil then
          sv = tonumber(UHCC_CharDB.purchases[item.option.checkboxId])
        end
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
          local mf = UHCC.mainFrame
          if uhccMoneyManagementEnabled() and mf then
            if type(mf.UHCC_draftPurchases) ~= "table" then
              mf.UHCC_draftPurchases = {}
              local base = uhccCommittedPurchasesView()
              for k, v in pairs(base) do mf.UHCC_draftPurchases[k] = v end
            end
            mf.UHCC_draftPurchases[item.option.checkboxId] = iv
            if mf.UHCC_UpdateMoneyUI then mf:UHCC_UpdateMoneyUI() end
          else
            UHCC_CharDB.purchases[item.option.checkboxId] = iv
            recalcSpentDisplay()
          end
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
      local y = -curSettingsY()
      local cb = CreateFrame("CheckButton", nil, child, "UICheckButtonTemplate")
      local indent = (item.opts and tonumber(item.opts.indent)) or 0
      local baseX = (settingsColX[settingsColumn + 1] or 0) + padX + indent
      cb:SetPoint("TOPLEFT", child, "TOPLEFT", baseX, y)
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
      cb.UHCC_set = item.set
      cb.UHCC_onChange = item.onChange

      -- Always hook settings checkboxes (they may be enabled/disabled dynamically).
      if cb.checkboxId then
        cb:HookScript("OnClick", function(self)
          ensureCharDB()
          local checked = self:GetChecked() and true or false

          -- External controls can override persistence.
          if type(self.UHCC_set) == "function" then
            pcall(self.UHCC_set, checked, self)
          else
            UHCC_CharDB.settings[self.checkboxId] = checked
          end

          if type(self.UHCC_onChange) == "function" then
            pcall(self.UHCC_onChange, checked, self)
          end

          -- Money Management depends on Annoy me.
          if self.checkboxId == "SETTINGS-ANNOY" then
            local mf = UHCC.mainFrame
            local mm = (mf and mf.UHCC_settingsControls) and mf.UHCC_settingsControls["SETTINGS-MONEYMGT"] or nil
            if not self:GetChecked() then
              UHCC_CharDB.settings["SETTINGS-MONEYMGT"] = false
              if mm then
                mm:SetChecked(false)
                mm:SetEnabled(false)
                if mm.Text then mm.Text:SetTextColor(0.7, 0.7, 0.7, 1) end
              end
            else
              if mm then
                mm:SetEnabled(true)
                if mm.Text then mm.Text:SetTextColor(1, 1, 1, 1) end
              end
            end
          end
          -- If Money Management was toggled while the window is open, (re)initialize the draft state now.
          if self.checkboxId == "SETTINGS-MONEYMGT" then
            -- Bank Name is required: allow checking first, but prompt/focus immediately.
            if self:GetChecked() then
              local bn = uhccNormalizeNameForCompare(uhccGetBankNameSetting())
              if bn == "" then
                print("|cffffcc00UHCC|r: Please fill in Bank Name to enable Money Management.")
                local mf2 = UHCC.mainFrame
                if mf2 and mf2.UHCC_settingsControls and mf2.UHCC_settingsControls["SETTINGS-BANKNAME"] then
                  local eb = mf2.UHCC_settingsControls["SETTINGS-BANKNAME"]
                  if eb and eb.SetFocus then
                    eb:SetFocus()
                    eb:HighlightText()
                  end
                end
              end
            end
            local mf = UHCC.mainFrame
            if mf then
              if self:GetChecked() then
                mf.UHCC_draftPurchases = {}
                local base = uhccCommittedPurchasesView()
                for k, v in pairs(base) do mf.UHCC_draftPurchases[k] = v end
              else
                mf.UHCC_draftPurchases = nil
              end
            end
          end
          -- Keep Money UI in sync when toggling the mode.
          do
            local mf = UHCC.mainFrame
            if mf and mf.UHCC_UpdateMoneyUI then mf:UHCC_UpdateMoneyUI() end
          end
          -- Apply immediately (zone overlay, bag highlights + tooltips, equip flash).
          recalcSpentDisplay()
        end)
      end

      -- Register the checkbox so dependencies can update it live.
      do
        local mf = UHCC.mainFrame
        if mf and cb.checkboxId then
          mf.UHCC_settingsControls = mf.UHCC_settingsControls or {}
          mf.UHCC_settingsControls[cb.checkboxId] = cb
        end
      end

      local desc = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      desc:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 28, -8)
      desc:SetWidth(math.max(160, settingsLeftW - (baseX + 28) - 12))
      desc:SetJustifyH("LEFT")
      desc:SetNonSpaceWrap(false)
      desc:SetText(item.description or "")

      local descH = desc:GetStringHeight() or 0
      bumpSettingsY(26 + 8 + math.max(descH, 14) + 24)
    elseif item.kind == "settings_text" then
      local padX = 16
      local y = -curSettingsY()

      local label = child:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
      local baseX = (settingsColX[settingsColumn + 1] or 0) + padX
      label:SetPoint("TOPLEFT", child, "TOPLEFT", baseX, y)
      label:SetText(item.label or "")

      local eb = CreateFrame("EditBox", nil, child, "InputBoxTemplate")
      eb:SetAutoFocus(false)
      local ebW = clamp(settingsLeftW - padX - 12, 160, 260)
      eb:SetSize(ebW, 20)
      eb:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
      eb:SetText(item.value or "")
      eb:SetCursorPosition(0)
      eb.UHCC_set = item.set
      eb.UHCC_onChange = item.onChange

      eb:HookScript("OnEditFocusLost", function(self)
        if item.option and item.option.checkboxId then
          ensureCharDB()
          local v = tostring(self:GetText() or "")
          if type(self.UHCC_set) == "function" then
            pcall(self.UHCC_set, v, self)
          else
            UHCC_CharDB.settings[item.option.checkboxId] = v
          end

          if type(self.UHCC_onChange) == "function" then
            pcall(self.UHCC_onChange, v, self)
          end
          recalcSpentDisplay()
        end
      end)
      eb:HookScript("OnEnterPressed", function(self)
        self:ClearFocus()
      end)

      local desc = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      desc:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 4, -6)
      desc:SetWidth(math.max(160, settingsLeftW - padX - 12))
      desc:SetJustifyH("LEFT")
      desc:SetNonSpaceWrap(false)
      desc:SetText(item.description or "")

      local descH = desc:GetStringHeight() or 0
      bumpSettingsY(26 + 20 + 6 + 6 + math.max(descH, 14) + 18)

      -- Register the editbox so validations can focus it, etc.
      do
        local mf = UHCC.mainFrame
        if mf and item.option and item.option.checkboxId then
          mf.UHCC_settingsControls = mf.UHCC_settingsControls or {}
          mf.UHCC_settingsControls[item.option.checkboxId] = eb
        end
      end
    elseif item.kind == "settings_info" then
      local padX = 16
      local y = -curSettingsY()
      local fs = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      fs:SetPoint("TOPLEFT", child, "TOPLEFT", (settingsColX[settingsColumn + 1] or 0) + padX, y)
      fs:SetWidth(math.max(160, settingsLeftW - padX - 12))
      fs:SetJustifyH("LEFT")
      fs:SetNonSpaceWrap(false)
      fs:SetText(item.text or "")
      fs:SetTextColor(0.9, 0.9, 0.9, 1)
      local h = fs:GetStringHeight() or 0
      bumpSettingsY(math.max(h, 14) + 16)
    elseif item.kind == "settings_button" then
      local padX = 16
      local y = -curSettingsY()

      local btn = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
      btn:SetPoint("TOPLEFT", child, "TOPLEFT", (settingsColX[settingsColumn + 1] or 0) + padX, y)
      btn:SetSize(140, 22)
      btn:SetText(item.label or "Button")
      btn:SetEnabled(true)

      btn:SetScript("OnClick", function()
        if type(item.onClick) == "function" then
          pcall(item.onClick, btn)
          return
        end
        if item.action == "reset_character" then
          if StaticPopup_Show then
            StaticPopup_Show("UHCC_RESET_CHARACTER")
          else
            resetCharChallengeData()
          end
        end
      end)

      bumpSettingsY(22 + 18)
    end
  end

  local gridHeight = math.max(1, math.ceil(line / (maxRows * maxCols)) * (maxRows * rowH + blockGap) + 60)
  local height = math.max(gridHeight, math.max(settingsCursorY[1] or 0, settingsCursorY[2] or 0) + 36)
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
    if bg.SetTexture then
      bg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
      -- Flip vertically so the tab looks anchored at the bottom.
      bg:SetTexCoord(0, 1, 1, 0)
    else
      bg:SetColorTexture(0.42, 0.34, 0.14, 1)
    end
    fs:SetFontObject(GameFontHighlightSmall)
    fs:SetTextColor(1, 1, 0.85, 1)
  else
    if bg.SetTexture then
      bg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-InActiveTab")
      -- Flip vertically so the tab looks anchored at the bottom.
      bg:SetTexCoord(0, 1, 1, 0)
    else
      bg:SetColorTexture(0.12, 0.12, 0.12, 0.98)
    end
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

  -- Top-left: round MiniMap-style ring; smaller spell icon centered in the ring opening.
  -- MiniMap-TrackingBorder is asymmetrical (tracking tab), so icon + bg share a small nudge vs. texture center.
  do
    local pf = CreateFrame("Frame", "UHCC_MainFramePortrait", f)
    pf:SetFrameLevel((f:GetFrameLevel() or 0) + 5)
    local RING_SZ = 76
    local ICON_SZ = 32
    local BG_SZ = 64
    -- Visually centers content in the circular part of the border (MiniMap ring tab skews the hole).
    local HOLE_OX, HOLE_OY = -16, 16
    pf:SetSize(RING_SZ, RING_SZ)
    -- Whole portrait (ring + icon): nudge vs. frame corner — was (8,-8); 5px left + 5px up → (3,-3)
    pf:SetPoint("TOPLEFT", f, "TOPLEFT", -18, 18)

    local ring = pf:CreateTexture(nil, "OVERLAY")
    ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    ring:SetSize(RING_SZ, RING_SZ)
    ring:SetPoint("CENTER", pf, "CENTER", 0, 0)

    local bg = pf:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\QUESTFRAME\\QuestPortraitBackground")
    bg:SetSize(BG_SZ, BG_SZ)
    bg:SetPoint("CENTER", pf, "CENTER", HOLE_OX, HOLE_OY)

    local icon = pf:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\ICONS\\Ability_Warrior_Rampage")
    icon:SetSize(ICON_SZ, ICON_SZ)
    icon:SetPoint("CENTER", pf, "CENTER", HOLE_OX, HOLE_OY)

    -- Clip icon (and bg) to a circle — same mask as Blizzard character portraits when supported.
    do
      local maskPath = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
      if pf.CreateMaskTexture and icon.AddMaskTexture then
        local function applyRoundMask(target, sz)
          local m = pf:CreateMaskTexture()
          m:SetTexture(maskPath, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
          m:SetSize(sz, sz)
          m:SetPoint("CENTER", target, "CENTER", 0, 0)
          target:AddMaskTexture(m)
        end
        pcall(applyRoundMask, icon, ICON_SZ)
        pcall(applyRoundMask, bg, BG_SZ)
      end
    end
  end

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
      ensureCharDB()
      local annoyOn = (UHCC_CharDB.settings and UHCC_CharDB.settings["SETTINGS-ANNOY"]) and true or false
      for _, opt in ipairs(UHCC.OPTIONS) do
        if opt.tab == "settings" and opt.inputType == "checkbox" then
          ensureCharDB()
          local cur = (UHCC_CharDB.settings and UHCC_CharDB.settings[opt.checkboxId]) and true or false
          local disabled = false
          local indent = nil
          -- Money Management depends on Annoy me.
          if opt.checkboxId == "SETTINGS-ANNOY" then
            annoyOn = cur
          elseif opt.checkboxId == "SETTINGS-MONEYMGT" then
            indent = 18
            if not annoyOn then
              cur = false
              disabled = true
            end
          end
          spec[#spec + 1] = {
            kind = "settings_checkbox",
            label = (opt.label or ""),
            description = opt.description or "",
            opts = { checked = cur, disabled = disabled, indent = indent },
            option = opt,
          }
        elseif opt.tab == "settings" and opt.inputType == "text" then
          ensureCharDB()
          local v = (UHCC_CharDB.settings and UHCC_CharDB.settings[opt.checkboxId]) or nil
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

      -- External providers: right column injection.
      do
        local function asKey(k)
          k = tostring(k or "")
          if k == "" then return nil end
          return k
        end

        local function curBool(key, defaultVal, getter)
          if type(getter) == "function" then
            local ok, v = pcall(getter)
            if ok then return v and true or false end
          end
          local v = (UHCC_CharDB.settings and UHCC_CharDB.settings[key])
          if v == nil then return defaultVal and true or false end
          return v and true or false
        end

        local function curText(key, defaultVal, getter)
          if type(getter) == "function" then
            local ok, v = pcall(getter)
            if ok then return tostring(v or "") end
          end
          local v = (UHCC_CharDB.settings and UHCC_CharDB.settings[key])
          if v == nil then v = defaultVal end
          return tostring(v or "")
        end

        local anyExternal = false
        for _, providerName in ipairs(UHCC.externalSettingsProviderOrder or {}) do
          local fn = UHCC.externalSettingsProviders and UHCC.externalSettingsProviders[providerName] or nil
          if type(fn) == "function" then
            local ok, items = pcall(fn)
            if ok and type(items) == "table" and #items > 0 then
              if not anyExternal then
                spec[#spec + 1] = { kind = "settings_column", column = 1 }
                anyExternal = true
              end
              -- Optional provider title.
              spec[#spec + 1] = { kind = "settings_info", text = ("|cffffcc00%s|r"):format(providerName) }
              for _, it in ipairs(items) do
                local k = tostring(it.kind or "")
                if k == "spacer" then
                  spec[#spec + 1] = { kind = "settings_info", text = " " }
                elseif k == "info" then
                  spec[#spec + 1] = { kind = "settings_info", text = tostring(it.text or "") }
                elseif k == "checkbox" then
                  local key = asKey(it.key or it.checkboxId or it.id)
                  if key then
                    local cur = curBool(key, it.default, it.get)
                    spec[#spec + 1] = {
                      kind = "settings_checkbox",
                      label = tostring(it.label or key),
                      description = tostring(it.description or ""),
                      opts = { checked = cur, disabled = it.disabled and true or false, indent = it.indent },
                      option = { checkboxId = key, cost = 0, tab = "settings", category = "external_settings" },
                      set = it.set,
                      onChange = it.onChange,
                    }
                  end
                elseif k == "text" then
                  local key = asKey(it.key or it.checkboxId or it.id)
                  if key then
                    spec[#spec + 1] = {
                      kind = "settings_text",
                      label = tostring(it.label or key),
                      description = tostring(it.description or ""),
                      value = curText(key, it.default, it.get),
                      option = { checkboxId = key, cost = 0, tab = "settings", category = "external_settings" },
                      set = it.set,
                      onChange = it.onChange,
                    }
                  end
                elseif k == "button" then
                  spec[#spec + 1] = {
                    kind = "settings_button",
                    label = tostring(it.label or "Button"),
                    onClick = it.onClick,
                  }
                end
              end
            end
          end
        end
        if anyExternal then
          spec[#spec + 1] = { kind = "settings_column", column = 0 }
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
      spec[#spec + 1] = { kind = "spacer" }
      spec[#spec + 1] = {
        kind = "settings_info",
        text = "Support: |cff66ccffhttps://github.com/JulioPotier/UltimateHardcoreChallengeUI/issues|r",
      }
      spec[#spec + 1] = {
        kind = "settings_info",
        text = "Tip me golds on |cffff69b4Kirbank-Soulseeker|r ;)",
      }
      return spec
    end

    local spec = {}

    local sectionTitles = nil
    local sectionColumns = nil
    if tabKey == "gear_quality" then
      sectionTitles = {
        equipment_slots_a = "Character slots",
        gear_quality = "Gear Quality",
        gear_quest = "Quest Gear",
      }
      sectionColumns = {
        equipment_slots_a = 0,
        equipment_slots_b = 1,
        gear_quality = 2,
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
        -- Horde shows Ragefire Chasm + Wailing Caverns; Alliance shows The Stockade.
        if tabKey == "zones_dungeons" and opt.category == "dungeons" then
          local faction = (UnitFactionGroup and UnitFactionGroup("player")) or nil
          local mid = tonumber(opt.term)
          if faction == "Horde" and mid == 717 then
            skip = true -- hide Stockade for Horde
          elseif faction == "Alliance" and (mid == 2437 or mid == 718) then
            skip = true -- hide Ragefire + Wailing Caverns for Alliance
          end
        end
        if tabKey == "gear_quality" and (opt.category == "equipment_slots_a" or opt.category == "equipment_slots_b") then
          if opt.checkboxId == "EQUIP-RELIC" and not uhccPlayerShowsRelicSlotOption() then skip = true end
          if opt.checkboxId == "EQUIP-RANGE" and not uhccPlayerShowsRangeWeaponSlotOption() then skip = true end
        end

        if not skip then
          if lastSection ~= opt.category and (opt.inputType == "checkbox" or opt.inputType == "range") then
            local col = sectionColumns and sectionColumns[opt.category]
            local title = sectionTitles and sectionTitles[opt.category]
            if col ~= nil or (title ~= nil and title ~= "") then
              if #spec > 0 then spec[#spec + 1] = { kind = "spacer" } end
              spec[#spec + 1] = {
                kind = "section",
                text = title or "",
                column = col,
              }
              lastSection = opt.category
            end
          end

          if opt.inputType == "checkbox" then
            local text = opt.label .. formatCostSilver(uhccGetDisplayCostForOption(opt))
            local plvl = (UnitLevel and UnitLevel("player")) or 0
            local reqLvl = tonumber(opt.minPlayerLevel) or 0
            local lowLvl = ((opt.category == "dungeons") or (opt.category == "battlegrounds")) and reqLvl > 0 and plvl < reqLvl
            if lowLvl then
              text = text .. (" - lvl %d"):format(reqLvl)
            end
            local weaponDenied = isWeaponPurchaseOption(opt) and not playerCanUseWeaponTerm(opt.term)
            local selfFoundDenied = uhccOptionDeniedInSelfFound(opt)
            local chkOpts = nil
            if selfFoundDenied then
              chkOpts = { checked = false, disabled = true }
            elseif weaponDenied then
              chkOpts = { checked = false, disabled = true }
            elseif optionLocksFreeChoice(opt) then
              chkOpts = { checked = true, disabled = true }
            else
              -- UI check state: in Money Management mode, show draft (if any) instead of purchased.
              local cur = nil
              local mf = UHCC.mainFrame
              if uhccMoneyManagementEnabled() and mf and type(mf.UHCC_draftPurchases) == "table" then
                cur = mf.UHCC_draftPurchases[opt.checkboxId]
              else
                cur = getCharCheckboxState(opt)
                -- When Money Management is ON but the frame isn't shown yet (no draft),
                -- reflect pending (due) purchases in the UI so they stay checked after /reload.
                if (not cur) and uhccMoneyManagementEnabled() then
                  ensureCharDB()
                  if UHCC_CharDB.pendingPurchases and UHCC_CharDB.pendingPurchases[opt.checkboxId] then
                    cur = true
                  end
                end
              end
              if cur then chkOpts = { checked = true } end
              if lowLvl then
                chkOpts = chkOpts or {}
                chkOpts.disabled = true
              end
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

  -- Allow runtime rebuild (e.g. external settings providers registered after the frame is created).
  f.UHCC_buildSpecForTab = buildSpecForTab
  function f:UHCC_RebuildSettingsTab()
    if not self.tabPanels or not self.UHCC_buildSpecForTab then return end
    local settingsTabId2 = #tabNames
    local panel = self.tabPanels[settingsTabId2]
    if not panel then return end
    local spec2 = self.UHCC_buildSpecForTab("settings") or {}
    buildTabPage(panel, tabNames[settingsTabId2], spec2)
    -- Ensure the selected tab stays consistent visually.
    setTabSelected(self.UHCC_selectedTabId or settingsTabId2)
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
    -- Default textured tab background (overridden by applyCustomTabLook).
    bg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-InActiveTab")
    bg:SetTexCoord(0, 1, 1, 0)
    tab.UHCC_bg = bg

    -- No visible hover highlight (avoid the default larger-looking highlight, and avoid invalid nil arg).
    local hi = tab:CreateTexture(nil, "HIGHLIGHT")
    hi:SetAllPoints()
    hi:SetColorTexture(1, 1, 1, 0)

    tab:SetScript("OnClick", function(self) setTabSelected(self:GetID()) end)

    if i == 1 then
      tab:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -36)
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
  spent:SetPoint("TOPRIGHT", f, "TOPRIGHT", -120, -20)
  spent:SetSize(220, 20)
  f.spentFrame = spent
  f.UHCC_spentAnchorX = -120
  f.UHCC_spentAnchorY_mmOn = -20
  f.UHCC_spentAnchorY_mmOff = -35 -- 15px lower when Money Management is disabled
  function f:UHCC_UpdateSpentAnchor()
    if not self.spentFrame then return end
    local y = uhccMoneyManagementEnabled() and self.UHCC_spentAnchorY_mmOn or self.UHCC_spentAnchorY_mmOff
    self.spentFrame:ClearAllPoints()
    self.spentFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", self.UHCC_spentAnchorX or -120, y or -20)
  end

  local goldIcon, silverIcon = uhccMoneyDisplayTokens()

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
    goldIcon, silverIcon = uhccMoneyDisplayTokens()
    spentValue:SetText(("%02d %s %02d %s"):format(g, goldIcon, s, silverIcon))
  end
  recalcSpentDisplay()

  -- Money management UI (debt + cart + purchase button)
  local debtLabel = spent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  debtLabel:SetPoint("TOPRIGHT", spentLabel, "BOTTOMRIGHT", 0, -2)
  debtLabel:SetJustifyH("RIGHT")
  debtLabel:SetText("Due:")
  local debtValue = spent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  debtValue:SetPoint("LEFT", debtLabel, "RIGHT", 30, 0)
  debtValue:SetJustifyH("LEFT")
  debtValue:SetText("00 " .. goldIcon .. " 00 " .. silverIcon)
  f.debtValueText = debtValue

  local cartLabel = spent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  cartLabel:SetPoint("TOPRIGHT", debtLabel, "BOTTOMRIGHT", 0, -2)
  cartLabel:SetJustifyH("RIGHT")
  cartLabel:SetText("Cart:")
  local cartValue = spent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  cartValue:SetPoint("LEFT", cartLabel, "RIGHT", 30, 0)
  cartValue:SetJustifyH("LEFT")
  cartValue:SetText("00 " .. goldIcon .. " 00 " .. silverIcon)
  f.cartValueText = cartValue

  function f:UHCC_UpdateMoneyUI()
    ensureCharDB()
    local mmOn = uhccMoneyManagementEnabled()
    if self.UHCC_UpdateSpentAnchor then self:UHCC_UpdateSpentAnchor() end
    local faction = (UnitFactionGroup and UnitFactionGroup("player")) or nil
    local skullIcon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14:0:0|t"
    goldIcon, silverIcon = uhccMoneyDisplayTokens()
    local due = uhccGetMoneyDueCopper()
    local dg, ds = formatGoldSilverFromCopper(due)
    debtValue:SetText(("%02d %s %02d %s"):format(dg, goldIcon, ds, silverIcon))

    local availableAfterDebt = (GetMoney and GetMoney() or 0) - due
    if availableAfterDebt < 0 then availableAfterDebt = 0 end

    local add = 0
    if mmOn and type(self.UHCC_draftPurchases) == "table" then
      add = uhccComputeAdditionalCostCopperForDraft(self.UHCC_draftPurchases, uhccCommittedPurchasesView())
    end
    local cg, cs = formatGoldSilverFromCopper(add)
    cartValue:SetText(("%02d %s %02d %s"):format(cg, goldIcon, cs, silverIcon))
    if self.purchaseBtn then
      if mmOn then self.purchaseBtn:Show() else self.purchaseBtn:Hide() end
      self.purchaseBtn:SetEnabled(add > 0 and availableAfterDebt >= add)
    end

    -- Hide Due/Cart when Money Management is off.
    if mmOn then
      debtLabel:Show()
      debtValue:Show()
      cartLabel:Show()
      cartValue:Show()
    else
      debtLabel:Hide()
      debtValue:Hide()
      cartLabel:Hide()
      cartValue:Hide()
    end

    -- While Money Management is ON, disable unaffordable (not-yet-selected) checkboxes live.
    if type(self.UHCC_purchaseControls) == "table" then
      local remaining = availableAfterDebt - add
      if remaining < 0 then remaining = 0 end

      for id, cb in pairs(self.UHCC_purchaseControls) do
        local opt = id and UHCC_OPTION_BY_ID[id] or nil
        if cb and cb.IsEnabled and cb.SetEnabled and opt and opt.tab ~= "settings" then
          local forcedFree = optionLocksFreeChoice(opt)
          local deniedSF = uhccOptionDeniedInSelfFound(opt)
          local deniedWeapon = isWeaponPurchaseOption(opt) and (not playerCanUseWeaponTerm(opt.term))
          local plvl = (UnitLevel and UnitLevel("player")) or 0
          local reqLvl = tonumber(opt.minPlayerLevel) or 0
          local lowLvl = ((opt.category == "dungeons") or (opt.category == "battlegrounds")) and reqLvl > 0 and plvl < reqLvl

          local purchased = (UHCC_CharDB.purchases and UHCC_CharDB.purchases[id]) and true or false
          local pending = (UHCC_CharDB.pendingPurchases and UHCC_CharDB.pendingPurchases[id]) and true or false
          local cur = (mmOn and type(self.UHCC_draftPurchases) == "table") and self.UHCC_draftPurchases[id] or nil
          local checked = (cur ~= nil) and (cur and true or false) or purchased or pending

          -- Label text + suffixes (Paid/Pending/In Cart) + dungeon low-level marker.
          if cb.Text and cb.Text.SetText and opt and opt.label then
            local baseText = opt.label .. formatCostSilver(uhccGetDisplayCostForOption(opt))
            if lowLvl then
              baseText = baseText .. (" - lvl %d"):format(reqLvl)
            end
            -- Enemy capital marker (skull) for cities.
            if opt.category == "kalimdor_cities" or opt.category == "ek_cities" then
              local lab = uhccNormalizeNameForCompare(opt.label)
              local enemy = false
              if faction == "Alliance" then
                enemy = (lab == "orgrimmar" or lab == "thunder bluff" or lab == "undercity")
              elseif faction == "Horde" then
                enemy = (lab == "stormwind city" or lab == "darnassus" or lab == "ironforge")
              end
              if enemy then
                baseText = baseText .. " - " .. skullIcon
              end
            end
            cb.UHCC_baseText = baseText
            if mmOn and purchased then
              cb.Text:SetText(baseText .. " - Paid")
            elseif mmOn and pending then
              cb.Text:SetText(baseText .. " - Pending")
            elseif mmOn and cur and (not purchased) and (not pending) then
              cb.Text:SetText(baseText .. " - In Cart")
            else
              cb.Text:SetText(baseText)
            end
          end

          local canToggle = true
          if forcedFree or deniedSF or deniedWeapon then
            canToggle = false
          elseif lowLvl then
            canToggle = false
          elseif mmOn and purchased then
            -- Paid purchases are locked while Money Management is enabled.
            canToggle = false
          elseif checked then
            -- Allow unchecking (except paid-lock case above) to reduce cart.
            canToggle = true
          elseif mmOn then
            -- Only allow checking if affordable with remaining.
            local price = uhccCostToCopper((opt and opt.cost) or 0)
            if price > remaining then
              canToggle = false
            end
          else
            -- Money Management off: normal behavior (toggle allowed).
            canToggle = true
          end

          cb:SetEnabled(canToggle)
          if cb.Text and cb.Text.SetTextColor then
            if canToggle then
              cb.Text:SetTextColor(1, 1, 1, 1)
            else
              cb.Text:SetTextColor(0.7, 0.7, 0.7, 1)
            end
          end
        end
      end
    end
  end

  f:HookScript("OnShow", function(self)
    ensureCharDB()
    if uhccMoneyManagementEnabled() then
      self.UHCC_draftPurchases = {}
      local base = uhccCommittedPurchasesView()
      for k, v in pairs(base) do
        self.UHCC_draftPurchases[k] = v
      end
    else
      self.UHCC_draftPurchases = nil
    end
    if self.UHCC_UpdateMoneyUI then self:UHCC_UpdateMoneyUI() end
  end)
  f:HookScript("OnHide", function(self)
    -- Closing discards draft changes.
    self.UHCC_draftPurchases = nil
    -- If Money Management is ON, Bank Name must be set. If not, force MM OFF on close.
    do
      ensureCharDB()
      if uhccMoneyManagementEnabled() then
        local bn = uhccNormalizeNameForCompare(uhccGetBankNameSetting())
        if bn == "" then
          UHCC_CharDB.settings["SETTINGS-MONEYMGT"] = false
          if self.UHCC_settingsControls and self.UHCC_settingsControls["SETTINGS-MONEYMGT"] then
            local mm = self.UHCC_settingsControls["SETTINGS-MONEYMGT"]
            if mm and mm.SetChecked then mm:SetChecked(false) end
          end
          if self.UHCC_UpdateMoneyUI then self:UHCC_UpdateMoneyUI() end
          print("|cffffcc00UHCC|r: Money Management was disabled because Bank Name is missing.")
        end
      end
    end
  end)

  -- Close button (bottom-right)
  local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  closeBtn:SetSize(120, 26)
  closeBtn:SetPoint("BOTTOMRIGHT", -14, 14)
  closeBtn:SetText("Close")
  closeBtn:SetScript("OnClick", function() f:Hide() end)

  local purchaseBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  purchaseBtn:SetSize(120, 26)
  purchaseBtn:SetPoint("BOTTOMLEFT", 14, 14)
  purchaseBtn:SetText("Purchase")
  purchaseBtn:Hide()
  f.purchaseBtn = purchaseBtn
  purchaseBtn:SetScript("OnClick", function()
    ensureCharDB()
    if not uhccMoneyManagementEnabled() then return end
    if type(f.UHCC_draftPurchases) ~= "table" then return end
    local committed = uhccCommittedPurchasesView()
    local add = uhccComputeAdditionalCostCopperForDraft(f.UHCC_draftPurchases, committed)
    if add <= 0 then return end
    local available = (GetMoney and GetMoney() or 0) - uhccGetMoneyDueCopper()
    if available < add then
      print("|cffffcc00UHCC|r: Not enough available gold (after debt). Pay your debt first.")
      return
    end
    -- Commit draft → pending purchases (not effective until debt is paid).
    for k, v in pairs(f.UHCC_draftPurchases) do
      UHCC_CharDB.pendingPurchases[k] = v
    end
    uhccSetMoneyDueCopper(uhccGetMoneyDueCopper() + add)
    -- Reset draft to committed state.
    f.UHCC_draftPurchases = {}
    local base = uhccCommittedPurchasesView()
    for k, v in pairs(base) do f.UHCC_draftPurchases[k] = v end
    recalcSpentDisplay()
    if f.UHCC_UpdateMoneyUI then f:UHCC_UpdateMoneyUI() end
  end)

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
  if not tex or not tex.SetTexture then return end
  tex:SetTexture("Interface\\Icons\\Ability_Warrior_Rampage")
  -- Gentle inset LibDBIcon-style (~5%); ring in OVERLAY above ARTWORK trims the corners.
  tex:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  tex:SetVertexColor(1, 1, 1, 1)
end

local function createMinimapButton()
  if UHCC.minimapButton then
    positionMinimapButton(UHCC.minimapButton)
    return UHCC.minimapButton
  end

  local btn = CreateFrame("Button", "UHCC_MinimapButton", Minimap)
  UHCC.minimapButton = btn

  -- Same footprint as LibDBIcon-1.0 (Classic Era): aligns icon + TrackingBorder HUD.
  btn:SetSize(31, 31)
  btn:SetFrameStrata("HIGH")
  btn:SetFrameLevel(Minimap:GetFrameLevel() + 8)
  btn:SetMovable(true)
  btn:EnableMouse(true)
  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  btn:RegisterForDrag("LeftButton")

  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  -- BACKGROUND → ARTWORK → OVERLAY: dark chip, then spell art, ring on top (hides square edges).
  local chip = btn:CreateTexture(nil, "BACKGROUND")
  chip:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  chip:SetSize(20, 20)
  chip:SetPoint("TOPLEFT", 7, -5)

  local icon = btn:CreateTexture(nil, "ARTWORK")
  icon:SetSize(17, 17)
  icon:SetPoint("TOPLEFT", 7, -6)
  applyMinimapIcon(icon)
  btn.icon = icon

  local ring = btn:CreateTexture(nil, "OVERLAY")
  ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  ring:SetSize(53, 53)
  ring:SetPoint("TOPLEFT", 0, 0)

  btn:SetAlpha(1)

  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("|cffffcc00UltimateHardcoreChallengeUI|r", 1, 1, 1)
    GameTooltip:AddLine("Left-click: Toggle window", 0.9, 0.9, 0.9)
    GameTooltip:AddLine("Drag: Move icon", 0.9, 0.9, 0.9)
    GameTooltip:AddLine("Command: /uhcc", 0.75, 0.75, 0.75)
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

StaticPopupDialogs["UHCC_CANCEL_DUE_PURCHASE"] = {
  text = "|cffffcc00UHCC|r\n\nAre you sure you want to cancel the due purchase of |cffffcc00%s|r?\n\nThis will remove it from your due cart and reduce your debt accordingly.",
  button1 = YES,
  button2 = NO,
  OnShow = function(self)
    -- Ensure this confirmation stays above the UHCC main window.
    if self and self.SetFrameStrata then
      self:SetFrameStrata("FULLSCREEN_DIALOG")
    end
    if self and self.SetFrameLevel then
      self:SetFrameLevel(7000)
    end
    if self and self.Raise then
      self:Raise()
    end
  end,
  OnAccept = function(_, data)
    ensureCharDB()
    if type(data) ~= "table" then return end
    local opt = data.option
    local cb = data.checkbox
    local id = opt and opt.checkboxId or (cb and cb.checkboxId) or nil
    if not id or not UHCC_CharDB.pendingPurchases or not UHCC_CharDB.pendingPurchases[id] then return end

    UHCC_CharDB.pendingPurchases[id] = nil
    local costCopper = uhccCostToCopper(uhccGetDisplayCostForOption(opt))
    uhccSetMoneyDueCopper(uhccGetMoneyDueCopper() - costCopper)

    local mf = UHCC.mainFrame
    if mf then
      -- Reset draft to committed view (now without this pending item).
      if uhccMoneyManagementEnabled() then
        mf.UHCC_draftPurchases = {}
        local base = uhccCommittedPurchasesView()
        for k, v in pairs(base) do mf.UHCC_draftPurchases[k] = v end
      end
      if cb and cb.SetChecked then cb:SetChecked(false) end
      if mf.UHCC_UpdateMoneyUI then mf:UHCC_UpdateMoneyUI() end
    end
    recalcSpentDisplay()
  end,
  OnCancel = function(_, data)
    -- Restore the checkmark if user cancels.
    if type(data) == "table" and data.checkbox and data.checkbox.SetChecked then
      data.checkbox:SetChecked(true)
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
events:RegisterEvent("UNIT_AURA")
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
events:RegisterEvent("MAIL_SEND_SUCCESS")
events:RegisterEvent("TAXIMAP_OPENED")
events:RegisterEvent("TAXIMAP_CLOSED")
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
    if UHCC and UHCC.mainFrame and UHCC.mainFrame.UHCC_UpdateMoneyUI then
      UHCC.mainFrame:UHCC_UpdateMoneyUI()
    end
  elseif event == "BAG_UPDATE_DELAYED" then
    uhccEnsureBagHighlightHooksInstalled()
    uhccRefreshAllBagHighlights()
    -- Some Classic builds don't reliably fire PLAYER_EQUIPMENT_CHANGED for bag slots.
    -- BAG_UPDATE_DELAYED is a safe fallback to refresh equip violation warnings.
    uhccUpdateEquipViolationOverlay()
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
  elseif event == "UNIT_AURA" then
    if name == "player" then
      uhccUpdateEquipViolationOverlay()
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
  elseif event == "MAIL_SEND_SUCCESS" then
    -- Money Management payment: if player sends gold to the configured bank character, reduce debt.
    ensureCharDB()
    if not uhccMoneyManagementEnabled() then return end
    local bankName = uhccNormalizeNameForCompare(uhccGetBankNameSetting())
    if bankName == "" then return end

    local sentRecipient = uhccLastSendMailRecipient
    if sentRecipient == nil and SendMailNameEditBox and SendMailNameEditBox.GetText then
      sentRecipient = SendMailNameEditBox:GetText()
    end
    local rlow = uhccNormalizeNameForCompare(sentRecipient)
    if rlow ~= bankName then return end

    local money = tonumber(uhccLastSendMailMoneyCopper) or 0
    if money <= 0 and GetSendMailMoney then
      money = tonumber(GetSendMailMoney()) or 0
    end
    if money > 0 then
      local due = uhccGetMoneyDueCopper()
      uhccSetMoneyDueCopper(due - money)
      if uhccGetMoneyDueCopper() <= 0 then
        -- Debt fully paid: activate pending purchases.
        for k, v in pairs(UHCC_CharDB.pendingPurchases or {}) do
          UHCC_CharDB.purchases[k] = v
        end
        UHCC_CharDB.pendingPurchases = {}
      end
      if UHCC.mainFrame and UHCC.mainFrame.UHCC_UpdateMoneyUI then
        UHCC.mainFrame:UHCC_UpdateMoneyUI()
      end
      recalcSpentDisplay()
    end

    -- If mailbox is still locked, restore the bank recipient immediately to avoid warnings.
    if uhccAnnoyEnabled() and (not uhccIsPurchasedById("SERVICE-MAIL")) then
      if SendMailNameEditBox and SendMailNameEditBox.SetText then
        SendMailNameEditBox:SetText(uhccGetBankNameSetting())
      end
    end
  elseif event == "TAXIMAP_OPENED" then
    uhccTaxiMapOpen = true
    uhccUpdateEquipViolationOverlay()
  elseif event == "TAXIMAP_CLOSED" then
    uhccTaxiMapOpen = false
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
