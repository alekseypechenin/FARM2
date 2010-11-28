package Entities
{
	// Namespaces
	import Utils.*;
	import flash.geom.Point;
	import flash.display.*;
	
	
	// Represents object that determines Field(Gives) game object (potato, clover and Sunflower)
	public class FieldObject extends GameObject
	{
		public static const maxState:int = 5;
		
		// Uniq number
	    public var id:Number;
	    
	    // Gives type
	    public var type:String;
	    
	    // Gives state 
	    public var state:Number;
	       
	    // Constructor
	    public function FieldObject(tiledBackground:TiledBackground,
	    						    position:Point,	    					
	    						    zOrder:int,
	    						    id:int,
	    						    type:String,
	    						    state:int)
		{
			super(tiledBackground,position,zOrder);
			this.id = id;
			this.state = state;											
			this.type = type;
		}		  
	}
}