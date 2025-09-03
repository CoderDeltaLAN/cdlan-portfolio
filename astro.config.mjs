import { defineConfig } from 'astro/config';
export default defineConfig({
  site: 'https://coderdeltalan.github.io',
  base: '/cdlan-portfolio/',
  output: 'static',
  build: { inlineStylesheets: 'auto' },
});
