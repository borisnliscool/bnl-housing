<script lang="ts">
	import { pageStore } from "../../src/store/stores";
	import { useNuiEvent } from "../../src/utils/useNuiEvent";

	export let id: string;
	let isVisible: boolean;

	pageStore.subscribe((page) => {
		isVisible = page == id;
	});

	useNuiEvent<string>("setPage", (page) => {
		pageStore.set(page);
	});
</script>

{#if isVisible}
	<section class="w-full h-screen relative">
		<slot />
	</section>
{/if}
