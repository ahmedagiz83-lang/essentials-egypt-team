/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['DM Sans', 'system-ui', 'sans-serif'],
        display: ['Syne', 'system-ui', 'sans-serif'],
      },
      colors: {
        gold: '#C9A84C',
        'gold-light': '#F0D080',
        'gold-dark': '#8B6914',
        'bg-1': '#0A0A0F',
        'bg-2': '#111118',
        'bg-3': '#1A1A24',
        'bg-4': '#222230',
        'border-1': '#2A2A3A',
        'border-2': '#3A3A50',
      },
    },
  },
  plugins: [],
};
