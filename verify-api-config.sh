#!/bin/bash

# API配置验证工具

echo "=========================================="
echo "    API 配置验证工具"
echo "=========================================="
echo

# 检查环境文件
echo "1. 检查环境配置文件:"
if [ -f ".env.local" ]; then
    echo "✓ .env.local 存在"
    source .env.local
    echo "  API_BASE_URL = $API_BASE_URL"
    echo "  PORT = $PORT"
else
    echo "✗ .env.local 不存在"
fi

echo

# 检查webpack配置
echo "2. 检查webpack代理配置:"
if grep -q "192.168.67.109:8001" config/index.js; then
    echo "✓ webpack代理配置正确"
    echo "  代理目标: 192.168.67.109:8001"
else
    echo "✗ webpack代理配置可能有问题"
fi

echo

# 检查API配置文件
echo "3. 检查API配置逻辑:"
if grep -q "NODE_ENV === 'development'" src/config/api.js; then
    echo "✓ 开发环境API配置正确"
    echo "  开发环境将使用代理路径: /api"
else
    echo "✗ API配置可能有问题"
fi

echo

# 模拟开发环境API配置
echo "4. 模拟API配置结果:"
echo "开发环境 (NODE_ENV=development):"
echo "  前端访问: http://localhost:8080"
echo "  API调用: /api/login"
echo "  代理目标: http://192.168.67.109:8001/admin/login"
echo
echo "生产环境 (NODE_ENV=production):"
echo "  API调用: $API_BASE_URL/admin/login"

echo

# 验证建议
echo "=========================================="
echo "验证步骤:"
echo "=========================================="
echo
echo "1. 启动开发服务器:"
echo "   ./start-dev.sh"
echo
echo "2. 在浏览器中访问:"
echo "   http://localhost:8080 (注意是localhost，不是IP)"
echo
echo "3. 打开开发者工具，检查Network面板:"
echo "   - 登录请求的URL应该是: /api/login"
echo "   - 不应该看到完整的URL (http://192.168.67.109:8001/admin/login)"
echo
echo "4. 如果仍有CORS错误:"
echo "   - 清除浏览器缓存"
echo "   - 确保使用localhost而不是IP地址访问"
echo "   - 检查控制台中的API配置日志"
echo
echo "=========================================="
echo "故障排除:"
echo "=========================================="
echo
echo "如果API仍然直接调用IP地址:"
echo "1. 检查浏览器控制台是否有 '[API] 开发环境：使用代理路径 /api' 日志"
echo "2. 确保 NODE_ENV 设置为 'development'"
echo "3. 重启开发服务器"
echo "4. 清除浏览器缓存和localStorage"
