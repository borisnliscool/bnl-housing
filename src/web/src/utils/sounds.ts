const buildEventHandler = (name: string) => (event: Event) => {
	const audio = new Audio((event!.target as HTMLElement).dataset.sound ?? `sounds/${name}.ogg`);
	audio.play();
};

const soundOnEvent = (event: keyof HTMLElementEventMap, name: string) => {
	return (node: HTMLElement) => {
		const handleEvent = buildEventHandler(name);
		node.addEventListener(event, handleEvent, true);

		return {
			destroy() {
				node.removeEventListener(event, handleEvent, true);
			}
		};
	};
};

export const soundOnEnter = soundOnEvent('mouseenter', 'hover');
export const soundOnClick = soundOnEvent('click', 'click');
export const soundOnFocus = soundOnEvent('focus', 'click');
