<script lang="ts">
	import { onMount } from 'svelte';
	import { slide } from 'svelte/transition';
	import type { PropType, SelectOptionType } from '../../types';
	import { fetchNui } from '../../utils/fetchNui';
	import { cn, isEnvBrowser } from '../../utils/misc';
	import { soundOnClick, soundOnEnter } from '../../utils/sounds';
	import GradientBackdrop from '../elements/GradientBackdrop.svelte';
	import Page from '../elements/Page.svelte';
	import Panel from '../elements/Panel.svelte';
	import Skeleton from '../elements/Skeleton.svelte';
	import DisplayProp from './DisplayProp.svelte';
	import SelectedProp from './SelectedProp.svelte';

	let categories: Promise<SelectOptionType[]>;
	let props: Promise<Record<string, PropType>>;

	let category: SelectOptionType | undefined = undefined;
	let propsParent: HTMLDivElement;

	let selectedProp: PropType | undefined = undefined;

	const clickProp = async () => {
		await fetchNui('selectProp', selectedProp.id);
		selectedProp = undefined;
	};

	const fetchProps = (category: string): Promise<Record<string, PropType>> => {
		const props: Promise<Record<string, PropType>> = isEnvBrowser()
			? new Promise((r) =>
					r({
						v_ret_gc_chair03: {
							category: 'test',
							id: 'v_ret_gc_chair03',
							name: 'Chair',
							price: 70
						}
					})
				)
			: fetchNui('getProps', category);

		props.then((_) =>
			propsParent?.scrollIntoView({
				behavior: 'smooth',
				block: 'start'
			})
		);

		return props;
	};

	const fetchCategories = (): Promise<SelectOptionType[]> => {
		const categories: Promise<SelectOptionType[]> = isEnvBrowser()
			? new Promise((r) =>
					r([
						{ name: 'test', value: 'test' },
						{ name: 'test2', value: 'test2' }
					])
				)
			: fetchNui('getCategories');

		categories.then((r) => (category = r.at(0)));

		return categories;
	};

	$: if (category) props = fetchProps(String(category.value));

	onMount(() => {
		categories = fetchCategories();
	});
</script>

<Page id="propPicker">
	{#if selectedProp}
		<div class="fixed right-4 top-4 w-full max-w-md" transition:slide>
			<SelectedProp {selectedProp} on:click={clickProp} />
		</div>
	{/if}

	<GradientBackdrop
		class="fixed bottom-0 left-0 right-0 grid h-1/3 min-h-72 grid-cols-3 gap-1 rounded-b-none lg:grid-cols-5"
	>
		<Panel class="overflow-y-auto p-3">
			<div class="grid gap-1 lg:grid-cols-2">
				{#await categories}
					{#each Array(12) as _}
						<Skeleton class="h-full rounded" />
					{/each}
				{:then value}
					{#if value}
						{#each value as item}
							<button
								class={cn(
									'size-full h-10 rounded-md',
									category?.value == item.value
										? 'bg-gradient-to-tr from-blue-600 to-blue-400 text-white'
										: ''
								)}
								on:click={() => (category = item)}
								use:soundOnClick
								use:soundOnEnter
							>
								{item.name}
							</button>
						{/each}
					{:else}
						{#each Array(12) as _}
							<Skeleton class="h-full rounded" />
						{/each}
					{/if}
				{:catch error}
					<p class="col-span-full text-red-500">{error}</p>
				{/await}
			</div>
		</Panel>

		<Panel class="col-span-2 h-full overflow-hidden overflow-y-auto p-0 lg:col-span-4">
			<div
				class="grid grid-cols-2 gap-2 p-3 md:grid-cols-4 lg:grid-cols-7 2xl:grid-cols-8"
				bind:this={propsParent}
			>
				{#await props}
					{#each Array(16) as _}
						<Skeleton class="aspect-square rounded" />
					{/each}
				{:then value}
					{#if value}
						{#each Object.values(value) as prop}
							<DisplayProp
								on:click={() => {
									selectedProp = selectedProp?.id === prop.id ? undefined : prop;
								}}
								{prop}
							/>
						{/each}
					{:else}
						{#each Array(12) as _}
							<Skeleton class="h-full rounded" />
						{/each}
					{/if}
				{:catch error}
					<p class="col-span-full text-red-500">{error}</p>
				{/await}
			</div>
		</Panel>
	</GradientBackdrop>
</Page>
