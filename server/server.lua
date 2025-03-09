local warehouseKey = os.time() * math.random(1000, 9999)

RegisterNetEvent('tw-recCenter:server:setPlayerBucket', function (state)
  if state then
    SetPlayerRoutingBucket(source, tonumber(warehouseKey))
  else
    SetPlayerRoutingBucket(source, 0)
  end
end)