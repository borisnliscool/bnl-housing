import { writable } from 'svelte/store';
import { fetchNui } from '../utils/fetchNui';

const currencyStore = writable<'€' | '$'>('€');

fetchNui('getLocaleItem', 'currency').then((r) => currencyStore.set(r));

export default currencyStore;
