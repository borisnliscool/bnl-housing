<script lang="ts">
	import { createEventDispatcher, onMount } from 'svelte';
	import { cn } from '../../utils/misc';
	import { soundOnClick } from '../../utils/sounds';
	import Check from '../icons/Check.svelte';

	let className = '';
	export { className as class };
	export let toggled = false;
	export let tooltip = '';

	const dispatch = createEventDispatcher();

	const toggle = () => {
		toggled = !toggled;
		dispatch('toggled', { toggled: toggled });
	};

	onMount(() => {
		if (toggled) dispatch('toggled', { toggled: toggled });
	});
</script>

<button class="group flex items-center gap-2 outline-none" on:click={toggle} use:soundOnClick>
	<div
		class={cn(
			'group relative grid aspect-square w-full place-items-center rounded border text-white outline-none transition-all hover:shadow-sm group-focus-visible:border-blue-400 group-focus-visible:ring',
			toggled ? 'border-blue-500 bg-blue-500' : 'border-gray-300 bg-white',
			className
		)}
	>
		<div class:opacity-100={toggled} class="pointer-events-none text-2xl opacity-0 transition-all">
			<slot name="icon">
				<Check
					class={cn(
						'size-4 fill-white transition-all',
						toggled ? 'rotate-0 scale-100' : '-rotate-45 scale-50'
					)}
				/>
			</slot>
		</div>

		{#if tooltip}
			<div
				class="absolute left-[100%] ml-4 hidden whitespace-nowrap rounded bg-black/95 p-1 px-2 text-white group-hover:block"
			>
				<!-- eslint-disable svelte/no-at-html-tags -->
				{@html tooltip}
			</div>
		{/if}
	</div>

	<slot />
</button>
