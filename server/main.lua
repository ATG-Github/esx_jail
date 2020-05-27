-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
--		   Created By: ElPumpo AKA Hawaii_Beach		      --
--			 Protected By: ATG-Github AKA ATG			  --
-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function checkIfLegit(source, target)
	-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
	--				Let's grab our data...					  --
	-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
	local src, tgt = source, target;
	if src ~= nil and tgt ~= nil then
		local xSrc, xTgt = ESX.GetPlayerFromId(src), ESX.GetPlayerFromId(tgt);
		if xSrc ~= nil and xTgt ~= nil then
			local srcIdent, tgtIdent = xSrc.identifier, xTgt.identifier;
			local srcJob = xSrc.job.name;
			local tgtJob = xTgt.job.name;
			local srcGroup = xSrc.getGroup();
			-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
			--				Let's define legitimacy...			      --
			-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
			local legit = {
				["legit"] = true,
				["reason"] = "No flags found."
			};
			-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
			--				Let's test for legitimacy!			      --
			-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
			if srcJob ~= "police" then
				if srcGroup ~= "admin" and srcGroup ~= "superadmin" then
					legit = {
						["legit"] = false,
						["reason"] = "Source does not have the police job, and is not staff."
					}
					return legit
				end
			end
			-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
			--		     If we've made it here, it's legit!           --
			-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= --
			return legit
		else
			legit = {
				["legit"] = false,
				["reason"] = "xSrc or xTgt == nil."
			}
			return legit
		end
	else
		legit = {
			["legit"] = false,
			["reason"] = "Source or Target == nil."
		}
		return legit
	end
end

-- jail command
TriggerEvent('es:addGroupCommand', 'jail', 'admin', function(source, args, user)
	local src = source;
	local tgt = tonumber(args[1]);
	if args[1] and GetPlayerName(tgt) ~= nil and tonumber(args[2]) then
		local legit = checkIfLegit(src, tgt)
		if legit["legit"] == true then
			TriggerEvent('esx_jail:sendToJail', tgt, tonumber(args[2] * 60))
		else
			print(
				string.format(
					"^2%s^7 -> [^1%s^7] ^1%s^7 has attempted to place [^5%s^7] ^5%s^7 into jail via the ^2jail^7 command. The legitimacy check returned ^1false^7 with the reason of ^2%s^7.",
					GetCurrentResourceName(), src, GetPlayerName(src), tgt, GetPlayerName(tgt), legit["reason"]
				)
			)
		end
	else
		TriggerClientEvent('chat:addMessage', src, { args = { '^1SYSTEM', 'Invalid player ID or jail time!' } } )
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Put a player in jail", params = {{name = "id", help = "target id"}, {name = "time", help = "jail time in minutes"}}})

-- unjail
TriggerEvent('es:addGroupCommand', 'unjail', 'admin', function(source, args, user)
	local src = source;
	local tgt = tonumber(args[1]);
	if args[1] then
		if GetPlayerName(tgt) ~= nil then
			local legit = checkIfLegit(src, tgt)
			if legit["legit"] == true then
				TriggerEvent('esx_jail:unjailQuest', tgt)
			else
				print(
					string.format(
						"^2%s^7 -> [^1%s^7] ^1%s^7 has attempted to remove [^5%s^7] ^5%s^7 from jail via the ^2unjail^7 command. The legitimacy check returned ^1false^7 with the reason of ^2%s^7.",
						GetCurrentResourceName(), src, GetPlayerName(src), tgt, GetPlayerName(tgt), legit["reason"]
					)
				)
			end
		else
			TriggerClientEvent('chat:addMessage', src, { args = { '^1SYSTEM', 'Invalid player ID!' } } )
		end
	else
		local legit = checkIfLegit(src, src)
		if legit["legit"] == true then
			TriggerEvent('esx_jail:unjailQuest', src)
		else
			print(
				string.format(
					"^2%s^7 -> [^1%s^7] ^1%s^7 has attempted to remove theirself from jail via the ^2endcomserv^7 command. The legitimacy check returned ^1false^7 with the reason of ^2%s^7.",
					GetCurrentResourceName(), src, GetPlayerName(src), legit["reason"]
				)
			)
		end
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Unjail people from jail", params = {{name = "id", help = "target id"}}})

-- send to jail and register in database
RegisterServerEvent('esx_jail:sendToJail')
AddEventHandler('esx_jail:sendToJail', function(t, q)
	local src, tgt = source, t;
	local qty = q;

	if src ~= nil and tgt ~= nil then
		local legit = checkIfLegit(src, tgt);
		if legit["legit"] == true then
			local xSrc, xTgt = ESX.GetPlayerFromId(src), ESX.GetPlayerFromId(tgt);
			if xSrc ~= nil and xTgt ~= nil then
				local srcIdent, tgtIdent = xSrc.identifier, xTgt.identifier;

				MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier = @identifier', {
					['@identifier'] = tgtIdent
				}, function(result)
					if result[1] then
						MySQL.Async.execute('UPDATE jail SET jail_time = @jail_time WHERE identifier = @identifier', {
							['@identifier'] = tgtIdent,
							['@jail_time'] = jailTime
						})
					else
						MySQL.Async.execute('INSERT INTO jail (identifier, jail_time) VALUES (@identifier, @jail_time)', {
							['@identifier'] = tgtIdent,
							['@jail_time'] = jailTime
						})
					end
				end)
				
				TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('jailed_msg', GetPlayerName(tgt), ESX.Math.Round(jailTime / 60)) }, color = { 147, 196, 109 } })
				TriggerClientEvent('esx_policejob:unrestrain', tgt)
				TriggerClientEvent('esx_jail:jail', tgt, jailTime)
			end
		else
			print(
				string.format(
					"^2%s^7 -> [^1%s^7] ^1%s^7 has attempted to remove [^5%s^7] ^5%s^7 from jail via the ^2sendToJail^7 event. The legitimacy check returned ^1false^7 with the reason of ^2%s^7.",
					GetCurrentResourceName(), src, GetPlayerName(src), tgt, GetPlayerName(tgt), legit["reason"]
				)
			)
		end
	end
end)

-- should the player be in jail?
RegisterServerEvent('esx_jail:checkJail')
AddEventHandler('esx_jail:checkJail', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local identifier = GetPlayerIdentifiers(_source)[1] -- get steam identifier

	MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] ~= nil then
			TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('jailed_msg', GetPlayerName(_source), ESX.Math.Round(result[1].jail_time / 60)) }, color = { 147, 196, 109 } })
			TriggerClientEvent('esx_jail:jail', _source, tonumber(result[1].jail_time))
		end
	end)
end)

-- unjail via command
RegisterServerEvent('esx_jail:unjailQuest')
AddEventHandler('esx_jail:unjailQuest', function(t)
	local src, tgt = source, t;
	local legit = checkIfLegit(src, tgt);
	if legit["legit"] == true then
		unjail(tgt)
	else
		print(
			string.format(
				"^2%s^7 -> [^1%s^7] ^1%s^7 has attempted to remove [^5%s^7] ^5%s^7 from jail via the ^2unjailQuest^7 event. The legitimacy check returned ^1false^7 with the reason of ^2%s^7.",
				GetCurrentResourceName(), src, GetPlayerName(src), tgt, GetPlayerName(tgt), legit["reason"]
			)
		)
	end
end)

-- unjail after time served
RegisterServerEvent('esx_jail:unjailTime')
AddEventHandler('esx_jail:unjailTime', function()
	unjail(source)
end)

-- keep jailtime updated
RegisterServerEvent('esx_jail:updateRemaining')
AddEventHandler('esx_jail:updateRemaining', function(jailTime)
	local identifier = GetPlayerIdentifiers(source)[1]
	MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE jail SET jail_time = @jailTime WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@jailTime'] = jailTime
			})
		end
	end)
end)

function unjail(target)
	local identifier = GetPlayerIdentifiers(target)[1]
	MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('DELETE from jail WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})

			TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('unjailed', GetPlayerName(target)) }, color = { 147, 196, 109 } })
		end
	end)

	TriggerClientEvent('esx_jail:unjail', target)
end
