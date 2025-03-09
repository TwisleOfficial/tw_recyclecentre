Config = {}

Config.Debug = true

Config.Framework = 'qb'            -- qb , qbx, esx
Config.Notification = 'ox'         -- ox , qb
Config.Inventory = 'ox'            -- ox , qb
Config.Progress = 'ox-circle'      -- ox-normal , ox-circle , qb
Config.OxCirclePosition = 'bottom' -- only matters if Config.Progress = 'ox-circle'

Config.WarehouseData = {
    enterCoords = vec4(55.68, 6472.29, 31.43, 47.81),
    leaveCoords = vec4(1073.01, -3102.63, -39.0, 93.2),
    turnInCoords = vec4(1049.67, -3095.56, -39.0, 0.36),

    blipdata = {
        sprite = 365,
        color = 2,
        scale = 0.8,
        title = 'Recycle Center'
    },

    managerData = {
        model = 'mp_m_waremech_01',
        coords = vec4(1048.34, -3099.35, -39.0, 273.0),

        interaction = {
            enabled = true,
            firstname = 'Rec',
            lastname = 'Plarstic',
            text = 'How are you? Im the manager around here. If you need anything let me know!',
            buttons = {
                {
                    text = 'Id Like To Go On/Off Duty.',
                    event = 'tw-recyclecentre:client:HandleDuty',
                    server = false,
                    close = true,

                },
                {
                    text = 'I dont need anything sorry.',
                    close = true
                },
            }
        }
    },

    pickups = {
        vector4(1067.68, -3095.57, -39.9, 342.39),
        vector4(1065.20, -3095.57, -39.9, 342.39),
        vector4(1062.73, -3095.57, -39.9, 342.39),
        vector4(1060.37, -3095.57, -39.9, 342.39),
        vector4(1057.95, -3095.57, -39.9, 342.39),
        vector4(1055.58, -3095.57, -39.9, 342.39),
        vector4(1053.09, -3095.57, -39.9, 342.39),
        vector4(1053.07, -3102.62, -39.9, 342.39),
        vector4(1055.49, -3102.62, -39.9, 342.39),
        vector4(1057.93, -3102.62, -39.9, 342.39),
        vector4(1060.19, -3102.62, -39.9, 342.39),
        vector4(1062.71, -3102.62, -39.9, 342.39),
        vector4(1065.19, -3102.62, -39.9, 342.39),
        vector4(1067.46, -3102.62, -39.9, 342.39),
        vector4(1067.69, -3109.71, -39.9, 342.39),
        vector4(1065.13, -3109.71, -39.9, 342.39),
        vector4(1062.70, -3109.71, -39.9, 342.39),
        vector4(1060.24, -3109.71, -39.9, 342.39),
        vector4(1057.76, -3109.71, -39.9, 342.39),
        vector4(1055.52, -3109.71, -39.9, 342.39),
        vector4(1053.16, -3109.71, -39.9, 342.39),
    }
}

Config.PickupModels = {
    'prop_boxpile_05a',
    'prop_boxpile_04a',
    'prop_boxpile_06b',
    'prop_boxpile_02c',
    'prop_boxpile_02b',
    'prop_boxpile_01a',
    'prop_boxpile_08a',
}

-- Nice debug function so you dont need to check if Config.Debug is true on every print
function dbug(...)
    if Config.Debug then print('^3[DEBUG]^7', ...) end
end