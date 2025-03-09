local leaveTarget = nil
local enterTarget = nil
local managerPed = nil

local pickupObject = nil

local warData = Config.WarehouseData
local target = exports.ox_target

local onDuty = false
local holding = false

local pickups = {}

local function DoProgress(duration, label, anim)
    if not anim then anim = {} end

    if Config.Progress == 'qb' then
        QBCore.Functions.Progressbar(label, label, duration, false, true, {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            },
            {
                animDict = anim[1],
                anim = anim[2],
            }, {}, {}, function()
                return true
            end, function()
                return false
            end)
    elseif Config.Progress == 'ox-normal' then
        if lib.progressBar({
                duration = duration,
                label = label,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
                anim = {
                    dict = anim[1],
                    cip = anim[2],
                }
            })
        then
            return true
        else
            return false
        end
    else
        if lib.progressCircle({
                duration = duration,
                label = label,
                position = Config.OxCirclePosition,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
                anim = {
                    dict = anim[1],
                    clip = anim[2],
                }
            })
        then
            return true
        else
            return false
        end
    end
end

local function DoNotify(duration, title, desc, type)
    if Config.Notification == 'qb' then
        QBCore.Functions.Notify(title .. ": " .. desc, type, duration)
    else
        lib.notify({
            title = title,
            description = desc,
            type = type,
            duration = duration,
        })
    end
end

local function RequestOurModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
        RequestModel(model)
    end
end

local function DoFade(toCoords)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)

    FreezeEntityPosition(cache.ped, true)
    SetEntityVisible(cache.ped, false, false)
    SetEntityAlpha(cache.ped, 0, false)

    SetEntityCoords(cache.ped, toCoords.x, toCoords.y, toCoords.z - 1, true, false, false, false)
    SetEntityHeading(cache.ped, toCoords.w)

    Citizen.Wait(500)

    SetEntityVisible(cache.ped, true, false)
    SetEntityAlpha(cache.ped, 255, false)
    FreezeEntityPosition(cache.ped, false)

    DoScreenFadeIn(1000)
    Citizen.Wait(1000)
end

local function DutyChange(newState)
    if newState then
        onDuty = true
        DoNotify(2500, 'Rec Job', 'You are on duty!', 'success')
    else
        onDuty = false
        target:removeZone('rec_warehouse_pickup')
        if holding then
            holding = false
            ClearPedTasks(cache.ped)
            DeleteEntity(pickupObject)
        end

        DoNotify(2500, 'Rec Job', 'You are off duty!', 'error')
    end
end

local function PickupPickup()
    if not exports.tw_bridge:doProgress(5000, 'Picking Up Box...', { 'mini@repair', 'fixing_a_ped' }) then
        return
    end

    target:removeZone('rec_warehouse_pickup')

    -- Holding Logic
    local boxModel = 'prop_cs_cardbox_01'
    local anim = {'anim@heists@box_carry@', 'idle'}
    RequestAnimDict(anim[1])
    while not HasAnimDictLoaded(anim[1]) do
        Wait(1)
        RequestAnimDict(anim[1])
        print('Reuqesting : ' .. anim[1])
    end
    TaskPlayAnim(cache.ped, anim[1], anim[2], 5.0, -1, -1, 50, 0, false, false, false)
    RequestOurModel(boxModel)
    pickupObject = CreateObject(boxModel, 0,0,0, true, true,true)
    SetModelAsNoLongerNeeded(boxModel)
    AttachEntityToEntity(pickupObject, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true,
    true, false, true, 1, true)
    holding = true

    Citizen.CreateThread(function()
        while holding do
            Wait(1)
            DrawMarker(2, warData.turnInCoords.x, warData.turnInCoords.y, warData.turnInCoords.z + 3, 0, 0, 0, 180.0, 0, 0, 1.0, 1.0, 1.0, 255,
                0, 0, 100, true, false, 2, false, nil, nil, false)
        end
    end)
end

local function GetPickupLocation()
    local pickupLoc = GetEntityCoords(pickups[math.random(1, #pickups)])

    exports.ox_target:addBoxZone({
        coords = pickupLoc.xyz,
        name = 'rec_warehouse_pickup',
        size = vec3(2.7, 2.7, 2.7),
        rotation = 177.31,
        debug = Config.Debug,
    
        options = { {
            distance = 1.5,
            icon = 'fas fa-box',
            label = 'Pickup Box',
            onSelect = function()
                PickupPickup()
            end
        } }
    })

    Citizen.CreateThread(function()
        while onDuty and not holding do
            Wait(1)
            DrawMarker(2, pickupLoc.x, pickupLoc.y, pickupLoc.z + 3, 0, 0, 0, 180.0, 0, 0, 1.0, 1.0, 1.0, 255,
                0, 0, 100, true, false, 2, false, nil, nil, false)
        end
    end)
end

local function DropOffPickup()
    if not holding then
        exports.tw_bridge:doNotify(2500, 'Rec Job', 'What are you doing', 'error')
        return
    end

    if not exports.tw_bridge:doProgress(5000, 'Dropping Off Box...', { 'mini@repair', 'fixing_a_ped' }) then
        return
    end

    GetPickupLocation()
    holding = false
    ClearPedTasks(cache.ped)
    DeleteEntity(pickupObject)
end

local function SpawnManagerPed()
    local pedData = warData.managerData

    RequestOurModel(pedData.model)

    managerPed = CreatePed(1, pedData.model, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1, pedData.coords.w, false, false)
    FreezeEntityPosition(managerPed, true)
    SetEntityInvincible(managerPed, true)
    SetBlockingOfNonTemporaryEvents(managerPed, true)

    exports.ox_target:addLocalEntity(managerPed, {
        {
            distance = 1.5,
            name = "manager_rec_warehouse",
            icon = 'fas fa-comment',
            label = 'To Talk Manager',
            onSelect = function()
                exports.dialog:OpenDialog(managerPed, pedData.interaction, nil, nil, nil, 400)
            end,
        }
    })
end

local function BuildWarehouse()
    SpawnManagerPed()

    for i, pickup in pairs(warData.pickups) do
        local model = Config.PickupModels[math.random(1 , #Config.PickupModels)]
        RequestOurModel(model)
        local object = CreateObject(model, pickup.x, pickup.y, pickup.z, false, false, false)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        SetEntityInvincible(object, true)
        table.insert(pickups, object)
    end

    local dropOffLoc = warData.turnInCoords
    local dropOff = CreateObject(Config.PickupModels[4], dropOffLoc.x, dropOffLoc.y, dropOffLoc.z,  false, false, false)
    PlaceObjectOnGroundProperly(dropOff)
    FreezeEntityPosition(dropOff, true)
    SetEntityInvincible(dropOff, true)
    table.insert(pickups, dropOff)

    exports.ox_target:addLocalEntity(dropOff, {
        {
            distance = 1.5,
            name = "dz_rec_warehouse",
            icon = 'fas fa-box',
            label = 'Drop Off Pickup',
            onSelect = function()
                DropOffPickup()
            end,
        }
    })
end

local function LeaveWarehouse()
    
    target:removeZone("leave_rec_warehouse")

    TriggerServerEvent('tw-recCenter:server:setPlayerBucket', false)

    for i = 1, #pickups do
        DeleteEntity(pickups[i])
    end
    pickups = {}

    DeleteEntity(managerPed)
    DutyChange(false)

    if holding then
        holding = false
        ClearPedTasks(cache.ped)
        DeleteEntity(pickupObject)
    end

    DoFade(warData.enterCoords)
end

local function EnterWarehouse()
    BuildWarehouse()

    local interiorId = GetInteriorAtCoords(1050.0, -3100.0, -39.0)
    LoadInterior(interiorId)
    RefreshInterior(interiorId)

    TriggerServerEvent('tw-recCenter:server:setPlayerBucket', true)

    DoFade(warData.leaveCoords)

    leaveTarget = target:addBoxZone({
        coords = warData.leaveCoords.xyz,
        name = "leave_rec_warehouse",
        size = vec3(5, 1, 5),
        rotation = warData.leaveCoords.w,
        debug = Config.Debug,
    
        options = { {
            distance = 1.5,
            icon = 'fas fa-door-open',
            label = 'Leave Warehouse',
            onSelect = function()
                LeaveWarehouse()
            end
        } }
    })
end

Citizen.CreateThread(function()
    enterTarget = exports.ox_target:addBoxZone({
        coords = warData.enterCoords.xyz,
        name = "enter_rec_warehouse",
        size = vec3(5, 1, 5),
        rotation = warData.enterCoords.w,
        debug = Config.Debug,
    
        options = { {
            distance = 1.5,
            icon = 'fas fa-door-open',
            label = 'Enter Warehouse',
            onSelect = function()
                EnterWarehouse()
            end
        } }
    })
end)

RegisterNetEvent('tw-recyclecentre:client:HandleDuty', function ()
    if onDuty then
        DutyChange(false)
    else
        DutyChange(true)
        GetPickupLocation()
    end
end)
