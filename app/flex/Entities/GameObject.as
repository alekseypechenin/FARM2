package Entities
{
	// Namespaces
	import Utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	/*
		The base class for all objects in the game.
	*/
	public class GameObject extends BaseObject
	{
		// object position
		public var position:Point = new Point(0, 0);
		// Determines if object is dragged
		public var onDragged:Boolean = false;
		// the bitmap data to display	
		private var _graphics:GraphicsResource = null;
		// World tile layer.
	    private var tiledBackground:TiledBackground = null;
	    // Constructor
		public function GameObject(tiledBackground:TiledBackground,position:Point, zOrder:int = 0)		{
			super(zOrder);
			inuse = false;
			this.tiledBackground = tiledBackground;	
			this.position = position.clone();									
		}
		
		// Graphics property
		//----------------------------
			
		// Set
		public function set graphics(value:GraphicsResource):void
		{
			if (value != null)
			{
				inuse = true;
				this._graphics = value;
				InitializeComplited();
			}
		}
		// Get
		public function get graphics():GraphicsResource
		{
			return this._graphics;
		} 
		
		// Override methods
		//----------------------------
			
		
		// Removes object
		override public function shutdown():void
		{
			if (inuse)
			{				
				super.shutdown();
				_graphics = null;							
			}
		} 
		// Draws object
		override public function copyToBackBuffer(db:BitmapData):void
		{		
			var screenPos:Point = tiledBackground.getObjectScreenPosition(new Point(position.x,position.y));			
			var screenPosInAccordanceWithHeigh: Point = new Point(
				 screenPos.x ,
				 screenPos.y - (this.graphics.drawRect.height - tiledBackground.maxObjectHeight));
			if (!onDragged)
			{				
				db.copyPixels(graphics.bitmap, graphics.bitmap.rect, screenPosInAccordanceWithHeigh, graphics.bitmapAlpha, new Point(0, 0), true);
			}
			else
			{
				db.copyPixels(graphics.bitmap, graphics.bitmap.rect, screenPosInAccordanceWithHeigh, graphics.draggingBitmapAlpha, new Point(0, 0), true);
			}
		}	

		// Ovveride this method if you want to implement functionality to it
		public function InitializeComplited():void { }				
			
	}
}