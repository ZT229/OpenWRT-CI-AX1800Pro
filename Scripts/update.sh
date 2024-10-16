#更新 OpenWRT 的包源并安装所有包
echo "更新包源并安装包..."
./scripts/feeds update -a || { echo "feeds update 失败"; exit 1; }
./scripts/feeds install -a || { echo "feeds install 失败"; exit 1; }

#更新 OpenWRT 源码
echo "正在更新 OpenWRT 源码..."
git pull || { echo "git pull 失败"; exit 1; }

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	HP_RULES="surge"
	HP_PATCH="homeproxy/root/etc/homeproxy"

	chmod +x ./$HP_PATCH/scripts/*
	rm -rf ./$HP_PATCH/resources/*

	git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" ./$HP_RULES/
	cd ./$HP_RULES/ && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

	echo $RES_VER | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver
	awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
	sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt
	mv -f ./{china_*,gfw_list}.{ver,txt} ../$HP_PATCH/resources/

	cd .. && rm -rf ./$HP_RULES/

	echo "homeproxy date has been updated!"
fi

#移除Shadowsocks组件
PW_FILE=$(find ./feeds -maxdepth 3 -type f -wholename "*/luci-app-passwall/Makefile")
if [ -f "$PW_FILE" ]; then
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks_Libev/,/x86_64/d' $PW_FILE
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR/,/default n/d' $PW_FILE
	sed -i '/Shadowsocks_NONE/d; /Shadowsocks_Libev/d; /ShadowsocksR/d' $PW_FILE

	echo "passwall has been fixed!"
fi

# 修改默认主机名
CFG_FILE="./package/base-files/files/bin/config_generate"
if [ -f "$CFG_FILE" ]; then
    if grep -q "hostname='$wrt_name'" "$CFG_FILE"; then
        echo "hostname='$wrt_name'，跳过修改"
    else
        echo "hostname='$wrt_name'不存在，修复"
        sed -i "s/hostname='.*'/hostname='$wrt_name'/g" "$CFG_FILE"
    fi
fi

# 检查文件是否包含 ipaddr:-"192.168.8.1"
if grep -q 'ipaddr:-"192.168.8.1"' "$CFG_FILE"; then
    echo "ipaddr:-\"192.168.8.1\" 已存在，跳过替换。"
else
    # 替换 ipaddr:-"192.168.1.1" 为 ipaddr:-"192.168.8.1"
    sed -i 's/ipaddr:-"192.168.1.1"/ipaddr:-"192.168.8.1"/g' "$CFG_FILE"
    echo "已将 ipaddr:-\"192.168.1.1\" 替换为 ipaddr:-\"192.168.8.1\"。"
fi



#修复freeswitch依赖缺失
FW_FILE=$(find ./feeds/telephony/ -maxdepth 3 -type f -wholename "*/freeswitch/Makefile")
if [ -f "$FW_FILE" ]; then
    # 检查 Makefile 中是否已经存在 libpcre2
    if grep -q "libpcre2" "$FW_FILE"; then
        echo "libpcre2 已经存在，跳过修改 freeswitch Makefile。"
    else
        echo "libpcre2 不存在，修复 freeswitch Makefile。"
        sed -i "s/libpcre/libpcre2/g" "$FW_FILE"
    fi
fi

#再次安装所有包
echo "再次安装所有包..."
./scripts/feeds install -a || { echo "feeds install 失败"; exit 1; }

echo "更新完成！"
