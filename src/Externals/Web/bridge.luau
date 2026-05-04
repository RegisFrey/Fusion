export type HTMLElement = any

export type WebBridge = {
	DOCUMENT_BODY: "DOCUMENT_BODY",
	console: {
		log: (string) -> nil,
		warn: (string) -> nil,
		error: (string) -> nil,
	},
	createElement: (tag: string) -> HTMLElement,
	setProperty: (el: HTMLElement, key: string, value: any) -> nil,
	--- Observes a property and returns a cleanup function
	observeProperty: (el: HTMLElement, key: string, onUpdate: () -> nil) -> () -> nil,
	setParent: (el: HTMLElement, parent: (HTMLElement | "DOCUMENT_BODY")?) -> nil,

	performance: any,
	setTimeout: (cb: () -> any, ms: number) -> number,
	queueMicrotask: (cb: () -> any) -> any,
	requestAnimationFrame: (cb: () -> any) -> any,
}

local bridge = if __WEB_BRIDGE ~= nil
	then __WEB_BRIDGE
	else setmetatable({}, {
		__index = function(self, key)
			warn(
				"No web bridge is attached. Your luau bundler must inject a bridge as the __WEB_BRIDGE global variable."
			)
		end,
	})

return bridge :: WebBridge
