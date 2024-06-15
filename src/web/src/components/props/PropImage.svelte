<script lang="ts">
	import type { PropType } from '../../types';
	import { cn } from '../../utils/misc';

	let className = '';
	export { className as class };

	export let prop: PropType;
</script>

<img
	class={cn('size-full object-contain', className)}
	loading="lazy"
	alt={prop.id}
	src="images/props/{prop.id}.webp"
/>
