# CORS 问题解决方案

## 问题描述

您遇到的CORS错误：
```
Access to XMLHttpRequest at 'http://192.168.67.109:8001/admin/login' from origin 'http://192.168.67.109:8080' has been blocked by CORS policy: Response to preflight request doesn't pass access control check: The value of the 'Access-Control-Allow-Origin' header in the response must not be the wildcard '*' when the request's credentials mode is 'include'.
```

## 根本原因

1. **后端CORS配置冲突**：
   - 后端设置了 `Access-Control-Allow-Origin: *`（通配符）
   - 同时设置了 `Access-Control-Allow-Credentials: true`
   - 当请求包含凭据（cookies, authorization headers）时，这两个设置是冲突的

2. **跨域请求**：
   - 前端运行在 `http://192.168.67.109:8080`
   - 后端运行在 `http://192.168.67.109:8001`
   - 不同端口被认为是不同的源（Origin）

## 解决方案

### 1. 前端解决方案（推荐）：使用开发代理

我已经配置了webpack代理，将API请求代理到后端服务器：

```javascript
// config/index.js 中的代理配置
proxyTable: {
    "/api": {
        target: "http://192.168.67.109:8001",
        changeOrigin: true,
        secure: false,
        pathRewrite: {
            '^/api': '/admin'  // 将 /api 路径重写为 /admin
        }
    },
    "/admin": {
        target: "http://192.168.67.109:8001",
        changeOrigin: true,
        secure: false
    }
}
```

**使用方法：**
1. 确保使用 `http://localhost:8080` 访问前端（不是直接用IP）
2. API调用会自动代理到后端，避免跨域问题

### 2. 启动开发服务器

```bash
# 方法1: 使用提供的启动脚本
./start-dev.sh

# 方法2: 使用npm脚本
npm run dev:local:nobrowser

# 方法3: 手动启动
npm run dev
```

### 3. 访问方式

✅ **正确方式**：
- 前端：`http://localhost:8080`
- API请求会自动代理到 `http://192.168.67.109:8001`

❌ **错误方式**：
- 直接访问：`http://192.168.67.109:8080`（会导致CORS错误）

## 后端解决方案（如果可以修改后端）

如果您可以修改后端CORS配置，应该：

```javascript
// 正确的CORS配置
app.use(cors({
    origin: ['http://localhost:8080', 'http://192.168.67.109:8080'], // 明确指定允许的源
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
```

**不要同时使用：**
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Credentials: true`

## 测试和验证

1. **测试API连接**：
   ```bash
   ./test-api-connection.sh
   ```

2. **检查代理是否工作**：
   - 启动开发服务器：`./start-dev.sh`
   - 在浏览器中访问：`http://localhost:8080`
   - 打开开发者工具，检查Network面板
   - API请求应该显示为 `/api/login` 而不是完整的URL

3. **检查请求头**：
   - 代理请求应该没有CORS错误
   - 请求的URL应该是相对路径（如 `/api/login`）

## 故障排除

### 问题1：仍然有CORS错误
- 确保使用 `localhost:8080` 而不是IP地址访问
- 检查浏览器是否缓存了旧的请求
- 清除浏览器缓存并重新加载

### 问题2：代理不工作
- 检查 `config/index.js` 中的代理配置
- 确保后端服务正在运行
- 检查控制台日志中的代理信息

### 问题3：API路径不匹配
- 前端API调用应该使用 `/api/` 前缀
- 代理会自动将 `/api/` 重写为 `/admin/`
- 确保API配置文件正确

## 最佳实践

1. **开发环境**：使用webpack代理（当前解决方案）
2. **测试环境**：配置nginx反向代理
3. **生产环境**：前后端部署在同一域名下，或正确配置CORS
4. **总是使用localhost进行本地开发**，避免IP地址直接访问

## 相关文件

- `config/index.js` - webpack代理配置
- `src/config/api.js` - API基础地址配置
- `.env.local` - 环境变量配置
- `start-dev.sh` - 开发环境启动脚本
- `test-api-connection.sh` - API连接测试脚本
