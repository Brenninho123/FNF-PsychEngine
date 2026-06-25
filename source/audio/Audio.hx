package audio;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Audio
{
	public static var music:FlxSound;
	private static var _activeTweens:Map<FlxSound, FlxTween> = new Map();

	public static function playMusic(path:String, volume:Float = 1.0, loop:Bool = true):Void
	{
		stopMusic();

		music = new FlxSound();
		music.loadEmbedded(Paths.music(path), loop);
		music.volume = volume;
		music.play();
		FlxG.sound.list.add(music);
	}

	public static function playSound(path:String, volume:Float = 1.0, ?onComplete:Void->Void):FlxSound
	{
		var sound:FlxSound = new FlxSound();
		sound.loadEmbedded(Paths.sound(path), false);
		sound.volume = volume;
		
		if (onComplete != null)
			sound.onComplete = onComplete;
			
		sound.play();
		FlxG.sound.list.add(sound);
		return sound;
	}

	public static function fadeMusic(duration:Float, targetVolume:Float, ?ease:Dynamic):Void
	{
		if (music == null || !music.playing) return;
		fadeSound(music, duration, targetVolume, ease);
	}

	public static function fadeSound(sound:FlxSound, duration:Float, targetVolume:Float, ?ease:Dynamic):Void
	{
		if (sound == null) return;

		cancelTween(sound);

		var tweenEase = (ease != null) ? ease : FlxEase.linear;
		var tween = FlxTween.num(sound.volume, targetVolume, duration, {
			ease: tweenEase,
			onUpdate: function(twn:FlxTween) {
				sound.volume = twn.value;
			},
			onComplete: function(twn:FlxTween) {
				_activeTweens.remove(sound);
				if (targetVolume <= 0) sound.stop();
			}
		});

		_activeTweens.set(sound, tween);
	}

	public static function stopMusic():Void
	{
		if (music != null)
		{
			cancelTween(music);
			music.stop();
			music.destroy();
			music = null;
		}
	}

	public static function pauseMusic():Void
	{
		if (music != null && music.playing)
			music.pause();
	}

	public static function resumeMusic():Void
	{
		if (music != null && !music.playing)
			music.play();
	}

	private static function cancelTween(sound:FlxSound):Void
	{
		if (_activeTweens.exists(sound))
		{
			var tween = _activeTweens.get(sound);
			if (tween != null) tween.cancel();
			_activeTweens.remove(sound);
		}
	}
}
