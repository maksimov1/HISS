const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: './app/assets/js/main.js',
  output: {
     path: path.resolve(__dirname, 'build'),
     filename: 'main.js',
  },
  plugins: [
    // Copy our app's index.html to the build folder.
    new CopyWebpackPlugin([
      { from: './app/index.html', to: "index.html" },
      { from: './app/patient.html', to: "patient.html" },
      { from: './app/doctor.html', to: "doctor.html" },
      { from: './app/insurance_company.html', to: "insurance_company.html" },
      { from: './app/assets/css', to: "assets/css" },
      { from: './app/assets/fonts', to: "assets/fonts" },
      { from: './app/images/', to: "images" },
      { from: './app/assets/js', to: "assets/js" },
    ])
  ],
  module: {
    rules: [
      {
       test: /\.css$/,
       use: [ 'style-loader', 'css-loader' ]
      },
      {
       test: /\.js$/, // запустим загрузчик во всех файлах .js
       exclude: /node_modules/, // проигнорируем все файлы в папке  node_modules
       use: 'jshint-loader'
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
