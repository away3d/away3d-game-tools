package agt.parsing.vos
{
	import away3d.containers.ObjectContainer3D;

	public class SceneObjectVO extends GameMapVOBase
	{
		public var isRoot : Boolean;
		public var object : ObjectContainer3D;
		
		public function SceneObjectVO()
		{
			super();
			
			type = TYPE_SCENE;
		}
	}
}