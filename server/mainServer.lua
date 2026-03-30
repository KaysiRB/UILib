-- ACE permissions
local acePermissions = {
    'command.testui1',
    'command.testui2',
    'command.testui3',
    'command.ui_lib_test'
}

for _, cmd in ipairs(acePermissions) do
    ExecuteCommand(('add_ace group.admin %s allow'):format(cmd))
end