# LoveHX

A small template for creating Love2D games with Haxe.

## Instructions

The following are required to be installed and in your PATH:
- [Haxe](https://haxe.org/)
- [Love2D](https://love2d.org/) (The `lovec` command is used for console output)
- [hxp](https://lib.haxe.org/p/hxp) - a Haxe library for running build scripts

In the root folder, you can run the following commands:
- **hxp build** - Builds the project to the `Build` folder, containing the `main.lua` for the Love2D game.\
Optionally add `--run` to run the game after building.
- **hxp run** - Runs the game from the `Build` folder.
- **hxp gen** - Generates Haxe files for Love2D using the [love-haxe-wrappergen](https://github.com/SylviBlossom/love-haxe-wrappergen).

When cloning the project, much of the Love2D library will be missing. Running `hxp gen` or `hxp build` will create the necessary files. \
\
Additionally, when building, files inside the `Resources` folder will be copied to `Build/Resources`, and files inside the `LuaSource` folder will be copied into the root of the `Build` folder.