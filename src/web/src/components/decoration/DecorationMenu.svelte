<script lang="ts">
	import type { modeType, spaceType } from "src/utils/misc";
	import { slide } from "svelte/transition";
	import { editorMode, editorSpace } from "../../store/stores";
	import { fetchNui } from "../../utils/fetchNui";
	import { useKeyPress } from "../../utils/useKeyPress";
	import IconCheckbox from "../elements/IconCheckbox.svelte";
	import Page from "../elements/Page.svelte";
	import Editor from "./Editor.svelte";

	let isVisible: boolean;
	let transparency: boolean = false;
	let outline: boolean = false;
	let boundingbox: boolean = false;

	$: fetchNui("setTransparent", transparency);
	$: fetchNui("setOutline", outline);
	$: fetchNui("setBoundingBox", boundingbox);

	const setMode = (mode: modeType) => editorMode.set(mode);
	const setSpace = (space: spaceType) => editorSpace.set(space);

	useKeyPress("r", () => isVisible && setMode("rotate"));
	useKeyPress("w", () => isVisible && setMode("translate"));
	useKeyPress("1", () => isVisible && setSpace("world"));
	useKeyPress("2", () => isVisible && setSpace("local"));
	useKeyPress("Escape", () => isVisible && fetchNui("cancelPlacement"));
	useKeyPress("t", () => {
		if (isVisible) transparency = !transparency;
	});
	useKeyPress("o", () => {
		if (isVisible) outline = !outline;
	});
	useKeyPress("b", () => {
		if (isVisible) boundingbox = !boundingbox;
	});
</script>

<Page id="decoration" bind:isVisible>
	<Editor />

	<div class="absolute left-4 top-1/2 flex -translate-y-1/2 flex-col gap-2" transition:slide={{ axis: "x" }}>
		<div class="flex w-14 flex-col gap-2 rounded-lg bg-gray-200/95 p-2 shadow-lg">
			<IconCheckbox
				icon="mdi:cursor-move"
				tooltip="Move <kbd>(w)</kbd>"
				toggled={$editorMode == "translate"}
				on:toggled={(e) => (e.detail.toggled ? setMode("translate") : null)}
			/>
			<IconCheckbox
				icon="mdi:rotate-orbit"
				tooltip="Rotate <kbd>(r)</kbd>"
				toggled={$editorMode == "rotate"}
				on:toggled={(e) => (e.detail.toggled ? setMode("rotate") : null)}
			/>
		</div>

		<div class="flex w-14 flex-col gap-2 rounded-lg bg-gray-200/95 p-2 shadow-lg">
			<IconCheckbox
				icon="mdi:cube-outline"
				tooltip="Bounding Box <kbd>(b)</kbd>"
				toggled={boundingbox}
				on:toggled={(e) => (boundingbox = e.detail.toggled)}
			/>
			<IconCheckbox
				icon="mdi:crop-square"
				tooltip="Outline <kbd>(o)</kbd>"
				toggled={outline}
				on:toggled={(e) => (outline = e.detail.toggled)}
			/>
			<IconCheckbox
				icon="mdi:opacity"
				tooltip="Transparency <kbd>(t)</kbd>"
				toggled={transparency}
				on:toggled={(e) => (transparency = e.detail.toggled)}
			/>
		</div>

		<div class="flex w-14 flex-col gap-2 rounded-lg bg-gray-200/95 p-2 shadow-lg">
			<IconCheckbox
				icon="mdi:web"
				tooltip="World space <kbd>(1)</kbd>"
				toggled={$editorSpace == "world"}
				on:toggled={(e) => (e.detail.toggled ? setSpace("world") : null)}
			/>
			<IconCheckbox
				icon="mdi:map-marker"
				tooltip="Local space <kbd>(2)</kbd>"
				toggled={$editorSpace == "local"}
				on:toggled={(e) => (e.detail.toggled ? setSpace("local") : null)}
			/>
		</div>
	</div>

	<div class="absolute bottom-0 right-0 flex items-end justify-between gap-4 rounded-tl-lg bg-gray-200/90 p-4">
		<div class="flex gap-2">
			<button
				class="max-w-[6rem] rounded bg-gray-500 p-3 px-6 text-sm text-white"
				on:click={() => fetchNui("cancelPlacement")}
			>
				Back <kbd>(ESC)</kbd>
			</button>
			<button
				class="max-w-[6rem] rounded bg-blue-700 p-3 px-6 text-sm text-white"
				on:click={() => fetchNui("savePlacement")}
			>
				Place
			</button>
		</div>
	</div>
</Page>
