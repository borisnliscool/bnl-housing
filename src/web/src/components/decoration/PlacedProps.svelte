<script lang="ts">
	import PlacedPropInfo from "./PlacedPropInfo.svelte";

	import { onMount } from "svelte";
	import { fetchNui } from "../../utils/fetchNui";
	import type { PlacedProp } from "../../utils/interfaces";
	import { isEnvBrowser } from "../../utils/misc";
	import { useNuiEvent } from "../../utils/useNuiEvent";
	import Spinner from "../elements/Spinner.svelte";

	let propPromise: Promise<PlacedProp[]>;
	let propCount = 0;

	$: (async () => (propCount = (await propPromise)?.length ?? 0))();

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
						name: "prop_chair",
						location: JSON.stringify({ x: 3.23, y: 5.12, z: 1.23 }),
						rotation: JSON.stringify({ x: 0.0, y: 0.0, z: 180.0 }),
						metadata: JSON.stringify([]),
					},
					{
						id: 2,
						model: "prop_table",
						name: "prop_table",
						location: JSON.stringify({ x: 1.56, y: 1.45, z: 5.23 }),
						rotation: JSON.stringify({ x: 0.0, y: 0.0, z: 90.0 }),
						metadata: JSON.stringify([]),
					},
				]);
			});
			return;
		}

		propPromise = fetchNui("getPlacedProps");
	});
</script>

<div>
	<h1 class="pb-1 font-bold">Placed props</h1>

	<div class="flex max-h-96 flex-col gap-2 overflow-y-auto" class:pr-2={propCount >= 8}>
		{#await propPromise}
			<div class="grid h-full place-items-center rounded-lg">
				<div class="flex items-center gap-5">
					<Spinner class="w-8" />
					<p>Loading...</p>
				</div>
			</div>
		{:then props}
			{#if props && props.length > 0}
				{#each props as prop (prop.id)}
					<PlacedPropInfo {prop} />
				{/each}
			{:else}
				<p class="py-4 text-center text-sm text-gray-500">No placements found</p>
			{/if}
		{/await}
	</div>
</div>
