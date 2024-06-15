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
	<slot />
</div>
