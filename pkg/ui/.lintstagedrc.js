module.exports = {
  'src/**/*.{js,jsx,ts,tsx}': ['eslint --fix --max-warnings=0 --no-error-on-unmatched-pattern'],
  'src/**/*.{json,css,scss,md}': ['prettier --write'],
}
