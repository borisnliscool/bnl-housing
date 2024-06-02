<script>
	import "./app.scss";
	import VisibilityProvider from "./providers/VisibilityProvider.svelte";
	import { isEnvBrowser } from "./utils/misc";
</script>

{#if isEnvBrowser()}
	<img
		src="https://zip.boris.foo/r/CvSCLP.jpg?compress=false"
		alt="development background"
		class="-z-10 fixed left-0 top-0 h-full w-full object-cover object-center"
	/>
{/if}

<VisibilityProvider>Hello world</VisibilityProvider>
