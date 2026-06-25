package backend;

#if DISCORD_ALLOWED
import sys.thread.Thread;
import lime.app.Application;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import flixel.util.FlxStringUtil;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	private inline static final _defaultID:String = "863222024192262205";
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordPresence = new DiscordPresence();
	@:unreflective private static var __thread:Thread;

	public static function check()
	{
		#if desktop
		if (ClientPrefs.data.discordRPC) initialize();
		else if (isInitialized) shutdown();
		#end
	}

	public static function prepare()
	{
		#if desktop
		if (!isInitialized && ClientPrefs.data.discordRPC)
			initialize();

		Application.current.window.onClose.add(function() {
			if (isInitialized) shutdown();
		});
		#end
	}

	public dynamic static function shutdown()
	{
		#if desktop
		isInitialized = false;
		Discord.Shutdown();
		#end
	}

	#if desktop
	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		changePresence();
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void {}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void {}
	#end

	public static function initialize()
	{
		#if desktop
		var discordHandlers:DiscordEventHandlers = #if (hxdiscord_rpc > "1.2.4") new DiscordEventHandlers(); #else DiscordEventHandlers.create(); #end
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), #if (hxdiscord_rpc > "1.2.4") false #else 1 #end, null);

		if (__thread == null)
		{
			__thread = Thread.create(() ->
			{
				while (true)
				{
					if (isInitialized)
					{
						#if DISCORD_DISABLE_IO_THREAD
						Discord.UpdateConnection();
						#end
						Discord.RunCallbacks();
					}
					Sys.sleep(1.0);
				}
			});
		}
		isInitialized = true;
		#end
	}

	public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, largeImageKey:String = 'icon')
	{
		#if desktop
		var startTimestamp:Float = 0;
		if (hasStartTimestamp) startTimestamp = Date.now().getTime();
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		presence.state = state;
		presence.details = details;
		presence.smallImageKey = smallImageKey;
		presence.largeImageKey = largeImageKey;
		presence.largeImageText = "Engine Version: " + states.MainMenuState.psychEngineVersion;
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		updatePresence();
		#end
	}

	public static function updatePresence()
	{
		#if desktop
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence.__presence));
		#end
	}

	inline public static function resetClientID()
	{
		clientID = _defaultID;
	}

	private static function set_clientID(newID:String)
	{
		var change:Bool = (clientID != newID);
		clientID = newID;

		if (change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}
		return newID;
	}

	#if (MODS_ALLOWED && DISCORD_ALLOWED)
	public static function loadModRPC()
	{
		var pack:Dynamic = Mods.getPack();
		if (pack != null && pack.discordRPC != null && pack.discordRPC != clientID)
		{
			clientID = pack.discordRPC;
		}
	}
	#end

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State)
	{
		Lua_helper.add_callback(lua, "changeDiscordPresence", changePresence);
		Lua_helper.add_callback(lua, "changeDiscordClientID", function(?newID:String) {
			if (newID == null) newID = _defaultID;
			clientID = newID;
		});
	}
	#end
}

@:allow(backend.DiscordClient)
private final class DiscordPresence
{
	public var state(get, set):String;
	public var details(get, set):String;
	public var smallImageKey(get, set):String;
	public var largeImageKey(get, set):String;
	public var largeImageText(get, set):String;
	public var startTimestamp(get, set):Int;
	public var endTimestamp(get, set):Int;

	@:noCompletion private var __presence:DiscordRichPresence;

	function new()
	{
		#if desktop
		__presence = #if (hxdiscord_rpc > "1.2.4") new DiscordRichPresence(); #else DiscordRichPresence.create(); #end
		#end
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("state", state),
			LabelValuePair.weak("details", details),
			LabelValuePair.weak("smallImageKey", smallImageKey),
			LabelValuePair.weak("largeImageKey", largeImageKey),
			LabelValuePair.weak("largeImageText", largeImageText),
			LabelValuePair.weak("startTimestamp", startTimestamp),
			LabelValuePair.weak("endTimestamp", endTimestamp)
		]);
	}

	@:noCompletion inline function get_state():String return #if desktop __presence.state #else "" #end;
	@:noCompletion inline function set_state(value:String):String return #if desktop __presence.state = value #else value #end;

	@:noCompletion inline function get_details():String return #if desktop __presence.details #else "" #end;
	@:noCompletion inline function set_details(value:String):String return #if desktop __presence.details = value #else value #end;

	@:noCompletion inline function get_smallImageKey():String return #if desktop __presence.smallImageKey #else "" #end;
	@:noCompletion inline function set_smallImageKey(value:String):String return #if desktop __presence.smallImageKey = value #else value #end;

	@:noCompletion inline function get_largeImageKey():String return #if desktop __presence.largeImageKey #else "" #end;
	@:noCompletion inline function set_largeImageKey(value:String):String return #if desktop __presence.largeImageKey = value #else value #end;

	@:noCompletion inline function get_largeImageText():String return #if desktop __presence.largeImageText #else "" #end;
	@:noCompletion inline function set_largeImageText(value:String):String return #if desktop __presence.largeImageText = value #else value #end;

	@:noCompletion inline function get_startTimestamp():Int return #if desktop __presence.startTimestamp #else 0 #end;
	@:noCompletion inline function set_startTimestamp(value:Int):Int return #if desktop __presence.startTimestamp = value #else value #end;

	@:noCompletion inline function get_endTimestamp():Int return #if desktop __presence.endTimestamp #else 0 #end;
	@:noCompletion inline function set_endTimestamp(value:Int):Int return #if desktop __presence.endTimestamp = value #else value #end;
}
#end
