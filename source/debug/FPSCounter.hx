package debug;

import flixel.FlxG;
import openfl.Lib;
import haxe.Timer;
import openfl.text.TextField;
import openfl.text.TextFormat;

class FPSCounter extends TextField
{
	public var currentFPS(default, null):Int = 0;
	public var memoryMegas(get, never):Float;
	public var totalMemoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;
	@:noCompletion private var lastFramerateUpdateTime:Float;
	@:noCompletion private var updateTime:Int;
	@:noCompletion private var framesCount:Int = 0;
	@:noCompletion private var prevTime:Int;
	@:noCompletion private var deltaTimeout:Float = 0.0;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		positionFPS(x, y);

		selectable = false;
		mouseEnabled = false;
		multiline = true;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		width = FlxG.width;
		text = "FPS: ";

		times = [];
		lastFramerateUpdateTime = Timer.stamp();
		prevTime = Lib.getTimer();
		updateTime = prevTime + 500;
	}

	public dynamic function updateText():Void
	{
		final memoryText:String = flixel.util.FlxStringUtil.formatBytes(memoryMegas);
		final taskText:String = flixel.util.FlxStringUtil.formatBytes(totalMemoryMegas);

		text = 'FPS: $currentFPS • Memory: $memoryText • Task: $taskText';
		textColor = currentFPS < FlxG.stage.window.frameRate * 0.5 ? 0xFFFF0000 : 0xFFFFFFFF;
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		if (ClientPrefs.data.fpsRework)
		{
			if (FlxG.stage.window.frameRate != ClientPrefs.data.framerate && FlxG.stage.window.frameRate != FlxG.game.focusLostFramerate)
				FlxG.stage.window.frameRate = ClientPrefs.data.framerate;

			framesCount++;

			final currentTime:Int = Lib.getTimer();
			if (currentTime < updateTime)
				return;

			final elapsed:Int = currentTime - prevTime;
			currentFPS = Math.ceil((framesCount * 1000) / elapsed);
			framesCount = 0;
			prevTime = currentTime;
			updateTime = currentTime + 500;

			if ((FlxG.updateFramerate >= currentFPS + 5 || FlxG.updateFramerate <= currentFPS - 5)
				&& Timer.stamp() - lastFramerateUpdateTime >= 1.5
				&& currentFPS >= 30)
			{
				FlxG.updateFramerate = FlxG.drawFramerate = currentFPS;
				lastFramerateUpdateTime = Timer.stamp();
			}
		}
		else
		{
			final now:Float = Timer.stamp() * 1000;
			times.push(now);
			while (times[0] < now - 1000)
				times.shift();

			if (deltaTimeout < 50)
			{
				deltaTimeout += deltaTime;
				return;
			}

			currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
			deltaTimeout = 0.0;
		}

		updateText();
	}

	inline function get_memoryMegas():Float
	{
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#else
		return 0.0;
		#end
	}

	inline function get_totalMemoryMegas():Float
	{
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED);
		#else
		return 0.0;
		#end
	}

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1):Void
	{
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}
}