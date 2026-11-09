local aoi = {}
local GRID_SIZE = 10 -- 每个格子的大小（米/像素坐标）

local grids = {}   -- [grid_key] = { [player_id] = agent_addr }
local players = {} -- [player_id] = { x = 0, y = 0, grid_key = "" }

local function get_grid_key(x, y)
    local gx = math.floor(x / GRID_SIZE)
    local gy = math.floor(y / GRID_SIZE)
    return gx .. "_" .. gy
end

-- 玩家进入场景或移动
function aoi.update_position(player_id, agent_addr, x, y)
    local new_key = get_grid_key(x, y)
    local p = players[player_id]

    if not p then
        -- 新玩家加入
        players[player_id] = { addr = agent_addr, x = x, y = y, grid_key = new_key }
        grids[new_key] = grids[new_key] or {}
        grids[new_key][player_id] = agent_addr
    elseif p.grid_key ~= new_key then
        -- 跨格子了，从旧格子移除，加入新格子
        if grids[p.grid_key] then
            grids[p.grid_key][player_id] = nil
        end
        grids[new_key] = grids[new_key] or {}
        grids[new_key][player_id] = agent_addr
        p.grid_key = new_key
        p.x, p.y = x, y
    else
        p.x, p.y = x, y
    end
end

-- 获取九宫格内的所有其他玩家（用于广播种地、动作）
function aoi.get_surrounding_agents(player_id)
    local p = players[player_id]
    if not p then return {} end

    local gx, gy = string.match(p.grid_key, "(%d+)_(%d+)")
    gx, gy = tonumber(gx), tonumber(gy)

    local neighbors = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            local key = (gx + dx) .. "_" .. (gy + dy)
            local g = grids[key]
            if g then
                for pid, addr in pairs(g) do
                    if pid ~= player_id then
                        table.insert(neighbors, { player_id = pid, addr = addr })
                    end
                end
            end
        end
    end
    return neighbors
end

return aoi
