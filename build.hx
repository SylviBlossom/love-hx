import hxp.Log;
import hxp.Path;
import sys.FileSystem;
import hxp.System;
import hxp.HXML;

class Build extends hxp.Script {

    public function new() {
        super();

        switch(command) {
            case "build": build();
            case "run": run();
            case "gen": gen();
            default: {
                if (command != "default" && command != "--help") {
                    Log.println('Unknown command $command');
                }
                Log.println("Usage: hxp [command] [options]");
                Log.println("  build: Build the project");
                Log.println("  run  : Run the project");
                Log.println("  gen  : Generate Love2D wrapper");
            }
        }
    }

    function build() {
        if (!FileSystem.isDirectory("LoveGen")) {
            Log.println("Love2D sources not found - generating");
            if (!gen()) {
                Log.println("Wrappergen failed, cancelling build");
                return;
            }
        }

        Log.println("Preparing build directory");

        System.removeDirectory("Build");
        System.makeDirectory("Build");

        Log.println("Building Haxe");

        var hxml = new HXML({
            cp: ["Source", "LoveGen"],
            defines: ["lua-ver=5.3", "lua-jit", "lua-vanilla"],
            lua: "Build/main.lua",
            main: "Main"
        });
        hxml.build();

        if (FileSystem.isDirectory("LuaSource")) {
            
            Log.println("Copying lua source files");

            System.recursiveCopy("LuaSource", "Build");
        }

        if (FileSystem.isDirectory("Resources")) {
            Log.println("Copying resources");

            System.makeDirectory("Build/Resources");
            System.recursiveCopy("Resources", "Build/Resources");
        }

        Log.println("Done!");

        if (options.exists("--run") || options.exists("-r")) {
            run();
        }
    }


    function run() {
        if (options.exists("--build") || options.exists("-b")) {
            build();
        } else if (!FileSystem.isDirectory("Build")) {
            Log.println("Build directory not found, running build");
            build();
        }

        Log.println("Running project");

        System.runCommand("Build", "lovec .");
    }


    function gen():Bool {
        var success = true;

        var tempDir = System.getTemporaryDirectory();

        try {
            Log.println("Cloning love-haxe-wrappergen");
            System.runCommand(tempDir, "git clone https://github.com/SylviBlossom/love-haxe-wrappergen.git");

            var wrapperGenDir = Path.combine(tempDir, "love-haxe-wrappergen");

            Log.println("Updating love-api submodule");
            System.runCommand(wrapperGenDir, "git submodule update --init love-api");

            Log.println("Running wrappergen");
            tryRunHaxify(wrapperGenDir);

            if (FileSystem.isDirectory("LoveGen")) {
                Log.println("Cleaning up previous genned love sources");
                System.removeDirectory("LoveGen");
            }

            Log.println("Copying newly genned love sources");
            System.makeDirectory("LoveGen");
            System.makeDirectory("LoveGen/love");
            System.recursiveCopy(Path.combine(wrapperGenDir, "love"), "LoveGen/love");

        } catch (e) {
            Log.error("Wrappergen failed", "", e);
            success = false;
        }

        Log.println("Cleaning up");
        System.removeDirectory(tempDir);

        Log.println("Done!");

        return success;
    }

    function tryRunHaxify(dir:String) {
        try {
            System.runCommand(dir, "lua53 haxify.lua", null, false);
            return;
        } catch(e) {}
        try {
            System.runCommand(dir, "lua haxify.lua", null, false);
            return;
        } catch(e) {}

        Log.println("Lua not found, creating Love2D entrypoint");

        var loveScript = "
            require(\"haxify\")

            function love.load()
                love.event.quit()
            end
        ";
        System.writeText(loveScript, Path.combine(dir, "main.lua"));
        System.runCommand(dir, "lovec .");
    }
}