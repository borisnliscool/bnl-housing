<script lang="ts">
	import { fade } from "svelte/transition";
	import { pageStore } from "../../store/stores";
	import { useNuiEvent } from "../../utils/useNuiEvent";

	export let id: string;
	export let isVisible: boolean = false;
	export let transition = fade;

    $: isVisible = $pageStore == id;

	useNuiEvent<string>("setPage", (page) => {
        $pageStore = page;
	});
</script>

{#if isVisible}
	<section
		class="fixed top-0 left-0 w-full h-screen"
		transition:transition={{ duration: 150 }}
	>
		<div class="h-full relative">
			<slot />
		</div>
	</section>
{/if}
