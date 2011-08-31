package agt.controllers.camera
{

import agt.input.InputContext;
import agt.input.events.InputEvent;

import away3d.containers.ObjectContainer3D;

import flash.geom.Vector3D;

public class OrbitCameraController extends CameraControllerBase
{
	private var _target:ObjectContainer3D;
	private var _targetSphericalCoordinates:Vector3D;
	private var _currentSphericalCoordinates:Vector3D;

	private var _minElevation:Number = -Math.PI/2;
	private var _maxElevation:Number = Math.PI/2;
	private var _minRadius:Number = 0;
	private var _maxRadius:Number = Number.MAX_VALUE;

	public function OrbitCameraController(camera:ObjectContainer3D, target:ObjectContainer3D = null)
	{
		this.target = target || new ObjectContainer3D();
		super(camera);
	}

	override public function set inputContext(context:InputContext):void
	{
		super.inputContext = context;
		registerEvent(InputEvent.MOVE_Z, moveRadius);
		registerEvent(InputEvent.MOVE_X, moveAzimuth);
		registerEvent(InputEvent.MOVE_Y, moveElevation);
		registerEvent(InputEvent.ROTATE_Y, moveAzimuth);
		registerEvent(InputEvent.ROTATE_X, moveElevation);
	}

	override public function update():void
	{
		super.update();

		_targetSphericalCoordinates.y = containValue(_targetSphericalCoordinates.y, _minElevation, _maxElevation);
		_targetSphericalCoordinates.z = containValue(_targetSphericalCoordinates.z, _minRadius, _maxRadius);

		// ease spherical position
		var dx:Number = _targetSphericalCoordinates.x - _currentSphericalCoordinates.x;
		var dy:Number = _targetSphericalCoordinates.y - _currentSphericalCoordinates.y;
		var dz:Number = _targetSphericalCoordinates.z - _currentSphericalCoordinates.z;
		_currentSphericalCoordinates.x += dx*angularEase;
		_currentSphericalCoordinates.y += dy*angularEase;
		_currentSphericalCoordinates.z += dz*linearEase;
		_camera.position = sphericalToCartesian(_currentSphericalCoordinates);
		_camera.lookAt(_target.position);
	}

	public function moveAzimuth(amount:Number):void
	{
		_targetSphericalCoordinates.x -= amount*0.001;
	}

	public function moveElevation(amount:Number):void
	{
		_targetSphericalCoordinates.y -= amount*0.001;
	}

	public function moveRadius(amount:Number):void
	{
		_targetSphericalCoordinates.z -= amount;
	}

	private function containValue(value:Number, min:Number, max:Number):Number
	{
		if(value < min)
			return min;
		else if(value > max)
			return max;
		else
			return value;
	}

	public function get target():ObjectContainer3D
	{
		return _target;
	}

	public function set target(value:ObjectContainer3D):void
	{
		_target = value;
	}

	override public function set camera(value:ObjectContainer3D):void
	{
		super.camera = value;
		_targetSphericalCoordinates = cartesianToSpherical(_camera.position);
		_currentSphericalCoordinates = _targetSphericalCoordinates.clone();
	}

	private function sphericalToCartesian(sphericalCoords:Vector3D):Vector3D
	{
		var cartesianCoords:Vector3D = new Vector3D();
		var r:Number = sphericalCoords.z;
		cartesianCoords.y = _target.y + r*Math.sin(-sphericalCoords.y);
		var cosE:Number = Math.cos(-sphericalCoords.y);
		cartesianCoords.x = _target.x + r*cosE*Math.sin(sphericalCoords.x);
		cartesianCoords.z = _target.z + r*cosE*Math.cos(sphericalCoords.x);
		return cartesianCoords;
	}

	private function cartesianToSpherical(cartesianCoords:Vector3D):Vector3D
	{
		var cartesianFromCenter:Vector3D = new Vector3D();
		cartesianFromCenter.x = cartesianCoords.x - _target.x;
		cartesianFromCenter.y = cartesianCoords.y - _target.y;
		cartesianFromCenter.z = cartesianCoords.z - _target.z;
		var sphericalCoords:Vector3D = new Vector3D();
		sphericalCoords.z = cartesianFromCenter.length;
		sphericalCoords.x = Math.atan2(cartesianFromCenter.x, cartesianFromCenter.z);
		sphericalCoords.y = -Math.asin((cartesianFromCenter.y)/sphericalCoords.z);
		return sphericalCoords;
	}

	public function get minElevation():Number
	{
		return _minElevation;
	}

	public function set minElevation(value:Number):void
	{
		_minElevation = value;
	}

	public function get maxElevation():Number
	{
		return _maxElevation;
	}

	public function set maxElevation(value:Number):void
	{
		_maxElevation = value;
	}

	public function get maxRadius():Number
	{
		return _maxRadius;
	}

	public function set maxRadius(value:Number):void
	{
		_maxRadius = value;
	}

	public function get minRadius():Number
	{
		return _minRadius;
	}

	public function set minRadius(value:Number):void
	{
		_minRadius = value;
	}
}
}
