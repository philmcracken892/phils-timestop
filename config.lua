
Config = {}

Config.Debug = false

Config.TriggerHour = 22  
Config.TriggerMinute = 30 
Config.slomo = 0.1

Config.TimeCheckInterval = 1


Config.AdvanceMinutesAfterEvent = 20


Config.PremonitionDuration = 0
Config.FreezeDuration = 60
Config.ExtraAnomalyChance = 0  


Config.GlobalEvent = false  -- true = server-wide, false = only in active areas


Config.ActiveAreas = {
    {x = -278.21, y = 807.05, z = 119.38, radius = 250.0},  -- Valentine town center (sheriff station area)
    {x = 2519.44, y = -1309.52, z = 46.74, radius = 300.0}  -- Saint Denis core (police HQ/market area)
}


Config.AllowManualItemTrigger = true
Config.ManualTriggerItemName = 'cursed_watch'  -- Item name in RSGCore items