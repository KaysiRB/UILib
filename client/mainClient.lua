local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, true)
end

-- TEST 1: Menu principal avec tous types
RegisterCommand('testui1', function()
    exports['UILib']:CreateMenu("🎮 UILib Demo - Tous types", {maxVisible = 10}, function()
        exports['UILib']:Button("Simple bouton", "Test callback", function()
            notify("Bouton cliqué !")
        end)
        
        local god = false
        exports['UILib']:Toggle("God Mode", god, function(state)
            god = state
            SetEntityInvincible(PlayerPedId(), state)
            notify("God: " .. (state and "ON" or "OFF"))
        end)
        
        exports['UILib']:Slider("NoClip Speed", 1.0, 5.0, 1.0, function(value)
            notify("Vitesse: " .. value)
        end)
    end)
end)

-- TEST 2: Submenus imbriqués
RegisterCommand('testui2', function()
    exports['UILib']:CreateMenu("📁 Navigation", {}, function()
        exports['UILib']:SubMenu("Armes", function()
            exports['UILib']:Button("Pistol", function()
                GiveWeaponToPed(PlayerPedId(), `WEAPON_PISTOL`, 250, false, true)
            end)
            exports['UILib']:Button("AK47", function()
                GiveWeaponToPed(PlayerPedId(), `WEAPON_ASSAULTRIFLE`, 250, false, true)
            end)
        end)
        
        exports['UILib']:SubMenu("Véhicules", function()
            exports['UILib']:Button("Adder", function()
                local hash = `adder`
                RequestModel(hash)
                while not HasModelLoaded(hash) do Wait(0) end
                local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 5.0, 0)
                CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), true, false)
            end)
        end)
    end)
end)

-- TEST 3: Player list dynamique
RegisterCommand('testui3', function()
    exports['UILib']:PlayerList("Admin Players", function(id, name)
        notify("Selected: " .. name .. " (" .. id .. ")")
    end)
end)

-- Keybind rapide
RegisterKeyMapping('ui_lib_test', 'Ouvrir UILib Demo', 'keyboard', 'F5')
RegisterCommand('ui_lib_test', function() TriggerEvent('testui1') end)