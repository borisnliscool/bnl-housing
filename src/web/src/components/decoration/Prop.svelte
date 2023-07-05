<script lang="ts">
	import { createEventDispatcher } from "svelte";
	import type { PropType } from "../../utils/interfaces";
	import { scale } from "svelte/transition";

	const dispatch = createEventDispatcher();
	const click = () => dispatch("click");

	export let data: PropType;
	export let animationDelay: number = 0;

	let sound: HTMLAudioElement;
	const playSoundEffect = () => sound.play();
</script>

<audio src="sounds/hover.ogg" preload="auto" bind:this={sound} />

<button
	on:click={click}
	class="prop"
	in:scale={{ delay: animationDelay }}
	on:mouseenter={playSoundEffect}
>
	<img
		class="image"
		loading="lazy"
		alt={data.name}
		src="images/{data.name}.webp"
	/>
</button>

<style lang="scss">
	.prop {
		@apply relative w-full aspect-square rounded-lg border border-gray-300 shadow-md hover:shadow-xl hover:scale-[1.05] transition-all grid place-items-center;
		background: linear-gradient(white 60%, #dfdfdf);

		.image {
			@apply w-[80%] aspect-square object-contain;
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
