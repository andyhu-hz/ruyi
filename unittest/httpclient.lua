package.path = "../3rd/skynet/lualib/?.lua;" .. package.path
package.cpath = "../3rd/skynet/luaclib/?.so;" .. package.cpath
package.cpath = "../3rd/lsocket/?.so;" .. package.cpath
package.path = "../src/?.lua;" .. package.path

lunit = require "lunitx"
ls = require "lsocket"
_ENV = lunit.module('handshake request','seeall')

local proto = require "protocol"
local socket = require "clientsocket"
local sproto = require "sproto"
local common = require "common"

if _VERSION ~= "Lua 5.3" then
    error "Use lua 5.3"
end

url = "http://127.0.0.1:8080/"
local host, port, path = string.match(url, "^http://([^:/]+):?(%d*)(/?.*)$")

function setup()
    if not host then
    	error("invalid url.")
    end

    if #port == 0 then port = 80 end
    if #path == 0 then path = "/" end
    sock, err = ls.connect(host, port)
    if not sock then
    	error(err)
    end

    -- wait for connect() to succeed or fail
    ls.select(nil, {sock})
    ok, err = sock:status()
    if not ok then
    	error(err)
    end
end

function teardown()
  foobar = nil
end

function test1()
    rq = "GET " .. path .. " HTTP/1.1\r\n"
    rq = rq .. "Host: " .. host .. ":" .. port .. "\r\n"
    rq = rq .. "Connection: close\r\n"
    rq = rq .. "\r\n"

    sent = 0
    repeat
        ls.select(nil, {sock})
        sent = sent + sock:send(string.sub(rq, sent, -1))
    until sent == #rq

    reply = ""
    repeat
        ls.select({sock})
        str, err = sock:recv()
        if str then
            reply = reply .. str
        elseif err then
            error(err)
        end
    until not str

    --print(reply)
    assert_equal(140, #reply)
end
