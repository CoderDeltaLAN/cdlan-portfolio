import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://coderdeltalan.github.io/cdlan-portfolio/',
  integrations: [
    tailwind({ applyBaseStyles: false }),
    mdx(),
    sitemap(),
  ],
  build: { inlineStylesheets: 'auto' },
});
