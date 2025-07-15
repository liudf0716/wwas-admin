#!/bin/bash
# API连接测试脚本

echo "=========================================="
echo "        API 连接测试工具"
echo "=========================================="
echo

# 读取当前配置
if [ -f .env.local ]; then
    source .env.local
    echo "当前配置的API地址: $API_BASE_URL"
else
    echo "警告: 未找到 .env.local 文件"
    API_BASE_URL="http://192.168.67.109:8001"
fi

echo "前端开发服务器端口: ${PORT:-8080}"
echo

# 测试后端API连接
echo "1. 测试后端API连接..."
if curl -s --connect-timeout 5 "$API_BASE_URL" >/dev/null; then
    echo "✓ 后端API服务器可访问"
else
    echo "✗ 后端API服务器不可访问"
    echo "请检查:"
    echo "  - 后端服务是否在运行"
    echo "  - IP地址是否正确: $API_BASE_URL"
    echo "  - 防火墙设置"
fi

# 测试特定API端点
echo
echo "2. 测试登录API端点..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$API_BASE_URL/admin/login" || echo "000")
if [ "$response" = "405" ] || [ "$response" = "400" ] || [ "$response" = "200" ]; then
    echo "✓ 登录API端点响应正常 (HTTP $response)"
elif [ "$response" = "000" ]; then
    echo "✗ 无法连接到登录API端点"
else
    echo "? 登录API端点响应: HTTP $response"
fi

# 测试CORS设置
echo
echo "3. 测试CORS设置..."
cors_headers=$(curl -s -H "Origin: http://localhost:8080" -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: Content-Type" -X OPTIONS "$API_BASE_URL/admin/login" -D - | grep -i "access-control")

if [ -n "$cors_headers" ]; then
    echo "✓ 检测到CORS头部:"
    echo "$cors_headers"
else
    echo "✗ 未检测到CORS头部"
    echo "这可能是CORS错误的原因"
fi

echo
echo "=========================================="
echo "建议解决方案:"
echo "=========================================="
echo
echo "如果API连接正常但仍有CORS错误，请:"
echo "1. 重启前端开发服务器 (npm run dev)"
echo "2. 使用代理模式访问: http://localhost:8080"
echo "3. 确保后端CORS配置正确"
echo
echo "开发服务器应该通过代理访问API，避免CORS问题"
echo "前端 http://localhost:8080 -> 代理 -> 后端 $API_BASE_URL"
