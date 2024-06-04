<script lang="ts">
	import { slide } from 'svelte/transition';
	import { cn } from '../../utils/misc';

	let className = '';
	export { className as class };
</script>

<div
	class={cn('rounded-xl bg-gradient-to-b from-sky-400 to-blue-600 p-1 shadow-xl', className)}
	transition:slide
>
	<div
		class="w-full rounded-lg border border-gray-50 bg-gradient-to-b from-gray-100 to-gray-200 p-4 pt-3 shadow-sm"
	>
		<slot />
	</div>
</div>
