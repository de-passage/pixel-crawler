const webpack = require("webpack")
module.exports = {
  entry: "./entry.js",
  output: {
    path: __dirname,
    filename: "bundle.js"
  },
  module: {
    loaders: [
    { test: /\.sass$/, use: [{ loader: "style-loader" // creates style nodes from JS strings 
							 }, { loader: "css-loader" // translates CSS into CommonJS 
							 }, { loader: "sass-loader" // compiles Sass to CSS 
							 }]},
    { test: /\.coffee$/, loader: "coffee-loader" },
    { test: /\.haml$/, loader: "haml-loader" }
    ]
  }
};

