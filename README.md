# OpenWRT-CI
云编译OpenWRT固件

官方版：
https://github.com/immortalwrt/immortalwrt.git

高通版：
https://github.com/VIKINGYFY/immortalwrt.git

# 固件简要说明：

仅选择 QCA-ALL 编译

# 目录简要说明：

workflows——自定义CI配置

Scripts——自定义脚本

Config——自定义配置

# 以下是该仓库对上游进行的调整

1.
.github/workflows/Auto-Clean.yml
去除每天早上4点自动清理

2.
.github/workflows/OWRT-ALL.yml
去除每天早上4点自动清理后自动编译

3.
.github/workflows/QCA-ALL.yml
去除每天早上4点自动清理后自动编译
每天早上4点自动编译

4.
.github/workflows/WRT-CORE.yml
	sudo apt-get update -yqq
	sudo apt-get install -yqq clang-13
更新clang-13

内置 btop 简单明了的系统资源占用查看工具
内置 curl 网络通信工具
内置 kmod-tcp-bbr BBR 拥塞控制算法替换Cubic(单车变摩托)