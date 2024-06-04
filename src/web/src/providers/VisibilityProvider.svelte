<script lang="ts">
	import { visibility } from '../store/stores';
	import { debugData } from '../utils/debugData';
	import { useNuiEvent } from '../utils/useNuiEvent';

	useNuiEvent<boolean>('setVisible', (visible) => ($visibility = visible));

	debugData([
		{
			action: 'setVisible',
			data: true
		}
	]);
</script>

<main>
	{#if $visibility}
		<slot />
	{/if}
</main>
