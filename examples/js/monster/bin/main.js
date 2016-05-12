var stage = new PIXI.Stage(0x66FF99);
var renderer = new PIXI.autoDetectRenderer(480, 270);
document.body.appendChild(renderer.view);


var loader = new PIXI.loaders.Loader();
loader.after(PIXI.flump.Parser(1));
loader.add("MonsterLibrary", "./flump-assets/monster/library.json")
loader.once("complete", begin);
loader.load();

animate();


function begin(){
	var monster = new PIXI.flump.Movie("walk");	
	stage.addChild(monster);
	monster.x = 200;
	monster.y = 200;
}


function animate(){
	 requestAnimationFrame(animate);
	 renderer.render(stage);
}