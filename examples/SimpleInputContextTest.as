package
{

	import flash.display.Sprite;

	[SWF(frameRate="10")]
	public class SimpleInputContextTest extends Sprite
	{
		private var _context : IInputContext;

		public function SimpleInputContextTest()
		{
			super();

			trace('setting up example');
			var ctx : KeyboardInputContext = new KeyboardInputContext(stage);
			ctx.map(InputType.TRANSLATE_Z, Keyboard.W);
			ctx.map(InputType.TRANSLATE_X, Keyboard.A);
			ctx.map(InputType.TRANSLATE_Y, Keyboard.W, Keyboard.SHIFT);
			_context = ctx;

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(ev : Event) : void
		{
			trace('tx?', _context.inputActive(InputType.TRANSLATE_X));
			trace('ty?', _context.inputActive(InputType.TRANSLATE_Y));
			trace('tz?', _context.inputActive(InputType.TRANSLATE_Z));
		}
	}
}
