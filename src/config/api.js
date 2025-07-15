// API 配置文件
// 此文件用于管理 API 基础地址，适用于前端代码

// 获取 API 基础地址
function getApiBaseUrl() {
  // 1. 首先检查运行时配置（部署后可修改）
  if (typeof window !== 'undefined' && window.APP_CONFIG && window.APP_CONFIG.API_BASE_URL) {
    return window.APP_CONFIG.API_BASE_URL;
  }
  
  // 2. 检查构建时环境变量
  if (process.env.API_BASE_URL && process.env.API_BASE_URL !== '""' && process.env.API_BASE_URL !== "''") {
    return process.env.API_BASE_URL;
  }
  
  // 3. 默认使用相对路径
  return '/api';
}

// 导出配置
export const API_CONFIG = {
  BASE_URL: getApiBaseUrl(),
  UNI_URL: 'http://wifidogx.online'
};

export default API_CONFIG;
