package
agt.utils{

	import agt.controllers.entities.character.AnimatedCharacterEntityController;
	import agt.physics.entities.CharacterEntity;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;

	import away3d.entities.Mesh;

	import flash.geom.Vector3D;

	public class SimpleGameCharacter
	{
		public var baseMesh:Mesh;
		public var entity:CharacterEntity;
		public var controller:AnimatedCharacterEntityController;
		public var skin:Mesh;

		public function SimpleGameCharacter(mesh:Mesh, 
									  idleAnimation:SkeletonAnimationSequence, 
									  walkAnimation:SkeletonAnimationSequence, 
									  runAnimation:SkeletonAnimationSequence, 
									  animationCrossFadeTime:Number = 0.25,
									  runSpeedThreshold:Number = 3, 
									  speedFactor : Number = 1.2)
		{
			// get mesh and wrap it to apply transform offsets
			this.baseMesh = mesh;
			var middleMesh:Mesh = new Mesh();
			middleMesh.scale(12);
			middleMesh.rotationY = 180;
			middleMesh.position = new Vector3D(0, -63, 0);
			middleMesh.addChild(mesh);
			skin = new Mesh();
			skin.addChild(middleMesh);

			// setup entity
			var width:Number = (mesh.maxX - mesh.minX) * middleMesh.scaleX;
			var height:Number = (mesh.maxY - mesh.minY) * middleMesh.scaleX;
			entity = new CharacterEntity(width, height * 0.01);
			entity.skin = skin;
			entity.characterController.jumpSpeed = 500;

			// animation and motion controller
			controller = new AnimatedCharacterEntityController(entity, mesh.animationState as SkeletonAnimationState);
			controller.addAnimationSequence(idleAnimation);
			controller.addAnimationSequence(walkAnimation);
			controller.addAnimationSequence(runAnimation);
			controller.idleAnimationName = idleAnimation.name;
			controller.walkAnimationName = walkAnimation.name;
			controller.runAnimationName = runAnimation.name;
			controller.animationCrossFadeTime = animationCrossFadeTime;
			controller.runSpeedThreshold = runSpeedThreshold;
			controller.speedFactor = speedFactor;
		}
	}
}
