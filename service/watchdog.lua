local skynet = require "skynet"

local watchdog = {}
local gate
local agents = {} -- [fd] = agent_addr

local CMD = {}
local SOCKET = {}

-- 启动网关
function CMD.start(source, conf)
    gate = skynet.newservice("gate")
    skynet.call(gate, "lua", "open", {
        port = conf.port,
        maxclient = conf.maxclient,
        nodelay = true,
        watchdog = skynet.self(),
    })
    skynet.error("网关已成功监听端口: " .. conf.port)
end

-- 客户端连入事件
function SOCKET.open(fd, addr)
    skynet.error(string.format("客户端接入成功 -> fd: %d, IP: %s", fd, addr))
    
    local agent = skynet.newservice("agent")
    agents[fd] = agent
    
	local dynamic_player_id = 1000 + fd

    skynet.call(agent, "lua", "start", {
        gate = gate,
        client = fd,
        player_id = dynamic_player_id
    })
end

-- 客户端断开连接事件
function SOCKET.close(fd)
    skynet.error(string.format("客户端断开连接 -> fd: %d", fd))
    local agent = agents[fd]
    if agent then
        skynet.send(agent, "lua", "disconnect")
        agents[fd] = nil
    end
end

-- 客户端发送数据事件
function SOCKET.data(fd, msg)
    local agent = agents[fd]
    if agent then
        skynet.send(agent, "lua", "client_message", msg)
    end
end

-- 统一分发 socket 子命令
function CMD.socket(source, subcmd, ...)
    local f = SOCKET[subcmd]
    if f then
        f(...)
    else
        skynet.error(string.format("未知 socket 子命令: %s", tostring(subcmd)))
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(source, ...)))
        else
            skynet.error("Watchdog 收到未知指令: " .. tostring(cmd))
        end
    end)
end)
