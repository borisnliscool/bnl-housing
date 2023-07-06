<script lang="ts">
	import { onMount } from "svelte";
	import Icon from "@iconify/svelte";
	import type { SelectOptionType, placement } from "../../utils/interfaces";
	import { fade } from "svelte/transition";
	import { soundOnEnter } from "../../utils/sounds";

	export let items: SelectOptionType[];
	export let value: any = undefined;
	export let shown = false;

	export let placement: placement = "top";
	export let cols = 10;
	let style = "";

	const generateClasses = (_placement: placement, _cols: number) => {
		let _style = "";

		const invertedPlacement = {
			bottom: "top",
			top: "bottom",
			left: "right",
			right: "left",
		}[_placement] as placement;

		_style += `${invertedPlacement}: 100%;`;
		_style += `grid-template-columns: repeat(${_cols}, 1fr);`;
		_style += `margin-${invertedPlacement}: 0.25rem;`;

		if (_placement == "left" || _placement == "right") {
			_style += "top: 0;";
		}

		return _style;
	};

	$: style = generateClasses(placement, cols);
	onMount(() => (value = value ? value : items[0]));
</script>

<div class="select">
	<button
		class="active"
		on:click={() => {
			shown = !shown;
		}}
	>
		{#if value}
			{value.name}
		{:else}
			<span class="text-gray-300">Select</span>
		{/if}

		<span class="text-gray-500 transition-transform" class:rotate-180={shown}>
			<Icon icon="fa6-solid:angle-down" />
		</span>
	</button>

	{#if shown}
		<button
			class="fixed top-0 left-0 w-full h-full cursor-default z-40"
			on:click={() => (shown = false)}
		/>

		<div class="options" {style} transition:fade={{ duration: 200 }}>
			{#each items as item}
				<button
					class="option {value == item
						? 'bg-blue-600 text-white'
						: 'hover:bg-blue-100'}"
					on:click={() => {
						value = item;
						shown = !shown;
					}}
                    use:soundOnEnter
				>
					{item.name}
				</button>
			{/each}
		</div>
	{/if}
</div>

<style lang="scss">
	.select {
		@apply relative w-full;
	}

	.active {
		@apply w-full text-left p-1 px-4 pr-2 border border-gray-400 rounded-md bg-white flex items-center justify-between;
	}

	.options {
		@apply absolute grid z-50 flex-col rounded-md overflow-hidden bg-white shadow-lg p-1;
	}

	.option {
		@apply text-left p-2 px-4 rounded-sm whitespace-pre;
		transition: background-color 100ms;
	}
</style>
