/**
 * Exports a minimal API from javascript
 * to manipulate the HTML document.
 */
export function prepareBridge () {

    /// This is just a constant we use to flag that a parent should go to document body.
    const DOCUMENT_BODY = "DOCUMENT_BODY"

    /// This table must be provided to luau
    return {
        DOCUMENT_BODY,

        /// expose console for logging from print
        console: console,

        createElement: (tag: string) => document.createElement(tag),
        
        // TODO: LATER: Security Eval - injection risks? how does e.g. Vue sanitize props.
        setProperty: (el: HTMLElement, key: string, value: any) => {
            if (!el) {
                console.warn(`Tried to set key "${key}" on invalid element`)
            };
            key = key.toLowerCase()
            if (key == 'data') key = 'dataset'
            if (key == 'style') key = 'cssText'
            if (key == 'class') key = 'className'
            if (key == 'text') key = 'textContent'
            // @ts-ignore
            el[key] = value
        },

        observeProperty: (el: HTMLElement, key: string, callback: () => any) => {
            const observer = new MutationObserver(callback)
            observer.observe(el, {
                attributeFilter: [key],
            })
            return function cleanup () {
                observer.disconnect()
            }
        },
        
        setParent: (el: HTMLElement, parent?: HTMLElement|"DOCUMENT_BODY") => {
            if (parent) {
                if (parent == DOCUMENT_BODY) {
                    document.body.appendChild(el);
                } else {
                    parent.appendChild(el);
                }
            } else {
                if (el.parentNode) {
                    el.parentNode.removeChild(el);
                }
            }
        },

        // expose timing specific functions -----
        performance,
        setTimeout: (cb: any, ms: number) => window.setTimeout(cb, ms),
        queueMicrotask: (cb: any) => window.queueMicrotask(cb),
        requestAnimationFrame: (cb: any) => window.requestAnimationFrame(cb),
    }
}

export default bridge
