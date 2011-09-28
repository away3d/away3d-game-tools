package agt.input.contexts
{

	import agt.input.CompositeInputContext;
	import agt.input.data.InputType;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.ui.Keyboard;

	public class DefaultMouseKeyboardInputContext extends CompositeInputContext
	{
		public function DefaultMouseKeyboardInputContext(context:Sprite, stage:Stage)
		{
			super();

			// mouse input
			var mouseInput:MouseInputContext = new MouseInputContext(context, stage);

			// keyboard input
			var keyboardInput:KeyboardInputContext = new KeyboardInputContext(stage);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_X, 50, Keyboard.RIGHT);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_X, -50, Keyboard.LEFT);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Z, 50, Keyboard.UP);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Z, -50, Keyboard.DOWN);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Y, 50, Keyboard.Z);
			keyboardInput.mapWithAmount(InputType.TRANSLATE_Y, -50, Keyboard.X);

			addContext(mouseInput);
			addContext(keyboardInput);
		}
	}
}
