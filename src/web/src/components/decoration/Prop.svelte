<script lang="ts">
	import { createEventDispatcher } from "svelte";
	import type { PropType } from "../../utils/interfaces";

	const dispatch = createEventDispatcher();
	const click = () => dispatch("click");

	export let data: PropType;
</script>

<button on:click={click} class="prop">
	<img
		class="image"
		loading="lazy"
		alt={data.name}
		src="images/{data.name}.webp"
	/>
</button>

<style lang="scss">
	.prop {
		@apply relative w-full aspect-square rounded-lg border border-gray-300 shadow-md hover:scale-[1.05] transition-all grid place-items-center;
		background: linear-gradient(white 60%, #dfdfdf);
	}

	.image {
		@apply w-[80%] aspect-square object-contain;
	}
</style>
