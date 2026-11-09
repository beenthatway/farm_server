local skynet = require "skynet"
require "skynet.manager"

skynet.start(function()
    skynet.error("=== 农村经营 MMORPG 服务端启动中 ===")

    -- 1. 启动数据库服务
    local db = skynet.uniqueservice("db_proxy")
    skynet.call(db, "lua", "init")

    -- 2. 启动农场系统服务
    skynet.uniqueservice("farm_service")

    -- 3. 启动村庄场景服务
    skynet.uniqueservice("scene")

    -- 4. 启动登录服务
    skynet.uniqueservice("loginserver")

    -- 5. 启动网络看门狗（由 Watchdog 去拉起网关并管理连接）
    local watchdog = skynet.newservice("watchdog")
    skynet.call(watchdog, "lua", "start", {
        port = 8888,
        maxclient = 1000,
    })

    skynet.error("=== 服务端全部启动成功，等待客户端连入 ===")
end)
