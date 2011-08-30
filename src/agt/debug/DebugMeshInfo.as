package agt.debug
{

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
}
}
