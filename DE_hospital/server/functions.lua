Notify = function(source, type, text)
    if Config.Notify == 'dlrms' then
        TriggerClientEvent('dlrms_notify', source, type, text)
    elseif Config.Notify == 'mythic' then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = type, text = text })
    elseif Config.Notify == 'other' then
        -- notify stuff here
        TriggerClientEvent('ox_lib:notify', source, {type = type, description = text})
    end
end