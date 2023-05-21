Notify = function(type, text)
    if Config.Notify == 'dlrms' then
        exports['dlrms_notify']:SendAlert(type, text)
    elseif Config.Notify == 'mythic' then
        exports['mythic_notify']:SendAlert(type, text)
    elseif Config.Notify == 'other' then
        -- Notify Stuff Here
    end
end