import js from '@eslint/js';
import globals from 'globals';
import pluginReact from 'eslint-plugin-react';
import { defineConfig } from 'eslint/config';
import prettierPlugin from 'eslint-plugin-prettier';
import prettierConfig from 'eslint-config-prettier';

export default defineConfig([
  {
    files: ['**/*.{js,mjs,cjs,jsx}'],
    plugins: { js, prettier: prettierPlugin },
    extends: ['js/recommended'],
    languageOptions: { globals: { ...globals.browser, ...globals.node } },
    rules: {
      ...prettierConfig.rules,
      semi: ['error', 'always'],
      // 'no-console': 'warn',
      // quotes: ['error', 'double'],
      'prettier/prettier': 'error',
    },
  },
  pluginReact.configs.flat.recommended,
]);
