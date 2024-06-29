<script lang="ts">
	import { editorMode } from '../../store/stores';
	import { fetchNui } from '../../utils/fetchNui';
	import { useKeyPress } from '../../utils/useKeyPress';
	import Page from '../elements/Page.svelte';
	import Scene from './Scene.svelte';

	import { Canvas } from '@threlte/core';

	let isVisible = false;

	useKeyPress('r', () => isVisible && editorMode.set('rotate'));
	useKeyPress('t', () => isVisible && editorMode.set('translate'));
	// useKeyPress('1', () => isVisible && editorSpace.set('local'));
	// useKeyPress('2', () => isVisible && editorSpace.set('world'));
	useKeyPress('Escape', () => isVisible && fetchNui('cancelPlacement'));
</script>

<Page id="editor" bind:isVisible>
	<Canvas>
		<Scene />
	</Canvas>

	<!-- TODO: Style this with new styles -->
	<div
		class="absolute bottom-0 right-0 flex items-end justify-between gap-4 rounded-tl-lg bg-gray-200/90 p-4"
	>
		<div class="flex gap-2">
			<button
				class="max-w-[8rem] whitespace-nowrap rounded bg-gray-500 p-3 px-6 text-sm text-white"
				on:click={() => fetchNui('cancelPlacement')}
			>
				Back <kbd>(ESC)</kbd>
			</button>
			<button
				class="max-w-[8rem] whitespace-nowrap rounded bg-blue-700 p-3 px-6 text-sm text-white"
				on:click={() => fetchNui('savePlacement')}
			>
				Place
			</button>
		</div>
	</div>
</Page>
