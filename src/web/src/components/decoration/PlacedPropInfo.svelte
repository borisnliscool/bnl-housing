<script lang="ts">
	import { slide } from "svelte/transition";

	export let prop: {
		id: number;
		model: string;
		location: string;
		rotation: string;
		metadata: string;
	};

    $: location = JSON.parse(prop.location);
    $: rotation = JSON.parse(prop.rotation);
    $: metadata = JSON.parse(prop.metadata);

	let visible = false;
</script>

<div class="p-2 pl-5 bg-gray-100/50 font-mono rounded-xl">
	<button class="w-full text-left" on:click={() => (visible = !visible)}>
		<span class="font-bold mr-2">
			{prop.id}
		</span>
		{prop.model}
	</button>

	{#if visible}
		<div
			class="w-full flex gap-2 items-center justify-between"
			transition:slide
		>
			<p class="text-gray-400 text-sm">
				x: {Math.round(location.x * 1000) / 1000}, 
                y: {Math.round(location.y * 1000) / 1000}, 
                z: {Math.round(location.z * 1000) / 1000}
			</p>
			<div>
				<button class="button bg-blue-700"> Edit </button>
				<button class="button bg-red-700"> Delete </button>
			</div>
		</div>
	{/if}
</div>

<style lang="scss">
	.button {
		@apply p-1 px-3 text-white rounded-md text-sm;
	}
</style>
