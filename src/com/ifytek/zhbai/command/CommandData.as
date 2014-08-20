package com.ifytek.zhbai.command 
{
	/**
	 * ...
	 * @author 柏梓涵
	 */
	public class CommandData 
	{
		public var func:Function;
		public var x:int;
		public var y:int;
		public function CommandData(func:Function,x:int,y:int) 
		{
			this.func = func;
			this.x = x;
			this.y = y;
		}
	}

}