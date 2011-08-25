package age.camera.controllers
{

public class DebugCameraController extends CameraControllerBase
{
	public var linearKeyboardSpeed:Number = 100; // determines how fast the camera moves on keyboard input
	public var angularMouseFactor:Number = 0.25; // determines how much the camera's rotation reacts to mouse motion

	public function DebugCameraController()
	{
		super();
	}

	override public function update():void
	{
		// update target orientation
		if(_mouseIsDown)
        {
            var dx:Number = _mousePositionCurrent.x - _mousePositionLast.x; // calculate rotation from mouse deltas
            var dy:Number = _mousePositionCurrent.y - _mousePositionLast.y;
			_cameraDummy.rotationY += dx * angularMouseFactor;
			_cameraDummy.rotationX += dy * angularMouseFactor;
            storeMousePosition();
        }

		// keys
		if(_key.keyIsDown(_key.RIGHT) || _key.keyIsDown(_key.D))
		{
			_cameraDummy.moveRight(linearKeyboardSpeed);
		}
		else if(_key.keyIsDown(_key.LEFT) || _key.keyIsDown(_key.A))
		{
			_cameraDummy.moveLeft(linearKeyboardSpeed);
		}
		if(_key.keyIsDown(_key.UP) || _key.keyIsDown(_key.W))
		{
			_cameraDummy.moveForward(linearKeyboardSpeed);
		}
		else if(_key.keyIsDown(_key.DOWN) || _key.keyIsDown(_key.S))
		{
			_cameraDummy.moveBackward(linearKeyboardSpeed);
		}
		if(_key.keyIsDown(_key.Z))
		{
			_cameraDummy.moveUp(linearKeyboardSpeed);
		}
		else if(_key.keyIsDown(_key.X))
		{
			_cameraDummy.moveDown(linearKeyboardSpeed);
		}

		super.update();
	}
}
}
