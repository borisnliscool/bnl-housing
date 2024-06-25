<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	import type { PropType } from '../../types';
	import { soundOnClick } from '../../utils/sounds';
	import GradientBackdrop from '../elements/GradientBackdrop.svelte';
	import Panel from '../elements/Panel.svelte';
	import PropImage from './PropImage.svelte';

	const dispatch = createEventDispatcher();
	const click = () => dispatch('click');

	export let selectedProp: PropType;
</script>

<GradientBackdrop class="w-full">
	<Panel>
		<div
			class="mx-auto mb-4 mt-1 aspect-square w-full rounded bg-gradient-to-bl from-sky-400/20 to-purple-600/20 p-8"
		>
			<PropImage class="drop-shadow" prop={selectedProp} />
		</div>

		<div class="flex items-end justify-between">
			<div>
				<h1 class="text-xl">{selectedProp.name}</h1>

				<p class="text-neutral-600">
					${selectedProp.price}
				</p>
			</div>

			<button
				class="h-10 w-fit rounded-md bg-gradient-to-tr from-blue-600 to-blue-400 px-6 text-white"
				use:soundOnClick
				on:click
			>
				Buy now
			</button>
		</div>
	</Panel>
</GradientBackdrop>
