local UILib = {}
local menuStack = {}
local currentMenu = nil
local menuItems = {}
local callbacks = {}

-- Core render
local function renderMenu()
    local safeItems = {}
    for i, item in ipairs(menuItems) do
        safeItems[i] = {
            label = item.label or "",
            desc = item.desc or ""
        }
    end
    
    SendNUIMessage({
        action = "openMenu",
        menu = {
            title = currentMenu.title,
            items = safeItems
        }
    })
end

-- Auto back button
local function addBackButton()
    if #menuStack > 0 then
        table.insert(menuItems, { label = "← Back", type = "back" })
        table.insert(callbacks, function()
            local prev = table.remove(menuStack)
            currentMenu = prev.menu
            menuItems = prev.items
            callbacks = prev.callbacks
            renderMenu()
        end)
    end
end

-- Exports publics
function UILib.CreateMenu(title, options, builder)
    menuItems = {}
    callbacks = {}
    local opts = options or {}
    currentMenu = {
        title = title,
        maxVisible = opts.maxVisible or 12,
        theme = opts.theme or "default"
    }
    
    builder()
    addBackButton()
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    renderMenu()
end

function UILib.Button(label, description, cb)
    table.insert(menuItems, {label = label, desc = description, type = "button"})
    table.insert(callbacks, #menuItems, cb)
end

function UILib.Toggle(label, state, cb)
    local function getLabel() return label .. " [" .. (state and "ON" or "OFF") .. "]" end
    
    table.insert(menuItems, {label = getLabel(), state = state, type = "toggle"})
    local idx = #menuItems
    callbacks[idx] = function()
        state = not state
        cb(state)
        menuItems[idx].label = getLabel()
        menuItems[idx].state = state
        SendNUIMessage({action = "updateItem", index = idx-1, label = getLabel(), state = state})
    end
end

function UILib.Slider(label, min, max, value, cb)
    table.insert(menuItems, {
        label = label, 
        type = "slider", 
        min = min, 
        max = max, 
        value = value
    })
    local idx = #menuItems
    callbacks[idx] = function(newValue)
        value = newValue
        cb(value)
        menuItems[idx].value = value
        SendNUIMessage({action = "updateItem", index = idx-1, value = value})
    end
end

function UILib.SubMenu(label, builder)
    table.insert(menuItems, {label = label .. " →", type = "submenu"})
    local idx = #menuItems
    callbacks[idx] = function()
        table.insert(menuStack, {
            menu = currentMenu,
            items = menuItems,
            callbacks = callbacks
        })
        
        menuItems = {}
        callbacks = {}
        currentMenu = {title = label, parent = true}
        
        builder()
        addBackButton()
        renderMenu()
    end
end

function PlayerList(title, callback)
    CreateMenu(title, function()
        for id = 0, 128 do
            if NetworkIsPlayerActive(id) then
                local serverId = GetPlayerServerId(id)
                local name = GetPlayerName(id) or "Unknown"
                Button(name .. " (ID:" .. serverId .. ")", function()
                    callback(serverId, name)
                end)
            end
        end
        Finish()
    end)
end
exports('PlayerList', PlayerList)

function UILib.Finish() end
function UILib.Close()
    menuStack = {}
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({action = "closeMenu"})
end

-- NUI Callbacks
RegisterNUICallback("select", function(data, cb)
    local idx = data.index + 1
    if callbacks[idx] then callbacks[idx](data.value) end
    cb("ok")
end)

RegisterNUICallback("closeMenu", function(_, cb)
    UILib.Close()
    cb("ok")
end)

-- Exports globaux
exports('CreateMenu', UILib.CreateMenu)
exports('Button', UILib.Button)
exports('Toggle', UILib.Toggle)
exports('Slider', UILib.Slider)
exports('SubMenu', UILib.SubMenu)
exports('Close', UILib.Close)