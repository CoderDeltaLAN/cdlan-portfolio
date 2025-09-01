import { defineConfig } from 'astro/config';
import github from '@astrojs/github';

export default defineConfig({
  integrations: [github()],
  site: 'https://coderdeltalan.github.io/cdlan-portfolio/',
});
