Config = {}

Config.Notify = 'dlrms' -- 'dlrms' / 'mythic' / 'other'

Config.CheckInTimer = 5 -- Check in timer in seconds
Config.CheckInPrice = 300 -- Check in price
Config.HealingTimer = 10 -- Amount of time it takes for the player to be healed in the bed in seconds
Config.PedDist = 5.0 -- Distance for ped to spawn
Config.RespawnCoords = vector4(311.98, -588.98, 43.28, 69.8) -- Where you spawn after being healed

Config.CheckIn = {
    {
        name = 'pillboxcheckin',
        ped = 's_m_m_doctor_01',
        coords = vector4(308.6, -595.39, 43.28, 72.11)
    }
}

Config.BedCoords = {
    vector4(314.57, -584.04, 44.2, 345.6),
    vector4(311.22, -582.62, 44.2, 345.6)
}