package age.input
{

import age.input.data.MouseActions;
import age.input.events.InputEvent;

import flash.display.Sprite;
import flash.display.Stage;
import flash.ui.Keyboard;

public class WASDAndMouseInputContext extends CompositeInputContext
{
	public var keyboardContext:KeyboardInputContext;
	public var mouseContext:MouseInputContext;

	public function WASDAndMouseInputContext(stage:Stage, display:Sprite, linearSpeed:Number, mouseInputFactorX:Number = 1, mouseInputFactorY:Number = 1)
	{
		super();

		keyboardContext = new KeyboardInputContext(stage);
		keyboardContext.map(Keyboard.W, new InputEvent(InputEvent.MOVE_Z, linearSpeed));
		keyboardContext.map(Keyboard.S, new InputEvent(InputEvent.MOVE_Z, -linearSpeed));
		keyboardContext.map(Keyboard.A, new InputEvent(InputEvent.MOVE_X, -linearSpeed));
		keyboardContext.map(Keyboard.D, new InputEvent(InputEvent.MOVE_X, linearSpeed));
		keyboardContext.map(Keyboard.UP, new InputEvent(InputEvent.MOVE_Z, linearSpeed), false);
		keyboardContext.map(Keyboard.DOWN, new InputEvent(InputEvent.MOVE_Z, -linearSpeed), false);
		keyboardContext.map(Keyboard.LEFT, new InputEvent(InputEvent.MOVE_X, -linearSpeed), false);
		keyboardContext.map(Keyboard.RIGHT, new InputEvent(InputEvent.MOVE_X, linearSpeed), false);
		keyboardContext.map(Keyboard.Z, new InputEvent(InputEvent.MOVE_Y, -linearSpeed));
		keyboardContext.map(Keyboard.X, new InputEvent(InputEvent.MOVE_Y, linearSpeed));
		keyboardContext.mapMultiplier(Keyboard.SHIFT, 4);

		mouseContext = new MouseInputContext(display);
		mouseContext.map(MouseActions.DRAG_X, new InputEvent(InputEvent.ROTATE_Y));
		mouseContext.map(MouseActions.DRAG_Y, new InputEvent(InputEvent.ROTATE_X));
		mouseContext.mouseInputFactorX = mouseInputFactorX;
		mouseContext.mouseInputFactorY = mouseInputFactorY;

		addContext(keyboardContext);
		addContext(mouseContext);
	}
}
}
