// Tailwind CSS v3 configuration
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/gatherly_web.ex",
    "../lib/gatherly_web/**/*.*ex"
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00",
        primary: '#3b82f6',
        secondary: '#f43f5e',
        accent: '#8b5cf6',
        neutral: '#1f2937',
        'base-100': '#ffffff',
        'base-200': '#f9fafb',
        'base-300': '#f3f4f6',
        info: '#3b82f6',
        success: '#10b981',
        warning: '#f59e0b',
        error: '#ef4444',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('daisyui'),
    function({ addVariant }) {
      addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &']);
      addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &']);
      addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &']);
      addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']);
    }
  ],
  daisyui: {
    themes: [
      {
        gatherly: {
          "primary": "#3b82f6",
          "secondary": "#f43f5e", 
          "accent": "#8b5cf6",
          "neutral": "#1f2937",
          "base-100": "#ffffff",
          "base-200": "#f9fafb",
          "base-300": "#f3f4f6",
          "info": "#3b82f6",
          "success": "#10b981",
          "warning": "#f59e0b",
          "error": "#ef4444",
        },
      },
    ],
    darkTheme: "light",
    base: true,
    styled: true,
    utils: true,
    logs: true,
    prefix: "",
  },
}