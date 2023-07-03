<script lang="ts">
	import { fetchNui } from "../../utils/fetchNui";
	import type { PropType } from "../../utils/interfaces";
	import Page from "../Page.svelte";
	import Select from "../elements/Select.svelte";
	import Prop from "./Prop.svelte";

	const categories = [
		{
			name: "Bar",
			value: "bar",
		},
		{
			name: "Bathroom",
			value: "bathroom",
		},
		{
			name: "Bins",
			value: "bins",
		},
		{
			name: "Construction",
			value: "construction",
		},
		{
			name: "Electrical",
			value: "electrical",
		},
		{
			name: "Equipment",
			value: "equipment",
		},
		{
			name: "Garage",
			value: "garage",
		},
		{
			name: "Industrial",
			value: "industrial",
		},
		{
			name: "Interior",
			value: "interior",
		},
		{
			name: "Kitchen",
			value: "kitchen",
		},
		{
			name: "Minigame",
			value: "minigame",
		},
		{
			name: "Office",
			value: "office",
		},
		{
			name: "Outdoor",
			value: "outdoor",
		},
		{
			name: "Potted",
			value: "potted",
		},
		{
			name: "Recreational",
			value: "recreational",
		},
		{
			name: "Rubbish",
			value: "rubbish",
		},
		{
			name: "Seating",
			value: "seating",
		},
		{
			name: "Storage",
			value: "storage",
		},
		{
			name: "Utility",
			value: "utility",
		},
		{
			name: "Walls and fences",
			value: "wallsAndFences",
		},
	];

	let props: PropType[] = [];
	let category: any;

	const fetchProps = async (category: string) => {
		if (!category) return;
		props = await fetchNui("getProps", category);
	};

	$: fetchProps(category?.value);

    const selectProp = async (model: string) => {
        await fetchNui("selectProp", model);
    }
</script>

<Page id="propPicker">
	<div
		class="absolute bottom-0 left-0 px-6 py-4 w-full bg-gray-200/90 flex justify-between gap-4"
	>
		<div class="w-[14rem]">
			<p>Category</p>
			<Select items={categories} bind:value={category} />
		</div>

		<div class="props">
			{#each props as prop}
				<Prop data={prop} on:click={() => selectProp(prop.name)} />
			{/each}
		</div>
	</div>
</Page>

<style lang="scss">
	.props {
		@apply w-full max-h-72 grid grid-cols-4 gap-1 p-2 overflow-y-auto md:grid-cols-6 lg:grid-cols-8 xl:grid-cols-10 2xl:grid-cols-12;
	}
</style>
