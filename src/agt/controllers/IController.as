/**
 * Created by Li using IntelliJ IDEA.
 * Date: 9/7/11
 */
package agt.controllers
{

	import agt.input.IInputContext;

	public interface IController
	{
		function update():void;
		function get inputContext():IInputContext;
		function set inputContext(context:IInputContext):void;
	}
}
