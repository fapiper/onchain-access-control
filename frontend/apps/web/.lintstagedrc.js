export default {
  'src/**/*.{js,jsx,ts,tsx}': ['eslint --fix --max-warnings=0', 'prettier --write'],
  'src/**/*.{json,css,scss,md}': ['prettier --write'],
}
