const buildEventHandler = (name: string) => (event: MouseEvent) => {
	const audio = new Audio((event!.target as HTMLElement).dataset.sound ?? `sounds/${name}.ogg`);
	audio.play();
};

export function soundOnEnter(node: HTMLElement) {
	const handleEvent = buildEventHandler("hover");
	node.addEventListener("mouseenter", handleEvent, true);

	return {
		destroy() {
			node.removeEventListener("mouseenter", handleEvent, true);
		},
	};
}

export function soundOnClick(node: HTMLElement) {
	const handleEvent = buildEventHandler("click");
	node.addEventListener("click", handleEvent, true);

	return {
		destroy() {
			node.removeEventListener("click", handleEvent, true);
		},
	};
}
