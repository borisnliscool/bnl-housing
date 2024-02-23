<script lang="ts">
	import { createEventDispatcher } from "svelte";
	import { scale } from "svelte/transition";
	import type { PropType } from "../../utils/interfaces";
	import { soundOnEnter } from "../../utils/sounds";

	const dispatch = createEventDispatcher();
	const click = () => dispatch("click");

	export let data: PropType;
	export let animationDelay: number = 0;
	export let hoverEffects = true;
</script>

{#if hoverEffects}
	<button on:click={click} class="prop hover" in:scale={{ delay: animationDelay }} use:soundOnEnter>
		<img class="image" loading="lazy" alt={data.id} src="images/props/{data.id}.webp" />
	</button>
{:else}
	<div class="prop" in:scale={{ delay: animationDelay }}>
		<img class="image" loading="lazy" alt={data.id} src="images/props/{data.id}.webp" />
	</div>
{/if}

<style lang="scss">
	.prop {
		@apply relative grid aspect-square w-full cursor-default place-items-center rounded-lg shadow transition-all;
		@apply border border-gray-300 bg-gradient-to-b from-white via-white to-gray-200;

		.image {
			@apply pointer-events-none aspect-square w-[80%] object-contain;
		}
	}

	.hover {
		@apply cursor-pointer hover:shadow-lg;

		&:hover {
			@apply z-10;
			transform: scale(1.05) perspective(100rem) rotateX(10deg);
		}
	}
</style>
