package agt.parsing
{
	import agt.parsing.vos.RigidBodyVO;
	import agt.parsing.vos.SceneObjectVO;
	import agt.parsing.vos.SpawnPointVO;

	public interface IGameMapParserDelegate
	{
		function handleSpawnPoint(vo : SpawnPointVO) : void;
		function handleSceneObject(vo : SceneObjectVO) : void;
		function handleRigidBody(vo : RigidBodyVO) : void;
	}
}