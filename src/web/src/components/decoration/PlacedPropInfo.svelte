<script context="module" lang="ts">
	import { writable } from "svelte/store";
	const activeId = writable(-1);
	let id = 0;
</script>

<script lang="ts">
	import { slide } from "svelte/transition";
	import { fetchNui } from "../../utils/fetchNui";
	import { soundOnEnter } from "../../utils/sounds";

	export let prop: {
		id: number;
		name: string;
		model: string;
		location: string;
		rotation: string;
		metadata: string;
	};

	$: location = JSON.parse(prop.location);

	const componentId = id++;
	$: active = $activeId == componentId;

	function setActive() {
		$activeId = $activeId != componentId ? componentId : -1;
	}

	$: coords = {
		x: Math.round(location.x * 1000) / 1000,
		y: Math.round(location.y * 1000) / 1000,
		z: Math.round(location.z * 1000) / 1000,
	};
</script>

<div class="rounded-md bg-gray-100 p-2 pl-5">
	<button class="w-full text-left" on:click={setActive} use:soundOnEnter>
		{prop.name}
	</button>

	{#if active}
		<div class="flex w-full items-center justify-between gap-2" transition:slide>
			<p class="text-sm text-gray-400">
				x: {coords.x}, y: {coords.y}, z: {coords.z}
			</p>
			<div>
				<button
					class="rounded bg-blue-700 p-1 px-3 text-sm text-white"
					on:click={() => fetchNui("editProp", prop.id)}
				>
					Edit
				</button>
				<button
					class="rounded bg-red-700 p-1 px-3 text-sm text-white"
					on:click={() => fetchNui("deleteProp", prop.id)}
				>
					Delete
				</button>
			</div>
		</div>
	{/if}
</div>
