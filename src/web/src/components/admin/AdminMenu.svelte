<script lang="ts">
	import { scale } from "svelte/transition";
	import { fetchNui } from "../../utils/fetchNui";
	import type { SelectOptionType } from "../../utils/interfaces";
	import { useKeyPress } from "../../utils/useKeyPress";
	import Page from "../elements/Page.svelte";
	import Select from "../elements/Select.svelte";

	type PropertyType = "house" | "garage" | "warehouse" | "office";

	const newProperty: {
		location: string;
		model: string;
		propertyType: PropertyType;
		zipcode: string;
		streetName: string;
		buildingNumber: string;
	} = {
		location: "",
		model: "",
		propertyType: "house",
		zipcode: "",
		streetName: "",
		buildingNumber: "",
	};

	let propertyTypeSelect: SelectOptionType | undefined;
	$: newProperty.propertyType = propertyTypeSelect?.value as PropertyType;

	useKeyPress("Escape", () => fetchNui("close"));
</script>

<Page id="adminMenu">
	<div
		class="absolute w-full max-w-md top-0 left-0 m-3 p-3 px-4 bg-gray-200/95 shadow-lg rounded-lg flex flex-col gap-2"
		transition:scale
	>
		<h1 class="text-lg font-bold">Create new property</h1>

		<div class="flex flex-col gap-1">
			<label for="location" class="text-sm">Property coordinates</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="text"
				id="location"
				placeholder="leave empty for current location"
				bind:value={newProperty.location}
			/>
		</div>

		<div class="flex flex-col gap-1">
			<label for="model" class="text-sm">Shell model</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="text"
				id="model"
				placeholder="shell_michael"
				bind:value={newProperty.model}
			/>
		</div>

		<div class="flex flex-col gap-1">
			<label for="" class="text-sm">Property type</label>
			<Select
				class="w-full"
				items={[
					{ name: "House", value: "house" },
					{ name: "Garage", value: "garage" },
					{ name: "Warehouse", value: "warehouse" },
					{ name: "Office", value: "office" },
				]}
				bind:value={propertyTypeSelect}
				placement="bottom"
				cols={1}
			/>
		</div>

		<div class="flex flex-col gap-1">
			<label for="zipcode" class="text-sm">Zipcode</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="text"
				id="zipcode"
				placeholder="715"
				bind:value={newProperty.zipcode}
			/>
		</div>

		<div class="flex flex-col gap-1">
			<label for="streetName" class="text-sm">Street Name</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="text"
				id="streetName"
				placeholder="Alta Street"
				bind:value={newProperty.streetName}
			/>
		</div>

		<div class="flex flex-col gap-1">
			<label for="buildingNumber" class="text-sm">Building Number</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="number"
				id="buildingNumber"
				placeholder="17"
				bind:value={newProperty.buildingNumber}
			/>
		</div>

		<button
			class="py-2 bg-blue-600 text-white rounded-md mt-2 outline-none focus:ring"
		>
			Create
		</button>
	</div>
</Page>
