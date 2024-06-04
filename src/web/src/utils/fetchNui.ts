/**
 * @param eventName - The endpoint eventname to target
 * @param data - Data you wish to send in the NUI Callback
 *
 * @return returnData - A promise for the data sent back by the NuiCallbacks CB argument
 */

import { isEnvBrowser } from './misc';

type OptionalWindow = Window &
	typeof globalThis & {
		GetParentResourceName: () => string | undefined;
	};

export async function fetchNui<T = unknown>(eventName: string, data: unknown = {}): Promise<T> {
	if (isEnvBrowser()) throw new Error("couldn't fetch nui from browser");

	const options = {
		method: 'post',
		headers: {
			'Content-Type': 'application/json; charset=UTF-8'
		},
		body: JSON.stringify(data)
	};

	const resourceName = (window as OptionalWindow).GetParentResourceName
		? (window as OptionalWindow).GetParentResourceName()
		: 'nui-frame-app';

	const resp = await fetch(`https://${resourceName}/${eventName}`, options);
	return await resp.json();
}
