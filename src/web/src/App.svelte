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
	debugData([
		{
			action: "setPosition",
			data: {x: 15, y: 5, z: -10},
		},
	]);
</script>

<VisibilityProvider>
	<AdminMenu />
	<DecorationMenu />
</VisibilityProvider>
