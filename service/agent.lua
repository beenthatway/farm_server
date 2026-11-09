local skynet = require "skynet"

local gate
local client_fd
local player_id
local farm_service

local CMD = {}

function CMD.start(conf)
    gate = conf.gate
    client_fd = conf.client
    player_id = conf.player_id
    farm_service = skynet.uniqueservice("farm_service")
    skynet.error(string.format("玩家 Agent 初始化完成, PlayerID: %d, Client FD: %d", player_id, client_fd))
end

-- 收到客户端发来的消息
function CMD.client_message(msg)
    skynet.error("收到客户端发来的原始消息字节长度: " .. #msg)
    -- 后续在这里解析协议（如 Sproto 或 Protobuf）并派发给种地、收割逻辑

	--local response_str = "Server received your message!"
    --skynet.send(gate, "lua", "write", client_fd, response_str)
	local reply_msg = "Echo from Server: " .. msg

    -- 包装成 Skynet gate 能识别的写指令
    skynet.send(gate, "lua", "write", client_fd, reply_msg)

end

function CMD.disconnect()
    skynet.error(string.format("玩家 [%d] 下线或断开", player_id))
    skynet.exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
    end)
end)
