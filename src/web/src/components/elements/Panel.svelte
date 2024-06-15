<script lang="ts">
	import { cn } from '../../utils/misc';

	let className = '';
	export { className as class };
</script>

<div
	class={cn(
		'relative size-full overflow-hidden rounded-lg border border-gray-50 bg-gradient-to-b from-gray-100 to-gray-200 p-4 pt-3 shadow-sm before:pointer-events-none before:absolute before:inset-0 before:top-0 before:bg-[url(/images/noise.webp)] before:opacity-15',
		className
	)}
>
	<slot />
</div>
