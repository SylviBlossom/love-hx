import love.timer.TimerModule;
import love.graphics.GraphicsModule;
import love.graphics.Image;
import love.LoveGame;

class MyGame extends LoveGame {

    private var ballImage:Image;
    private var spin:Float = 0;

    override function load(arg:Array<String>, unfilteredArg:Array<String>) {
        // Load the ball image
        ballImage = GraphicsModule.newImage("Resources/loveball.png");
    }

    override function update(dt:Float) {
        // Spin the ball around
        spin += dt;
    }

    override function draw() {
        // Draw the ball in the middle of the screen
        var x = GraphicsModule.getWidth()/2;
        var y = GraphicsModule.getHeight()/2;
        GraphicsModule.draw(ballImage, x, y, spin, 1, 1, ballImage.getWidth()/2, ballImage.getHeight()/2);
    }
}