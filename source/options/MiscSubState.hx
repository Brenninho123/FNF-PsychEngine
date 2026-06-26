package options;

class MiscSubState extends MusicBeatSubstate
{
	var options:Array<String> = [
		'Dev Mode',
		'Streaming Mode'
	];

	var descriptions:Map<String, String> = [
		'Dev Mode' => 'Unlocks debug tools and developer-only features.',
		'Streaming Mode' => 'Hides sensitive info and disables things that may cause issues while streaming or recording.'
	];

	var grpOptions:FlxTypedGroup<Alphabet>;
	var descriptionText:FlxText;
	var curSelected:Int = 0;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFea71fd;
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (num => option in options)
		{
			var label:Alphabet = new Alphabet(0, 0, getLabel(option), true);
			label.screenCenter();
			label.y += (92 * (num - (options.length / 2))) + 45;
			grpOptions.add(label);
		}

		descriptionText = new FlxText(0, FlxG.height - 60, FlxG.width, '', 18);
		descriptionText.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionText.scrollFactor.set();
		add(descriptionText);

		changeSelection();

  #if mobile
  addTouchPad('UP_DOWN', 'A_B');
  #end

		super.create();
	}

	function getLabel(option:String):String
	{
		var enabled:Bool = switch (option)
		{
			case 'Dev Mode': ClientPrefs.data.devMode;
			case 'Streaming Mode': ClientPrefs.data.streamingMode;
			default: false;
		}
		return option + ': ' + (enabled ? 'On' : 'Off');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
		else if (controls.ACCEPT)
			toggleSelected();
	}

	function toggleSelected():Void
	{
		var option:String = options[curSelected];
		switch (option)
		{
			case 'Dev Mode':
				ClientPrefs.data.devMode = !ClientPrefs.data.devMode;
			case 'Streaming Mode':
				ClientPrefs.data.streamingMode = !ClientPrefs.data.streamingMode;
		}

		grpOptions.members[curSelected].text = getLabel(option);
		ClientPrefs.saveSettings();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			item.alpha = (num == curSelected) ? 1 : 0.6;
		}

		descriptionText.text = descriptions.get(options[curSelected]);

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}