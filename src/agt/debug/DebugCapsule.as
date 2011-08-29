package agt.debug
{

import away3d.containers.ObjectContainer3D;
import away3d.core.base.Object3D;
import away3d.entities.Mesh;
import away3d.materials.MaterialBase;
import away3d.primitives.Cylinder;
import away3d.primitives.Sphere;

public class DebugCapsule extends ObjectContainer3D
{
	public function DebugCapsule(material:MaterialBase, radius:Number, height:Number)
	{
		super();

		var bottomSphere:Sphere = new Sphere(material, radius);
		bottomSphere.y = -height/2;
		addChild(bottomSphere);

		var topSphere:Mesh = bottomSphere.clone() as Mesh;
		topSphere.y = height/2;
		addChild(topSphere);

		var cylinder:Cylinder = new Cylinder(material, height);
		addChild(cylinder);
	}
}
}
