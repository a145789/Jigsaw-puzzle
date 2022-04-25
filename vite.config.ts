/// <reference types="vite/client" />

import { defineConfig } from "vite"
import reactRefresh from "@vitejs/plugin-react-refresh"
import createReScriptPlugin from "@jihchi/vite-plugin-rescript"
import Unocss from "unocss/vite"

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [reactRefresh(), Unocss(), createReScriptPlugin()],
})
