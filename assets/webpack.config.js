const path = require('path')

module.exports = {
  entry: {
    app: ['./js/app.js', './css/app.css'],
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/assets'),
    publicPath: '/assets/',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader',
          'postcss-loader'
        ]
      }
    ]
  },
  resolve: {
    modules: ['node_modules', path.resolve(__dirname, 'js')],
    extensions: ['.js', '.jsx', '.json']
  },
  stats: 'errors-warnings',
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
  watchOptions: {
    ignored: ['**/node_modules/**', '**/deps/**']
  }
}
