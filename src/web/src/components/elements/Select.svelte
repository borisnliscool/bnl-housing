<script lang="ts">
	import { onMount } from "svelte";
	import { fade } from "svelte/transition";
	import type { SelectOptionType, placement } from "../../types";
	import { soundOnClick, soundOnEnter } from "../../utils/sounds";
	import AngleDown from "../icons/AngleDown.svelte";

	export let items: SelectOptionType[];
	export let value: any = undefined;
	export let shown = false;

	export let placement: placement = "top";
	export let cols = 10;

	let style = "";

	const generateClasses = (placement: placement, _cols: number) => {
		let style = "";

		const invertedPlacement = {
			bottom: "top",
			top: "bottom",
			left: "right",
			right: "left",
		}[placement] as placement;

		style += `${invertedPlacement}: 100%;`;
		style += `grid-template-columns: repeat(${_cols}, 1fr);`;

		if (placement == "left" || placement == "right") {
			style += "top: 0;";
		}

		return style;
	};

	$: style = generateClasses(placement, cols);
	onMount(() => (value = value ? value : items[0]));
</script>

<div class="select">
	<button class="active" on:click={() => (shown = !shown)} use:soundOnClick>
		{#if value}
			{value.name}
		{:else}
			<span class="text-gray-300">Select</span>
		{/if}

		<span class="text-gray-500 transition-transform" class:rotate-180={!shown}>
			<div class="size-3">
				<AngleDown />
			</div>
		</span>
	</button>

	{#if shown}
		<button
			class="fixed left-0 top-0 z-40 h-full w-full cursor-default"
			on:click={() => (shown = false)}
		/>

		<div
			class="options {$$props.class}"
			transition:fade={{ duration: 200 }}
			{style}
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
					use:soundOnClick
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
		@apply absolute z-50 grid flex-col overflow-hidden rounded-md bg-white p-1 shadow-lg;
	}

	.option {
		@apply whitespace-pre rounded p-2 px-4 text-left outline-none focus:bg-blue-100;
		transition: background-color 100ms;
	}
</style>
