#!/bin/bash

# 如果需要编译 skynet，可以先执行 make (首次需要)
# cd skynet && make linux && cd ..

# 启动 skynet 并加载配置文件
./skynet/skynet config/config.farm
