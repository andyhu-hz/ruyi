package.path = "../3rd/skynet/lualib/?.lua;" .. package.path
package.cpath = "../3rd/skynet/luaclib/?.so;" .. package.cpath
package.path = "../src/?.lua;" .. package.path

if _VERSION ~= "Lua 5.3" then
    error "Use lua 5.3"
end

lunit = require "lunitx"
_ENV = lunit.module('handshake request','seeall')

local proto = require "protocol"
local socket = require "clientsocket"
local sproto = require "sproto"
local common = require "common"

local host = nil 
local request = nil

local fd = 0
local session = 0
local last = ""

local function send_package(fd, pack)
    assert(fd)
    local package = string.pack(">s2", pack)
    socket.send(fd, package)
end

local function unpack_package(text)
    local size = #text
    if size < 2 then
        return nil, text
    end
    local s = text:byte(1) * 256 + text:byte(2)
    if size < s+2 then
        return nil, text
    end
    return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
    local result
    result, last = unpack_package(last)
    if result then
        return result, last
    end
    local r = socket.recv(fd)
    if not r then
        return nil, last
    end
    if r == "" then
        error "Server closed"
    end
    return unpack_package(last .. r)
end

local function dispatch_package()
    while true do
        local v
        v, last = recv_package(last)
        if not v then
            break
        end
        return host:dispatch(v)
    end
end

local function get_response()
     while true do
         local t, s, content
         t, s, content = dispatch_package()
         if t or s or content then
            return t, s, content
         end
     end
end

local function send_request(name, args)
    session = session + 1
    local str = request(name, args, session)
    send_package(fd, str)
    --print("Request: "..name..", session="..session)
end

function setup()
    fd = assert(socket.connect("127.0.0.1", 5000))
    host = sproto.new(proto.s2c):host "package"
    request = host:attach(sproto.new(proto.c2s))
end

function teardown()
    fd = 0
end

function test1()
    send_request("handshake")
    local t, s, content = get_response()
    assert_equal("RESPONSE", t)
    assert_equal(session, s)
    assert_equal("server handshake responese", content['msg'])
end
