package agt.parsing
{
	import agt.parsing.util.SceneGraphIterator;
	import agt.parsing.vos.RigidBodyVO;
	import agt.parsing.vos.SceneObjectVO;
	import agt.parsing.vos.SpawnPointVO;
	import agt.physics.PhysicsScene3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class GameMapParser extends EventDispatcher
	{
		private var _delegate : IGameMapParserDelegate;
		
		public function GameMapParser(delegate : IGameMapParserDelegate)
		{
			super();
			
			_delegate = delegate;
		}
		
		
		public function parseSceneGraph(container : ObjectContainer3D) : void
		{
			var it : SceneGraphIterator;
			
			it = new SceneGraphIterator(container);
			while (it.hasMore) {
				var obj : ObjectContainer3D;
				var visual : Boolean;
				
				obj = it.next();
				
				if (obj.extra && obj.extra.hasOwnProperty('agt_type')) {
					switch (obj.extra['agt_type']) {
						case 'phys':
							_parsePhysics(obj);
							break;
						
						case 'spawn':
							_parseSpawnPoint(obj);
							break;
						
						case 'pickup':
							break;
					}
				}
				else {
					var scene_vo : SceneObjectVO;
					
					scene_vo = new SceneObjectVO();
					scene_vo.isRoot = (obj.parent == container);
					scene_vo.object = obj;
					_delegate.handleSceneObject(scene_vo);
				}
			}
		}
		
		
		private function _parsePhysics(obj : ObjectContainer3D) : void
		{
			switch (obj.extra['agt_phys_type']) {
				case 'rbody':
					var rbody_vo : RigidBodyVO;
					
					rbody_vo = new RigidBodyVO();
					rbody_vo.shape = RigidBodyVO.SHAPE_TRIMESH;
					rbody_vo.shapeGeometry = Mesh(obj).geometry;
					rbody_vo.x = obj.x;
					rbody_vo.y = obj.y;
					rbody_vo.z = obj.z;
					rbody_vo.mass = parseFloat(obj.extra['agt_phys_rbody_mass']);
					rbody_vo.friction = parseFloat(obj.extra['agt_phys_rbody_friction']);
					
					_delegate.handleRigidBody(rbody_vo);
					break;
			}
		}
		
		
		private function _parseSpawnPoint(obj : ObjectContainer3D) : void
		{
			var spawn_vo : SpawnPointVO;
			
			spawn_vo = new SpawnPointVO();
			spawn_vo.x = obj.x;
			spawn_vo.y = obj.y;
			spawn_vo.z = obj.z;
			spawn_vo.spawnType = obj.extra['agt_spawn_type'];
			
			_delegate.handleSpawnPoint(spawn_vo);
		}
	}
}


