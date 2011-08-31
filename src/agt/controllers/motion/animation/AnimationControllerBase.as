package agt.controllers.motion.animation {
	import agt.controllers.ControllerBase;

	import away3d.animators.SmoothSkeletonAnimator;
	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.entities.Mesh;

	public class AnimationControllerBase extends ControllerBase {
		protected var _mesh : Mesh;
		protected var _animator : SmoothSkeletonAnimator;

		public function AnimationControllerBase(mesh : Mesh) {
			_mesh = mesh;
			_animator = new SmoothSkeletonAnimator(SkeletonAnimationState(mesh.animationState));
			_animator.updateRootPosition = false;
			super();
		}

		public function addAnimationSequence(sequence : SkeletonAnimationSequence) : void {
			_animator.addSequence(sequence);
		}
	}
}
