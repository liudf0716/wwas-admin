#!/bin/bash

# WWAS Admin 开发环境启动脚本
# 此脚本会自动配置代理以避免CORS问题

echo "=========================================="
echo "    启动 WWAS Admin 开发环境"
echo "=========================================="
echo

# 检查Node.js和npm
if ! command -v node &> /dev/null; then
    echo "错误: 未找到 Node.js，请先安装 Node.js"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "错误: 未找到 npm，请先安装 npm"
    exit 1
fi

# 检查依赖是否已安装
if [ ! -d "node_modules" ]; then
    echo "检测到依赖未安装，正在安装..."
    npm install
    if [ $? -ne 0 ]; then
        echo "错误: 依赖安装失败"
        exit 1
    fi
fi

# 检查环境配置文件
if [ ! -f ".env.local" ]; then
    echo "警告: 未找到 .env.local 文件，创建默认配置..."
    cat > .env.local << EOF
# 本地开发环境配置

# 后端 API 服务器地址和端口
API_BASE_URL=http://192.168.67.109:8001

# 前端开发服务器端口（webpack-dev-server）
PORT=8080

# 是否自动打开浏览器（在无图形界面环境中设为 false）
OPEN_BROWSER=false
EOF
fi

# 读取配置
source .env.local

echo "配置信息:"
echo "- API 地址: ${API_BASE_URL}"
echo "- 前端端口: ${PORT}"
echo "- 自动打开浏览器: ${OPEN_BROWSER:-true}"
echo

# 测试后端连接
echo "测试后端API连接..."
if curl -s --connect-timeout 5 "$API_BASE_URL" >/dev/null; then
    echo "✓ 后端API连接正常"
else
    echo "警告: 无法连接到后端API ($API_BASE_URL)"
    echo "请确保后端服务正在运行"
    echo
    read -p "是否仍要启动前端开发服务器? (y/n): " continue_choice
    if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
        echo "启动已取消"
        exit 1
    fi
fi

echo
echo "=========================================="
echo "启动开发服务器..."
echo "=========================================="
echo
echo "前端地址: http://localhost:${PORT}"
echo "API代理: /api -> ${API_BASE_URL}/admin"
echo "          /admin -> ${API_BASE_URL}/admin"
echo "          /public -> ${API_BASE_URL}/public"
echo
echo "🔴 重要提醒："
echo "   ✅ 正确访问: http://localhost:${PORT}"
echo "   ❌ 错误访问: http://192.168.67.109:${PORT} (会导致404错误)"
echo
echo "   webpack代理只在localhost访问时生效！"
echo "   如果您在Windows中访问WSL2服务，请确保："
echo "   1. 已运行端口转发脚本 (awas-port-manager.bat)"
echo "   2. 在Windows浏览器中访问 http://localhost:${PORT}"
echo

# 启动开发服务器
echo "正在启动..."
npm run dev:local:nobrowser
