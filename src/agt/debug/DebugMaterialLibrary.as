package agt.debug {
	import away3d.materials.ColorMaterial;

	public class DebugMaterialLibrary {
		private static var _instance : DebugMaterialLibrary;
		private var _lights : Array;
		private var _redMaterial : ColorMaterial;
		private var _greenMaterial : ColorMaterial;
		private var _blueMaterial : ColorMaterial;
		private var _whiteMaterial : ColorMaterial;

		public function DebugMaterialLibrary() {
		}

		public static function get instance() : DebugMaterialLibrary {
			if (!_instance)
				_instance = new DebugMaterialLibrary();
			return _instance;
		}

		public function set lights(value : Array) : void {
			_lights = value;
		}

		public function get redMaterial() : ColorMaterial {
			if (!_redMaterial) {
				_redMaterial = new ColorMaterial(0xFF0000);

				if (_lights)
					_redMaterial.lights = _lights;
			}
			return _redMaterial;
		}

		public function get greenMaterial() : ColorMaterial {
			if (!_greenMaterial) {
				_greenMaterial = new ColorMaterial(0x00FF00);

				if (_lights)
					_greenMaterial.lights = _lights;
			}
			return _greenMaterial;
		}

		public function get blueMaterial() : ColorMaterial {
			if (!_blueMaterial) {
				_blueMaterial = new ColorMaterial(0x0000FF);

				if (_lights)
					_blueMaterial.lights = _lights;
			}
			return _blueMaterial;
		}

		public function get whiteMaterial() : ColorMaterial {
			if (!_whiteMaterial) {
				_whiteMaterial = new ColorMaterial(0xFFFFFF);

				if (_lights)
					_whiteMaterial.lights = _lights;
			}
			return _whiteMaterial;
		}
	}
}
