#!/bin/bash
# 遇到错误立即停止
set -e

# --- 1. 路径与变量定义 ---
PROXY_DIR="$HOME/.config/mihomo"
mkdir -p "$PROXY_DIR"

# 这里使用了你提供的确切文件名
BIN_FILENAME="mihomo-linux-amd64-v1.19.19.gz"
# 指向你个人仓库的 Raw 链接
RAW_URL="https://raw.githubusercontent.com/zangzh17/text_ai/main/$BIN_FILENAME"
# 如果在国内下载慢，可以使用镜像：
# RAW_URL="https://mirror.ghproxy.com/https://raw.githubusercontent.com/zangzh17/text_ai/main/$BIN_FILENAME"

echo "🚀 开始一键配置代理环境..."

# --- 2. 写入配置文件 (config.yaml) ---
# 注意：请确保此处的密码和节点信息是你最新的
cat << 'EOF' > "$PROXY_DIR/config.yaml"
port: 7890
socks-port: 7891
allow-lan: true
mode: rule
log-level: info
external-controller: :9090

proxies:
  - name: "🇺🇸 My Home Server"
    type: ss
    server: wfh-la.duckdns.org
    port: 54321
    cipher: aes-256-gcm
    password: "SetAGoodStrongPasswordHere!!"
    udp: true

proxy-groups:
  - name: "🚀 节点选择"
    type: select
    proxies:
      - "🇺🇸 My Home Server"
      - "DIRECT"

rules:
  - DOMAIN-SUFFIX,anthropic.com,🚀 节点选择
  - DOMAIN-KEYWORD,openai,🚀 节点选择
  - GEOIP,CN,DIRECT
  - MATCH,🚀 节点选择
EOF

echo "✅ 配置文件已创建。"

# --- 3. 下载并处理内核文件 ---
echo "📥 正在从个人仓库下载内核: $BIN_FILENAME ..."
curl -L "$RAW_URL" -o "$PROXY_DIR/$BIN_FILENAME"

echo "📦 正在解压并重命名..."
# 解压
gunzip -f "$PROXY_DIR/$BIN_FILENAME"
# 找到解压出的文件并统一命名为 mihomo，方便脚本调用
mv "$PROXY_DIR/mihomo-linux-amd64-v1.19.19" "$PROXY_DIR/mihomo" 2>/dev/null || true
chmod +x "$PROXY_DIR/mihomo"

# --- 4. 注入环境变量与快捷函数 ---
if ! grep -q "proxy_on()" ~/.bashrc; then
    cat << 'EOF' >> ~/.bashrc

# --- Proxy Aliases ---
proxy_on() {
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export ALL_PROXY="socks5://127.0.0.1:7891"
    echo "✅ 终端代理已开启 (127.0.0.1:7890)"
}

proxy_off() {
    unset http_proxy https_proxy ALL_PROXY
    echo "❌ 终端代理已关闭"
}

proxy_start() {
    if pgrep -x "mihomo" > /dev/null; then
        echo "⚠️  Mihomo 已在运行中。"
    else
        nohup $HOME/.config/mihomo/mihomo -d $HOME/.config/mihomo > /dev/null 2>&1 &
        echo "🚀 Mihomo 内核已在后台启动。"
    fi
}
EOF
fi

echo "-------------------------------------------"
echo "✨ 配置成功！"
echo "请执行: source ~/.bashrc"
echo "然后执行: proxy_start && proxy_on"
echo "-------------------------------------------"
