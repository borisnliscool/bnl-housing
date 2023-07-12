<script lang="ts">
	import PlacedPropInfo from "./PlacedPropInfo.svelte";

	import { isEnvBrowser } from "../../utils/misc";
	import { fetchNui } from "../../utils/fetchNui";
	import { onMount } from "svelte";
	import Spinner from "../elements/Spinner.svelte";
	import { useNuiEvent } from "../../utils/useNuiEvent";
	import type { PlacedProp } from "../../utils/interfaces";
	import { scale } from "svelte/transition";

	let propPromise: Promise<PlacedProp[]>;

	useNuiEvent("setPlacedProps", (props: PlacedProp[]) => {
		propPromise = new Promise((r) => r(props));
	});

	onMount(() => {
		if (isEnvBrowser()) {
			propPromise = new Promise((r) => {
				r([
					{
						id: 1,
						model: "prop_chair",
						location: JSON.stringify({ x: 3.23, y: 5.12, z: 1.23 }),
						rotation: JSON.stringify({ x: 0.0, y: 0.0, z: 180.0 }),
						metadata: JSON.stringify([]),
					},
				]);
			});
			return;
		}
		propPromise = fetchNui("getPlacedProps");
	});
</script>

<div class="placed-menu" transition:scale>
	<h1 class="font-bold">Placed props</h1>

	<div class="flex flex-col gap-2 max-h-96 overflow-y-auto pr-1.5">
		{#await propPromise}
			<div class="h-full grid place-items-center rounded-lg">
				<div class="flex items-center gap-5">
					<Spinner class="w-8" />
					<p>Loading...</p>
				</div>
			</div>
		{:then props}
			{#if props && props.length > 0}
				{#each props as prop}
					<PlacedPropInfo {prop} />
				{/each}
			{:else}
				<p class="text-center text-sm text-gray-500">No placements found</p>
			{/if}
		{/await}
	</div>
</div>

<style lang="scss">
	.placed-menu {
		@apply absolute w-full max-w-md top-0 right-0 m-3 p-3 px-4 bg-gray-200/95 shadow-lg rounded-lg flex flex-col gap-1;
	}
</style>
