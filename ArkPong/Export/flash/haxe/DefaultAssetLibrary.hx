package;


import haxe.Timer;
import haxe.Unserializer;
import lime.app.Preloader;
import lime.audio.AudioSource;
import lime.audio.openal.AL;
import lime.audio.AudioBuffer;
import lime.graphics.Image;
import lime.text.Font;
import lime.utils.ByteArray;
import lime.utils.UInt8Array;
import lime.Assets;

#if sys
import sys.FileSystem;
#end

#if flash
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;
#end


class DefaultAssetLibrary extends AssetLibrary {
	
	
	public var className (default, null) = new Map <String, Dynamic> ();
	public var path (default, null) = new Map <String, String> ();
	public var type (default, null) = new Map <String, AssetType> ();
	
	private var lastModified:Float;
	private var timer:Timer;
	
	
	public function new () {
		
		super ();
		
		#if flash
		
		className.set ("assets/Ball.bmp", __ASSET__assets_ball_bmp);
		type.set ("assets/Ball.bmp", AssetType.TEXT);
		className.set ("assets/Block1.bmp", __ASSET__assets_block1_bmp);
		type.set ("assets/Block1.bmp", AssetType.TEXT);
		className.set ("assets/Block2.bmp", __ASSET__assets_block2_bmp);
		type.set ("assets/Block2.bmp", AssetType.TEXT);
		className.set ("assets/Block3.bmp", __ASSET__assets_block3_bmp);
		type.set ("assets/Block3.bmp", AssetType.TEXT);
		className.set ("assets/Block4.bmp", __ASSET__assets_block4_bmp);
		type.set ("assets/Block4.bmp", AssetType.TEXT);
		className.set ("assets/blockbrick.jpg", __ASSET__assets_blockbrick_jpg);
		type.set ("assets/blockbrick.jpg", AssetType.IMAGE);
		className.set ("assets/bluebrick.jpg", __ASSET__assets_bluebrick_jpg);
		type.set ("assets/bluebrick.jpg", AssetType.IMAGE);
		className.set ("assets/boob3s4.jpg", __ASSET__assets_boob3s4_jpg);
		type.set ("assets/boob3s4.jpg", AssetType.IMAGE);
		className.set ("assets/bossSnort.png", __ASSET__assets_bosssnort_png);
		type.set ("assets/bossSnort.png", AssetType.IMAGE);
		className.set ("assets/Bouncer.bmp", __ASSET__assets_bouncer_bmp);
		type.set ("assets/Bouncer.bmp", AssetType.BINARY);
		className.set ("assets/fire.JPG", __ASSET__assets_fire_jpg);
		type.set ("assets/fire.JPG", AssetType.IMAGE);
		className.set ("assets/greenbrick.jpg", __ASSET__assets_greenbrick_jpg);
		type.set ("assets/greenbrick.jpg", AssetType.IMAGE);
		className.set ("assets/oppsnort2.PNG", __ASSET__assets_oppsnort2_png);
		type.set ("assets/oppsnort2.PNG", AssetType.IMAGE);
		className.set ("assets/powerbirck.jpg", __ASSET__assets_powerbirck_jpg);
		type.set ("assets/powerbirck.jpg", AssetType.IMAGE);
		className.set ("assets/powerFire.png", __ASSET__assets_powerfire_png);
		type.set ("assets/powerFire.png", AssetType.IMAGE);
		className.set ("assets/powerFreeze.png", __ASSET__assets_powerfreeze_png);
		type.set ("assets/powerFreeze.png", AssetType.IMAGE);
		className.set ("assets/powerGold.png", __ASSET__assets_powergold_png);
		type.set ("assets/powerGold.png", AssetType.IMAGE);
		className.set ("assets/powerNinja.png", __ASSET__assets_powerninja_png);
		type.set ("assets/powerNinja.png", AssetType.IMAGE);
		className.set ("assets/powerPunch.png", __ASSET__assets_powerpunch_png);
		type.set ("assets/powerPunch.png", AssetType.IMAGE);
		className.set ("assets/powerSplit.png", __ASSET__assets_powersplit_png);
		type.set ("assets/powerSplit.png", AssetType.IMAGE);
		className.set ("assets/redbrick.jpg", __ASSET__assets_redbrick_jpg);
		type.set ("assets/redbrick.jpg", AssetType.IMAGE);
		className.set ("assets/Snort.png", __ASSET__assets_snort_png);
		type.set ("assets/Snort.png", AssetType.IMAGE);
		className.set ("assets/wood_wavy_BG.jpg", __ASSET__assets_wood_wavy_bg_jpg);
		type.set ("assets/wood_wavy_BG.jpg", AssetType.IMAGE);
		
		
		#elseif html5
		
		var id;
		id = "assets/Ball.bmp";
		path.set (id, id);
		
		type.set (id, AssetType.TEXT);
		id = "assets/Block1.bmp";
		path.set (id, id);
		
		type.set (id, AssetType.TEXT);
		id = "assets/Block2.bmp";
		path.set (id, id);
		
		type.set (id, AssetType.TEXT);
		id = "assets/Block3.bmp";
		path.set (id, id);
		
		type.set (id, AssetType.TEXT);
		id = "assets/Block4.bmp";
		path.set (id, id);
		
		type.set (id, AssetType.TEXT);
		id = "assets/blockbrick.jpg";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/bluebrick.jpg";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/boob3s4.jpg";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/bossSnort.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/Bouncer.bmp";
		path.set (id, id);
		
		type.set (id, AssetType.BINARY);
		id = "assets/fire.JPG";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/greenbrick.jpg";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/oppsnort2.PNG";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/powerbirck.jpg";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/powerFire.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/powerFreeze.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/powerGold.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/powerNinja.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/powerPunch.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/powerSplit.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/redbrick.jpg";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/Snort.png";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		id = "assets/wood_wavy_BG.jpg";
		path.set (id, id);
		
		type.set (id, AssetType.IMAGE);
		
		
		var assetsPrefix = ApplicationMain.config.assetsPrefix;
		if (assetsPrefix != null) {
			for (k in path.keys()) {
				path.set(k, assetsPrefix + path[k]);
			}
		}
		
		#else
		
		#if openfl
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		#end
		
		#if (windows || mac || linux)
		
		var useManifest = false;
		
		className.set ("assets/Ball.bmp", __ASSET__assets_ball_bmp);
		type.set ("assets/Ball.bmp", AssetType.TEXT);
		
		className.set ("assets/Block1.bmp", __ASSET__assets_block1_bmp);
		type.set ("assets/Block1.bmp", AssetType.TEXT);
		
		className.set ("assets/Block2.bmp", __ASSET__assets_block2_bmp);
		type.set ("assets/Block2.bmp", AssetType.TEXT);
		
		className.set ("assets/Block3.bmp", __ASSET__assets_block3_bmp);
		type.set ("assets/Block3.bmp", AssetType.TEXT);
		
		className.set ("assets/Block4.bmp", __ASSET__assets_block4_bmp);
		type.set ("assets/Block4.bmp", AssetType.TEXT);
		
		className.set ("assets/blockbrick.jpg", __ASSET__assets_blockbrick_jpg);
		type.set ("assets/blockbrick.jpg", AssetType.IMAGE);
		
		className.set ("assets/bluebrick.jpg", __ASSET__assets_bluebrick_jpg);
		type.set ("assets/bluebrick.jpg", AssetType.IMAGE);
		
		className.set ("assets/boob3s4.jpg", __ASSET__assets_boob3s4_jpg);
		type.set ("assets/boob3s4.jpg", AssetType.IMAGE);
		
		className.set ("assets/bossSnort.png", __ASSET__assets_bosssnort_png);
		type.set ("assets/bossSnort.png", AssetType.IMAGE);
		
		className.set ("assets/Bouncer.bmp", __ASSET__assets_bouncer_bmp);
		type.set ("assets/Bouncer.bmp", AssetType.BINARY);
		
		className.set ("assets/fire.JPG", __ASSET__assets_fire_jpg);
		type.set ("assets/fire.JPG", AssetType.IMAGE);
		
		className.set ("assets/greenbrick.jpg", __ASSET__assets_greenbrick_jpg);
		type.set ("assets/greenbrick.jpg", AssetType.IMAGE);
		
		className.set ("assets/oppsnort2.PNG", __ASSET__assets_oppsnort2_png);
		type.set ("assets/oppsnort2.PNG", AssetType.IMAGE);
		
		className.set ("assets/powerbirck.jpg", __ASSET__assets_powerbirck_jpg);
		type.set ("assets/powerbirck.jpg", AssetType.IMAGE);
		
		className.set ("assets/powerFire.png", __ASSET__assets_powerfire_png);
		type.set ("assets/powerFire.png", AssetType.IMAGE);
		
		className.set ("assets/powerFreeze.png", __ASSET__assets_powerfreeze_png);
		type.set ("assets/powerFreeze.png", AssetType.IMAGE);
		
		className.set ("assets/powerGold.png", __ASSET__assets_powergold_png);
		type.set ("assets/powerGold.png", AssetType.IMAGE);
		
		className.set ("assets/powerNinja.png", __ASSET__assets_powerninja_png);
		type.set ("assets/powerNinja.png", AssetType.IMAGE);
		
		className.set ("assets/powerPunch.png", __ASSET__assets_powerpunch_png);
		type.set ("assets/powerPunch.png", AssetType.IMAGE);
		
		className.set ("assets/powerSplit.png", __ASSET__assets_powersplit_png);
		type.set ("assets/powerSplit.png", AssetType.IMAGE);
		
		className.set ("assets/redbrick.jpg", __ASSET__assets_redbrick_jpg);
		type.set ("assets/redbrick.jpg", AssetType.IMAGE);
		
		className.set ("assets/Snort.png", __ASSET__assets_snort_png);
		type.set ("assets/Snort.png", AssetType.IMAGE);
		
		className.set ("assets/wood_wavy_BG.jpg", __ASSET__assets_wood_wavy_bg_jpg);
		type.set ("assets/wood_wavy_BG.jpg", AssetType.IMAGE);
		
		
		if (useManifest) {
			
			loadManifest ();
			
			if (Sys.args ().indexOf ("-livereload") > -1) {
				
				var path = FileSystem.fullPath ("manifest");
				lastModified = FileSystem.stat (path).mtime.getTime ();
				
				timer = new Timer (2000);
				timer.run = function () {
					
					var modified = FileSystem.stat (path).mtime.getTime ();
					
					if (modified > lastModified) {
						
						lastModified = modified;
						loadManifest ();
						
						if (eventCallback != null) {
							
							eventCallback (this, "change");
							
						}
						
					}
					
				}
				
			}
			
		}
		
		#else
		
		loadManifest ();
		
		#end
		#end
		
	}
	
	
	public override function exists (id:String, type:String):Bool {
		
		var requestedType = type != null ? cast (type, AssetType) : null;
		var assetType = this.type.get (id);
		
		if (assetType != null) {
			
			if (assetType == requestedType || ((requestedType == SOUND || requestedType == MUSIC) && (assetType == MUSIC || assetType == SOUND))) {
				
				return true;
				
			}
			
			#if flash
			
			if (requestedType == BINARY && (assetType == BINARY || assetType == TEXT || assetType == IMAGE)) {
				
				return true;
				
			} else if (requestedType == null || path.exists (id)) {
				
				return true;
				
			}
			
			#else
			
			if (requestedType == BINARY || requestedType == null || (assetType == BINARY && requestedType == TEXT)) {
				
				return true;
				
			}
			
			#end
			
		}
		
		return false;
		
	}
	
	
	public override function getAudioBuffer (id:String):AudioBuffer {
		
		#if flash
		
		var buffer = new AudioBuffer ();
		buffer.src = cast (Type.createInstance (className.get (id), []), Sound);
		return buffer;
		
		#elseif html5
		
		return null;
		//return new Sound (new URLRequest (path.get (id)));
		
		#else
		
		if (className.exists(id)) return AudioBuffer.fromBytes (cast (Type.createInstance (className.get (id), []), ByteArray));
		else return AudioBuffer.fromFile (path.get (id));
		
		#end
		
	}
	
	
	public override function getBytes (id:String):ByteArray {
		
		#if flash
		
		switch (type.get (id)) {
			
			case TEXT, BINARY:
				
				return cast (Type.createInstance (className.get (id), []), ByteArray);
			
			case IMAGE:
				
				var bitmapData = cast (Type.createInstance (className.get (id), []), BitmapData);
				return bitmapData.getPixels (bitmapData.rect);
			
			default:
				
				return null;
			
		}
		
		return cast (Type.createInstance (className.get (id), []), ByteArray);
		
		#elseif html5
		
		var bytes:ByteArray = null;
		var data = Preloader.loaders.get (path.get (id)).data;
		
		if (Std.is (data, String)) {
			
			bytes = new ByteArray ();
			bytes.writeUTFBytes (data);
			
		} else if (Std.is (data, ByteArray)) {
			
			bytes = cast data;
			
		} else {
			
			bytes = null;
			
		}
		
		if (bytes != null) {
			
			bytes.position = 0;
			return bytes;
			
		} else {
			
			return null;
		}
		
		#else
		
		if (className.exists(id)) return cast (Type.createInstance (className.get (id), []), ByteArray);
		else return ByteArray.readFile (path.get (id));
		
		#end
		
	}
	
	
	public override function getFont (id:String):Font {
		
		#if flash
		
		var src = Type.createInstance (className.get (id), []);
		
		var font = new Font (src.fontName);
		font.src = src;
		return font;
		
		#elseif html5
		
		return cast (Type.createInstance (className.get (id), []), Font);
		
		#else
		
		if (className.exists (id)) {
			
			var fontClass = className.get (id);
			return cast (Type.createInstance (fontClass, []), Font);
			
		} else {
			
			return Font.fromFile (path.get (id));
			
		}
		
		#end
		
	}
	
	
	public override function getImage (id:String):Image {
		
		#if flash
		
		return Image.fromBitmapData (cast (Type.createInstance (className.get (id), []), BitmapData));
		
		#elseif html5
		
		return Image.fromImageElement (Preloader.images.get (path.get (id)));
		
		#else
		
		if (className.exists (id)) {
			
			var fontClass = className.get (id);
			return cast (Type.createInstance (fontClass, []), Image);
			
		} else {
			
			return Image.fromFile (path.get (id));
			
		}
		
		#end
		
	}
	
	
	/*public override function getMusic (id:String):Dynamic {
		
		#if flash
		
		return cast (Type.createInstance (className.get (id), []), Sound);
		
		#elseif openfl_html5
		
		//var sound = new Sound ();
		//sound.__buffer = true;
		//sound.load (new URLRequest (path.get (id)));
		//return sound;
		return null;
		
		#elseif html5
		
		return null;
		//return new Sound (new URLRequest (path.get (id)));
		
		#else
		
		return null;
		//if (className.exists(id)) return cast (Type.createInstance (className.get (id), []), Sound);
		//else return new Sound (new URLRequest (path.get (id)), null, true);
		
		#end
		
	}*/
	
	
	public override function getPath (id:String):String {
		
		//#if ios
		
		//return SystemPath.applicationDirectory + "/assets/" + path.get (id);
		
		//#else
		
		return path.get (id);
		
		//#end
		
	}
	
	
	public override function getText (id:String):String {
		
		#if html5
		
		var bytes:ByteArray = null;
		var data = Preloader.loaders.get (path.get (id)).data;
		
		if (Std.is (data, String)) {
			
			return cast data;
			
		} else if (Std.is (data, ByteArray)) {
			
			bytes = cast data;
			
		} else {
			
			bytes = null;
			
		}
		
		if (bytes != null) {
			
			bytes.position = 0;
			return bytes.readUTFBytes (bytes.length);
			
		} else {
			
			return null;
		}
		
		#else
		
		var bytes = getBytes (id);
		
		if (bytes == null) {
			
			return null;
			
		} else {
			
			return bytes.readUTFBytes (bytes.length);
			
		}
		
		#end
		
	}
	
	
	public override function isLocal (id:String, type:String):Bool {
		
		var requestedType = type != null ? cast (type, AssetType) : null;
		
		#if flash
		
		//if (requestedType != AssetType.MUSIC && requestedType != AssetType.SOUND) {
			
			return className.exists (id);
			
		//}
		
		#end
		
		return true;
		
	}
	
	
	public override function list (type:String):Array<String> {
		
		var requestedType = type != null ? cast (type, AssetType) : null;
		var items = [];
		
		for (id in this.type.keys ()) {
			
			if (requestedType == null || exists (id, type)) {
				
				items.push (id);
				
			}
			
		}
		
		return items;
		
	}
	
	
	public override function loadAudioBuffer (id:String, handler:AudioBuffer -> Void):Void {
		
		#if (flash)
		if (path.exists (id)) {
			
			var soundLoader = new Sound ();
			soundLoader.addEventListener (Event.COMPLETE, function (event) {
				
				var audioBuffer:AudioBuffer = new AudioBuffer();
				audioBuffer.src = event.currentTarget;
				handler (audioBuffer);
				
			});
			soundLoader.load (new URLRequest (path.get (id)));
			
		} else {
			handler (getAudioBuffer (id));
			
		}
		#else
		handler (getAudioBuffer (id));
		
		#end
		
	}
	
	
	public override function loadBytes (id:String, handler:ByteArray -> Void):Void {
		
		#if flash
		
		if (path.exists (id)) {
			
			var loader = new URLLoader ();
			loader.addEventListener (Event.COMPLETE, function (event:Event) {
				
				var bytes = new ByteArray ();
				bytes.writeUTFBytes (event.currentTarget.data);
				bytes.position = 0;
				
				handler (bytes);
				
			});
			loader.load (new URLRequest (path.get (id)));
			
		} else {
			
			handler (getBytes (id));
			
		}
		
		#else
		
		handler (getBytes (id));
		
		#end
		
	}
	
	
	public override function loadImage (id:String, handler:Image -> Void):Void {
		
		#if flash
		
		if (path.exists (id)) {
			
			var loader = new Loader ();
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (event:Event) {
				
				var bitmapData = cast (event.currentTarget.content, Bitmap).bitmapData;
				handler (Image.fromBitmapData (bitmapData));
				
			});
			loader.load (new URLRequest (path.get (id)));
			
		} else {
			
			handler (getImage (id));
			
		}
		
		#else
		
		handler (getImage (id));
		
		#end
		
	}
	
	
	#if (!flash && !html5)
	private function loadManifest ():Void {
		
		try {
			
			#if blackberry
			var bytes = ByteArray.readFile ("app/native/manifest");
			#elseif tizen
			var bytes = ByteArray.readFile ("../res/manifest");
			#elseif emscripten
			var bytes = ByteArray.readFile ("assets/manifest");
			#elseif (mac && java)
			var bytes = ByteArray.readFile ("../Resources/manifest");
			#elseif ios
			var bytes = ByteArray.readFile ("assets/manifest");
			#else
			var bytes = ByteArray.readFile ("manifest");
			#end
			
			if (bytes != null) {
				
				bytes.position = 0;
				
				if (bytes.length > 0) {
					
					var data = bytes.readUTFBytes (bytes.length);
					
					if (data != null && data.length > 0) {
						
						var manifest:Array<Dynamic> = Unserializer.run (data);
						
						for (asset in manifest) {
							
							if (!className.exists (asset.id)) {
								
								#if ios
								path.set (asset.id, "assets/" + asset.path);
								#else
								path.set (asset.id, asset.path);
								#end
								type.set (asset.id, cast (asset.type, AssetType));
								
							}
							
						}
						
					}
					
				}
				
			} else {
				
				trace ("Warning: Could not load asset manifest (bytes was null)");
				
			}
		
		} catch (e:Dynamic) {
			
			trace ('Warning: Could not load asset manifest (${e})');
			
		}
		
	}
	#end
	
	
	/*public override function loadMusic (id:String, handler:Dynamic -> Void):Void {
		
		#if (flash || html5)
		
		//if (path.exists (id)) {
			
		//	var loader = new Loader ();
		//	loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (event) {
				
		//		handler (cast (event.currentTarget.content, Bitmap).bitmapData);
				
		//	});
		//	loader.load (new URLRequest (path.get (id)));
			
		//} else {
			
			handler (getMusic (id));
			
		//}
		
		#else
		
		handler (getMusic (id));
		
		#end
		
	}*/
	
	
	public override function loadText (id:String, handler:String -> Void):Void {
		
		//#if html5
		
		/*if (path.exists (id)) {
			
			var loader = new URLLoader ();
			loader.addEventListener (Event.COMPLETE, function (event:Event) {
				
				handler (event.currentTarget.data);
				
			});
			loader.load (new URLRequest (path.get (id)));
			
		} else {
			
			handler (getText (id));
			
		}*/
		
		//#else
		
		var callback = function (bytes:ByteArray):Void {
			
			if (bytes == null) {
				
				handler (null);
				
			} else {
				
				handler (bytes.readUTFBytes (bytes.length));
				
			}
			
		}
		
		loadBytes (id, callback);
		
		//#end
		
	}
	
	
}


#if !display
#if flash

@:keep @:bind #if display private #end class __ASSET__assets_ball_bmp extends flash.utils.ByteArray { }
@:keep @:bind #if display private #end class __ASSET__assets_block1_bmp extends flash.utils.ByteArray { }
@:keep @:bind #if display private #end class __ASSET__assets_block2_bmp extends flash.utils.ByteArray { }
@:keep @:bind #if display private #end class __ASSET__assets_block3_bmp extends flash.utils.ByteArray { }
@:keep @:bind #if display private #end class __ASSET__assets_block4_bmp extends flash.utils.ByteArray { }
@:keep @:bind #if display private #end class __ASSET__assets_blockbrick_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_bluebrick_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_boob3s4_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_bosssnort_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_bouncer_bmp extends flash.utils.ByteArray { }
@:keep @:bind #if display private #end class __ASSET__assets_fire_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_greenbrick_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_oppsnort2_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_powerbirck_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_powerfire_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_powerfreeze_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_powergold_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_powerninja_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_powerpunch_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_powersplit_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_redbrick_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_snort_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_wood_wavy_bg_jpg extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }


#elseif html5


























#else



#if (windows || mac || linux)


@:file("Assets/Ball.bmp") #if display private #end class __ASSET__assets_ball_bmp extends lime.utils.ByteArray {}
@:file("Assets/Block1.bmp") #if display private #end class __ASSET__assets_block1_bmp extends lime.utils.ByteArray {}
@:file("Assets/Block2.bmp") #if display private #end class __ASSET__assets_block2_bmp extends lime.utils.ByteArray {}
@:file("Assets/Block3.bmp") #if display private #end class __ASSET__assets_block3_bmp extends lime.utils.ByteArray {}
@:file("Assets/Block4.bmp") #if display private #end class __ASSET__assets_block4_bmp extends lime.utils.ByteArray {}
@:image("Assets/blockbrick.jpg") #if display private #end class __ASSET__assets_blockbrick_jpg extends lime.graphics.Image {}
@:image("Assets/bluebrick.jpg") #if display private #end class __ASSET__assets_bluebrick_jpg extends lime.graphics.Image {}
@:image("Assets/boob3s4.jpg") #if display private #end class __ASSET__assets_boob3s4_jpg extends lime.graphics.Image {}
@:image("Assets/bossSnort.png") #if display private #end class __ASSET__assets_bosssnort_png extends lime.graphics.Image {}
@:file("Assets/Bouncer.bmp") #if display private #end class __ASSET__assets_bouncer_bmp extends lime.utils.ByteArray {}
@:image("Assets/fire.JPG") #if display private #end class __ASSET__assets_fire_jpg extends lime.graphics.Image {}
@:image("Assets/greenbrick.jpg") #if display private #end class __ASSET__assets_greenbrick_jpg extends lime.graphics.Image {}
@:image("Assets/oppsnort2.PNG") #if display private #end class __ASSET__assets_oppsnort2_png extends lime.graphics.Image {}
@:image("Assets/powerbirck.jpg") #if display private #end class __ASSET__assets_powerbirck_jpg extends lime.graphics.Image {}
@:image("Assets/powerFire.png") #if display private #end class __ASSET__assets_powerfire_png extends lime.graphics.Image {}
@:image("Assets/powerFreeze.png") #if display private #end class __ASSET__assets_powerfreeze_png extends lime.graphics.Image {}
@:image("Assets/powerGold.png") #if display private #end class __ASSET__assets_powergold_png extends lime.graphics.Image {}
@:image("Assets/powerNinja.png") #if display private #end class __ASSET__assets_powerninja_png extends lime.graphics.Image {}
@:image("Assets/powerPunch.png") #if display private #end class __ASSET__assets_powerpunch_png extends lime.graphics.Image {}
@:image("Assets/powerSplit.png") #if display private #end class __ASSET__assets_powersplit_png extends lime.graphics.Image {}
@:image("Assets/redbrick.jpg") #if display private #end class __ASSET__assets_redbrick_jpg extends lime.graphics.Image {}
@:image("Assets/Snort.png") #if display private #end class __ASSET__assets_snort_png extends lime.graphics.Image {}
@:image("Assets/wood_wavy_BG.jpg") #if display private #end class __ASSET__assets_wood_wavy_bg_jpg extends lime.graphics.Image {}



#end

#if openfl

#end

#end
#end

