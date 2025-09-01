import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://coderdeltalan.github.io',   // SOLO dominio
  base: '/cdlan-portfolio',                  // subruta del repo
  output: 'static',
  build: { inlineStylesheets: 'auto' },
});
