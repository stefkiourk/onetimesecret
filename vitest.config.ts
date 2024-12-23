import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import path from 'path'

// use mock service workers lib to mock API requests (any fetch or axios requests).

// test.environment is global setting. Can also use magic comments
// per file (see below) or setting test.environmentMatchGlobs.
//
//    @vitest-environment happy-dom
//    test('useTitle should work', () =>

// vi.mock needs to be a top level so they can override at start time
// and cannot use local variables (i.e. ones defined outside).

// Use vitest snapshots, inline snapshots. vitest -u to update snapshots.
// Inline snapshots can be used to test outputs in place of console.log.
// Check in snapshots to git. When updating automatically, can confirm
// before committing.

// @vitejs/plugin-vue is used to traspile composition API components to
// javascript. That's what makes them testable and allos import vue files.

// @vue/test-utils, mount function. Testing components with props.

// Functional components: <template functional>, uses `props.keyName`, context (listeners, slots, children etc)
export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',  // or 'happy-dom' (light faster dom), 'jsdom' (more feature complete), 'node' (no dom, so no document or window) -- node is the default
    include: [
      'tests/unit/vue/**/*.spec.ts',
      'tests/unit/vue/**/*.spec.vue',
    ],
    exclude: [
      '**/node_modules/**',
      '**/.trunk/**',
      '**/dist/**',
      '**/.{idea,git,cache,output,temp}/**',
    ],
    setupFiles: [
      'tests/unit/vue/setup.ts',
    ],
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
