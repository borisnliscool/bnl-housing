<script lang="ts">
	import { onMount } from "svelte";
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
	import currency from "../../store/currency";

    let categories = [];
    let props = [];
    let category = null;
    let isVisible = false;
    let selectedProp = null;
	
	// Fetch categories from the server
    async function fetchCategories() {
        const cats = await fetchNui("getCategories");
        if (cats) {
            categories = JSON.parse(cats);

            // Set the first category as the selected category
            if (categories.length > 0) {
                category = categories[0];
            }
        }
    }

	// Fetch props for the selected category
    $: if (categories.length > 0 && category) {
        fetchProps(category.value).then(fetchedProps => {
            props = fetchedProps || [];
        });
    }

    onMount(async () => {
        await fetchCategories();
        // After categories are loaded, fetch props for the first category

        if (category) {
            fetchProps(category.value).then(fetchedProps => {
                props = fetchedProps || [];
            });
        }
    });

	// Fetch props for the selected category
    async function fetchProps(category) {
        if (!category) return []; // Return an empty array if category is not defined

        if (isEnvBrowser()) {
            return [{ category: "", id: "v_ret_gc_chair03", name: "Chair", price: 70 }];
        }

        return await fetchNui("getProps", category) || [];
    }

    async function selectProp(model) {
        selectedProp = props.find((p) => p.id == model) || null;
    }

    useKeyPress("Escape", () => isVisible && fetchNui("close"));

	$: cols = categories.length > 0 ? Math.ceil(categories.length / 2) : 1;
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
				<button
					on:click={() => (selectedProp = null)}
					class="py-2 bg-gray-400 text-gray-100 rounded-md"
				>
					Cancel
				</button>
			</div>
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
					cols={cols}
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