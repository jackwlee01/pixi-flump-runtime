package;
	
import flump.library.FlumpLibrary;
import pixi.flump.Movie;
import pixi.flump.Sprite;
import pixi.plugins.app.Application;
import pixi.flump.Parser;
import pixi.interaction.InteractionManager;
import pixi.core.graphics.Graphics;
import pixi.loaders.Loader;


class Main extends Application{

	

	public static function main():Void {
		new Main();
	}


	public function new(){
		super();

		this.width = 600;
		this.height = 270;
		this.pixelRatio = 1;

		super.start();

		stage.scale.x = 1 / pixelRatio;
		stage.scale.y = 1 / pixelRatio;

		var loader = new Loader();

		loader.after(Parser.parse(1));
		loader.add("DogLibrary", "./flump-assets/dog/library.json");
		loader.once("complete", begin);
		loader.load();
	}


	public function begin(){
		var movie = new Movie("TestScene");
		movie.tint = 0xFFEA00;
		movie.loop = true;
		movie.animationSpeed = 1;
		movie.gotoAndPlay(0);
		stage.addChild(movie);


		/*
		var placeholder = movie.getLayer("Placeholder");
		var graphics = new Graphics();
		graphics.lineColor = 0x990000;
		graphics.beginFill(0x009900);
		graphics.drawCircle(100, 100, 100);
		placeholder.addChild(graphics);
		*/
		
	}


}