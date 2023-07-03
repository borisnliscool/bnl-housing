<script lang="ts">
	import { createEventDispatcher } from "svelte";
	import type { PropType } from "../../utils/interfaces";

	const dispatch = createEventDispatcher();
	const click = () => dispatch("click");

	export let data: PropType;
</script>

<button
	on:click={click}
	class="prop"
	style="--url: url('https://gtahash.ru/files/{data.category}/{data.name}.jpg');"
/>

<style lang="scss">
	.prop {
		@apply relative w-full aspect-square rounded-lg border border-gray-300 shadow-md bg-center bg-cover hover:scale-[1.05] transition-all bg-white;
		background-image: var(--url);
	}
</style>
