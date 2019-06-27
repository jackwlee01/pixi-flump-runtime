package;
	
import pixi.plugins.app.Application;
import pixi.loaders.Loader;


class Main extends Application{


	public static function main():Void {
		new Main();
	}


	public function new(){
		super();
		super.start();

		var loader = new Loader();
		loader.after(pixi.flump.Parser.parse(1));
		loader.add("MonsterLibrary", "./flump-assets/library.json");
		loader.once("complete", begin);
		loader.load();
	}


	public function begin(){
		var monster = new pixi.flump.Movie("walk");
		stage.addChild(monster);
		monster.x = 200;
		monster.y = 200;
	}

}