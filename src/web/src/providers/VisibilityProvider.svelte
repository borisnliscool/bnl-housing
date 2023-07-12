<script lang="ts">
	import { useNuiEvent } from "../utils/useNuiEvent";
	import { visibility } from "../store/stores";

	useNuiEvent<boolean>("setVisible", (visible) => ($visibility = visible));
</script>

<main>
	{#if $visibility}
		<slot />
	{/if}
</main>
