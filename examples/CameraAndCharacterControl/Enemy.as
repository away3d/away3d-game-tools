package CameraAndCharacterControl
{

	import agt.input.ai.AIStupidInputContext;
	import agt.physics.PhysicsScene3D;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.entities.Mesh;

	import flash.geom.Vector3D;

	public class Enemy extends HellKnight
	{
		public var inputContext:AIStupidInputContext;

		public function Enemy(mesh:Mesh, scene:PhysicsScene3D, idleAnimation:SkeletonAnimationSequence, walkAnimation:SkeletonAnimationSequence)
		{
		 	super(mesh, scene, idleAnimation, walkAnimation);

			inputContext = new AIStupidInputContext();
			controller.inputContext = inputContext;
		}

		public function update():void
		{
			controller.update();

			if(entity.container.y < -5000)
				entity.position = new Vector3D(0, 2000, 0);
		}
	}
}
