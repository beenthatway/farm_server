local skynet = require "skynet"
require "skynet.manager"

local CMD = {}
local agents = {} -- 保存已登录玩家的 agent 服务地址: [player_id] = agent_addr

-- 模拟登录与分配 Agent
function CMD.login(account)
    skynet.error("收到玩家登录请求, 账号: " .. tostring(account))
    
    -- 简单的虚拟分配一个 player_id (实际项目中应从数据库查表)
    local player_id = 1001 -- 为了测试先写死或随机生成
    
    -- 为该玩家创建一个专属的 agent 服务
    local agent = agents[player_id]
    if not agent then
        agent = skynet.newservice("agent")
        -- 初始化 agent
        skynet.call(agent, "lua", "start", { player_id = player_id })
        agents[player_id] = agent
        skynet.error(string.format("为玩家 [%s] 创建了专属 Agent 服务, ID: %d", account, player_id))
    end

    return true, player_id, agent
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            skynet.error("loginserver 未知指令: " .. tostring(cmd))
        end
    end)
    skynet.error("LoginServer 启动成功")
end)
