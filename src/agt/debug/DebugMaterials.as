package agt.debug
{

import away3d.materials.ColorMaterial;

public class DebugMaterials
{
	private static var _instance:DebugMaterials;

	private var _lights:Array;
	private var _redMaterial:ColorMaterial;

	public function DebugMaterials()
	{
	}

	public static function get instance():DebugMaterials
	{
		if(!_instance)
			_instance = new DebugMaterials();
		return _instance;
	}

	public function set lights(value:Array):void
	{
		_lights = value;
	}

	public function get redMaterial():ColorMaterial
	{
		if(!_redMaterial)
		{
			_redMaterial = new ColorMaterial(0xFF0000);

			if(_lights)
				_redMaterial.lights = _lights;
		}

		return _redMaterial;
	}
}
}
