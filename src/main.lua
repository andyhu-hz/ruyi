local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 100000

skynet.start(function()
    print("Running ruyi server under skynet directory")
    skynet.uniqueservice("protoloader")
    local console = skynet.newservice("console")
    skynet.newservice("debug_console",8000)
    skynet.newservice("simpledb")
    local watchdog = skynet.newservice("watchdog")
    skynet.call(watchdog, "lua", "start", {
        port = 5000,
        maxclient = max_client,
        nodelay = true,
    })
    print("Watchdog listen on port ", 5000)

    skynet.exit()
end)
