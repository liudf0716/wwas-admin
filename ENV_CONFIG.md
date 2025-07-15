# 环境配置使用说明

## 环境变量配置

项目支持通过环境变量来配置不同环境下的后端服务地址和其他参数，方便在不同环境中调试和部署。

### 可配置的环境变量

- `API_BASE_URL`: 后端 API 服务器地址 (默认: http://portal.chawrt.com:8001)
- `PORT`: 开发服务器端口 (默认: 8080)
- `OPEN_BROWSER`: 是否自动打开浏览器 (默认: true)
- `NODE_ENV`: 环境标识 (development/production)

### 环境配置文件

项目提供了以下预设的环境配置文件：

- `.env.example`: 配置文件模板
- `.env.local`: 本地开发环境配置
- `.env.test`: 测试环境配置
- `.env.production`: 生产环境配置

### 使用方法

#### 1. 使用预设环境

```bash
# 本地开发环境 (API: http://192.168.67.109:8001)
npm run dev:local

# 测试环境 (API: http://test.chawrt.com:8001)
npm run dev:test

# 生产环境 (API: http://portal.chawrt.com:8001)
npm run dev:prod

# 默认开发环境
npm run dev
```

#### 2. 自定义环境变量

创建 `.env` 文件：

```bash
cp .env.example .env
```

编辑 `.env` 文件，修改相应的配置：

```env
API_BASE_URL=http://your-api-server:8001
PORT=3000
OPEN_BROWSER=false
```

然后运行：

```bash
npm run dev
```

#### 3. 临时设置环境变量

在命令行中临时设置：

```bash
# Linux/Mac
API_BASE_URL=http://192.168.67.109:3001 npm run dev

# Windows (使用 cross-env)
npx cross-env API_BASE_URL=http://192.168.67.109:3001 npm run dev
```

### 注意事项

1. `.env` 文件应该被添加到 `.gitignore` 中，避免提交到版本控制系统
2. 环境配置文件的优先级：命令行环境变量 > .env 文件 > 默认值
3. 修改环境变量后需要重启开发服务器才能生效
