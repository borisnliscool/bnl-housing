<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	import type { PropType } from '../../types';
	import { cn } from '../../utils/misc';
	import { soundOnClick, soundOnEnter } from '../../utils/sounds';
	import PropImage from './PropImage.svelte';

	const dispatch = createEventDispatcher();
	const click = () => dispatch('click');

	let className = '';
	export { className as class };

	export let prop: PropType;
</script>

<button
	on:click={click}
	class={cn(
		'relative grid aspect-square w-full cursor-default place-items-center rounded-lg border border-gray-300 bg-gradient-to-b from-white via-white to-gray-200 shadow transition-all',
		'cursor-pointer hover:z-10 hover:shadow-md',
		className
	)}
	use:soundOnClick
	use:soundOnEnter
>
	<PropImage class="pointer-events-none p-4" {prop} />
</button>

<style>
	button:hover {
		transform: scale(1.05) perspective(100rem) rotateX(10deg);
	}
</style>
