package
{

	import agt.physics.PhysicsScene3D;
	import agt.debug.AGTSimpleGUI;

	import away3d.containers.View3D;
	import away3d.debug.AwayStats;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;

	/*
		Wraps an AGT example by adding it a signature, stats, a simple user interface
		and initializing the 3D basics.
	 */
	public class AGTExampleBase extends Sprite
	{
		[Embed(source="assets/fla/Signature.swf", symbol="Signature")]
		private var SignatureAsset:Class;

		public var gui:AGTSimpleGUI;
		public var view:View3D;
		public var scene:PhysicsScene3D;
		public var stats:AwayStats;

		private var _signature:Sprite;
		private var _signatureLabel:TextField;

		private const EDGE_OFFSET:Number = 5;

		public function AGTExampleBase()
		{
			// wait for stage before pre-init...
			addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
		}

		private function preInit():void
		{
			// init stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;

			// init signature
			_signature = new SignatureAsset() as Sprite;
			_signatureLabel = _signature.getChildByName("label") as TextField;
			_signatureLabel.text = "AwayGameTools example.";
			_signatureLabel.selectable = false;
			_signatureLabel.multiline = false;
			_signatureLabel.height = 22;
			addChild(_signature);

			// init away3d
			scene = new PhysicsScene3D();
			view = new View3D(scene); // use physics
			addChild(view);

			// init stats
			stats = new AwayStats(view);
			addChild(stats);

			// init simple gui
			gui = new AGTSimpleGUI(this, "", "C");
			gui.addGroup("View");
			gui.addStepper("view.antiAlias", 0, 8, {label:"AntiAlias"});
			gui.addSlider("view.camera.lens.near", 0, 1000, {label:"lens near"});
			gui.addSlider("view.camera.lens.far", 0, 100000, {label:"lens far"});
			gui.show();

			// listen for stage resize
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
			stageResizeHandler(null);

			// trigger init
			startExample();
		}

		protected function startExample():void
		{
			throw new Error("Method must be overriden.");
		}

		private function stageResizeHandler(evt:Event):void
		{
			// place signature at bottom left
			_signature.x = EDGE_OFFSET;
			_signature.y = stage.stageHeight - 22 - EDGE_OFFSET;

			// place stats at top right
			stats.x = stage.stageWidth - stats.width;
		}

		private function stageInitHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
			preInit();
		}

		public function get signatureText():String
		{
			return _signatureLabel.text;
		}

		public function set signatureText(value:String):void
		{
			_signatureLabel.text = value;
			_signatureLabel.width = _signatureLabel.textWidth + 10;
		}
	}
}
