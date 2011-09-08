package agt.debug
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;

	public class DebugMeshInfo
	{
		public static function traceMeshBounds(mesh:Mesh):void
		{
			var width:Number = mesh.maxX - mesh.minX;
			var height:Number = mesh.maxY - mesh.minY;
			var depth:Number = mesh.maxZ - mesh.minZ;

			trace("DebugMesh.as - mesh dimensions: " + width + ", " + height + ", " + depth);
		}

		public static function traceObjectHierarchy(obj:ObjectContainer3D, offset:String = ""):void
		{
			if(!(obj is ObjectContainer3D))
				return;

			var numChildren:uint = obj.numChildren;
			trace(offset + "object: " + obj.name + ", children: " + numChildren);
			for(var i:uint; i < numChildren; ++i)
			{
				var child:Mesh = obj.getChildAt(i) as Mesh;
				traceObjectHierarchy(child, offset + ">");
			}
		}
	}
}
