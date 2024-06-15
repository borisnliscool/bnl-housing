<script lang="ts">
	import { slide } from 'svelte/transition';
	import type { PropertyType, SelectOptionType } from '../../types';
	import { fetchNui } from '../../utils/fetchNui';
	import { soundOnClick } from '../../utils/sounds';
	import { useKeyPress } from '../../utils/useKeyPress';
	import Checkbox from '../elements/Checkbox.svelte';
	import GradientBackdrop from '../elements/GradientBackdrop.svelte';
	import Page from '../elements/Page.svelte';
	import Panel from '../elements/Panel.svelte';
	import Required from '../elements/RequiredStar.svelte';
	import Select from '../elements/Select.svelte';
	import { Input } from '../elements/input';

	const newProperty = {
		location: {
			x: 0,
			y: 0,
			z: 0,
			w: 0
		},
		model: '',
		propertyType: 'house',
		zipcode: '',
		streetName: '',
		buildingNumber: '',
		saleData: {
			isForSale: false,
			price: 0
		},
		rentData: {
			isForRent: false,
			price: 0
		}
	};

	let location: string = '';

	$: {
		const [x, y, z, w] = location.split(/,| /g).filter((r) => r);

		newProperty.location = {
			x: Number(x ?? 0),
			y: Number(y ?? 0),
			z: Number(z ?? 0),
			w: Number(w ?? 0)
		};
	}

	let propertyTypeSelect: SelectOptionType | undefined;
	$: newProperty.propertyType = propertyTypeSelect?.value as PropertyType;

	$: canCreate = !!(
		newProperty.model &&
		newProperty.propertyType &&
		newProperty.zipcode &&
		newProperty.streetName &&
		newProperty.buildingNumber
	);

	$: showLocation =
		newProperty.location?.x !== 0 ||
		newProperty.location?.y !== 0 ||
		newProperty.location?.z !== 0 ||
		newProperty.location?.w !== 0;

	useKeyPress('Escape', () => fetchNui('close'));

	const createProperty = async () => {
		await fetchNui('createProperty', newProperty);
	};
</script>

<Page id="adminMenu">
	<GradientBackdrop class="absolute left-4 top-4 max-h-[calc(100vh-2rem)] w-full max-w-md">
		<Panel>
			<div class="flex w-full flex-col gap-2">
				<h1 class="text-xl font-bold">Create new property</h1>

				<Input
					label="Property coordinates"
					placeholder="leave empty for current location"
					bind:value={location}
				/>

				{#if showLocation}
					<span class="grid grid-cols-4 px-1 text-xs text-neutral-500">
						<div>x: {newProperty.location?.x}</div>
						<div>y: {newProperty.location?.y}</div>
						<div>z: {newProperty.location?.z}</div>
						<div>w: {newProperty.location?.w}</div>
					</span>
				{/if}

				<Input
					label="Shell model"
					placeholder="shell_michael"
					required={true}
					bind:value={newProperty.model}
				/>

				<div class="flex flex-col gap-1">
					<p class="text-sm text-gray-500">
						Property type
						<Required />
					</p>

					<Select
						class="w-full"
						items={[
							{ name: 'House', value: 'house' },
							{ name: 'Garage', value: 'garage' },
							{ name: 'Warehouse', value: 'warehouse' },
							{ name: 'Office', value: 'office' }
						]}
						bind:value={propertyTypeSelect}
						placement="bottom"
						cols={1}
					/>
				</div>

				<Input label="Zipcode" placeholder="715" required={true} bind:value={newProperty.zipcode} />

				<Input
					label="Street Name"
					placeholder="Alta Street"
					required={true}
					bind:value={newProperty.streetName}
				/>

				<Input
					label="Building Number"
					placeholder="17"
					required={true}
					bind:value={newProperty.buildingNumber}
				/>

				<div class="mt-2 flex flex-col gap-2">
					<Checkbox class="w-6" bind:toggled={newProperty.saleData.isForSale}>
						<p>For Sale</p>
					</Checkbox>

					{#if newProperty.saleData.isForSale}
						<div transition:slide>
							<Input
								label="Sale price"
								placeholder="100.000"
								bind:value={newProperty.saleData.price}
							/>
						</div>
					{/if}
				</div>

				<button
					class="button mt-4"
					use:soundOnClick
					on:click={createProperty}
					disabled={!canCreate}
				>
					Create
				</button>
			</div>
		</Panel>
	</GradientBackdrop>
</Page>
