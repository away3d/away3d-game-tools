package agt.parsing.vos
{
	import away3d.core.base.Geometry;

	public class RigidBodyVO extends GameMapVOBase
	{
		public static const SHAPE_TRIMESH : String = 'trimesh';
		
		public var shape : String;
		
		public var x : Number;
		public var y : Number;
		public var z : Number;
		
		public var shapeGeometry : Geometry;
		
		public var mass : Number;
		public var friction : Number;
		
		
		public function RigidBodyVO()
		{
			type = TYPE_RIGID_BODY;
			super();
		}
	}
}