package;

//using Lambda;
//import haxe.Json;
//import SpineLibrary;

import pixi.display.FlumpMovie;
import pixi.display.FlumpLibraryLoader;
import pixi.core.PIXI;
import pixi.core.graphics.Graphics;
import pixi.core.display.Container;
import pixi.core.textures.Texture;
import pixi.core.renderers.SystemRenderer;
import pixi.core.renderers.Detector;
import pixi.core.sprites.Sprite;
import pixi.plugins.app.Application;


import pixi.loaders.ResourceLoader;


class Main extends Application{

	private var bodies = new Array<FlumpMovie>();
	private var frame:Float = 0;
	

	public function new(){
		super();
		this.backgroundColor = 0;
		this.onUpdate = tick;
		super.start();

		/*
		var loader:ResourceLoader = new ResourceLoader();
		loader.add("spriteAtlas", "./mascot/atlas0.atlas");

		loader.load(function(){
			trace("ANother loaded");
		});		
		*/

		FlumpLibraryLoader.load("./scarecrow").addOnce(function(flump){
			//trace(flump);
			for(i in 0 ... 10){
				var foot = flump.createMovie("patchDie");
				_stage.addChild(foot);
				foot.x = Math.random() * 900;
				foot.y = Math.random() * 500;
				bodies.push(foot);
			}
		});
	}

	public function tick(time:Float){
		/*
		while(_stage.children.length > 0){
			_stage.children.shift();
		}
		var graphics = new Graphics();
		graphics.beginFill(0xff0000);
		graphics.moveTo(-10, -10);
		graphics.lineTo(10, -10);
		graphics.lineTo(10, 10);
		graphics.lineTo(-10, 10);
		graphics.x = Math.random() * 500;
		graphics.y = Math.random() * 500;
		_stage.addChild(graphics);
		*/

		frame += 0.3;
		var i = 0;
		for(body in bodies){
			i++;
			if(body != null){		
				body.renderFrame(frame + i);
				body.x += 1;
				if(body.x > 900) body.x -= 900;
				//body.rotation += 0.1;
			}
		}
	}




	public static function main():Void {
		new Main();
	}

}