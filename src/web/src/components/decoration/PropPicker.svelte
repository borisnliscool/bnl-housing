<script lang="ts">
	import PlacedProps from "./PlacedProps.svelte";

	import { useKeyPress } from "../../utils/useKeyPress";
	import { fetchNui } from "../../utils/fetchNui";
	import type { PropType } from "../../utils/interfaces";
	import Page from "../elements/Page.svelte";
	import Select from "../elements/Select.svelte";
	import Prop from "./Prop.svelte";
	import { isEnvBrowser } from "../../utils/misc";
	import Spinner from "../elements/Spinner.svelte";
	import { scale } from "svelte/transition";

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
			value: "walls",
		},
	];

	let props: Promise<PropType[]>;
	let category: any;
	let isVisible: boolean;
	let selectedProp: PropType | null;

	const fetchProps = async (category: string) => {
		if (isEnvBrowser()) {
			return new Promise((r) => {
				r([{ category: "", id: "v_ret_gc_chair03", name: "Chair", price: 70 }]);
			});
		}

		if (!category) return;
		return fetchNui("getProps", category);
	};

	$: props = fetchProps(category?.value);

	const selectProp = async (model: string) => {
		selectedProp = Object.values(await props).find((p) => p.id == model)!;
	};

	useKeyPress("Escape", () => isVisible && fetchNui("close"));
</script>

<Page id="propPicker" bind:isVisible>
	<div class="side-menu" transition:scale>
		{#if selectedProp}
			<button on:click={() => (selectedProp = null)}> Close </button>
			selectedProp:

			<div class="w-1/2 mx-auto">
				<Prop data={selectedProp} hoverEffects={false} />
			</div>

			<pre>{JSON.stringify(selectedProp, null, 4)}</pre>

			<button on:click={() => fetchNui("selectProp", selectedProp?.id)}>
				Buy
			</button>
		{:else}
			<PlacedProps />
		{/if}
	</div>

	<div
		class="absolute bottom-0 left-0 px-6 py-4 w-full bg-gray-100/95 flex justify-between gap-4"
	>
		<div class="w-[14rem] flex flex-col justify-between">
			<div>
				<p>Category</p>
				<Select
					items={categories}
					bind:value={category}
					placement="bottom"
					cols={Math.floor(categories.length / 5)}
				/>
			</div>
			<button
				class="p-3 px-6 text-white rounded-md text-sm bg-gray-500"
				on:click={() => fetchNui("close")}
			>
				Close <kbd>(ESC)</kbd>
			</button>
		</div>

		<div
			class="w-full h-72 bg-gray-100/50 overflow-hidden shadow-sm rounded-tl-lg rounded-bl-lg"
		>
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
						<Prop
							data={prop}
							on:click={() => selectProp(prop.id)}
							animationDelay={index * 10}
						/>
					{/each}
				</div>
			{:catch}
				<div class="h-full grid place-items-center rounded-lg text-red-700">
					Something went wrong whilst trying to fetch props.
				</div>
			{/await}
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
