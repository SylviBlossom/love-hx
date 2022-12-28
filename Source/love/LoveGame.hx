package love;

import lua.UserData;
import love.joystick.JoystickHat;
import love.joystick.GamepadButton;
import love.keyboard.KeyConstant;
import love.joystick.GamepadAxis;
import love.event.EventPollResult;
import love.filesystem.DroppedFile;
import love.window.DisplayOrientation;
import lua.Os;
import love.keyboard.KeyboardModule;
import love.system.SystemModule;
import love.audio.AudioModule;
import love.joystick.Joystick;
import love.joystick.JoystickModule;
import love.mouse.MouseModule;
import love.window.WindowModule;
import lua.NativeStringTools;
import love.graphics.GraphicsModule;
import lua.NativeIterator;
import love.event.EventModule;
import love.timer.TimerModule;
import love.arg.ArgModule;
import lua.Lua;
import lua.Table;
import love.Love;
import love.keyboard.Scancode;

/**
    Optional base class for a LOVE game, providing simple overridable callbacks and helpful initialization.
**/
class LoveGame {
    public function new() {
        // Init seed for Math.random()
        lua.Math.randomseed(Os.time());

        // Hook all LOVE callbacks with this class's methods
        registerCallbacks();
    }

    private function registerCallbacks() {
        // General
        Love.load = (arg, unfilteredArg) -> load(Table.toArray(cast arg), Table.toArray(cast unfilteredArg));
        Love.quit = () -> quit();
        Love.update = (dt) -> update(dt);
        Love.draw = () -> draw();

        Love.run = () -> run();
        Love.errorhandler = (msg) -> errorHandler(msg, 2);

        // Window callbacks

        Love.focus = (f) -> focus(f);
        Love.mousefocus = (f) -> mouseFocus(f);
        Love.resize = (w, h) -> resize(cast w, cast h);
        Love.visible = (v) -> visible(v);
        Love.filedropped = (file) -> fileDropped(file);
        Love.directorydropped = (path) -> directoryDropped(path);
        Love.displayrotated = (index, orientation) -> displayRotated(cast index, orientation);

        // Keyboard callbacks

        Love.keypressed = (key, scancode, isRepeat) -> keyPressed(key, scancode, isRepeat);
        Love.keyreleased = (key, scancode) -> keyReleased(key, scancode);
        Love.textinput = (text) -> textInput(text);
        Love.textedited = (text, start, length) -> textEdited(text, cast start, cast length);

        // Mouse callbacks

        Love.mousemoved = (x, y, dx, dy, istouch) -> mouseMoved(cast x, cast y, cast dx, cast dy, istouch);
        Love.mousepressed = (x, y, button, istouch, presses) -> mousePressed(cast x, cast y, cast button, istouch, cast presses);
        Love.mousereleased = (x, y, button, istouch, presses) -> mouseReleased(cast x, cast y, cast button, istouch, cast presses);
        Love.wheelmoved = (x, y) -> wheelMoved(cast x, cast y);

        // Joystick callbacks

        Love.gamepadaxis = (joystick, axis, value) -> gamepadAxis(joystick, axis, value);
        Love.gamepadpressed = (joystick, button) -> gamepadPressed(joystick, button);
        Love.gamepadreleased = (joystick, button) -> gamepadReleased(joystick, button);
        Love.joystickadded = (joystick) -> joystickAdded(joystick);
        Love.joystickaxis = (joystick, axis, value) -> joystickAxis(joystick, cast axis, value);
        Love.joystickhat = (joystick, hat, direction) -> joystickHat(joystick, cast hat, direction);
        Love.joystickpressed = (joystick, button) -> joystickPressed(joystick, cast button);
        Love.joystickreleased = (joystick, button) -> joystickReleased(joystick, cast button);
        Love.joystickremoved = (joystick) -> joystickRemoved(joystick);

        // Touch callbacks

        Love.touchmoved = (id, x, y, dx, dy, pressure) -> touchMoved(id, cast x, cast y, cast dx, cast dy, pressure);
        Love.touchpressed = (id, x, y, dx, dy, pressure) -> touchPressed(id, cast x, cast y, cast dx, cast dy, pressure);
        Love.touchreleased = (id, x, y, dx, dy, pressure) -> touchReleased(id, cast x, cast y, cast dx, cast dy, pressure);
    }


    // General callbacks

    public function load(arg:Array<String>, unfilteredArg:Array<String>) { }

    public function update(dt:Float) { }

    public function draw() { }

    public function quit():Bool { return false; }

    // Window callbacks

    public function focus(focus:Bool) {}

    public function mouseFocus(focus:Bool) { }

    public function resize(w:Int, h:Int) { }

    public function visible(visible:Bool) { }

    public function fileDropped(file:DroppedFile) { }

    public function directoryDropped(path:String) { }

    public function displayRotated(index:Int, orientation:DisplayOrientation) {}

    // Keyboard callbacks

    public function keyPressed(key:KeyConstant, scancode:Scancode, isRepeat:Bool) { }

    public function keyReleased(key:KeyConstant, scancode:Scancode) { }

    public function textInput(text:String) { }

    public function textEdited(text:String, start:Int, length:Int) { }

    // Mouse callbacks

    public function mouseMoved(x:Int, y:Int, dx:Int, dy:Int, isTouch:Bool) { }

    public function mousePressed(x:Int, y:Int, button:Int, isTouch:Bool, presses:Int) { }

    public function mouseReleased(x:Int, y:Int, button:Int, isTouch:Bool, presses:Int) { }

    public function wheelMoved(x:Int, y:Int) { }

    // Joystick callbacks

    public function gamepadAxis(joystick:Joystick, axis:GamepadAxis, value:Float) { }

    public function gamepadPressed(joystick:Joystick, button:GamepadButton) { }

    public function gamepadReleased(joystick:Joystick, button:GamepadButton) { }

    public function joystickAdded(joystick:Joystick) { }

    public function joystickAxis(joystick:Joystick, axis:Int, value:Float) { }

    public function joystickHat(joystick:Joystick, hat:Int, direction:JoystickHat) { }

    public function joystickPressed(joystick:Joystick, button:Int) { }

    public function joystickReleased(joystick:Joystick, button:Int) { }

    public function joystickRemoved(joystick:Joystick) { }

    // Touch callbacks

    public function touchMoved(id:UserData, x:Int, y:Int, dx:Int, dy:Int, pressure:Float) { }

    public function touchPressed(id:UserData, x:Int, y:Int, dx:Int, dy:Int, pressure:Float) { }

    public function touchReleased(id:UserData, x:Int, y:Int, dx:Int, dy:Int, pressure:Float) { }


    private function pollEvents():Array<EventPollResult> {
        var events:Array<EventPollResult> = [];

        var iter:Void->EventPollResult = EventModule.poll();

        var result:EventPollResult = null;
        while (true) {
            result = iter();
            if (result.name == null) {
                break;
            }
            events.push(result);
        }
        
        return events;
    }

    // The default LOVE 11.4 main loop
    public function run():Void->Dynamic {
        if (Love.load != null) Love.load(ArgModule.parseGameArguments(Lua.arg), Lua.arg);

        // We don't want the first frame's dt to include time taken by love.load.
        if (TimerModule != null) TimerModule.step();

        var dt:Float = 0;

        // Main loop time.
        return () -> {
            // Process events.
            if (EventModule != null) {
                EventModule.pump();
                for (event in pollEvents()) {
                    if (event.name == "quit") {
                        if (Love.quit == null || !Love.quit()) {
                            return event.a != null ? event.a : 0;
                        }
                    }
                    Lua.rawget(Love.handlers, event.name)(event.a, event.b, event.c, event.d, event.e, event.f);
                }
            }

            // Update dt, as we'll be passing it to update
            if (TimerModule != null) dt = TimerModule.step();

            // Call update and draw
            if (Love.update != null) Love.update(dt); // will pass 0 if love.timer is disabled

            if (GraphicsModule != null && GraphicsModule.isActive()) {
                GraphicsModule.origin();

                var bgColor = GraphicsModule.getBackgroundColor();
                GraphicsModule.clear(bgColor.r, bgColor.g, bgColor.b, bgColor.a);

                if (Love.draw != null) Love.draw();

                GraphicsModule.present();
            }

            if (TimerModule != null) TimerModule.sleep(0.001);

            return null;
        }
    }


    private function errorPrinter(msg:String, layer:Int = 1) {
        var error = LuaErrorDebug.traceback("Error: " + msg, 1 + layer);
        trace(NativeStringTools.gsub(error, "\n[^\n]+$", ""));
    }

    // The default LOVE 11.4 error handler
    public function errorHandler(msg:Dynamic, layer:Int = 1):Void->Dynamic {
        var msgStr = Std.string(msg);

        errorPrinter(msgStr, layer + 1);

        if (WindowModule == null || GraphicsModule == null || EventModule == null) {
            return null;
        }

        if (!GraphicsModule.isCreated() || !WindowModule.isOpen()) {
            var result = Lua.pcall(WindowModule.setMode, 800, 600);
            if (!result.status || !result.value) {
                return null;
            }
        }

        // Reset state.
        if (MouseModule != null) {
            MouseModule.setVisible(true);
            MouseModule.setGrabbed(false);
            MouseModule.setRelativeMode(false);
            if (MouseModule.isCursorSupported()) {
                MouseModule.setCursor(null);
            }
        }
        if (JoystickModule != null) {
            var joysticks:Table<Int, Joystick> = cast JoystickModule.getJoysticks();
            for (joystick in Table.toArray(joysticks)) {
                joystick.setVibration();
            }
        }
        if (AudioModule != null) AudioModule.stop();

        GraphicsModule.reset();
        var font = GraphicsModule.setNewFont(14);

        GraphicsModule.setColor(1, 1, 1);

        var traceback = LuaErrorDebug.traceback("", layer);

        GraphicsModule.origin();

        //local sanitizedmsg = {}
        //for char in msg:gmatch(utf8.charpattern) do
        //	table.insert(sanitizedmsg, char)
        //end
        //sanitizedmsg = table.concat(sanitizedmsg)

        var err = new Array<String>();

        err.push("Error\n");
        err.push(msgStr); // TODO: UTF-8 support

        //if #sanitizedmsg ~= #msg then
        //	table.insert(err, "Invalid UTF-8 string in error message.")
        //end

        err.push("\n");

        var tracebackLines = NativeStringTools.gmatch(traceback, "(.-)\n");
        for (line in NativeIterator.fromF(tracebackLines).toIterator()) {
            if (NativeStringTools.match(line, "boot.lua") == null) {
                line = NativeStringTools.gsub(line, "stack traceback:", "Traceback\n");
                err.push(line);
            }
        }

        var p = err.join("\n");

        p = NativeStringTools.gsub(p, "\t", "");
        p = NativeStringTools.gsub(p, "%[string \"(.-)\"%]", "%1");

        var draw = () -> {
            if (!GraphicsModule.isActive()) return;
            var pos = 70;
            //  89/255, 157/255, 220/255  - The classic blue
            GraphicsModule.clear(255/255, 155/255, 221/255);
            GraphicsModule.printf(p, pos, pos, GraphicsModule.getWidth() - pos);
            GraphicsModule.present();
        }

        var fullErrorText = p;
        var copyToClipboard = () -> {
            if (SystemModule == null) return;
            SystemModule.setClipboardText(fullErrorText);
            p = p + "\nCopied to clipboard!";
        }

        if (SystemModule != null) {
            p = p + "\n\nPress Ctrl+C or tap to copy this error";
        }

        return () -> {

            EventModule.pump();

            for (event in pollEvents()) {
                if (event.name == "quit") {
                    return 1;
                } else if (event.name == "keypressed" && event.a == KeyConstant.Escape) {
                    return 1;
                } else if (event.name == "keypressed" && event.a == KeyConstant.C && KeyboardModule.isDown(Lctrl, Rctrl)) {
                    copyToClipboard();
                } else if (event.name == "touchpressed") {
                    var name = WindowModule.getTitle();
                    if (name.length == 0 || name == "Untitled") {
                        name = "Game";
                    }
                    var buttons = ["OK", "Cancel"];
                    if (SystemModule != null) {
                        buttons.push("Copy to clipboard");
                    }
                    var pressed = WindowModule.showMessageBox("Quit " + name + "?", "", Table.fromArray(buttons));
                    if (pressed == 1) {
                        return 1;
                    } else if (pressed == 3) {
                        copyToClipboard();
                    }
                }
            }

            draw();

            if (TimerModule != null) {
                TimerModule.sleep(0.1);
            }

            return null;
        }
    }
}

/*
    Haxe function for Debug.traceback doesnt work because of the
    thread argument at the start, so here's one without it
*/
@:native("debug")
extern class LuaErrorDebug {
    static function traceback(?message:String, ?level:Int):String;
}