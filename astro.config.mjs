import { defineConfig } from 'astro/config';

const IS_CI = process.env.GITHUB_ACTIONS === 'true';

export default defineConfig({
  site: IS_CI ? 'https://coderdeltalan.github.io/cdlan-portfolio' : 'http://localhost:4321',
  base: IS_CI ? '/cdlan-portfolio' : '/',
  output: 'static',
  build: { inlineStylesheets: 'auto' },
});
