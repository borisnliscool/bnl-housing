<script lang="ts">
	import { useNuiEvent } from "../utils/useNuiEvent";
	import { visibility } from "../store/stores";

	let isVisible: boolean;

	visibility.subscribe((visible) => {
		isVisible = visible;
	});

	useNuiEvent<boolean>("setVisible", (visible) => {
		visibility.set(visible);
	});
</script>

<main>
	{#if isVisible}
		<slot />
	{/if}
</main>
