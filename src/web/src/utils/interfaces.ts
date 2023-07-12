export interface SelectOptionType {
	name: string | number;
	value: string | number;
}

export interface PropType {
	name: string;
	category: string;
}

export type placement = "top" | "bottom" | "left" | "right";

export interface PlacedProp {
	id: number;
	model: string;
	location: string;
	rotation: string;
	metadata: string;
}
