<script lang="ts">
	import { createEventDispatcher, onMount } from "svelte";

	export let toggled = false;
	export let label = "";

	const dispatch = createEventDispatcher();

	const toggle = () => {
		toggled = !toggled;
		dispatch("toggled", { toggled: toggled });
	};

	onMount(() => {
		if (toggled) dispatch("toggled", { toggled: toggled });
	});
</script>

<button class="flex gap-2 items-center outline-none" on:click={toggle}>
	<div
		class="w-9 h-5 rounded-full overflow-hidden p-0.5 transition-colors {!toggled
			? 'bg-gray-400'
			: 'bg-blue-400'} relative"
	>
		<div
			class="h-4 w-4 transition-all {!toggled
				? 'ml-0 bg-gray-600'
				: 'ml-4 bg-blue-600'} rounded-full"
		/>
	</div>

	{#if label}
		<p>{@html label}</p>
	{/if}
</button>
