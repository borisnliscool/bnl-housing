<script lang="ts">
	import { cn } from '../../utils/misc';

	let className = '';
	export { className as class };
</script>

<div
	class={cn(
		'overflow-y-auto rounded-xl bg-gradient-to-bl from-sky-400 to-purple-600 p-1 shadow-xl',
		className
	)}
>
	<div
		class="size-full overflow-hidden rounded-lg border border-gray-50 bg-gradient-to-b from-gray-100 to-gray-200 shadow-sm"
	>
		<div
			class="relative p-4 pt-3 before:pointer-events-none before:absolute before:inset-0 before:top-0 before:bg-[url(/images/noise.webp)] before:opacity-15"
		>
			<slot />
		</div>
	</div>
</div>
