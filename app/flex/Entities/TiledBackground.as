package Entities
{
	// Namespaces
	import Core.*;
	
	import Utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import mx.collections.*;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.*;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	// Crates main landshaft
	public class TiledBackground extends GameObject
	{
		// Field size attributes
		public const maxObjectWidth:int = 100;
		public const maxObjectHeight:int = 54;
	
		// MaxOffsets
		public var xMaxOffset:Number = 0;
		public var yMaxOffset:Number = 0;		
		// Background Offsets		
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;		
		// Resource pool of Fields object
		public var fieldsObjects:ArrayCollection = new ArrayCollection();

		// Offset field attributes. Determines global objects offset in accordance with background
		private const objectsGlobalOffsetX:int = -5;
		private const objectsGlobalOffsetY:int = 22;
		
		// Max size of 'Field' objects array
		private const maxMatrixX:int = 15;
		private const maxMatrixY:int = 27
		
		// Matrix coordinates that is determined by Mouse Pointer. Default = undefined
		private var globalMatrixPosition: Point = new Point(-1,-1);		
			
		// Request manager. Allows to call HTTP request
		private var requestManager:RequestManager = null;
				
		// The background moving feature variables 	
		private var prevMousePoint: Point = null;
		private var wasMoving:Boolean = false;
		
		// Mouse Pointer 
		private var mousePointer: GameObject = null;
		// Mouse Pointer Drag and drop
		private var mouseDragAndDropObject: GameObject = null;
		
		// Size of background
		private var width:Number;
		private var height:Number;
				
		// Constructor	
		public function TiledBackground(width:Number,height:Number)
		{
			super(this, new Point(0,0),ZOrders.BACKGROUNDZORDER);
			this.width = width;
			this.height = height;
			
			var loadManager:ResourcesLoader = new ResourcesLoader(GameObjectManager.Instance.serverAddress,this);
			loadManager.securityErrorHandler = securityErrorHandler;
			loadManager.ioErrorHandler = ioErrorHandler;		
			loadManager.load(ResourceManager.BackGroundID1);
		}
		
		// 'Logic' methods
		//----------------------------
				
		// Update fields in accordance with new XML data
		public function updateFieldObjects(fieldsData: XMLList):void
		{		
			var field:FieldObject;
			var fieldData:XML;
			
			for each (fieldData in fieldsData) 
			{
				var fieldPosition:Point = new Point(Number(fieldData.x),Number(fieldData.y))
				var needLoadResouce:Boolean = false;
				
				// Debug information
				trace(fieldData.x,fieldData.y,fieldData.ftype,fieldData.fstate);
				
				field = getFieldObjectsByID(fieldData.id);
				
				if (field == null)
				{
					needLoadResouce = true;
					field = new FieldObject(
								this,
								fieldPosition,
								getZOrder(fieldPosition),
								fieldData.id,
								fieldData.ftype,
								fieldData.fstate)
					fieldsObjects.addItem(field);
				}
				else 
				{
					if (field.state != fieldData.fstate)
					{
						needLoadResouce = true;
						field.state = fieldData.fstate;
					}
					field.position = fieldPosition;
					field.zOrder = getZOrder(fieldPosition);
				}
				
				if (needLoadResouce)
				{		
					var loadManager:ResourcesLoader = new ResourcesLoader(GameObjectManager.Instance.serverAddress,field);
					loadManager.securityErrorHandler = securityErrorHandler;
					loadManager.ioErrorHandler = ioErrorHandler;		
					loadManager.load(ResourceManager.getResourceFromPool(fieldData.ftype,fieldData.fstate));
				}
			}		
		}
								
		// Delete unusable object
		public function deleteUnusableFieldObject(removedField: FieldObject):void
		{
			var i:int = 0;
			var field:FieldObject;	
			for (i = 0; i < fieldsObjects.length; ++i)
			{
				field = FieldObject(fieldsObjects.getItemAt(i));
				if (field.id == removedField.id)
				{
					field.shutdown();
					fieldsObjects.removeItemAt(i);
					break;
				}
			}
		}
		
		// Get field object in accordance with matrixPosition or its ID value
		public function getFieldObjects(matrixPosition: Point): FieldObject
		{
			var fieldObject:FieldObject;
			for each (fieldObject in fieldsObjects)
			{
				if (fieldObject.position.x == matrixPosition.x
					&& fieldObject.position.y == matrixPosition.y)
				{
					return fieldObject;
				}
			} 
			return null;
		}
		
		// Get field object in accordance Field ID value
		public function getFieldObjectsByID(fieldID: Number): FieldObject
		{
			var fieldObject:FieldObject;
			for each (fieldObject in fieldsObjects)
			{
				if (fieldObject.id == fieldID)
				{
					return fieldObject;
				}
			} 
			return null;
		}
		
		// Get field object screen position
		public function getObjectScreenPosition(matrixPosition: Point): Point
		{
			var worldPosition:Point = getObjectWolrdPosition(matrixPosition)
			
			return new Point( 
				worldPosition.x - xOffset,
				worldPosition.y - yOffset)
		}
		
		// Get game object world position in accordance with matrix position
		public function getObjectWolrdPosition(matrixPosition:Point): Point
		{
			var objectPosition: Point;
			if (matrixPosition.y % 2 == 0)
			{
				 objectPosition = new Point
							(matrixPosition.x * maxObjectWidth + objectsGlobalOffsetX,
							matrixPosition.y * maxObjectHeight/2 + objectsGlobalOffsetY);	
			}
			else
			{
				objectPosition = new Point
							(matrixPosition.x * maxObjectWidth + maxObjectWidth/2 + objectsGlobalOffsetX,
							matrixPosition.y *maxObjectHeight/2 + objectsGlobalOffsetY);				
			} 
			return new Point(objectPosition.x ,objectPosition.y);
		}
		
		// Get matrix position of mouse pointer in accordance with screen mouse pointer
		public function getMatrixPosition(worldPosition: Point):Point
		{
			// As default = Undefined
			var _globalMatrixPosition:Point = new Point(-1,-1);
			
			// Min side of object
			var squareMinSide:Number = Math.min(maxObjectWidth,maxObjectHeight);
						
			// Min length of Mouse pointer and objects position
			var minLength: Number = Number.MAX_VALUE;
						
			for (var i:int = 0; i < 15; ++i){			
			for (var j:int = 0; j < 27; ++j){															
					var objectPosition:Point = getObjectWolrdPosition(new Point(i,j));
					var objectCenter:Point = new Point
							(objectPosition.x + maxObjectWidth / 2,
							objectPosition.y + maxObjectHeight / 2);
							
					var diffX:Number = objectCenter.x - worldPosition.x
					var diffY:Number = objectCenter.y - worldPosition.y
					
					var lengthMouseFromObjectCenter: Number = 
					Math.sqrt(diffX*diffX + diffY*diffY);
					
					minLength = Math.min(lengthMouseFromObjectCenter,minLength);
					
					if (lengthMouseFromObjectCenter <= squareMinSide/2)
					{														
						_globalMatrixPosition = new Point(i,j);
						return _globalMatrixPosition;
					}				
				}										
			}	
			return _globalMatrixPosition;
		}
			
		// Get object Z order 
		public function getZOrder(matrixPosition:Point):int
		{
			return matrixPosition.x + matrixPosition.y * maxMatrixX;
		}
		
		// 'Field' object changing methods
		//----------------------------
			
		// Add field
		public function addFieldObject():void
		{
			if (!overBackgroundBounds(mousePointer.position))
			{
				Alert.show("Нельзя выносить объект за пределы.");
				return;
			}
			
			if (getFieldObjects(mousePointer.position) != null)
			{
				Alert.show("Вы не можете сажать на этом участке поля.");
				return;
			}
			
			var givesType:String = GivesState.stateToString();
					
			requestManager.requestQuery(
					RequestManager.ADDGIVE,
					{ftype: givesType, x: mousePointer.position.x,y: mousePointer.position.y});		
			requestManager.requestSend();
		}
		
		// Grows fields
		public function growFieldObject():void
		{
			var needGrow:Boolean = false
			var fieldObject:FieldObject;
			for each (fieldObject in fieldsObjects)
			{
				if (fieldObject.state < FieldObject.maxState)
				{
					needGrow = true;
					break;
				}
			} 
			if (needGrow)
			{
				requestManager.requestQuery(RequestManager.GROWGIVES);			
				requestManager.requestSend();
			}
			else
			{
				Alert.show("Нечему расти..");
			}
		}
		
		// Take fields
		public function takeFieldObject():void
		{
			var needTake:Boolean = false
			var fieldObject:FieldObject = getFieldObjects(mousePointer.position);
			if (fieldObject != null && fieldObject.state == FieldObject.maxState)
			{
				needTake = true;
			}
			 
			if (needTake)
			{
				requestManager.requestQuery(RequestManager.TAKEGIVES,{id: fieldObject.id});			
				requestManager.requestSend();
				deleteUnusableFieldObject(fieldObject);
			}
			else
			{
				Alert.show("Нечего собирать..");
			}
		}
		
		// Update fields in accordance with field object
		public function updateFieldObject(fieldObject: FieldObject):void
		{
			if (!overBackgroundBounds(mousePointer.position))
			{
				Alert.show("Нельзя выносить объект за пределы.");
				return;
			}
			
			if (getFieldObjects(mousePointer.position) != null)
			{
				Alert.show("Этот участок поля уже занят.");
				return;
			}
			
			requestManager.requestQuery(
					RequestManager.UPDATEGIVES,
					{id: fieldObject.id, x: mousePointer.position.x,y: mousePointer.position.y});		
			requestManager.requestSend();
		}
		
		// Check bounds of game field
		private function overBackgroundBounds(mousePosition:Point):Boolean
		{
			var startXpos:int = 7;
			var startYpos:int = 2;
			var endYpos:int = 26;
			var middleSection:int = 6;
			
			var determinedMouseSection:int = (mousePosition.y - 1)/2
			trace(determinedMouseSection)
			
			var determinedMaxXOffset:int;
			var determinedMinXOffset:int;
			
			if (determinedMouseSection <= middleSection)
			{
				determinedMaxXOffset = startXpos + determinedMouseSection -1;
				if ((mousePosition.y) % 2 != 0)
				{
					determinedMaxXOffset -=1;
				}
				
				determinedMinXOffset = startXpos - determinedMouseSection + 1
			}
			else
			{
				determinedMinXOffset = startXpos - (startXpos - (determinedMouseSection - (middleSection -1)))
				if ((mousePosition.y) % 2 == 0)
				{
					determinedMinXOffset +=1;
				}
				
				determinedMaxXOffset = startXpos + (startXpos - (determinedMouseSection - (middleSection -2)))
			}
			
			trace(determinedMinXOffset, determinedMaxXOffset)
			trace(mousePosition.x >= determinedMinXOffset && mousePosition.x <= determinedMaxXOffset && mousePosition.y > startYpos && mousePosition.y < endYpos)
			
			return mousePosition.x >= determinedMinXOffset && 
				   mousePosition.x <= determinedMaxXOffset && 
				   mousePosition.y > startYpos && 
				   mousePosition.y < endYpos;
		}
		
		private function destroyMouseDragObject():void
		{
			if (mouseDragAndDropObject != null)
			{	
				mouseDragAndDropObject.shutdown();
				mouseDragAndDropObject = null;
			}
		}
		
		
		// Resource Manager handlers
		//----------------------------
		
		// RequestManager Fault event handler 
		private function faultHandler(event:FaultEvent):void
		{
			trace(this + "RequestManager faultHandler: " + event);
			GameObjectManager.Instance.lastError =  event.fault.message;
		}	
	
		// RequestManager Result event handler 				
		private function resultHandler(event:ResultEvent):void
		{
			var result:Object = event.result;
        	if (result == "error")
        	{
        		 GameObjectManager.Instance.lastError =  "Извините, сервер не доступен. Повторите попытку позже.";
        		 return;
        	}
			
			var fieldsAsXML:XML = result as XML;
				
			if (!fieldsAsXML.hasSimpleContent())
			{
				var fields:XMLList = fieldsAsXML..field;
				
				if (fields.length() == 0) 
				{
					// Assume that xml contains only one node
					updateFieldObjects(new XMLList(fieldsAsXML));
				}
				else
				{
					updateFieldObjects(fields);
				}
			}
		}
		
		
		// ResourceLoader handlers
		//----------------------------
		
		// Resourece loader Security Error handler
        private function securityErrorHandler(event:SecurityErrorEvent):void
        {
            trace(this + "securityErrorHandler: " + event);
            GameObjectManager.Instance.lastError =  event.text;
        }

		// Resourece loader ioError handler
        private function ioErrorHandler(event:IOErrorEvent):void
        {
            trace(this + "ioErrorHandler: " + event);
            GameObjectManager.Instance.lastError =  event.text;
        }
	
		
		// Override methods
		//----------------------------
			
		// Initialize method. Occures only when object initializing is completed
		override public function InitializeComplited():void
		{
			xMaxOffset = this.graphics.drawRect.width - width;
			yMaxOffset = this.graphics.drawRect.height - height;					
			xOffset = xMaxOffset / 2;
			yOffset = yMaxOffset / 2;
			
			mousePointer = new GameObject(this,new Point(0,0),1);			
			var loadManager:ResourcesLoader = new ResourcesLoader(GameObjectManager.Instance.serverAddress,mousePointer);
			loadManager.securityErrorHandler = securityErrorHandler;
			loadManager.ioErrorHandler = ioErrorHandler;		
			loadManager.load(ResourceManager.MousePointerID1);			
			mousePointer.hidden = true;	
						
			requestManager = new RequestManager(GameObjectManager.Instance.serverAddress,resultHandler,faultHandler);		
			requestManager.requestQuery(RequestManager.RETURNSALLGIVES);		
			requestManager.requestSend();
		}

		// Removes object
		override public function shutdown():void
		{
			if (mousePointer != null )
				mousePointer.shutdown();
			super.shutdown();
		}
		
		// Frame ping
		override public function enterFrame(dt:Number):void
		{
			if (xOffset <= 0) 		   { xOffset = 0; }
			if (yOffset <= 0) 		   { yOffset = 0; }
			if (xOffset >= xMaxOffset) { xOffset = xMaxOffset; }			 
			if (yOffset >= yMaxOffset) { yOffset = yMaxOffset; }
			
			switch (CommandState.State)
			{				
				case CommandState.None:
					// Nothing
					break;
				case CommandState.Give:
					addFieldObject();	
					CommandState.State = CommandState.None;					
					break;			
				case CommandState.Grow:
					growFieldObject();		
					CommandState.State = CommandState.None;
					break;
				case CommandState.Take:
					takeFieldObject();		
					CommandState.State = CommandState.None;
					break;
			}
			
			ResourcesLoader.clearStack();
		}
		
		// MouseDown event handler 
		override public function mouseDown(event:MouseEvent):void
		{		
			// We should not do any operations if mouse pointer is hidden						 	
			if (mousePointer.hidden)
			{ 
				return;
			}
				
			prevMousePoint = new Point(event.localX, event.localY);
			wasMoving = false;
			
			var dragginObject:FieldObject = getFieldObjects(globalMatrixPosition);
			if (dragginObject != null)
			{
				mouseDragAndDropObject = new FieldObject(
							this,globalMatrixPosition,getZOrder(globalMatrixPosition),
							dragginObject.id,
							dragginObject.type,
							dragginObject.state
							);
							
				mouseDragAndDropObject.onDragged = true;
				mouseDragAndDropObject.graphics = dragginObject.graphics;
			}		
		}
		
		// MouseUp event handler 
		override public function mouseUp(event:MouseEvent):void
		{
			if (!wasMoving)
			{
				if (!mousePointer.hidden)
				{
					if (GivesState.State != GivesState.None)
					{
						CommandState.State = CommandState.Give;
					}
					else
					{
						CommandState.State = CommandState.Take;
						destroyMouseDragObject();
					}
					return;
				}
			}
			
			if (mouseDragAndDropObject != null)
			{
				updateFieldObject(FieldObject(mouseDragAndDropObject));
				destroyMouseDragObject();
			}
		}
		
		// MouseMove event handler
		override public function mouseMove(event:MouseEvent):void
		{	
			event.target is Canvas ? mousePointer.hidden = false 
									: mousePointer.hidden = true;
			
			// We should not do any operations if mouse pointer is hidden						 	
			if (mousePointer.hidden)
			{ 
				return;
			}
		
			if (event.buttonDown)
			{
				wasMoving = true; 
				if (mouseDragAndDropObject == null)
				{
					var newXOffset: Number = event.localX - prevMousePoint.x;
					var newYOffset: Number = event.localY - prevMousePoint.y;
						
					xOffset += -newXOffset;
					yOffset += -newYOffset;
					prevMousePoint = new Point(event.localX, event.localY);
					
				}
			}
				
			globalMatrixPosition = getMatrixPosition(
										new Point(event.localX + xOffset,
										event.localY + yOffset))
																		
			if (globalMatrixPosition.x != -1 && globalMatrixPosition.y != -1)
			{			
				mousePointer.position = globalMatrixPosition;
				mousePointer.hidden = false;
			}
			
			if (mouseDragAndDropObject != null)
			{
					mouseDragAndDropObject.position = globalMatrixPosition;
					mouseDragAndDropObject.zOrder = getZOrder(globalMatrixPosition);
			}
		}
						
		// Draws Tiled background
		override public function copyToBackBuffer(db:BitmapData):void
		{		
			if (graphics != null)
			{
				// Create visual bounds	
				var recVisBounds:Rectangle = new Rectangle(
						0+xOffset,
						0+yOffset,
						0+xOffset+width,
						0+xOffset+height);
									
				db.copyPixels(graphics.bitmap, recVisBounds, new Point(0,0), graphics.bitmapAlpha, new Point(0, 0), true);
			}		
		}

	}
}