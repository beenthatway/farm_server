local skynet = require "skynet"

local lands = {} -- 保存所有玩家的农田数据: [player_id] = { [land_id] = crop_info }

local CMD = {}

-- 播种指令
function CMD.plant(player_id, land_id, crop_type)
    lands[player_id] = lands[player_id] or {}
    
    local now = skynet.time()
    local mature_time = 30 -- 假设 30 秒成熟
    
    lands[player_id][land_id] = {
        crop_type = crop_type,
        plant_time = now,
        mature_at = now + mature_time,
        status = "growing"
    }

    -- 注册 Skynet 定时器处理成熟逻辑
    skynet.timeout(mature_time * 100, function()
        if lands[player_id] and lands[player_id][land_id] then
            lands[player_id][land_id].status = "mature"
            skynet.error(string.format("玩家 [%d] 地块 [%d] 的作物 [%s] 已成熟！", player_id, land_id, crop_type))
            
            -- 可以向玩家在线的 Agent 推送消息
            -- skynet.send(agent_addr, "lua", "notify", "crop_mature", land_id)
        end
    end)

    return true, "播种成功"
end

-- 收割指令
function CMD.harvest(player_id, land_id)
    local player_lands = lands[player_id]
    if not player_lands or not player_lands[land_id] then
        return false, "该地块未种植任何作物"
    end

    local land = player_lands[land_id]
    if land.status ~= "mature" then
        return false, "作物未成熟，无法收割"
    end

    local crop_type = land.crop_type
    player_lands[land_id] = nil -- 清空农田

    return true, { crop = crop_type, count = 3 }
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            skynet.error("未知指令: " .. tostring(cmd))
        end
    end)
end)
