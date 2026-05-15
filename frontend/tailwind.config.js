/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "#fdfdfd",
        surface: "#ffffff",
        border: "#e5e7eb",
        foreground: "#111827",
        muted: "#6b7280",
        accent: "#0f172a",
        accentHover: "#1e293b",
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      }
    },
  },
  plugins: [],
}

