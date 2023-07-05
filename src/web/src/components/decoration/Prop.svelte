<script lang="ts">
	import { createEventDispatcher } from "svelte";
	import type { PropType } from "../../utils/interfaces";
	import { scale } from "svelte/transition";
	import { soundOnEnter } from "../../utils/sounds";

	const dispatch = createEventDispatcher();
	const click = () => dispatch("click");

	export let data: PropType;
	export let animationDelay: number = 0;
</script>

<button
	on:click={click}
	class="prop"
	in:scale={{ delay: animationDelay }}
    use:soundOnEnter
    data-sound="sounds/hover.ogg"
>
	<img
		class="image"
		loading="lazy"
		alt={data.name}
		src="images/props/{data.name}.webp"
	/>
</button>

<style lang="scss">
	.prop {
		@apply relative w-full aspect-square rounded-lg border border-gray-300 shadow-md hover:shadow-xl hover:scale-[1.05] transition-all grid place-items-center;
		background: linear-gradient(white 60%, #dfdfdf);

		.image {
			@apply w-[80%] aspect-square object-contain pointer-events-none;
		}

		&:hover {
			@apply z-10;
			transform: scale(1.1) perspective(100rem) rotateX(10deg);

			.image {
				filter: drop-shadow(0 0 1rem #00c0ff80);
			}
		}
	}
</style>
