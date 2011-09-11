package agt.debug
{

	import away3d.library.AssetLibrary;
	import away3d.library.assets.IAsset;
	import away3d.library.utils.AssetLibraryIterator;

	public class DebugAssetLibrary
	{
		public static function traceAssetNames():void
		{
			trace("Current assets in library:");
			var iterator:AssetLibraryIterator = AssetLibrary.createIterator();
			var asset:IAsset;
			for(var i:uint; i < iterator.numAssets; ++i)
			{
				asset = iterator.currentAsset;
				trace("asset - name: " + asset.name + ", type: " + asset.assetType);
				iterator.next();
			}
		}
	}
}
