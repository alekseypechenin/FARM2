package Core
{
	import Entities.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import mx.collections.*;
	import mx.core.*;
	
	import Utils.Config;
	
	// Provides the main functions of application
	public class GameObjectManager
	{
		// double buffer
		public var backBuffer:BitmapData;
		// Server Url Address. Default = 
		public var serverAddress:String;
		// Last errors
		public var lastError:String = null;
		// Default width
		private var width:Number = 640;
		// Default height
		private var height:Number = 480;	
		// colour to use to clear backbuffer with	 
		private var clearColor:uint = 0x000000;
		// static instance 
		protected static var instance:GameObjectManager = null;
		// the last frame time 
		protected var lastFrame:Date;
		// a collection of the BaseObjects 
		protected var baseObjects:ArrayCollection = new ArrayCollection();
		// a collection where new BaseObjects are placed, to avoid adding items 
		// to baseObjects while in the baseObjects collection while it is in a loop
		protected var newBaseObjects:ArrayCollection = new ArrayCollection();
		// a collection where removed BaseObjects are placed, to avoid removing items 
		// to baseObjects while in the baseObjects collection while it is in a loop
		protected var removedBaseObjects:ArrayCollection = new ArrayCollection();
		
		static public function get Instance():GameObjectManager
		{
			if ( instance == null )
			instance = new GameObjectManager();
			return instance;
		}
		
		// Constructor
		public function GameObjectManager()
		{		
			backBuffer = new BitmapData(width, height, false);	
			if ( instance != null )
				throw new Error( "Only one Singleton instance should be instantiated" );		
		}
		
		// Initialezes objects when game was started
		public function startup(serverUrl:String,width:Number, height:Number):void
		{
			this.width = width;
			this.height = height;
			backBuffer = new BitmapData(this.width, this.height, false);		
			lastFrame = new Date();
			serverAddress = serverUrl;
			
			var tiles:TiledBackground = new TiledBackground(width,height);
			
			GivesState.State = GivesState.Potato;	
			CommandState.State = CommandState.None;
			lastError = null;
		}
			
		// Destroyed objects when game was exit	
		public function shutdown():void
		{
			GivesState.State = GivesState.None;
			CommandState.State = CommandState.None;
			shutdownAll();
		}
		
		// Updates objects per frame seconds
		public function enterFrame():void
		{
			// Calculate the time since the last frame
			var thisFrame:Date = new Date();
			var seconds:Number = (thisFrame.getTime() - lastFrame.getTime())/1000.0;
	    	lastFrame = thisFrame;
	    	
	    	removeDeletedBaseObjects();
	    	insertNewBaseObjects();
	    		    	    		    		  
	    	// now allow objects to update themselves
			for each (var gameObject:BaseObject in baseObjects)
				if (gameObject.inuse) 
					gameObject.enterFrame(seconds);
	    	
	    	drawObjects();
		}
		
		// Click event handler for all objects
		public function click(event:MouseEvent):void
		{
			for each (var gameObject:BaseObject in baseObjects)
				if (gameObject.inuse) 
					gameObject.click(event);
		}
		
		// Mouse down event handler for all objects
		public function mouseDown(event:MouseEvent):void
		{
			for each (var gameObject:BaseObject in baseObjects)
				if (gameObject.inuse) 
					gameObject.mouseDown(event);
		}
		
		// Mouse up event handler for all objects
		public function mouseUp(event:MouseEvent):void
		{
			for each (var gameObject:BaseObject in baseObjects)
				if (gameObject.inuse) 
					gameObject.mouseUp(event);
		}
		
		// Mouse move event handler for all objects
		public function mouseMove(event:MouseEvent):void
		{
			for each (var gameObject:BaseObject in baseObjects)
				if (gameObject.inuse) 
					gameObject.mouseMove(event);
		}
		
		// Draws all objects
		protected function drawObjects():void
		{
			backBuffer.fillRect(backBuffer.rect, clearColor);
			
			// draw the objects
			for each (var baseObject:BaseObject in baseObjects)
				if (baseObject.inuse && !baseObject.hidden)
					baseObject.copyToBackBuffer(backBuffer);
		}
				
		// Adds BaseObject into collection of new objects
		public function addBaseObject(baseObject:BaseObject):void
		{
			newBaseObjects.addItem(baseObject);
		}
		
		// Add BaseObject into collection of new removed objects
		public function removeBaseObject(baseObject:BaseObject):void
		{
			removedBaseObjects.addItem(baseObject);
		}
	
		// Refresh objects orders drawing
		public function refreshObjects():void
		{
			var sort:Sort = new Sort();
			var sortByZOrder:SortField = new SortField("zOrder",true,false,true);
			sort.fields = [sortByZOrder];
			baseObjects.sort = sort;
			baseObjects.refresh();	
		}
		
		// Removes all game objects
		protected function shutdownAll():void
		{
			// don't dispose objects twice
			for each (var baseObject:BaseObject in baseObjects)
			{
				var found:Boolean = false;
				for each (var removedObject:BaseObject in removedBaseObjects)
				{
					if (removedObject == baseObject)
					{
						found = true;
						break;
					}
				}
				
				if (!found)
					baseObject.shutdown();
			}
		}
		
		// Insert new base objects
		protected function insertNewBaseObjects():void
		{
			// insert the object acording to it's Z position
			for each (var baseObject:BaseObject in newBaseObjects)
			{
				for (var i:int = 0; i < baseObjects.length; ++i)
				{
					var otherBaseObject:BaseObject = baseObjects.getItemAt(i) as BaseObject;
					
					if (otherBaseObject.zOrder > baseObject.zOrder ||
						otherBaseObject.zOrder == -1)
						break;
				}

				baseObjects.addItemAt(baseObject, i);
			}
			
			newBaseObjects.removeAll();
		}
		
		// Removed base objects that were marked for deleting
		protected function removeDeletedBaseObjects():void
		{			
			for each (var removedObject:BaseObject in removedBaseObjects)
			{
				var i:int = 0;
				for (i = 0; i < baseObjects.length; ++i)
				{
					if (baseObjects.getItemAt(i) == removedObject)
					{
						baseObjects.removeItemAt(i);
						break;
					}
				}
				
			}
			
			removedBaseObjects.removeAll();
		}
	
	}
}