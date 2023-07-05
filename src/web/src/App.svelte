<script lang="ts">
	import AdminMenu from "./components/admin/AdminMenu.svelte";
	import DecorationMenu from "./components/decoration/DecorationMenu.svelte";
	import PropPicker from "./components/decoration/PropPicker.svelte";
	import VisibilityProvider from "./providers/VisibilityProvider.svelte";
	import { debugData } from "./utils/debugData";
	import { isEnvBrowser } from "./utils/misc";

	debugData([
		{
			action: "setVisible",
			data: true,
		},
	]);
	debugData([
		{
			action: "setPage",
			data: "decoration",
		},
	]);

	window.addEventListener("click", (event) => {
		const target = event.target as HTMLElement;
		if (target.tagName == "BUTTON" || target.tagName == "A") {
			let clickAudio = new Audio("sounds/click.ogg");
			clickAudio.play();
		}
	});
</script>

{#if isEnvBrowser()}
	<div
		class="fixed top-0 left-0 h-full w-full bg-center bg-cover"
		style="background-image: url(https://zip.boris.foo/r/FiveM_b2802_GTAProcess-BYuZzuJT.jpg?compress=false);"
	/>
{/if}

<VisibilityProvider>
	<AdminMenu />
	<DecorationMenu />
	<PropPicker />
</VisibilityProvider>
