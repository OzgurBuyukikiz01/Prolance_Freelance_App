import type { Config } from 'tailwindcss';

export default {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Primary — Electric Violet (brand)
        primary: {
          50:  '#F3F0FF',
          100: '#E9E3FF',
          200: '#D4C9FF',
          300: '#B5A3FF',
          400: '#9075FF',
          500: '#7248FE',
          600: '#5E2FE8',
          700: '#4B1EC7',
          800: '#3C19A0',
          900: '#2E1580',
          950: '#1A0A4A',
          DEFAULT: '#7248FE',
        },
        // Secondary — Ocean Mint
        secondary: {
          50:  '#EDFDF8',
          100: '#D2F9EE',
          200: '#A8F2DC',
          300: '#6AE8C5',
          400: '#2DD5A8',
          500: '#0EBD90',
          600: '#059873',
          700: '#077A5D',
          800: '#085F49',
          900: '#064E3C',
          950: '#022B21',
          DEFAULT: '#0EBD90',
        },
        // Accent — Electric Coral
        accent: {
          50:  '#FFF4F0',
          100: '#FFE4D9',
          200: '#FFC4AA',
          300: '#FF9E7A',
          400: '#FF7A52',
          500: '#FF5833',
          600: '#E63F1A',
          700: '#C22E10',
          800: '#9A230C',
          900: '#7A1C0A',
          950: '#3D0A03',
          DEFAULT: '#FF5833',
        },
        // Neutral — Warm Slate
        neutral: {
          50:  '#F9F8F7',
          100: '#F2F0EE',
          200: '#E6E2DE',
          300: '#CFC8C0',
          400: '#B0A69A',
          500: '#8D8178',
          600: '#6B6059',
          700: '#504740',
          800: '#352E28',
          900: '#1E1812',
          950: '#100E0A',
        },
        // Brand aliases (map to primary violet palette)
        brand: {
          DEFAULT: '#7248FE',
          light:   '#F3F0FF',
          dark:    '#5E2FE8',
          50:  '#F3F0FF',
          100: '#E9E3FF',
          200: '#D4C9FF',
          300: '#B5A3FF',
          400: '#9075FF',
          500: '#7248FE',
          600: '#5E2FE8',
          700: '#4B1EC7',
          800: '#3C19A0',
          900: '#2E1580',
        },
        // Glass tokens for admin panel
        glass: {
          white: 'rgba(255, 255, 255, 0.05)',
          border: 'rgba(255, 255, 255, 0.10)',
          'border-strong': 'rgba(255, 255, 255, 0.18)',
        },
        // Admin dark backgrounds
        admin: {
          base: '#0A0F1E',
          surface: '#0F1628',
          elevated: '#14203A',
        },
      },
      fontFamily: {
        sans: ['var(--font-poppins)', 'system-ui', 'sans-serif'],
      },
      backgroundImage: {
        'brand-gradient':  'linear-gradient(135deg, #FF5833 0%, #7248FE 100%)',
        'coral-gradient':  'linear-gradient(135deg, #FF5833 0%, #FF8A65 100%)',
        'mint-gradient':   'linear-gradient(135deg, #0EBD90 0%, #2DD5A8 100%)',
        'violet-gradient': 'linear-gradient(135deg, #7248FE 0%, #9075FF 100%)',
        'hero-gradient':   'linear-gradient(135deg, #FFF4F0 0%, #F3F0FF 50%, #EDFDF8 100%)',
        'glass-gradient':  'linear-gradient(135deg, rgba(255,88,51,0.06) 0%, rgba(114,72,254,0.06) 100%)',
      },
      boxShadow: {
        glass:         '0 8px 32px rgba(0, 0, 0, 0.30), inset 0 1px 0 rgba(255, 255, 255, 0.10)',
        'glass-sm':    '0 4px 16px rgba(0, 0, 0, 0.20)',
        'glow-coral':  '0 0 24px rgba(255, 88, 51, 0.35)',
        'glow-violet': '0 0 24px rgba(114, 72, 254, 0.35)',
        'glow-mint':   '0 0 24px rgba(14, 189, 144, 0.35)',
        card:          '0 2px 16px rgba(30, 24, 18, 0.07)',
        'card-hover':  '0 8px 32px rgba(30, 24, 18, 0.12)',
        brand:         '0 4px 24px rgba(114, 72, 254, 0.25)',
      },
      animation: {
        'fade-in':  'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1)',
        'float':    'float 6s ease-in-out infinite',
        'shimmer':  'shimmer 2s linear infinite',
        'pulse-glow': 'pulseGlow 2s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%':   { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%':   { transform: 'translateY(12px)', opacity: '0' },
          '100%': { transform: 'translateY(0)',     opacity: '1' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%':      { transform: 'translateY(-8px)' },
        },
        shimmer: {
          '0%':   { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0'  },
        },
        pulseGlow: {
          '0%, 100%': { opacity: '0.6' },
          '50%':      { opacity: '1.0' },
        },
      },
    },
  },
  plugins: [],
} satisfies Config;
