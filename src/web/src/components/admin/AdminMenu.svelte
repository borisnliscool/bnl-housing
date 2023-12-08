<script lang="ts">
	import { scale } from "svelte/transition";
	import { fetchNui } from "../../utils/fetchNui";
	import type { SelectOptionType } from "../../utils/interfaces";
	import { useKeyPress } from "../../utils/useKeyPress";
	import IconCheckbox from "../elements/IconCheckbox.svelte";
	import Page from "../elements/Page.svelte";
	import Select from "../elements/Select.svelte";

	type PropertyType = "house" | "garage" | "warehouse" | "office";

	const newProperty: {
		location: {
			x: number;
			y: number;
			z: number;
			w: number;
		};
		model: string;
		propertyType: PropertyType;
		zipcode: string;
		streetName: string;
		buildingNumber: string;
		saleData: {
			isForSale: boolean;
			price: number;
		};
		rentData: {
			isForRent: boolean;
			price: number;
		};
	} = {
		location: {
			x: 0,
			y: 0,
			z: 0,
			w: 0,
		},
		model: "",
		propertyType: "house",
		zipcode: "",
		streetName: "",
		buildingNumber: "",
		saleData: {
			isForSale: false,
			price: 0,
		},
		rentData: {
			isForRent: false,
			price: 0,
		},
	};

	let location: string = "";
	$: {
		const [x, y, z, w] = location.split(/,| /g).filter((r) => r);

		newProperty.location = {
			x: Number(x ?? 0),
			y: Number(y ?? 0),
			z: Number(z ?? 0),
			w: Number(w ?? 0),
		};
	}

	let propertyTypeSelect: SelectOptionType | undefined;
	$: newProperty.propertyType = propertyTypeSelect?.value as PropertyType;

	useKeyPress("Escape", () => fetchNui("close"));
</script>

<Page id="adminMenu">
	<div
		class="absolute w-full max-h-[95%] overflow-y-auto max-w-md top-0 left-0 m-3 p-3 px-4 bg-gray-200/95 shadow-lg rounded-lg flex flex-col gap-2"
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
				bind:value={location}
			/>

			<span class="text-xs text-neutral-500">
				x: {newProperty.location?.x}, y: {newProperty.location?.y}, z: {newProperty
					.location?.z}, w: {newProperty.location?.w},
			</span>
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
			<label for="" class="text-sm">
				Property type
				<span class="text-red-500">*</span>
			</label>
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
			<label for="zipcode" class="text-sm">
				Zipcode
				<span class="text-red-500">*</span>
			</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="text"
				id="zipcode"
				placeholder="715"
				bind:value={newProperty.zipcode}
			/>
		</div>

		<div class="flex flex-col gap-1">
			<label for="streetName" class="text-sm">
				Street Name
				<span class="text-red-500">*</span>
			</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="text"
				id="streetName"
				placeholder="Alta Street"
				bind:value={newProperty.streetName}
			/>
		</div>

		<div class="flex flex-col gap-1">
			<label for="buildingNumber" class="text-sm">
				Building Number
				<span class="text-red-500">*</span>
			</label>
			<input
				class="px-4 py-2 rounded outline-none focus:ring"
				type="text"
				id="buildingNumber"
				placeholder="17"
				bind:value={newProperty.buildingNumber}
			/>
		</div>

		<div class="mt-2 flex flex-col gap-2">
			<div class="flex items-center gap-2">
				<div class="w-6">
					<IconCheckbox
						class="!text-sm"
						bind:toggled={newProperty.saleData.isForSale}
					/>
				</div>

				<p>For sale</p>
			</div>

			{#if newProperty.saleData.isForSale}
				<div class="flex flex-col gap-1">
					<label for="saleprice" class="text-sm">
						Sale price
						<span class="text-red-500">*</span>
					</label>
					<input
						class="px-4 py-2 rounded outline-none focus:ring"
						type="text"
						id="saleprice"
						placeholder="100.000"
						bind:value={newProperty.saleData.price}
					/>
				</div>
			{/if}
		</div>

		<div class="mt-2 flex flex-col gap-2">
			<div class="flex items-center gap-2">
				<div class="w-6">
					<IconCheckbox
						class="!text-sm"
						bind:toggled={newProperty.rentData.isForRent}
					/>
				</div>

				<p>For rent</p>
			</div>

			{#if newProperty.rentData.isForRent}
				<div class="flex flex-col gap-1">
					<label for="rentprice" class="text-sm">
						Rent price
						<span class="text-red-500">*</span>
					</label>
					<input
						class="px-4 py-2 rounded outline-none focus:ring"
						type="text"
						id="rentprice"
						placeholder="100.000"
						bind:value={newProperty.rentData.price}
					/>
				</div>
			{/if}
		</div>

		<button
			class="py-2 bg-blue-600 text-white rounded-md mt-2 outline-none focus:ring"
			on:click={() => fetchNui("createProperty", newProperty)}
		>
			Create
		</button>
	</div>
</Page>
