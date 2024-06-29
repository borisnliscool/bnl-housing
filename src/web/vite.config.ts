import { svelte } from '@sveltejs/vite-plugin-svelte';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
	plugins: [
		// { ...threeMinifier(), enforce: 'pre' },
		svelte()
	],
	base: './',
	build: {
		outDir: 'build'
	}
});
