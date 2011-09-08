package agt.debug
{

	import away3d.library.AssetLibrary;
	import away3d.library.utils.AssetLibraryIterator;

	public class DebugAssetLibrary
	{
		public static function traceAssetNames():void
		{
			var iterator:AssetLibraryIterator = AssetLibrary.createIterator();
			for(var i:uint; i < iterator.numAssets; ++i)
			{
				trace("asset: " + iterator.currentAsset.name);
				iterator.next();
			}
		}
	}
}
