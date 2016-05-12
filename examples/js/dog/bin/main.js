var stage = new PIXI.Stage(0x66FF99);
var renderer = new PIXI.autoDetectRenderer(480, 270);
document.body.appendChild(renderer.view);


var loader = new PIXI.loaders.Loader();
loader.after(PIXI.flump.Parser(1));
loader.add("DogLibrary", "./flump-assets/dog/library.json")
loader.once("complete", begin);
loader.load();

animate();


function begin(){
	var movie = new PIXI.flump.Movie("TestScene");	
	stage.addChild(movie);
	
	/*
	movie.loop = true;	
	movie.animationSpeed = 1;
	movie.gotoAndPlay(0);
	*/
}


function animate(){
	 requestAnimationFrame(animate);
	 renderer.render(stage);
}