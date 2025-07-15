#!/bin/bash

# 404错误诊断脚本

echo "=========================================="
echo "    API 404 错误诊断工具"
echo "=========================================="
echo

# 检查用户当前的访问方式
echo "🔍 诊断步骤 1: 检查访问方式"
echo
echo "您刚才遇到的错误："
echo "POST http://192.168.67.109:8080/api/admin/login 404 (Not Found)"
echo
echo "问题分析："
echo "❌ 您使用了: http://192.168.67.109:8080"
echo "✅ 应该使用: http://localhost:8080"
echo

# 检查代理配置
echo "🔍 诊断步骤 2: 检查代理配置"
echo

if netstat -tulpn 2>/dev/null | grep -q ":8080"; then
    echo "✅ 开发服务器正在端口8080上运行"
else
    echo "❌ 开发服务器未在端口8080上运行"
    echo "   请运行: ./start-dev.sh"
    exit 1
fi

# 测试localhost访问
echo
echo "🔍 诊断步骤 3: 测试localhost访问"
echo

echo "测试前端服务器响应..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
    echo "✅ localhost:8080 可以访问"
else
    echo "❌ localhost:8080 无法访问"
fi

echo
echo "测试API代理..."
api_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/sysinfo/detail 2>/dev/null || echo "000")
if [ "$api_response" = "200" ] || [ "$api_response" = "401" ] || [ "$api_response" = "403" ]; then
    echo "✅ API代理正常工作 (HTTP $api_response)"
else
    echo "❌ API代理可能有问题 (HTTP $api_response)"
fi

# 测试IP地址访问
echo
echo "🔍 诊断步骤 4: 测试IP地址访问"
echo

echo "测试通过IP访问前端..."
if curl -s -o /dev/null -w "%{http_code}" http://192.168.67.109:8080 | grep -q "200"; then
    echo "✅ 192.168.67.109:8080 前端可以访问"
else
    echo "❌ 192.168.67.109:8080 前端无法访问"
fi

echo
echo "测试通过IP访问API代理..."
api_ip_response=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.67.109:8080/api/sysinfo/detail 2>/dev/null || echo "000")
if [ "$api_ip_response" = "404" ]; then
    echo "❌ 通过IP访问API代理失败 (HTTP $api_ip_response) - 这是预期的"
    echo "   原因: webpack-dev-server代理只在localhost下工作"
elif [ "$api_ip_response" = "200" ] || [ "$api_ip_response" = "401" ] || [ "$api_ip_response" = "403" ]; then
    echo "✅ 通过IP访问API代理意外工作了 (HTTP $api_ip_response)"
else
    echo "? 通过IP访问API代理状态未知 (HTTP $api_ip_response)"
fi

echo
echo "=========================================="
echo "📋 解决方案"
echo "=========================================="
echo

echo "🎯 立即解决方案:"
echo "1. 在浏览器地址栏中将地址改为: http://localhost:8080"
echo "2. 刷新页面并重新尝试登录"
echo

echo "🔄 如果您在Windows中访问WSL2服务:"
echo "1. 确保已运行端口转发: awas-port-manager.bat"
echo "2. 在Windows浏览器中访问: http://localhost:8080"
echo "3. 不要使用IP地址访问"
echo

echo "🔧 永久解决方案:"
echo "1. 更新书签/收藏夹使用localhost地址"
echo "2. 配置hosts文件(可选):"
echo "   echo '127.0.0.1 wwas-admin.local' >> /etc/hosts"
echo "   然后可以使用: http://wwas-admin.local:8080"
echo

echo "🧪 验证修复:"
echo "1. 访问 http://localhost:8080"
echo "2. 打开开发者工具 -> Network面板"
echo "3. 尝试登录，检查请求URL应该是: /api/admin/login"
echo "4. 不应该看到完整URL: http://192.168.67.109:8001/admin/login"
echo

echo "🆘 如果仍有问题:"
echo "1. 清除浏览器缓存"
echo "2. 重启开发服务器: ./start-dev.sh"
echo "3. 检查控制台错误日志"
echo "4. 运行: ./verify-api-config.sh"

echo
echo "=========================================="
echo "当前建议的访问地址: http://localhost:8080"
echo "=========================================="
