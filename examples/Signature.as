package
{

	import flash.display.Sprite;
	import flash.text.TextField;

	public class Signature extends Sprite
	{
		[Embed(source="assets/fla/Signature.swf", symbol="Signature")]
		private var SignatureAsset:Class;

		private var _signature:Sprite;
		private var _signatureLabel:TextField;

		public function Signature()
		{
			// init signature
			_signature = new SignatureAsset() as Sprite;
			_signatureLabel = _signature.getChildByName("label") as TextField;
			_signatureLabel.text = "AwayGameTools example.";
			_signatureLabel.selectable = false;
			_signatureLabel.multiline = false;
			_signatureLabel.height = 22;
			addChild(_signature);
		}

		public function set text(value:String):void
		{
			_signatureLabel.text = value;
			_signatureLabel.width = _signatureLabel.textWidth + 10;
		}
	}
}
