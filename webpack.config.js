var path = require('path');
var webpack = require('webpack');

module.exports = {
  color: true,
  entry: [
    "webpack-dev-server/client?http://0.0.0.0:8080",
    'webpack/hot/only-dev-server',
    './src/scripts/router'
  ],
  devtool: "eval",
  debug: true,
  output: {
    path: path.join(__dirname, "public"),
    filename: 'app-bundle.js'
  },
  resolveLoader: {
    modulesDirectories: ['node_modules']
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
    new webpack.IgnorePlugin(/vertx|ipc/) // https://github.com/webpack/webpack/issues/353
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
      { test: /\.jsx$/, exclude: /(node_modules|bower_components)/, loaders: ['react-hot', 'babel']},
      { test: /\.cjsx$/, loaders: ['react-hot', 'coffee', 'cjsx']},
      { test: /\.coffee$/, loader: 'coffee' }
    ]
  }
};
