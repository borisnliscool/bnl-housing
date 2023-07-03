<script lang="ts">
	import { pageStore } from "../../store/stores";
	import { useNuiEvent } from "../../utils/useNuiEvent";

	export let id: string;
	export let isVisible: boolean = false;

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
