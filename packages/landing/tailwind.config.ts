import type { Config } from 'tailwindcss';

export default {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '#6C63FF',
          dark: '#4840C4',
          light: '#EEF0FF',
        },
      },
      fontFamily: {
        sans: ['var(--font-inter)', 'system-ui', 'sans-serif'],
      },
      backgroundImage: {
        'hero-gradient': 'linear-gradient(135deg, #f8f7ff 0%, #eef0ff 50%, #f0f9ff 100%)',
      },
      boxShadow: {
        brand: '0 4px 24px 0 rgba(108,99,255,0.18)',
        card: '0 2px 16px 0 rgba(15,23,42,0.07)',
        'card-hover': '0 8px 32px 0 rgba(15,23,42,0.12)',
      },
    },
  },
  plugins: [],
} satisfies Config;
