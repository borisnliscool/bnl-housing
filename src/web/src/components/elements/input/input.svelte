<script lang="ts">
	import type { HTMLInputAttributes } from 'svelte/elements';
	import type { InputEvents } from '.';
	import { cn } from '../../../utils/misc';
	import RequiredStar from '../RequiredStar.svelte';

	type $$Props = HTMLInputAttributes & {
		label: string;
		required?: boolean;
	};
	//eslint-disable-next-line @typescript-eslint/no-unused-vars
	type $$Events = InputEvents;

	let input: HTMLInputElement;
	let className: $$Props['class'] = undefined;

	export let label: string;
	export let required: boolean = false;
	export let value: $$Props['value'] = undefined;
	export { className as class };

	export const focus = () => input?.focus();
</script>

<label class={cn('flex flex-col gap-1 text-sm', className)}>
	<p class="text-gray-500">
		{label}

		{#if required}
			<RequiredStar />
		{/if}
	</p>

	<input
		class="rounded-md border border-gray-300 px-3.5 py-2 text-base outline-none transition-all focus-visible:border-blue-400 focus-visible:ring"
		bind:value
		bind:this={input}
		on:blur
		on:change
		on:click
		on:focus
		on:focusin
		on:focusout
		on:keydown
		on:keypress
		on:keyup
		on:mouseover
		on:mouseenter
		on:mouseleave
		on:paste
		on:input
		{...$$restProps}
	/>
</label>

<style lang="scss">
	input[type='search']::-webkit-search-cancel-button {
		@apply hidden;
	}
</style>
