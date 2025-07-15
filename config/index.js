// see http://vuejs-templates.github.io/webpack for documentation.
var path = require("path");

module.exports = {
    build: {
        env: require("./prod.env"),
        index: path.resolve(__dirname, "../dist/index.html"),
        assetsRoot: path.resolve(__dirname, "../dist"),
        assetsSubDirectory: "static",
        assetsPublicPath: "/",
        productionSourceMap: false,
        // Gzip off by default as many popular static hosts such as
        // Surge or Netlify already gzip all static assets for you.
        // Before setting to `true`, make sure to:
        // npm install --save-dev compression-webpack-plugin
        productionGzip: false,
        productionGzipExtensions: ["js", "css"],
        // Run the build command with an extra argument to
        // View the bundle analyzer report after build finishes:
        // `npm run build --report`
        // Set to `true` or `false` to always turn it on or off
        bundleAnalyzerReport: process.env.npm_config_report,
    },
    dev: {
        env: require("./dev.env"),
        port: process.env.PORT || 8080,
        autoOpenBrowser: process.env.OPEN_BROWSER !== 'false',
        assetsSubDirectory: "static",
        assetsPublicPath: "/",
        proxyTable: {
            "/api": {
                target: process.env.API_BASE_URL || "http://192.168.67.109:8001",
                changeOrigin: true,
                secure: false,
                logLevel: 'debug',
                // 不进行路径重写，保持原始路径
                onProxyReq: function(proxyReq, req, res) {
                    console.log('[PROXY] ' + req.method + ' ' + req.url + ' -> ' + proxyReq.path);
                },
                onError: function(err, req, res) {
                    console.log('[PROXY ERROR] ' + req.url + ' -> ' + err.message);
                }
            },
            "/admin": {
                target: process.env.API_BASE_URL || "http://192.168.67.109:8001",
                changeOrigin: true,
                secure: false,
                logLevel: 'debug',
                onProxyReq: function(proxyReq, req, res) {
                    console.log('[PROXY] ' + req.method + ' ' + req.url + ' -> ' + proxyReq.path);
                }
            },
            "/public": {
                target: process.env.API_BASE_URL || "http://192.168.67.109:8001",
                changeOrigin: true,
                secure: false,
                logLevel: 'debug'
            },
        },
        // CSS Sourcemaps off by default because relative paths are "buggy"
        // with this option, according to the CSS-Loader README
        // (https://github.com/webpack/css-loader#sourcemaps)
        // In our experience, they generally work as expected,
        // just be aware of this issue when enabling this option.
        cssSourceMap: false,
    },
};
