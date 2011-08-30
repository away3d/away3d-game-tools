package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	public class Main extends Sprite {
		
		// Setting
		// 0=simpleplayercontrols, 1=simpelcameracontrols
		private var _selectedExample : int = 1;

		public function Main() {
			this.addEventListener(Event.ENTER_FRAME, tempLoop);
		}

		private function init() : void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 30;
			startExample();
		}

		private function startExample() : void {
			switch (_selectedExample) {
				case 0:
					var simplePlayerControls : SimplePlayerControls = new SimplePlayerControls();
					this.addChild(simplePlayerControls);
					break;
				case 1:
					var simpleCameraControls : SimpleCameraControls = new SimpleCameraControls;
					this.addChild(simpleCameraControls);
					break;
			}
		}

		// Make sure the stage is ready
		private function tempLoop(event : Event) : void {
			if ( stage.stageWidth > 0 && stage.stageHeight > 0 ) {
				this.removeEventListener(Event.ENTER_FRAME, tempLoop);
				init();
			}
		}
	}
}