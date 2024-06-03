<script lang="ts">
	import { slide } from "svelte/transition";
	import type { SelectOptionType } from "../../types";
	import { fetchNui } from "../../utils/fetchNui";
	import { soundOnClick } from "../../utils/sounds";
	import { useKeyPress } from "../../utils/useKeyPress";
	import IconCheckbox from "../elements/IconCheckbox.svelte";
	import Page from "../elements/Page.svelte";
	import Panel from "../elements/Panel.svelte";
	import Select from "../elements/Select.svelte";

	type PropertyType = "house" | "garage" | "warehouse" | "office";

	const newProperty = {
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
	<Panel
		class="absolute left-0 top-0 m-3 max-h-[95%] w-full max-w-md overflow-y-auto"
	>
		<div class="flex flex-col gap-2 w-full">
			<h1 class="text-xl font-bold">Create new property</h1>

			<label class="text-input-group">
				<p>Property coordinates</p>

				<input
					type="text"
					placeholder="leave empty for current location"
					bind:value={location}
				/>

				<span class="text-xs text-neutral-500 grid grid-cols-4 px-1">
					<div>x: {newProperty.location?.x}</div>
					<div>y: {newProperty.location?.y}</div>
					<div>z: {newProperty.location?.z}</div>
					<div>w: {newProperty.location?.w}</div>
				</span>
			</label>

			<label class="text-input-group">
				<p>
					Shell model
					<span class="text-red-500">*</span>
				</p>

				<input
					type="text"
					placeholder="shell_michael"
					bind:value={newProperty.model}
				/>
			</label>

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

			<label class="text-input-group">
				<p>
					Zipcode
					<span class="text-red-500">*</span>
				</p>

				<input type="text" placeholder="715" bind:value={newProperty.zipcode} />
			</label>

			<label class="text-input-group">
				<p>
					Street Name
					<span class="text-red-500">*</span>
				</p>

				<input
					type="text"
					placeholder="Alta Street"
					bind:value={newProperty.streetName}
				/>
			</label>

			<label class="text-input-group">
				<p>
					Building Number
					<span class="text-red-500">*</span>
				</p>

				<input
					type="text"
					placeholder="17"
					bind:value={newProperty.buildingNumber}
				/>
			</label>

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
					<label class="text-input-group" transition:slide>
						<p>
							Sale price
							<span class="text-red-500">*</span>
						</p>

						<input
							type="text"
							placeholder="100.000"
							bind:value={newProperty.saleData.price}
						/>
					</label>
				{/if}
			</div>

			<button
				class="button mt-4"
				use:soundOnClick
				on:click={() => fetchNui("createProperty", newProperty)}
			>
				Create
			</button>
		</div>
	</Panel>
</Page>
