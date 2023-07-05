export function soundOnEnter(node: HTMLElement) {
	const handleEvent = (event: MouseEvent) => {
		const audio = new Audio(
			(event!.target as HTMLElement).dataset.sound ?? "sounds/hover.ogg"
		);
		audio.play();
	};

	node.addEventListener("mouseenter", handleEvent, true);

	return {
		destroy() {
			node.removeEventListener("mouseenter", handleEvent, true);
		},
	};
}

export function soundOnClick(node: HTMLElement) {
	const handleEvent = (event: MouseEvent) => {
		const audio = new Audio(
			(event!.target as HTMLElement).dataset.sound ?? "sounds/click.ogg"
		);
		audio.play();
	};

	node.addEventListener("click", handleEvent, true);

	return {
		destroy() {
			node.removeEventListener("click", handleEvent, true);
		},
	};
}
