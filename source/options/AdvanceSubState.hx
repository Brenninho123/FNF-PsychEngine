package options;

class AdvancedSubState extends MusicBeatSubstate
{
	var options:Array<String> = [
		'Reset Save Data'
	];

	var grpOptions:FlxTypedGroup<Alphabet>;
	var descriptionText:FlxText;
	var curSelected:Int = 0;
	var confirming:Bool = false;

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
			var label:Alphabet = new Alphabet(0, 0, option, true);
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.BACK)
		{
			if (confirming)
			{
				confirming = false;
				updateLabel();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
			}
		}
		else if (controls.ACCEPT)
			onAccept();
	}

	function onAccept():Void
	{
		switch (options[curSelected])
		{
			case 'Reset Save Data':
				if (confirming)
				{
					confirming = false;
					resetSaveData();
					updateLabel();
					descriptionText.text = 'Save data has been reset.';
				}
				else
				{
					confirming = true;
					updateLabel();
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
		}
	}

	function resetSaveData():Void
	{
		FlxG.save.erase();
		FlxG.sound.play(Paths.sound('confirmMenu'));
	}

	function updateLabel():Void
	{
		var label:Alphabet = grpOptions.members[curSelected];
		label.text = confirming ? options[curSelected] + ': Press ACCEPT again to confirm' : options[curSelected];
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		confirming = false;

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			item.alpha = (num == curSelected) ? 1 : 0.6;
		}

		updateLabel();
		descriptionText.text = 'Erases highscores, unlocks and other locally saved data. This cannot be undone.';

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}