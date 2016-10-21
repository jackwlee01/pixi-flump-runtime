## What is Flump?

[Flump](https://github.com/tconkling/flump) is a Flash animation exporter that converts Sprites and nested MovieClip animations. It converts your graphics to sprite atlases along with an xml file that describes library and keyframe information.

## What is Pixi Flump Runtime?

Pixi Flump Runtime is a library built for Pixi.js to support animation exported from Flump. It is built with Haxe and works for both Haxe and Javascript projects.


## Features
- Sprites
- MovieClips (nested timelines!)
- Frame labels with events
- Pivot data
- Multi resolution support (currently experimental)
- Familiar and easy API
- Documentation (better documentation coming soon)

## New Features
pixi-flump-runtime support additional features from the flump fork https://github.com/mathieuanthoine/flump :
- mask (one layer masked by a static layer)
- tint
- base class (Movie/Sprite getBaseClass method)
- custom data (Movie/Sprite getCustomData and Movie getLayerCustomData methods)

In Flash/Animate, custom data are stored as persistent data.
Use persistent data panel in Flash/Animate (https://github.com/mathieuanthoine/AnimateCCPersistentDataTools) to easily manage persistent data


## Examples

The examples demonstrate the usage. In order to view the examples locally, ensure that you run your HTTP Server on the project root (pixi-flump-runtime).


<a href="https://cdn.rawgit.com/jackwlee01/pixi-flump-runtime/master/examples/js/dog/bin/index.html"><img src="http://i.imgur.com/k3mjwgR.png"></a>
<br><sub><a href="https://cdn.rawgit.com/jackwlee01/pixi-flump-runtime/master/examples/js/dog/bin/index.html">View the dog example</a></sub>

<a href="https://cdn.rawgit.com/jackwlee01/pixi-flump-runtime/master/examples/js/monster/bin/index.html"><img src="http://i.imgur.com/MAzJOL6.png"></a>
<br><sub><a href="https://cdn.rawgit.com/jackwlee01/pixi-flump-runtime/master/examples/js/monster/bin/index.html">View the monster example</a></sub>

## Documentation

See the [wiki](https://github.com/jackwlee01/pixi-flump-runtime/wiki) for the complete api.

