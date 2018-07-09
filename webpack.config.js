const path = require('path');
const webpack = require("webpack");
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: './app/assets/js/main.js',
  output: {
     path: path.resolve(__dirname, 'build'),
     filename: 'main.js',
  },
  plugins: [
    new CopyWebpackPlugin([
      { from: './app/index.html', to: "index.html" },
      { from: './app/patient.html', to: "patient.html" },
      { from: './app/doctor.html', to: "doctor.html" },
      { from: './app/instruction.html', to: "instruction.html" },
      { from: './app/insurance_company.html', to: "insurance_company.html" },
      { from: './app/assets/css', to: "assets/css" },
      { from: './app/assets/fonts', to: "assets/fonts" },
      { from: './app/images/', to: "images" },
      //{ from: './app/assets/js', to: "assets/js" },
	 ]),
	 new webpack.ProvidePlugin({
		'$': "jquery",
		'jQuery': "jquery",
		'Popper': 'popper.js'
    }),
  ],
  module: {
    rules: [
      {
       test: /\.css$/,
       use: [ 'style-loader', 'css-loader' ]
      }
    ],
    loaders: [
      { test: /\.json$/, use: 'json-loader' },
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015'],
          plugins: ['transform-runtime']
        }
      }
    ]
  }
}
