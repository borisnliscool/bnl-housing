<script context="module" lang="ts">
	import { writable } from "svelte/store";
	const activeId = writable(0);
	let id = 0;
</script>

<script lang="ts">
	import { fetchNui } from "../../utils/fetchNui";
	import { slide } from "svelte/transition";

	export let prop: {
		id: number;
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
</script>

<div class="p-2 pl-5 bg-gray-100/50 font-mono rounded-xl">
	<button class="w-full text-left" on:click={setActive}>
		<span class="font-bold mr-2">
			{prop.id}
		</span>
		{prop.model}
	</button>

	{#if active}
		<div
			class="w-full flex gap-2 items-center justify-between"
			transition:slide
		>
			<p class="text-gray-400 text-sm">
				x: {Math.round(location.x * 1000) / 1000}, y: {Math.round(
					location.y * 1000
				) / 1000}, z: {Math.round(location.z * 1000) / 1000}
			</p>
			<div>
				<button
					class="button bg-blue-700"
					on:click={() => fetchNui("editProp", prop.id)}
				>
					Edit
				</button>
				<button
					class="button bg-red-700"
					on:click={() => fetchNui("deleteProp", prop.id)}
				>
					Delete
				</button>
			</div>
		</div>
	{/if}
</div>

<style lang="scss">
	.button {
		@apply p-1 px-3 text-white rounded-md text-sm;
	}
</style>
