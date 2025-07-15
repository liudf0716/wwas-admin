# 部署指南

## 快速开始 - 配置本地环境

如果您的本地服务器 IP 不是 `192.168.67.109`，请按以下步骤配置：

### 🚀 方式一：使用配置向导（推荐）

```bash
# 运行配置向导，自动检测并配置您的 IP
./setup-env.sh
```

配置向导会：
- 自动检测您的本机 IP 地址
- 提供交互式配置界面
- 自动备份现有配置
- 更新 `.env.local` 文件

### 选项二：手动修改环境配置文件

```bash
# 1. 编辑本地环境配置
nano .env.local

# 2. 修改 API_BASE_URL 为您的实际 IP
# API_BASE_URL=http://YOUR_ACTUAL_IP:8001

# 3. 保存后运行
npm run build:local
```

### 选项三：临时指定 IP 地址

```bash
# 直接在命令行指定您的 IP
API_BASE_URL=http://192.168.1.100:8001 npm run build
```

### 选项四：使用智能部署脚本

```bash
# 自动检测 IP 并部署
./deploy.sh local

# 或指定特定 IP
./deploy.sh local 192.168.1.100
```

## 构建和部署流程

### 1. 开发环境运行

```bash
# 使用默认配置（代理到 portal.chawrt.com:8001）
npm run dev

# 使用本地后端服务（192.168.67.109:8001）
npm run dev:local

# 使用测试环境后端
npm run dev:test

# 使用生产环境后端
npm run dev:prod
```

### 2. 生产构建

#### 方式一：使用预设的构建脚本

```bash
# 构建到本地环境（使用 .env.local 中配置的地址）
npm run build:local

# 构建到测试环境（使用 .env.test 中配置的地址）
npm run build:test

# 构建到生产环境（使用 .env.production 中配置的地址）
npm run build:prod

# 默认构建（使用相对路径 /api，适合部署到同一服务器）
npm run build
```

#### 方式二：自定义 API 地址构建

```bash
# 临时指定 API 地址
API_BASE_URL=http://your-server:8001 npm run build

# 或者使用自定义环境文件
dotenv -e .env.your-custom npm run build
```

#### 方式三：修改本地配置文件

1. 复制模板文件：
```bash
cp .env.local.template .env.local
```

2. 编辑 `.env.local` 文件，修改 IP 地址：
```bash
# 修改为您的实际本地服务器地址
API_BASE_URL=http://192.168.1.100:8001
```

3. 然后运行：
```bash
npm run build:local
```

### 3. 部署到 awas 服务器

#### 标准部署（推荐）

如果前端和后端部署在同一服务器上：

```bash
# 1. 构建（使用默认相对路径）
npm run build

# 2. 拷贝到 awas 的 public 目录
cp -r dist/* /path/to/awas/public/
```

这种方式下，所有 API 请求都会发送到同一服务器的 `/api` 路径。

#### 跨服务器部署

如果前端和后端部署在不同服务器上：

```bash
# 1. 构建时指定后端服务器地址
API_BASE_URL=http://your-backend-server:8001 npm run build

# 2. 拷贝到前端服务器
cp -r dist/* /path/to/frontend/server/
```

### 4. 运行时动态配置（可选）

如果需要在部署后修改 API 地址，可以编辑 `static/js/config.js` 文件：

```javascript
// 在部署后的 /path/to/awas/public/static/js/config.js 文件中
window.APP_CONFIG = {
  API_BASE_URL: 'http://new-backend-server:8001'
};
```

修改后刷新页面即可生效，无需重新构建。

### 5. 部署脚本示例

创建一个智能部署脚本 `deploy.sh`：

```bash
#!/bin/bash

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

# 清理旧的构建文件
rm -rf dist/

# 构建项目
case "$1" in
    "local")
        # 如果用户指定了 IP，使用指定的 IP
        if [ ! -z "$2" ]; then
            echo "使用指定的 IP: $2"
            API_BASE_URL="http://$2:8001" npm run build
        else
            # 自动检测本机 IP
            get_local_ip
            echo "自动检测到本机 IP: $LOCAL_IP"
            read -p "是否使用此 IP? [Y/n]: " confirm
            if [[ $confirm == [nN] || $confirm == [nN][oO] ]]; then
                read -p "请输入正确的 IP 地址: " user_ip
                LOCAL_IP=$user_ip
            fi
            API_BASE_URL="http://$LOCAL_IP:8001" npm run build
        fi
        ;;
    "test")
        npm run build:test
        ;;
    "prod")
        npm run build:prod
        ;;
    *)
        npm run build
        ;;
esac

# 备份现有文件（可选）
if [ -d "$AWAS_PUBLIC_DIR" ]; then
    mv "$AWAS_PUBLIC_DIR" "${AWAS_PUBLIC_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# 拷贝新文件
cp -r dist/ "$AWAS_PUBLIC_DIR"

echo "部署完成！"
echo "前端文件已拷贝到: $AWAS_PUBLIC_DIR"
if [ "$1" = "local" ]; then
    echo "API 地址设置为: http://$LOCAL_IP:8001"
fi
```

使用方法：
```bash
# 自动检测本机 IP 并部署
./deploy.sh local

# 手动指定 IP 部署
./deploy.sh local 192.168.1.100

# 部署到测试环境
./deploy.sh test

# 部署到生产环境
./deploy.sh prod

# 默认部署（相对路径）
./deploy.sh
```

## 配置优先级

系统按以下优先级选择 API 基础地址：

1. **运行时配置**：`static/js/config.js` 中的 `window.APP_CONFIG.API_BASE_URL`
2. **构建时环境变量**：`process.env.API_BASE_URL`
3. **默认值**：`/api`（相对路径）

这样的设计确保了最大的灵活性，既支持构建时配置，也支持部署后的动态调整。
