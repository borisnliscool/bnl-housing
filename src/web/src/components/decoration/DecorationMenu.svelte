<script lang="ts">
	import { editorMode } from "../../store/stores";
	import Page from "../Page.svelte";
	import Editor from "./Editor.svelte";
</script>

<Page id="decoration">
	<Editor />

	<div
		class="absolute bottom-0 left-0 w-full h-24 bg-gray-200/75 flex items-center justify-center gap-4"
	>
		<button class="modeButton" on:click={() => editorMode.set("translate")}>
			Move
		</button>
		<button class="modeButton" on:click={() => editorMode.set("rotate")}>
			Rotate
		</button>
	</div>
</Page>

<style lang="scss">
	.modeButton {
		@apply p-3 px-6 bg-blue-700 text-white rounded-md text-sm;
		min-width: 8rem;
	}
</style>
