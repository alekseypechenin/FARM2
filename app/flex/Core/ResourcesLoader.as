package Core
{
	// Namespaces
	import Entities.GameObject;
	
	import Utils.GraphicsResource;
	
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	
	// Represents logic that allows to communicate with Server and obtain image data
	// It is wrapper of URLLoader object with additionally functions 
	public class ResourcesLoader
	{
		// Keep already loaded object
		static public var resourcePool:Dictionary = new Dictionary;
		// Keep stack of objects that want to load image that currently is loading
		static public var loadersStack:ArrayCollection = new ArrayCollection;
		// Keep stack of resource names that currently was triggred
		static public var resourceStack:Dictionary = new Dictionary;
		
		// Callback for result Handler
		public var securityErrorHandler:Function;
		
		// Callback for ioError Handler
		public var ioErrorHandler:Function;
		
		// Represent image resource name
		public var resourceName:String = null;
		
		// URLLoader object. Helps our to obtains image data.
		private var loader:URLLoader = new URLLoader();
		
		// Request url query. = Server URL + Image resource name
		private var requestURL:String = null;
		
		// Loader object. Help our to load data to image from byte array.
		private var loaderImage:Loader = null;
		
		// Represents target game object. For this object image should be loaded.
		private var gameObject: GameObject = null;
		
		// Constructor
		public function ResourcesLoader(requestServerURL:String,gameObject:GameObject)
		{ 
			this.gameObject = gameObject;
			this.requestURL = requestServerURL;
			this.loader.dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		// Load image by image name if it needed, or just returned alredy loaded image by name		
		public function load(resourceName:String):void
		{
			this.configureListeners(loader);
			this.resourceName = resourceName;
			
			if (resourcePool[resourceName] != null)
			{
				this.gameObject.graphics = resourcePool[resourceName];
				return;
			} 
			
			if (resourceStack[resourceName] != null)
			{
				loadersStack.addItem(this);
				return;
			}
			
			resourceStack[resourceName] = true;
			
			this.loader.load(new URLRequest(configureURL(resourceName)));
		}
	
		// Load images that in the stack
		public static function clearStack():void
		{
			if (loadersStack.length > 0)
			{
				var needCheck:Boolean = true;
				while (needCheck)
				{
					needCheck = false;
					var i:int;
					for (i=0; i<loadersStack.length; i++)
					{
						var loaders:ResourcesLoader = loadersStack[i] as ResourcesLoader;
						
						if (loaders != null && resourcePool[loaders.resourceName] != null)
						{
							// Founded!!!
							needCheck = true;
							loaders.gameObject.graphics = resourcePool[loaders.resourceName];
							loadersStack.removeItemAt(i);
							break;
						}
					}
				}
			}
		}
	
		// Returns request URL = Server URL + Image resource name
		private function configureURL(resourceName:String):String
		{
			return requestURL + resourceName;
		}
		
		// Add listeners for URLLoader object
		private function configureListeners(dispatcher:IEventDispatcher):void 
		{
           dispatcher.addEventListener(Event.COMPLETE, 
           		completeHandler);
           
           if (securityErrorHandler != null)
           dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
           if (ioErrorHandler != null)
           dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
        
        private function completeHandler(event:Event):void
        {
        	
            trace(this + "completeHandler: " + loader.data);
            
            loaderImage = new Loader();
            loaderImage.loadBytes(loader.data);
            loaderImage.contentLoaderInfo.addEventListener(Event.COMPLETE, finishLoader);  
        }
        
        // Occures when all bytes were loaded to Loader object
        private function finishLoader(event:Event):void 
      	{
			resourcePool[resourceName] = new GraphicsResource(loaderImage);
            this.gameObject.graphics = resourcePool[resourceName];
		}
	}
}