import { writable } from "svelte/store";

export const visibility = writable(false);
export const pageStore = writable();

export const editorMode = writable("translate");
export const editorSpace = writable("world");
