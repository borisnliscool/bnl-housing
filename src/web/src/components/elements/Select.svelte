<script lang="ts">
	import { onMount } from "svelte";
	import { fade } from "svelte/transition";
	import type { SelectOptionType, placement } from "../../types";
	import { cn } from "../../utils/misc";
	import { soundOnClick, soundOnEnter } from "../../utils/sounds";
	import AngleDown from "../icons/AngleDown.svelte";

	let className = "";
	export { className as class };

	export let items: SelectOptionType[];
	export let value: any = undefined;
	export let shown = false;

	export let placement: placement = "top";
	export let cols = 10;

	const generateClasses = (placement: placement, cols: number) => {
		let styles = [];

		const invertedPlacement = {
			bottom: "top",
			top: "bottom",
			left: "right",
			right: "left",
		}[placement] as placement;

		styles.push(`${invertedPlacement}: 100%;`);
		styles.push(`grid-template-columns: repeat(${cols}, 1fr);`);

		if (placement == "left" || placement == "right") {
			styles.push("top: 0;");
		}

		return styles.join(" ");
	};

	onMount(() => (value = value ? value : items[0]));
</script>

<div class="relative w-full">
	<button
		class="flex w-full items-center justify-between rounded border border-neutral-300 bg-white py-2 px-3.5 text-left outline-none focus-visible:border-blue-400 focus-visible:ring"
		on:click={() => (shown = !shown)}
		use:soundOnClick
	>
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
			class={cn(
				"absolute z-50 grid flex-col gap-1 overflow-hidden rounded-md bg-white p-2 shadow-lg",
				className
			)}
			transition:fade={{ duration: 200 }}
			style={generateClasses(placement, cols)}
		>
			{#each items as item}
				<button
					class={cn(
						"whitespace-pre rounded p-2 px-4 text-left outline-none focus:bg-blue-100 transition-all focus-visible:border-blue-400 focus-visible:ring",
						value == item ? "!bg-blue-600 text-white" : "hover:!bg-blue-100"
					)}
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
