import { writable } from 'svelte/store';
import { fetchNui } from '../utils/fetchNui';

const currencyStore = writable<string>('€');

fetchNui('getLocaleItem', 'currency').then(
	(r: unknown) => typeof r == 'string' && currencyStore.set(r)
);

export default currencyStore;
