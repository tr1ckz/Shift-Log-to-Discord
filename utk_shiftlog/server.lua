ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local timers = { -- if you want more job shifts add table entry here same as the examples below
    ambulance = {
        {} -- don't edit inside
    },
    police = {
        {} -- don't edit inside
    },
    mechanic = {
        {}

    },
    cardealer = {
        {}
        }
}

local dcname = "Shift Logger" -- bot's name
local http = "" -- webhook for police
local http2 = "" -- webhook for ems (you can add as many as you want)
local http3 = "" -- mechanic
local http4 = "" -- VCM
local avatar = "" -- bot's avatar
local mechavatar = "https://www.dafont.com/forum/attach/orig/8/8/880398.jpg"
local emsavatar = ""
local policeavatar = "https://www.logolynx.com/images/logolynx/60/6081a70682994e87ee9dc3395928a5d8.jpeg"
local vcmavatar = "https://images.vexels.com/media/users/3/147726/isolated/preview/3c35c23c922833a71a94e7d5faf28b88-car-sale-service-logo-by-vexels.png"

function DiscordLog(name, message, color, job)
    local connect = {
        {
            ["color"] = color,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "",
            },
        }
    }
    if job == "police" then
        PerformHttpRequest(http, function(err, text, headers) end, 'POST', json.encode({username = dcname, embeds = connect, avatar_url = policeavatar}), { ['Content-Type'] = 'application/json' })
    elseif job == "ambulance" then
        PerformHttpRequest(http2, function(err, text, headers) end, 'POST', json.encode({username = dcname, embeds = connect, avatar_url = emsavatar}), { ['Content-Type'] = 'application/json' })
    elseif job == "mechanic" then
        PerformHttpRequest(http3, function(err, text, headers) end, 'POST', json.encode({username = dcname, embeds = connect, avatar_url = mechavatar}), { ['Content-Type'] = 'application/json' })
    elseif job == "cardealer" then
        PerformHttpRequest(http4, function(err, text, headers) end, 'POST', json.encode({username = dcname, embeds = connect, avatar_url = vcmavatar}), { ['Content-Type'] = 'application/json' })
    end
end

RegisterServerEvent("utk_sl:userjoined")
AddEventHandler("utk_sl:userjoined", function(job)
    local id = source
    local xPlayer = ESX.GetPlayerFromId(id)
    local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    local firstname = result[1].firstname
    local lastname  = result[1].lastname

    table.insert(timers[job], {id = id, identifier = xPlayer.identifier, firstname = firstname, lastname = lastname, time = os.time(), date = os.date("%d/%m/%Y %X")})
end)

RegisterServerEvent("utk_sl:jobchanged")
AddEventHandler("utk_sl:jobchanged", function(old, new, method)
    local xPlayer = ESX.GetPlayerFromId(source)
    local header = nil
    local color = nil
    local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    local firstname = result[1].firstname
    local lastname  = result[1].lastname

    if old == "police" then
        header = "Police Shift" -- Header
        color = 3447003 -- Color
    elseif old == "ambulance" then
        header = "EMS Shift"
        color = 15158332
    elseif job == "mechanic" then
        header = "Mechanic Shift"
        color = 8421504
    elseif job == "cardealer" then
        header = "VCM Shift"
        color = 8447718
    end
    if method == 1 then
        for i = 1, #timers[old], 1 do
            if timers[old][i].identifier == xPlayer.identifier then
                local duration = os.time() - timers[old][i].time
                local date = timers[old][i].date
                local timetext = nil

                if duration > 0 and duration < 60 then
                    timetext = tostring(math.floor(duration)).." seconds"
                elseif duration >= 60 and duration < 3600 then
                    timetext = tostring(math.floor(duration / 60)).." minutes"
                elseif duration >= 3600 then
                    timetext = tostring(math.floor(duration / 3600).." hours, "..tostring(math.floor(math.fmod(duration, 3600)) / 60)).." minutes"
                end
                DiscordLog(header , "Name: **"..timers[old][i].firstname.. " " ..timers[old][i].lastname.. "**\n Shift duration: **__"..timetext.."__**\n Start date: **"..date.."**\n End date: **"..os.date("%d/%m/%Y %X").."**", color, old)
                table.remove(timers[old], i)
                break
            end
        end
    end
    if not (timers[new] == nil) then
        for t, l in pairs(timers[new]) do
            if l.id == xPlayer.source then
                table.remove(table[new], l)
            end
        end
    end
    if new == "police" or new == "ambulance" or new == "mechanic" or new == "cardealer" then
        table.insert(timers[new], {id = xPlayer.source, identifier = xPlayer.identifier, firstname = firstname, lastname = lastname, time = os.time(), date = os.date("%d/%m/%Y %X")})
    end

end)

AddEventHandler("playerDropped", function(reason)
    local id = source
    local header = nil
    local color = nil
    local xPlayer = ESX.GetPlayerFromId(source)
    local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    local firstname = result[1].firstname
    local lastname  = result[1].lastname

    for k, v in pairs(timers) do
        for n = 1, #timers[k], 1 do
            if timers[k][n].id == id then
                local duration = os.time() - timers[k][n].time
                local date = timers[k][n].date
                local timetext = nil

                if k == "police" then
                    header = "Police Shift"
                    color = 3447003
                elseif k == "ambulance" then
                    header = "EMS Shift"
                    color = 15158332
                elseif job == "mechanic" then
                    header = "Mechanic Shift"
                    color = 8421504
                elseif job == "cardealer" then
                    header = "VCM Shift"
                    color = 8447718
                end
                if duration > 0 and duration < 60 then
                    timetext = tostring(math.floor(duration)).." seconds"
                elseif duration >= 60 and duration < 3600 then
                    timetext = tostring(math.floor(duration / 60)).." minutes"
                elseif duration >= 3600 then
                    timetext = tostring(math.floor(duration / 3600).." hours, "..tostring(math.floor(math.fmod(duration, 3600)) / 60)).." minutes"
                end
                DiscordLog(header, "Name: **"..timers[k][n].firstname.. " " ..timers[k][n].lastname.. "**\n Shift duration: **__"..timetext.."__**\n Start date: **"..date.."**\n End date: **"..os.date("%d/%m/%Y %X").."**", color, k)
                table.remove(timers[k], n)
                return
            end
        end
    end
end)

--DiscordLog("[utk_shiftlog]", "Shift logger started!", 3447003, "police")
