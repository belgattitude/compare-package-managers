/**
 * Specific eslint rules for this app/package, extends the base rules
 * @see https://github.com/belgattitude/compare-package-managers/blob/main/docs/about-linters.md
 */

// Workaround for https://github.com/eslint/eslint/issues/3458 (re-export of @rushstack/eslint-patch)
require('@your-org/eslint-config-bases/patch/modern-module-resolution');

const {
  getDefaultIgnorePatterns,
} = require('@your-org/eslint-config-bases/helpers');

module.exports = {
  root: true,
  parserOptions: {
    tsconfigRootDir: __dirname,
    project: 'tsconfig.json',
  },
  ignorePatterns: [...getDefaultIgnorePatterns(), 'src/generated'],
  extends: [
    '@your-org/eslint-config-bases/typescript',
    '@your-org/eslint-config-bases/sonar',
    '@your-org/eslint-config-bases/regexp',
    '@your-org/eslint-config-bases/jest',
    // Apply prettier and disable incompatible rules
    '@your-org/eslint-config-bases/prettier',
  ],
  rules: {
    // optional overrides per project
  },
  overrides: [
    // optional overrides per project file match
  ],
};
