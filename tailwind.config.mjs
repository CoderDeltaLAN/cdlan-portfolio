export default {
  content: ['./src/**/*.{astro,md,mdx,js,ts}'],
  theme: {
    extend: {
      fontFamily: { sans: ['Inter Variable','Inter','ui-sans-serif','system-ui'] },
      colors: { ink:{100:'#e5e7eb',300:'#9ca3af',700:'#334155',900:'#0f172a'}, brand:{DEFAULT:'#60a5fa',2:'#22d3ee'} },
      boxShadow: { soft:'0 10px 40px rgba(0,0,0,.25)', glass:'inset 0 1px 0 rgba(255,255,255,.08), 0 8px 32px rgba(0,0,0,.25)' }
    }
  },
  darkMode: 'media',
  plugins: [],
}
