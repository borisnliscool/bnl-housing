import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export const cn = (...inputs: ClassValue[]) => twMerge(clsx(inputs));
export const isEnvBrowser = (): boolean =>
	!(window as Window & typeof globalThis & { invokeNative: unknown }).invokeNative;
