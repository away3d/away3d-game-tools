package CameraAndCharacterControl
{

	import agt.controllers.entities.character.AnimatedCharacterEntityController;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.CharacterEntity;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.entities.Mesh;

	public class HellKnight
	{
		public var baseMesh:Mesh;
		public var entity:CharacterEntity;
		public var controller:AnimatedCharacterEntityController;

		public function HellKnight(mesh:Mesh, scene:PhysicsScene3D, idleAnimation:SkeletonAnimationSequence, walkAnimation:SkeletonAnimationSequence)
		{
			// get mesh
			baseMesh = mesh;
			// transform is controlled by animator
			var middleMesh:Mesh = new Mesh();
			middleMesh.rotationY = -180;
			middleMesh.scale(6);
			middleMesh.moveTo(0, -400, 20);
			middleMesh.addChild(baseMesh);
			var playerMesh:Mesh = new Mesh();
			// transform is controlled by AWP
			playerMesh.addChild(middleMesh); // TODO: Can simplify hierarchy here?

			// setup player
			entity = new CharacterEntity(playerMesh, 150, 500);
			entity.character.jumpSpeed = 2000;
			scene.addCharacterEntity(entity);

			// player controller
			controller = new AnimatedCharacterEntityController(entity, baseMesh);
			controller.addAnimationSequence(walkAnimation); // TODO: Map animations to actions too?
			controller.addAnimationSequence(idleAnimation);
			controller.stop();
			controller.speedEase = 0.1;
			controller.animatorTimeScaleFactor = 0.05;
		}
	}
}
