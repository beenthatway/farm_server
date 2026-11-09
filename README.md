1.目录规划
farm_server/
├── skynet/                 # Skynet 源码子模块(需要自行在根目录下编译skynet)
├── config/                 # 配置文件
│   └── config.farm         # Skynet 启动配置
├── proto/                  # 协议定义 (Sproto 或 Protobuf)
│   └── farm.sproto
├── service/                # 自定义 Skynet 服务脚本
│   ├── main.lua            # 节点启动入口
│   ├── loginserver.lua     # 登录服务
│   ├── agent.lua           # 玩家逻辑服务
│   ├── farm_service.lua    # 农场逻辑服务
│   ├── scene.lua           # 村庄场景服务
│   └── db_proxy.lua        # 数据库代理
├── lualib/                 # 通用逻辑库与模块
│   ├── farm_logic.lua      # 农场数值计算
│   └── aoi.lua             # 场景兴趣点算法
└── run.sh                  # 启动脚本

