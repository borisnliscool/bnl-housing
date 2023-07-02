<script lang="ts">
	import { onMount } from "svelte";
	import { editorMode, editorSpace } from "../../store/stores";
	import Page from "../Page.svelte";
	import Editor from "./Editor.svelte";
	import type { modeType, spaceType } from "src/utils/misc";
	import { fetchNui } from "../../utils/fetchNui";

	let mode: modeType;
	let space: spaceType;

	editorMode.subscribe((_mode) => {
		mode = _mode as modeType;
	});

	editorSpace.subscribe((_space) => {
		space = _space as spaceType;
	});

	const setMode = (mode: modeType) => {
		editorMode.set(mode);
	};

	const setSpace = (space: spaceType) => {
		editorSpace.set(space);
	};

	onMount(() => {
		const keyHandler = (e: KeyboardEvent) => {
			switch (e.key) {
				case "r":
					setMode("rotate");
					break;
				case "w":
					setMode("translate");
					break;
				case "1":
					setSpace("world");
					break;
				case "2":
					setSpace("local");
					break;
				default:
					break;
			}
		};

		document.addEventListener("keydown", keyHandler);
		return () => document.removeEventListener("keydown", keyHandler);
	});
</script>

<Page id="decoration">
	<Editor />

	<div
		class="absolute bottom-0 left-0 px-6 py-4 w-full bg-gray-200/75 flex items-end justify-between gap-4"
	>
		<div class="flex gap-4">
			<div>
				<p>Mode</p>
				<button
					class="modeButton {mode == 'translate'
						? 'bg-blue-700'
						: 'bg-gray-500'}"
					on:click={() => setMode("translate")}
				>
					Move <span class="font-mono">(w)</span>
				</button>
				<button
					class="modeButton {mode == 'rotate' ? 'bg-blue-700' : 'bg-gray-500'}"
					on:click={() => setMode("rotate")}
				>
					Rotate <span class="font-mono">(r)</span>
				</button>
			</div>

			<div>
				<p>Space</p>
				<button
					class="modeButton {space == 'world' ? 'bg-blue-700' : 'bg-gray-500'}"
					on:click={() => setSpace("world")}
				>
					World <span class="font-mono">(1)</span>
				</button>
				<button
					class="modeButton {space == 'local' ? 'bg-blue-700' : 'bg-gray-500'}"
					on:click={() => setSpace("local")}
				>
					Local <span class="font-mono">(2)</span>
				</button>
			</div>
		</div>

		<div>
			<button
				class="modeButton bg-gray-500"
				on:click={() => fetchNui("cancelPlacement")}
			>
				Cancel
			</button>
			<button
				class="modeButton bg-blue-700"
				on:click={() => fetchNui("savePlacement")}
			>
				Save
			</button>
		</div>
	</div>
</Page>

<style lang="scss">
	.modeButton {
		@apply p-3 px-6 text-white rounded-md text-sm;
		min-width: 6rem;
	}
</style>
