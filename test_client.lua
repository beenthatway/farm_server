-- 正确配置 Skynet 的 Lua 库路径和 C 动态库路径
package.path = "skynet/lualib/?.lua;lualib/?.lua;?.lua"
package.cpath = "skynet/luaclib/?.so;skynet/cservice/?.so"

local socket = require "client.socket" -- Skynet 客户端网络库位于 client.socket 或 socket

print("正在连接服务端 127.0.0.1:8888 ...")
local fd = socket.connect("127.0.0.1", 8888)

if not fd then
    print("连接服务器失败！")
    return
end

print("连接成功！正在发送测试数据...")
-- 向服务器发送一条测试消息
socket.send(fd, "Hello Server, I am a farmer!")

-- 循环读取服务端返回的数据
while true do
    -- 尝试读取服务端发回的内容
    local chunk = socket.recv(fd)
    if chunk then
        print("收到服务端回包: ", chunk)
    else
        -- 没有数据时稍微休眠释放 CPU
        socket.usleep(100000)
    end
end

socket.close(fd)
