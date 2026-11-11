<div align="center">
    <a href="https://github.com/archadiumm/Aether/releases/latest">
        <img src="https://github.com/archadiumm/Aether/blob/main/img/Aether_3.png?raw=true" width="600">
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
- [x] Infinite Jump detection
- [x] Fling detection
- [x] Noclip detection
- [ ] Fly detection <i>(..and more!)</i>

# Installation

To get **Aether** in your game, get the package from the [latest release](https://github.com/archadiumm/Aether/releases/latest), so you can always have an updated version. It is reccomended to put the package in **ServerScriptService**.

Starting Aether up is as simple as requiring the Main module and calling the `init` method.

```luau
const Aether = ServerScriptService.Aether
const Main = require(Aether.Main)

Main:init()
```

# Configurations

You can also selectively toggle anticheat modules using a parameter inside of the init.
```luau
const options: Main.cheatOptions = {}
options.RemoteSpam = false -- // Turns Remote Spam detection off.

Main:init(options)
```

Here is the list of Aether config settings if you need them (they are also present in the main module):
```luau
Fling -- // Detects exploits that fling other players.
Noclip -- // Detects exploits that noclip through objects.
RemoteSpam -- // Detects remote spamming.
InfiniteJump -- // Detects infinite jumping.
Modifications -- // Detects humanoid modifications like speedhack, jumphack, etc.

Debug -- // Enables debug info. Used to test if Aether is falsely blocking parts of your game.
```

Since this is a general-use anticheat, some modules may unintentionally interfere with your game and make certain aspects unplayable. It is reccomended to use the `Debug` option to test which scripts are activating what.

# Showcase
<video src="[/img/](https://github.com/archadiumm/Aether/blob/main/img/aetherbeta.png?raw=true" width="320" height="240" controls></video>

Keep in mind that __**Aether is in beta**__. It is not recommended to use Aether until an official release is made.
