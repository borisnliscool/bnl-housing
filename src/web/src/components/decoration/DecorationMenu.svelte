<script lang="ts">
	import { onMount } from "svelte";
	import { editorMode } from "../../store/stores";
	import Page from "../Page.svelte";
	import Editor from "./Editor.svelte";
	import type { modeType } from "src/utils/misc";

	const setMode = (mode: modeType) => {
		editorMode.set(mode);
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
				default:
					break;
			}
		};

		window.addEventListener("keydown", keyHandler);
		return () => window.removeEventListener("keydown", keyHandler);
	});
</script>

<Page id="decoration">
	<Editor />

	<div
		class="absolute bottom-0 left-0 w-full h-24 bg-gray-200/75 flex items-center justify-center gap-4"
	>
		<button class="modeButton" on:click={() => setMode("translate")}>
			Move (w)
		</button>
		<button class="modeButton" on:click={() => setMode("rotate")}>
			Rotate (r)
		</button>
	</div>
</Page>

<style lang="scss">
	.modeButton {
		@apply p-3 px-6 bg-blue-700 text-white rounded-md text-sm;
		min-width: 8rem;
	}
</style>
