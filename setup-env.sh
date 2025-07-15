#!/bin/bash

# 环境配置向导
echo "==============================================="
echo "WWAS Admin 环境配置向导"
echo "==============================================="
echo ""

# 获取当前 .env.local 中的配置
current_ip=""
if [ -f ".env.local" ]; then
    current_ip=$(grep "API_BASE_URL" .env.local | cut -d'=' -f2 | sed 's/http:\/\///' | cut -d':' -f1)
fi

echo "当前本地环境配置的 IP: ${current_ip:-未设置}"
echo ""

# 自动检测本机 IP
detected_ip=$(hostname -I | awk '{print $1}')
if [ -z "$detected_ip" ]; then
    detected_ip=$(ip route get 1 | awk '{print $7}' | head -1)
fi

echo "检测到的本机 IP: ${detected_ip:-无法检测}"
echo ""

echo "请选择配置方式:"
echo "1. 使用检测到的 IP (推荐)"
echo "2. 手动输入 IP 地址"
echo "3. 查看现有配置"
echo "4. 退出"
echo ""

read -p "请输入选择 [1-4]: " choice

case $choice in
    1)
        if [ ! -z "$detected_ip" ]; then
            new_ip="$detected_ip"
        else
            echo "无法自动检测 IP，请手动输入"
            read -p "请输入 IP 地址: " new_ip
        fi
        ;;
    2)
        read -p "请输入 IP 地址: " new_ip
        ;;
    3)
        echo ""
        echo "=== 当前环境配置文件 ==="
        echo ""
        echo "📁 .env.local:"
        if [ -f ".env.local" ]; then
            cat .env.local
        else
            echo "文件不存在"
        fi
        echo ""
        echo "📁 .env.test:"
        if [ -f ".env.test" ]; then
            cat .env.test
        else
            echo "文件不存在"
        fi
        echo ""
        echo "📁 .env.production:"
        if [ -f ".env.production" ]; then
            cat .env.production
        else
            echo "文件不存在"
        fi
        exit 0
        ;;
    4)
        echo "退出配置向导"
        exit 0
        ;;
    *)
        echo "无效选择，退出"
        exit 1
        ;;
esac

# 验证 IP 格式
if [[ ! $new_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "IP 地址格式不正确: $new_ip"
    exit 1
fi

echo ""
echo "将要设置的配置:"
echo "  IP 地址: $new_ip"
echo "  API 地址: http://$new_ip:8001"
echo ""

read -p "确认更新配置? [Y/n]: " confirm
if [[ $confirm == [nN] || $confirm == [nN][oO] ]]; then
    echo "取消配置更新"
    exit 0
fi

# 备份现有配置
if [ -f ".env.local" ]; then
    cp .env.local .env.local.backup.$(date +%Y%m%d_%H%M%S)
    echo "已备份现有配置"
fi

# 更新配置文件
cat > .env.local << EOF
# 本地开发环境配置
# 修改下面的 IP 地址为您的实际本地服务器地址
API_BASE_URL=http://$new_ip:8001
PORT=8080
OPEN_BROWSER=true
NODE_ENV=development
EOF

echo ""
echo "✅ 配置更新完成！"
echo ""
echo "现在您可以使用以下命令:"
echo "  开发环境: npm run dev:local"
echo "  构建:     npm run build:local"
echo "  部署:     ./deploy.sh local"
echo ""
echo "新的 .env.local 配置:"
cat .env.local
