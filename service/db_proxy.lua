local skynet = require "skynet"
local redis = require "skynet.db.redis"

local db

local CMD = {}

function CMD.init()
    -- 连接 Redis 数据库（可以根据实际部署修改配置）
    db = redis.connect({
        host = "127.0.0.1",
        port = 6379,
        db = 0,
    })
    skynet.error("Redis 数据库代理连接成功")
end

-- 保存玩家农田数据到 Redis Hash
function CMD.save_land(player_id, land_id, crop_type, mature_at)
    local key = "player:land:" .. player_id
    db:hset(key, land_id, string.format("%s:%s", crop_type, mature_at))
end

-- 读取玩家农田数据并计算离线成熟状态
function CMD.get_and_check_lands(player_id)
    local key = "player:land:" .. player_id
    local data = db:hgetall(key)
    -- 返回给逻辑层进行解析和离线收益结算
    return data
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
    end)
end)
