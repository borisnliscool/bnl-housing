export type SelectValueType = string | number;

export interface SelectOptionType {
	name: string | number;
	value: SelectValueType;
}

export interface PropType {
	id: string;
	name: string;
	category: string;
	price: number;
}

export type Placement = 'top' | 'bottom' | 'left' | 'right';

export interface PlacedProp {
	id: number;
	name: string;
	model: string;
	location: string;
	rotation: string;
	metadata: string;
}

export type modeType = 'translate' | 'rotate';
export type spaceType = 'world' | 'local';

export type PropertyType = 'house' | 'garage' | 'warehouse' | 'office';
