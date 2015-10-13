package;
	
import flump.library.FlumpLibrary;
import pixi.display.FlumpFactory;
import pixi.display.FlumpMovie;
import pixi.plugins.app.Application;
import pixi.display.FlumpLibraryLoader;
import pixi.interaction.InteractionManager;
import pixi.core.graphics.Graphics;


class Main extends Application{

	private var movies = new Array<FlumpMovie>();
	private var pos:Int = 0;



	public static function main():Void {
		new Main();
	}


	public function new(){
		super();
		super.start();
		this.onUpdate = tick;


		FlumpLibraryLoader.load("./flump-assets/dog").addOnce( onLibraryLoaded );	

		js.Browser.document.onmousemove = function(e){
			pos = e.pageX*3;
		}
	}


	public function onLibraryLoaded(factory:FlumpFactory){
		var movie = factory.createMovie("TestScene");
		
		function onLabelPassed(label:String){
			trace(label);
			if(label == "forthFrame"){
				movie.gotoAndPlay(37);
				//movie.loop = true;
			}
		}


		movie.animationSpeed = 40;
		stage.addChild(movie);
		movies.push(movie);
		//movie.player.loop();

		movie.on("labelPassed", onLabelPassed);

		var dog = movie.getChildMovie("DogRunning");
		//dog.on("labelPassed", onLabelPassed);

		var placeholder = movie.getLayer("Placeholder");
		var graphics = new Graphics();
		graphics.lineColor = 0x990000;
		graphics.beginFill(0x009900);
		graphics.drawCircle(100, 100, 100);
		placeholder.addChild(graphics);

		/*
		haxe.Timer.delay(function(){
			var dog = factory.createMovie("DogRun");		
			stage.addChild(dog);
			dog.x = 100;
			dog.y = 100;

			dog.loop = true;
			dog.gotoAndStop(-30);

		}, 2000);
		*/
	}


	


	private function tick(t:Float){
		//for(movie in movies) trace(movie.currentFrame);
	}




}