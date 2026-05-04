The "Web" target for Fusion allows authoring reactive HTML documents with Fusion.

The current most viable way to run it is via `luau-web`.
https://github.com/xNasuni/luau-web

You will need some way to bundle your luau code,
currently combining vite + darklua is a semi-reasonable approach. (TODO: publish a vite-luau plugin that configures this).

In your javascript entrypoint you will need something like:
```js
import { LuauState, Mutable } from "luau-web";
import { prepareBridge } from "luau-web-fusion"
// We are assuming following is using a `vite-luau` plugin to bundling all requires:
import appCode from './app.luau';

async function startApp() {
	const state = await LuauState.createAsync();

    const bridge = prepareBridge()
		
	try {
		const app = state.loadstring(appCode);
		
		if (typeof app != 'function') {
			console.warn('Luau code did not load as a function:', app)
			return;
		}

        // we pass the bridge into our module
		const results = await app(bridge);

	} catch (e: any) {
		console.error("Luau Execution Error:", e.message || e);
		if (e.stack) console.error("JS Stack:", e.stack);
	}
}

startApp().catch(console.error);
```

and a sample app.luau might be:

```luau
local web = require("@self/bridge")
local Fusion = require("@fusion")
local scope = Fusion.scoped(Fusion)

local clicks = scope:Value(0)

scope:New("div")({
    id = "example",
    parent = web.DOCUMENT_BODY,
    [Fusion.Children] = {
        scope:New("h1")({
            text = scope:Computed(function (use)
                return `You clicked {use(clicks)} times`
            end),
        })
        scope:New("button")({
            text = "Click Me",
            [Fusion.OnEvent("click")] = function ()
                clicks:set(Fusion.peek(clicks) + 1)
            end,
        })
    }
})
```

Web external uses should have thier bundler wrap the whole bundle in a fn that recieves the web bridge as an argument and sets a global variable (bridge.luau expects `__WEB_BRIDGE`) in order for that to get exposed to all requesters of the bridge.luau.

It is also reasonable for a consumer to alias the bridge.luau. e.g. via thier `.luaurc`
```json:.luaurc
{
  "languageMode": "strict",
  "aliases": {
    "fusion": "./Packages/fusion@v0.3.0-externalized/src",
    "web-bridge": "./Packages/fusion@v0.3.0-externalized/src/Externals/Web/bridge"
  }
}`
```

Possibly also aliasing in a darklua config:
```json:.darklua.json
"bundle": {
    "require_mode": {
      "name": "luau",
      "aliases": {
        "@fusion": "./Packages/fusion@v0.3.0-externalized/src",
        "@web-bridge": "./Packages/fusion@v0.3.0-externalized/src/Externals/Web/bridge.luau"
      }
    }
},
```

Since you may need to import it for the root constants. However, importing the web bridge directly should be limited. Mostly you can let Fusion internally use it.
