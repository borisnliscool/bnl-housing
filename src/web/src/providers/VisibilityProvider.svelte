<script lang="ts">
	import { visibility } from "../store/stores";
	import { useNuiEvent } from "../utils/useNuiEvent";

	useNuiEvent<boolean>("setVisible", (visible) => ($visibility = visible));
</script>

<main>
	{#if $visibility}
		<slot />
	{/if}
</main>
