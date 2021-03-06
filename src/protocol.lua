local sprotoparser = require "sprotoparser"

local protocol = {}

protocol.c2s = sprotoparser.parse [[
.package {
    type 0 : integer
    session 1 : integer
}
handshake 1 {
    response {
        msg 0  : string
    }
}
get 2 {
    request {
        what 0 : string
    }
    response {
        result 0 : string
    }
}
set 3 {
    request {
        what 0 : string
        value 1 : string
    }
}
quit 4 {}
]]

protocol.s2c = sprotoparser.parse [[
.package {
    type 0 : integer
    session 1 : integer
}

heartbeat 1 {
    request {
        time 0 : string
    }
}
]]

return protocol
