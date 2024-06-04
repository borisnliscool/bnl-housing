<script lang="ts">
	import { slide } from "svelte/transition";
	import { cn } from "../../utils/misc";

	let className = "";
	export { className as class };
</script>

<div
	class={cn(
		"p-1 bg-gradient-to-b to-blue-600 from-sky-400 rounded-xl shadow-xl",
		className
	)}
	transition:slide
>
	<div
		class="bg-gradient-to-b from-gray-100 to-gray-200 border border-gray-50 shadow-sm pt-3 p-4 rounded-lg w-full"
	>
		<slot />
	</div>
</div>
