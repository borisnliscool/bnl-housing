<script lang="ts">
	import { cn } from '../../utils/misc';

	let className = '';
	export { className as class };
</script>

<div
	class={cn(
		'size-full animate-pulse rounded-md bg-gradient-to-br from-neutral-400 to-neutral-600',
		className
	)}
></div>
