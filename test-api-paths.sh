#!/bin/bash

# API路径测试脚本

echo "=========================================="
echo "    API 路径测试工具"
echo "=========================================="
echo

# 测试不同的API路径
echo "🧪 测试1: 测试 /api/admin/login 路径"
echo "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:8080/api/admin/login"
response1=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/admin/login 2>/dev/null || echo "000")
echo "响应: HTTP $response1"

echo
echo "🧪 测试2: 测试 /admin/login 路径"
echo "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:8080/admin/login"
response2=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/admin/login 2>/dev/null || echo "000")
echo "响应: HTTP $response2"

echo
echo "🧪 测试3: 测试 /api/sysinfo/detail 路径"
echo "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:8080/api/sysinfo/detail"
response3=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/sysinfo/detail 2>/dev/null || echo "000")
echo "响应: HTTP $response3"

echo
echo "🧪 测试4: 测试 /admin/sysinfo/detail 路径"
echo "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:8080/admin/sysinfo/detail"
response4=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/admin/sysinfo/detail 2>/dev/null || echo "000")
echo "响应: HTTP $response4"

echo
echo "=========================================="
echo "📊 测试结果分析"
echo "=========================================="
echo

if [ "$response1" = "404" ]; then
    echo "❌ /api/admin/login 返回404 - 这个路径有问题"
elif [ "$response1" = "200" ] || [ "$response1" = "405" ] || [ "$response1" = "400" ]; then
    echo "✅ /api/admin/login 响应正常 (HTTP $response1)"
else
    echo "? /api/admin/login 状态未知 (HTTP $response1)"
fi

if [ "$response2" = "404" ]; then
    echo "❌ /admin/login 返回404 - 这个路径有问题"
elif [ "$response2" = "200" ] || [ "$response2" = "405" ] || [ "$response2" = "400" ]; then
    echo "✅ /admin/login 响应正常 (HTTP $response2)"
else
    echo "? /admin/login 状态未知 (HTTP $response2)"
fi

echo
echo "📋 建议:"
if [ "$response1" != "404" ] && [ "$response2" != "404" ]; then
    echo "✅ 两个路径都工作正常，API配置正确"
    echo "   前端可以使用任一路径访问后端API"
elif [ "$response2" != "404" ]; then
    echo "✅ 使用 /admin 路径访问API"
    echo "   API配置: baseUrl = '/admin'"
elif [ "$response1" != "404" ]; then
    echo "✅ 使用 /api 路径访问API"
    echo "   API配置: baseUrl = '/api'"
else
    echo "❌ 两个路径都有问题，需要检查代理配置"
fi

echo
echo "🌐 现在可以测试登录功能:"
echo "1. 在浏览器中访问: http://localhost:8080"
echo "2. 尝试登录并观察Network面板中的请求"
echo "3. 请求应该成功且不出现CORS错误"
