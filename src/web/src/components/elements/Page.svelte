<script lang="ts">
	import { fade } from 'svelte/transition';
	import { pageStore } from '../../store/stores';
	import { debugData } from '../../utils/debugData';
	import { useNuiEvent } from '../../utils/useNuiEvent';

	export let id: string;
	export let isVisible: boolean = false;
	export let transition = fade;

	$: isVisible = $pageStore == id;

	useNuiEvent<string>('setPage', (page) => {
		$pageStore = page;
	});

	debugData([
		{
			action: 'setPage',
			data: 'adminMenu'
		}
	]);
</script>

{#if isVisible}
	<section class="fixed left-0 top-0 h-screen w-full" transition:transition>
		<div class="relative h-full">
			<slot />
		</div>
	</section>
{/if}
