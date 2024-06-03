<script lang="ts">
	import { createEventDispatcher, onMount } from "svelte";
	import { soundOnClick } from "../../utils/sounds";
	import Check from "../icons/Check.svelte";

	export let toggled = false;
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
	class="group relative grid aspect-square w-full place-items-center rounded text-white outline-none transition-all hover:shadow-sm {toggled
		? 'bg-blue-500'
		: 'bg-gray-400/25'}"
	on:click={toggle}
	use:soundOnClick
>
	<div
		class:opacity-100={toggled}
		class="pointer-events-none text-2xl opacity-0 transition-all {$$props.class}"
	>
		<slot>
			<Check
				class="size-4 fill-white transition-all {toggled
					? 'rotate-0 scale-100'
					: '-rotate-45 scale-50'}"
			/>
		</slot>
	</div>

	{#if tooltip}
		<div
			class="absolute left-[100%] ml-4 hidden whitespace-nowrap rounded bg-black/95 p-1 px-2 text-white group-hover:block"
		>
			{@html tooltip}
		</div>
	{/if}
</button>
