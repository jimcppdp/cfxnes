const nodeResolve = require('rollup-plugin-node-resolve');

module.exports = {
  input: 'src/server/index.js',
  output: {
    file: 'dist/index.js',
    format: 'cjs',
  },
  external: ['fs', 'path', 'express', 'express-history-api-fallback'],
  plugins: [nodeResolve()],
};
