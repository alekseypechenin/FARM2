package Entities
{
	// Namespaces
	import Core.*;
	
	import flash.display.*;
	import flash.events.*;
	
	// Base object of all objects in the game
	public class BaseObject
	{
		// Determines if object was deleted 
		public var inuse:Boolean = false;		
		// Object Z Order
		private var _zOrder:int = 0;
		// Determine whether object is drawing or not 
		public var hidden:Boolean = false;
				
		// Constructor
		public function BaseObject(zOrder:int)
		{
			this.inuse = true;
			this._zOrder = zOrder;
			GameObjectManager.Instance.addBaseObject(this);			
		}	
		// Removes object	
		public function shutdown():void
		{
			if (this.inuse)
			{
				this.inuse = false;
				GameObjectManager.Instance.removeBaseObject(this);
			}
		}
		
		// zOrder property
		//----------------------------
		
		// Get
		public function get zOrder():int
		{
			return this._zOrder
		}
		// Get
		public function set zOrder(value:int):void
		{
			this._zOrder = value;
			GameObjectManager.Instance.refreshObjects();
		}
		
		// Ovveride those methods if yuo want implement functionality fo them
		
		public function enterFrame(dt:Number):void {}		
		public function click(event:MouseEvent):void { }	
		public function mouseDown(event:MouseEvent):void { }		
		public function mouseUp(event:MouseEvent):void { }		
		public function mouseMove(event:MouseEvent):void { }
		public function collision(other:BaseObject):void { }
		public function copyToBackBuffer(db:BitmapData):void { }
	}
}