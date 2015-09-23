package flump.library;

class Label{

	public var name:String;
	public var keyframe:Keyframe;
	public var next:Label;
	public var prev:Label;

	public static var LABEL_ENTER:String = "labelEnter";
	public static var LABEL_EXIT:String = "labelExit";
	public static var LABEL_UPDATE:String = "labelUpdate";

	public function new(){}

}