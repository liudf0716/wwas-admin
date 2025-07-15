#!/bin/bash

# 智能部署脚本
# 用法: ./deploy.sh [local|test|prod] [IP地址]

# 设置变量
AWAS_PUBLIC_DIR="/path/to/awas/public"
LOCAL_IP=""

# 函数：获取本机 IP
get_local_ip() {
    # 尝试多种方法获取本机 IP
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    if [ -z "$LOCAL_IP" ]; then
        LOCAL_IP=$(ip route get 1 | awk '{print $7}' | head -1)
    fi
    if [ -z "$LOCAL_IP" ]; then
        LOCAL_IP="192.168.1.100"  # 默认值
    fi
}

# 显示使用帮助
show_help() {
    echo "使用方法: $0 [环境] [IP地址]"
    echo ""
    echo "环境选项:"
    echo "  local   - 本地环境部署"
    echo "  test    - 测试环境部署"
    echo "  prod    - 生产环境部署"
    echo "  (空)    - 默认部署（相对路径）"
    echo ""
    echo "示例:"
    echo "  $0 local                    # 自动检测本机 IP"
    echo "  $0 local 192.168.1.100     # 指定 IP 地址"
    echo "  $0 test                     # 测试环境"
    echo "  $0 prod                     # 生产环境"
    echo "  $0                          # 默认（相对路径）"
    exit 0
}

# 检查帮助参数
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

echo "开始部署前端项目..."

# 清理旧的构建文件
echo "清理旧的构建文件..."
rm -rf dist/

# 构建项目
case "$1" in
    "local")
        echo "构建本地环境版本..."
        # 如果用户指定了 IP，使用指定的 IP
        if [ ! -z "$2" ]; then
            echo "使用指定的 IP: $2"
            LOCAL_IP="$2"
        else
            # 自动检测本机 IP
            get_local_ip
            echo "自动检测到本机 IP: $LOCAL_IP"
            echo -n "是否使用此 IP? [Y/n]: "
            read confirm
            if [[ $confirm == [nN] || $confirm == [nN][oO] ]]; then
                echo -n "请输入正确的 IP 地址: "
                read user_ip
                LOCAL_IP=$user_ip
            fi
        fi
        echo "使用 API 地址: http://$LOCAL_IP:8001"
        API_BASE_URL="http://$LOCAL_IP:8001" npm run build
        ;;
    "test")
        echo "构建测试环境版本..."
        npm run build:test
        ;;
    "prod")
        echo "构建生产环境版本..."
        npm run build:prod
        ;;
    *)
        echo "构建默认版本（相对路径）..."
        npm run build
        ;;
esac

# 检查构建是否成功
if [ $? -ne 0 ]; then
    echo "构建失败！请检查错误信息。"
    exit 1
fi

echo "构建完成！"

# 如果指定了部署目录，则进行部署
if [ "$AWAS_PUBLIC_DIR" != "/path/to/awas/public" ]; then
    # 备份现有文件（可选）
    if [ -d "$AWAS_PUBLIC_DIR" ]; then
        backup_dir="${AWAS_PUBLIC_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "备份现有文件到: $backup_dir"
        mv "$AWAS_PUBLIC_DIR" "$backup_dir"
    fi

    # 拷贝新文件
    echo "拷贝文件到部署目录..."
    cp -r dist/ "$AWAS_PUBLIC_DIR"
    
    echo "部署完成！"
    echo "前端文件已拷贝到: $AWAS_PUBLIC_DIR"
else
    echo "请修改脚本中的 AWAS_PUBLIC_DIR 变量为实际的部署路径"
    echo "或手动拷贝 dist/ 目录下的文件到目标位置"
fi

if [ "$1" = "local" ]; then
    echo "API 地址设置为: http://$LOCAL_IP:8001"
fi

echo "完成！"
