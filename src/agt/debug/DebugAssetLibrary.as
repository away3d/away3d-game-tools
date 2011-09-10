package agt.debug
{

	import away3d.library.AssetLibrary;
	import away3d.library.utils.AssetLibraryIterator;

	public class DebugAssetLibrary
	{
		public static function traceAssetNames():void
		{
			trace("Current assets in library:");
			var iterator:AssetLibraryIterator = AssetLibrary.createIterator();
			for(var i:uint; i < iterator.numAssets; ++i)
			{
				trace("asset - name: " + iterator.currentAsset.name + ", type: " + iterator.currentAsset.assetType);
				iterator.next();
			}
		}
	}
}
