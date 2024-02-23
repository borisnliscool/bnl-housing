<script lang="ts">
	import Icon from "@iconify/svelte";
	import { createEventDispatcher, onMount } from "svelte";

	export let toggled = false;
	export let icon = "fa6-solid:check";
	export let tooltip = "";

	const dispatch = createEventDispatcher();

	const toggle = () => {
		toggled = !toggled;
		dispatch("toggled", { toggled: toggled });
	};

	onMount(() => {
		if (toggled) dispatch("toggled", { toggled: toggled });
	});
</script>

<button
	class="group relative grid aspect-square w-full place-items-center rounded-md text-white outline-none transition-all hover:shadow-sm {toggled
		? 'bg-blue-500'
		: 'bg-gray-400/25'}"
	on:click={toggle}
>
	<div class:opacity-100={toggled} class="pointer-events-none text-2xl opacity-0 transition-all {$$props.class}">
		<Icon {icon} />
	</div>

	{#if tooltip}
		<div
			class="absolute left-[100%] ml-4 hidden whitespace-nowrap rounded-md bg-black/95 p-1 px-2 text-white group-hover:block"
		>
			{@html tooltip}
		</div>
	{/if}
</button>
