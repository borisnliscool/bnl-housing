<script lang="ts">
	import AdminMenu from "./components/admin/AdminMenu.svelte";
	import DecorationMenu from "./components/decoration/DecorationMenu.svelte";
	import VisibilityProvider from "./providers/VisibilityProvider.svelte";
	import { debugData } from "./utils/debugData";

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
</script>

<VisibilityProvider>
	<AdminMenu />
	<DecorationMenu />
</VisibilityProvider>

<style global>
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
</style>
