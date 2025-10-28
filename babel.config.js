module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      ['module-resolver', {
        root: ['./'],
        alias: {
          '@': './src',            // se você usa imports tipo "@/models"
          '@views': './src/view',
          '@services': './src/services',
        },
        extensions: ['.ts', '.tsx', '.js', '.jsx', '.json']
      }],
      'react-native-reanimated/plugin',
    ],
  };
};
