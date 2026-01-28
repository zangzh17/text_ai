#!/bin/bash

# --- 1. 定义路径 ---
PROXY_DIR="$HOME/.config/mihomo"
mkdir -p "$PROXY_DIR"

echo "开始安装代理环境..."

# --- 2. 写入你的自定义配置文件 (Here Document) ---
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

  - name: "🍎 Apple"
    type: select
    proxies:
      - "DIRECT"
      - "🇺🇸 My Home Server"

rules:
  - GEOIP,LAN,DIRECT
  - DOMAIN-SUFFIX,apple.com,🍎 Apple
  - DOMAIN-SUFFIX,icloud.com,🍎 Apple
  - DOMAIN-SUFFIX,google.com,🚀 节点选择
  - DOMAIN-SUFFIX,youtube.com,🚀 节点选择
  - DOMAIN-SUFFIX,twitter.com,🚀 节点选择
  - DOMAIN-SUFFIX,telegram.org,🚀 节点选择
  - DOMAIN-SUFFIX,netflix.com,🚀 节点选择
  - DOMAIN-SUFFIX,anthropic.com,🚀 节点选择
  - DOMAIN-KEYWORD,openai,🚀 节点选择
  - GEOIP,CN,DIRECT
  - MATCH,🚀 节点选择
EOF

echo "✅ 配置文件已创建。"

# --- 3. 下载 Mihomo 内核 (amd64 版本) ---
echo "正在下载代理内核..."
BIN_URL="https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/v1.18.3/mihomo-linux-amd64-v1.18.3.gz"
curl -L "$BIN_URL" -o "$PROXY_DIR/mihomo.gz"
gunzip -f "$PROXY_DIR/mihomo.gz"
chmod +x "$PROXY_DIR/mihomo"

# --- 4. 注入环境变量到 .bashrc ---
if ! grep -q "proxy_on()" ~/.bashrc; then
    cat << 'EOF' >> ~/.bashrc

# --- Proxy Aliases ---
proxy_on() {
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export ALL_PROXY="socks5://127.0.0.1:7891"
    echo "✅ 终端代理已开启 (7890/7891)"
}

proxy_off() {
    unset http_proxy https_proxy ALL_PROXY
    echo "❌ 终端代理已关闭"
}

proxy_start() {
    # 检查是否已经在运行
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
echo "✨ 配置成功完成！"
echo "1. 执行 'source ~/.bashrc' 使配置生效。"
echo "2. 执行 'proxy_start' 启动代理引擎。"
echo "3. 执行 'proxy_on' 开启当前终端代理。"
echo "4. 现在运行 'claude' 即可畅通无阻。"
echo "-------------------------------------------"
