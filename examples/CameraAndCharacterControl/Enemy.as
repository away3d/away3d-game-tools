package CameraAndCharacterControl
{

	import agt.input.ai.StupidInputContext;
	import agt.physics.PhysicsScene3D;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.entities.Mesh;

	public class Enemy extends HellKnight
	{
		public var inputContext:StupidInputContext;

		public function Enemy(mesh:Mesh, scene:PhysicsScene3D, idleAnimation:SkeletonAnimationSequence, walkAnimation:SkeletonAnimationSequence)
		{
		 	super(mesh, scene, idleAnimation, walkAnimation);

			inputContext = new StupidInputContext();
			controller.inputContext = inputContext;
		}

		public function update():void
		{
			controller.update();
		}
	}
}
