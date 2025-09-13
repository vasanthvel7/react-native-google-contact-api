const path = require('path');
const { getDefaultConfig } = require('@react-native/metro-config');
const { withMetroConfig } = require('react-native-monorepo-config');

const root = path.resolve(__dirname, '..'); // library root

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * @type {import('metro-config').MetroConfig}
 */
const defaultConfig = getDefaultConfig(__dirname);

module.exports = withMetroConfig(defaultConfig, {
  root,
  dirname: __dirname,
  resolver: {
    // Ensure @react-native packages are resolved from the library root
    extraNodeModules: {
      '@react-native': path.resolve(root, 'node_modules/@react-native'),
    },
  },
  watchFolders: [
    // Watch the library root so changes are picked up
    path.resolve(root, 'node_modules'),
    root,
  ],
});
