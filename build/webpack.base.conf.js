var path = require("path");
var utils = require("./utils");
var webpack = require("webpack");
var config = require("../config");
var vueLoaderConfig = require("./vue-loader.conf");

function resolve(dir) {
    return path.join(__dirname, "..", dir);
}

module.exports = {
    entry: {
        app: ["babel-polyfill", "./src/main.js"],
    },
    //后期添加（当引入fs报错时）
    node: {
        fs: "empty",
    },
    ///////添加完毕

    output: {
        path: config.build.assetsRoot,
        filename: "[name].js",
        publicPath:
            process.env.NODE_ENV === "production"
                ? config.build.assetsPublicPath
                : config.dev.assetsPublicPath,
    },
    resolve: {
        extensions: [".js", ".vue", ".json"],
        modules: [resolve("src"), resolve("node_modules")],
        alias: {
            vue$: "vue/dist/vue.js",
            src: resolve("src"),
            assets: resolve("src/assets"),
            "@": resolve("src"),
        },
    },
    module: {
        rules: [
            {
                test: /\.vue$/,
                loader: "vue-loader",
            },
            {
                test: /\.js$/,
                loader: "babel-loader",
                include: [resolve("src"), resolve("test")],
                exclude: /node_modules/
            },
            {
                test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
                loader: "url-loader",
                query: {
                    limit: 10000,
                    name: utils.assetsPath("img/[name].[ext]"),
                },
            },
            {
                test: /\.(woff2?|eot|ttf|otf)(\?.*)?$/,
                loader: "url-loader",
                query: {
                    limit: 10000,
                    name: utils.assetsPath("fonts/[name].[hash:7].[ext]"),
                },
            },
        ],
    },
    // plugins: [
    //     new webpack.DllReferencePlugin({
    //       context: path.resolve(__dirname, '..'),
    //       manifest: require('./vendor-manifest.json')
    //     })
    // ]
};
