#!/bin/bash

# 配置变量
PROXY_DIR="$HOME/.config/mihomo"
CONFIG_URL="你的_CONFIG_YAML_的_RAW_链接" # 替换为你 GitHub 上的原始链接
BIN_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.18.3/mihomo-linux-amd64-v1.18.3.gz"

echo "🚀 开始一键配置代理环境..."

# 1. 创建目录
mkdir -p $PROXY_DIR

# 2. 下载并安装 Mihomo 内核
echo "📥 下载代理内核..."
curl -L $BIN_URL -o "$PROXY_DIR/mihomo.gz"
gunzip -f "$PROXY_DIR/mihomo.gz"
chmod +x "$PROXY_DIR/mihomo"

# 3. 下载你的配置文件
echo "📥 下载配置文件..."
# 这里如果你还没上传，脚本会先创建一个模板
if [ "$CONFIG_URL" == "你的_CONFIG_YAML_的_RAW_链接" ]; then
    echo "⚠️ 未检测到有效 URL，正在使用本地现有配置..."
else
    curl -L $CONFIG_URL -o "$PROXY_DIR/config.yaml"
fi

# 4. 注入环境变量和快捷函数到 .bashrc
echo "📝 配置环境变量..."
if ! grep -q "function proxy_on" ~/.bashrc; then
    cat << 'EOF' >> ~/.bashrc

# --- Proxy Shortcuts ---
proxy_on() {
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export ALL_PROXY="socks5://127.0.0.1:7891"
    echo "✅ Proxy Enabled (127.0.0.1:7890/7891)"
}

proxy_off() {
    unset http_proxy https_proxy ALL_PROXY
    echo "❌ Proxy Disabled"
}

# 启动代理守护进程的函数
proxy_start() {
    nohup $HOME/.config/mihomo/mihomo -d $HOME/.config/mihomo > /dev/null 2>&1 &
    echo "🚀 Mihomo Core started in background."
}
EOF
fi

echo "✨ 配置完成！"
echo "请执行 'source ~/.bashrc' 来刷新环境。"
echo "用法: 'proxy_start' 启动后台内核，'proxy_on' 开启当前终端代理。"
