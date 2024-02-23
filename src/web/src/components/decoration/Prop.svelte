<script lang="ts">
	import { createEventDispatcher } from "svelte";
	import type { PropType } from "../../utils/interfaces";
	import { scale } from "svelte/transition";
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
		@apply relative grid aspect-square w-full cursor-default place-items-center rounded-lg border border-gray-300 shadow-md transition-all;
		background: linear-gradient(white 60%, #dfdfdf);

		.image {
			@apply pointer-events-none aspect-square w-[80%] object-contain;
		}
	}

	.hover {
		@apply cursor-pointer hover:scale-[1.05] hover:shadow-xl;

		&:hover {
			@apply z-10;
			transform: scale(1.1) perspective(100rem) rotateX(10deg);

			.image {
				filter: drop-shadow(0 0 1rem #00c0ff80);
			}
		}
	}
</style>
