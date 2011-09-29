package agt.parsing.util
{
	import away3d.containers.ObjectContainer3D;

	public class SceneGraphIterator
	{
		private var _cur_idx : uint;
		private var _flat_list : Vector.<ObjectContainer3D>;
		
		public function SceneGraphIterator(container : ObjectContainer3D)
		{
			_flat_list = new Vector.<ObjectContainer3D>;
			_flatten(container);
			_cur_idx = 0;
		}
		
		
		public function get hasMore() : Boolean
		{
			return _cur_idx < _flat_list.length;
		}
		
		
		public function next() : ObjectContainer3D
		{
			return (_cur_idx<_flat_list.length)? _flat_list[_cur_idx++] : null;
		}
		
		
		private function _flatten(ctr : ObjectContainer3D) : void
		{
			var i : uint;
			
			for (i=0; i<ctr.numChildren; i++) {
				_flatten(ctr.getChildAt(i));
			}
			
			_flat_list.push(ctr);
		}
	}
}