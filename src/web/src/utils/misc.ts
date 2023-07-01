export const isEnvBrowser = (): boolean => !(window as any).invokeNative;
export type modeType = "translate" | "rotate";