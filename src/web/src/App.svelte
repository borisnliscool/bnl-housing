<script>
	import '@fontsource-variable/inter';
	import './app.scss';

	import AdminMenu from './components/admin/AdminMenu.svelte';
	import PropPicker from './components/props/PropPicker.svelte';

	import VisibilityProvider from './providers/VisibilityProvider.svelte';
	import { isEnvBrowser } from './utils/misc';
</script>

{#if isEnvBrowser()}
	<img
		src="https://zip.boris.foo/r/CvSCLP.jpg?compress=false"
		alt="development background"
		class="fixed left-0 top-0 -z-10 h-full w-full object-cover object-center"
	/>
{/if}

<VisibilityProvider>
	<AdminMenu />
	<PropPicker />
</VisibilityProvider>
