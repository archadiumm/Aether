<div align="center">
    <a href="https://github.com/archadiumm/Aether/releases/latest">
        <img src="https://github.com/archadiumm/Aether/blob/main/img/Aether.png?raw=true" width="600">
    </a>
    <br>
    <p style="color: #888888;">
        <code>~ General purpose <a href="create.roblox.com">Roblox</a> anticheat ~</code>
    </p>
</div>

<br><br>

> [!WARNING]
> **Aether** is currently in development, so it is pretty barebones at the moment.
> 
> Sorry for the inconvenience!

<br>

# About
**Aether** is a general-use anti-cheat used for detecting exploiters and kicking them before damage is done. And unlike some other all-in-one anticheat packages, individual Aether modules can be toggled at will to have the best possible experience in almost any game.

Aether currently supports the following:

- [x] Remote Spamming detection
- [x] Infinite Jump detection (messy at the moment)
- [ ] Fling detection
- [ ] Fly detection
- [ ] Noclip detection <i>(..and more!)</i>

# Installation

To get **Aether** in your game, get the package from the [latest release](https://github.com/archadiumm/Aether/releases/latest), so you can always have an updated version. It is reccomended to put the package in **ServerScriptService**.

Starting Aether up is as simple as requiring the Main module and calling the `init` method.

```luau
const Aether = ServerScriptService.Aether
const Main = require(Aether.Main)

Main:init()
```

You can also selectively toggle anticheat modules using a parameter inside of the init.

```luau
const options: Main.cheatOptions = {}
options.RemoteSpam = false -- // Turns Remote Spam detection off.

Main:Init(options)
```

Keep in mind that __**Aether is in beta**__. It is not recommended to use Aether until an official release is made.
