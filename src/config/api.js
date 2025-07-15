// API 配置文件
// 此文件用于管理 API 基础地址，适用于前端代码

// 获取 API 基础地址
function getApiBaseUrl() {
  // 1. 开发环境强制使用代理路径，避免CORS问题
  if (process.env.NODE_ENV === 'development') {
    // 在开发环境下，总是使用相对路径，让webpack-dev-server处理代理
    console.log('[API] 开发环境：使用代理路径 /api');
    return '/api';
  }
  
  // 2. 检查运行时配置（部署后可修改）
  if (typeof window !== 'undefined' && window.APP_CONFIG && window.APP_CONFIG.API_BASE_URL) {
    console.log('[API] 使用运行时配置:', window.APP_CONFIG.API_BASE_URL);
    return window.APP_CONFIG.API_BASE_URL;
  }
  
  // 3. 检查构建时环境变量
  if (process.env.API_BASE_URL && process.env.API_BASE_URL !== '""' && process.env.API_BASE_URL !== "''") {
    console.log('[API] 使用环境变量配置:', process.env.API_BASE_URL);
    return process.env.API_BASE_URL;
  }
  
  // 4. 生产环境默认使用相对路径
  console.log('[API] 使用默认配置: /api');
  return '/api';
}

// 导出配置
export const API_CONFIG = {
  BASE_URL: getApiBaseUrl(),
  UNI_URL: 'http://wifidogx.online'
};

export default API_CONFIG;
