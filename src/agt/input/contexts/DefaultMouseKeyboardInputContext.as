package agt.input.contexts
{

	import agt.input.CompositeInputContext;
	import agt.input.data.InputType;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.ui.Keyboard;

	public class DefaultMouseKeyboardInputContext extends CompositeInputContext
	{
		public var mouseInputContext:MouseInputContext;
		public var keyboardInputContext:KeyboardInputContext;

		public function DefaultMouseKeyboardInputContext(context:Sprite, stage:Stage)
		{
			super();

			// mouse input
			mouseInputContext = new MouseInputContext(context, stage);

			// keyboard input
			keyboardInputContext = new KeyboardInputContext(stage);
			keyboardInputContext.mapWithAmount(InputType.TRANSLATE_X, 50, Keyboard.RIGHT);
			keyboardInputContext.mapWithAmount(InputType.TRANSLATE_X, -50, Keyboard.LEFT);
			keyboardInputContext.mapWithAmount(InputType.TRANSLATE_Z, 50, Keyboard.UP);
			keyboardInputContext.mapWithAmount(InputType.TRANSLATE_Z, -50, Keyboard.DOWN);
			keyboardInputContext.mapWithAmount(InputType.TRANSLATE_Y, 50, Keyboard.Z);
			keyboardInputContext.mapWithAmount(InputType.TRANSLATE_Y, -50, Keyboard.X);

			addContext(mouseInputContext);
			addContext(keyboardInputContext);
		}
	}
}
