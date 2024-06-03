<script lang="ts">
	import { cn } from "../../utils/misc";

	let className: string | undefined;
	export { className as class };
</script>

<div
	class={cn(
		"p-1 bg-gradient-to-b from-blue-600 to-sky-400 rounded-xl shadow-xl",
		className
	)}
>
	<div
		class="bg-gradient-to-b from-gray-100 to-gray-200 shadow-sm pt-3 p-4 rounded-lg w-full"
	>
		<slot />
	</div>
</div>
