<script lang="ts">
	import { onMount } from "svelte";
	import { fade } from "svelte/transition";
	import type { SelectOptionType, placement } from "../../types";
	import { soundOnEnter } from "../../utils/sounds";
	import AngleDown from "../icons/AngleDown.svelte";

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
			<AngleDown />
		</span>
	</button>

	{#if shown}
		<button
			class="fixed left-0 top-0 z-40 h-full w-full cursor-default"
			on:click={() => (shown = false)}
		/>

		<div
			class="options {$$props.class}"
			{style}
			transition:fade={{ duration: 200 }}
		>
			{#each items as item}
				<button
					class="option {value == item
						? '!bg-blue-600 text-white'
						: 'hover:!bg-blue-100'}"
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
		@apply flex w-full items-center justify-between rounded border border-neutral-300 bg-white py-2 px-3.5 text-left outline-none focus-visible:ring;
	}

	.options {
		@apply absolute z-50 grid flex-col overflow-hidden rounded bg-white p-1 shadow-lg;
	}

	.option {
		@apply whitespace-pre rounded-sm p-2 px-4 text-left outline-none focus:bg-blue-100;
		transition: background-color 100ms;
	}
</style>
