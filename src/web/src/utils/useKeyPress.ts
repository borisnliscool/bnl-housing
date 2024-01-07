import { onMount, onDestroy } from "svelte";

export function useKeyPress(key: string, handler: (data: KeyboardEvent) => void) {
	const eventListener = (event: KeyboardEvent) => {
		event.key === key && handler(event);
	};
	onMount(() => window.addEventListener("keydown", eventListener));
	onDestroy(() => window.removeEventListener("keydown", eventListener));
}
