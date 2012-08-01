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

		public function DefaultMouseKeyboardInputContext( context:Sprite, stage:Stage, translationAmount:Number = 25, rotationAmount:Number = 10 ) {
			super();

			// mouse input
			mouseInputContext = new MouseInputContext( context, stage );
			mouseInputContext.dragXMultiplier = -rotationAmount;
			mouseInputContext.dragYMultiplier =  rotationAmount;

			// keyboard input
			keyboardInputContext = new KeyboardInputContext( stage );
			keyboardInputContext.mapWithAmount( InputType.TRANSLATE_X,  translationAmount, Keyboard.D );
			keyboardInputContext.mapWithAmount( InputType.TRANSLATE_X, -translationAmount, Keyboard.A );
			keyboardInputContext.mapWithAmount( InputType.TRANSLATE_Z,  translationAmount, Keyboard.W );
			keyboardInputContext.mapWithAmount( InputType.TRANSLATE_Z, -translationAmount, Keyboard.S );
			keyboardInputContext.mapWithAmount( InputType.TRANSLATE_Y,  translationAmount, Keyboard.X );
			keyboardInputContext.mapWithAmount( InputType.TRANSLATE_Y, -translationAmount, Keyboard.Z );

			addContext( mouseInputContext );
			addContext( keyboardInputContext );
		}
	}
}
