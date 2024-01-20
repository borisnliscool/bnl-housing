<script lang="ts">
	import PlacedProps from "./PlacedProps.svelte";

	import { onMount } from "svelte";
	import { scale } from "svelte/transition";
	import currency from "../../store/currency";
	import { fetchNui } from "../../utils/fetchNui";
	import type { PropType, SelectOptionType } from "../../utils/interfaces";
	import { isEnvBrowser } from "../../utils/misc";
	import { useKeyPress } from "../../utils/useKeyPress";
	import Page from "../elements/Page.svelte";
	import Select from "../elements/Select.svelte";
	import Spinner from "../elements/Spinner.svelte";
	import Prop from "./Prop.svelte";

	let categories: Promise<SelectOptionType[]>;
	let props: Promise<PropType[]>;

	let category: SelectOptionType | undefined = undefined;
	let selectedProp: PropType | undefined;
	let isVisible: boolean;

	const fetchProps = (category: string) => {
		if (isEnvBrowser()) {
			return new Promise((r) => {
				r([{ category: "", id: "v_ret_gc_chair03", name: "Chair", price: 70 }]);
			});
		}

		return fetchNui("getProps", category);
	};

	const fetchCategories = () => {
		if (isEnvBrowser()) {
			return new Promise((r) => {
				r([{ name: "test", value: "test" }]);
			});
		}

		return fetchNui("getCategories");
	};

	const selectProp = async (model: string) => {
		if (!props) return;
		selectedProp = Object.values(await props)?.find((p) => p.id == model);
	};

	$: if (category) props = fetchProps(String(category.value));

	useKeyPress("Escape", () => isVisible && fetchNui("close"));

	onMount(() => {
		categories = fetchCategories();
	});
</script>

<Page id="propPicker" bind:isVisible>
	<div class="side-menu" transition:scale>
		{#if selectedProp}
			<p class="text-center py-4 text-xl font-extrabold tracking-wide">
				{selectedProp.name}
			</p>
			<div class="w-2/3 mx-auto">
				<Prop data={selectedProp} hoverEffects={false} />
			</div>

			<div class="flex flex-col gap-1 mt-8">
				<button
					on:click={() => fetchNui("selectProp", selectedProp?.id)}
					class="py-2 bg-blue-600 text-white rounded-md"
				>
					{#if selectedProp.price == 0}
						Place
					{:else}
						Place for {$currency}{selectedProp.price}
					{/if}
				</button>
				<button on:click={() => (selectedProp = undefined)} class="py-2 bg-gray-400 text-gray-100 rounded-md">
					Cancel
				</button>
			</div>
		{:else}
			<PlacedProps />
		{/if}
	</div>

	<div class="absolute bottom-0 left-0 px-6 py-4 w-full bg-gray-100/95 flex justify-between gap-4">
		<div class="w-[14rem] flex flex-col justify-between">
			<div>
				<p>Category</p>

				{#if categories}
					{#await categories then _categories}
						<Select
							items={_categories}
							bind:value={category}
							placement="bottom"
							cols={Math.ceil(_categories.length / 5)}
						/>
					{/await}
				{/if}
			</div>
			<button class="p-3 px-6 text-white rounded-md text-sm bg-gray-500" on:click={() => fetchNui("close")}>
				Close <kbd>(ESC)</kbd>
			</button>
		</div>

		<div class="w-full h-72 bg-gray-100/50 overflow-hidden shadow-sm rounded-tl-lg rounded-bl-lg">
			{#if props}
				{#await props}
					<div class="h-full grid place-items-center rounded-lg">
						<div class="flex items-center gap-5">
							<Spinner class="w-8" />
							<p>Loading...</p>
						</div>
					</div>
				{:then _props}
					<div class="props">
						{#each Object.values(_props) as prop, index}
							<Prop data={prop} on:click={() => selectProp(prop.id)} animationDelay={index * 10} />
						{/each}
					</div>
				{:catch}
					<div class="h-full grid place-items-center rounded-lg text-red-700">
						Something went wrong whilst trying to fetch props.
					</div>
				{/await}
			{/if}
		</div>
	</div>
</Page>

<style lang="scss">
	.props {
		@apply w-full h-full grid grid-cols-4 gap-1 p-3 overflow-y-auto md:grid-cols-6 lg:grid-cols-8 xl:grid-cols-10 2xl:grid-cols-12;
		transform-style: preserve-3d;
	}

	.side-menu {
		@apply absolute w-full max-w-md top-0 right-0 m-3 p-3 px-4 bg-gray-200/95 shadow-lg rounded-lg flex flex-col gap-1;
	}
</style>
