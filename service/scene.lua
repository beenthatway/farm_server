local skynet = require "skynet"
local aoi = require "aoi" -- 引入我们之前写的 AOI 模块

local CMD = {}

function CMD.init()
    skynet.error("村庄场景与 AOI 服务初始化成功")
end

-- 玩家移动并更新九宫格位置
function CMD.update_pos(player_id, agent_addr, x, y)
    aoi.update_position(player_id, agent_addr, x, y)
    local neighbors = aoi.get_surrounding_agents(player_id)
    return neighbors
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
    end)
end)
