<script lang="ts">
	import { editorMode, editorSpace } from "../../store/stores";
	import Page from "../elements/Page.svelte";
	import Editor from "./Editor.svelte";
	import type { modeType, spaceType } from "src/utils/misc";
	import { fetchNui } from "../../utils/fetchNui";
	import { useKeyPress } from "../../utils/useKeyPress";
	import Toggle from "../elements/Toggle.svelte";

	let isVisible: boolean;
	let mode: modeType;
	let space: spaceType;

	let transparency: boolean = false;
	let outline: boolean = false;
	let boundingbox: boolean = false;

	$: fetchNui("setTransparent", transparency);
	$: fetchNui("setOutline", outline);
	$: fetchNui("setBoundingBox", boundingbox);

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

	useKeyPress("r", () => isVisible && setMode("rotate"));
	useKeyPress("w", () => isVisible && setMode("translate"));
	useKeyPress("1", () => isVisible && setSpace("world"));
	useKeyPress("2", () => isVisible && setSpace("local"));
	useKeyPress("Escape", () => isVisible && fetchNui("cancelPlacement"));
	useKeyPress("t", () => (transparency = !transparency));
	useKeyPress("o", () => (outline = !outline));
	useKeyPress("b", () => (boundingbox = !boundingbox));
</script>

<Page id="decoration" bind:isVisible>
	<Editor />

	<div
		class="absolute bottom-0 left-0 px-6 py-4 w-full bg-gray-200/90 flex items-end justify-between gap-4"
	>
		<div class="flex gap-4">
			<div>
				<p>Mode</p>
				<div class="flex rounded-md overflow-hidden">
					<button
						class="switchButton {mode == 'translate'
							? 'bg-blue-700'
							: 'bg-gray-500'}"
						on:click={() => setMode("translate")}
					>
						Move <kbd>(w)</kbd>
					</button>
					<button
						class="switchButton {mode == 'rotate'
							? 'bg-blue-700'
							: 'bg-gray-500'}"
						on:click={() => setMode("rotate")}
					>
						Rotate <kbd>(r)</kbd>
					</button>
				</div>
			</div>

			<div>
				<p>Space</p>
				<div class="flex rounded-md overflow-hidden">
					<button
						class="switchButton {space == 'world'
							? 'bg-blue-700'
							: 'bg-gray-500'}"
						on:click={() => setSpace("world")}
					>
						World <kbd>(1)</kbd>
					</button>
					<button
						class="switchButton {space == 'local'
							? 'bg-blue-700'
							: 'bg-gray-500'}"
						on:click={() => setSpace("local")}
					>
						Local <kbd>(2)</kbd>
					</button>
				</div>
			</div>

			<div>
				<p>Settings</p>
				<div class="flex gap-4">
					<div>
						<Toggle
							label="Transparency <kbd>(t)</kbd>"
							toggled={transparency}
						/>
						<Toggle label="Outline <kbd>(o)</kbd>" toggled={outline} />
					</div>
					<div>
						<Toggle label="Bounding box <kbd>(b)</kbd>" toggled={boundingbox} />
					</div>
				</div>
			</div>
		</div>

		<div class="flex gap-2">
			<button
				class="button bg-gray-500"
				on:click={() => fetchNui("cancelPlacement")}
			>
				Cancel <kbd>(ESC)</kbd>
			</button>
			<button
				class="button bg-blue-700"
				on:click={() => fetchNui("savePlacement")}
			>
				Save
			</button>
		</div>
	</div>
</Page>

<style lang="scss">
	.button {
		@apply p-3 px-6 text-white rounded-md text-sm;
		min-width: 6rem;
	}

	.switchButton {
		@apply p-3 px-6 text-white text-sm outline-none;
		min-width: 6rem;
	}
</style>
