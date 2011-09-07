/**
 * Created by Li using IntelliJ IDEA.
 * Date: 9/7/11
 */
package agt.input
{

	public interface IInputContext
	{
		function update():void;

		/**
		 * Defines whether this input context implements a certain input type,
		 * e.g. a WASD controller would likely return true on all the TRANSLATE
		 * input types, but not on the ROTATE ones.
		 */
		function inputImplemented(inputType:String):Boolean;

		/**
		 * Returns whether the current state (since last update()) for a certain
		 * event type is active, e.g. whether a key is down.
		 */
		function inputActive(inputType:String):Boolean;

		/**
		 * Returns the amount/strength of a certain input type at the current
		 * moment in time (since last update()).
		 */
		function inputAmount(inputType:String):Number;
	}
}
