var path = require('path');
var webpack = require('webpack');

module.exports = {
    entry: {
        app: [
            './src/scripts/router'
        ],
        squeezychat: [
            './src/scripts/squeezychat.jsx'
        ]
    },
    devtool: 'source-map',
    output: {
        path: path.join(__dirname, "public"),
        filename: "[name]-bundle.js",
    },
    resolveLoader: {
        modulesDirectories: ['..', 'node_modules']
    },
    plugins: [
        new webpack.DefinePlugin({
            // This has effect on the react lib size.
            "process.env": {
                NODE_ENV: JSON.stringify("production")
            }
        }),
        new webpack.IgnorePlugin(/vertx/),
        new webpack.IgnorePlugin(/un~$/),
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.UglifyJsPlugin()
    ],
    resolve: {
        extensions: ['', '.js', 'jsx', '.cjsx', '.coffee']
    },
    module: {
        loaders: [
            { test: /\.scss$/, loader: "style!css!sass?outputStyle=expanded&" +
            "includePaths[]=" +
            (path.resolve(__dirname, "./node_modules")) },
            // { test: /\.css$/, loaders: ['style', 'css']},
            { test: /\.cjsx$/, loaders: ['coffee', 'cjsx']},
            { test: /\.jsx$/, exclude: /(node_modules|bower_components)/, loaders: ['babel']},
            { test: /\.coffee$/, loader: 'coffee' }
        ]
    }
};
