package Core
{
	// Determines possible game Gives state.
	public final class GivesState
	{	
		// There is no gives state was selected
		public static const None:int=0;
		// Potato state
		public static const Potato:int=1;
		// Clover state
		public static const Clover:int=2;
		// Sunflower state
		public static const Sunflower:int=3;
		
		// Currently state value 
		private static var _state:int = CommandState.None;
		
		// Sets state value. Default state = None
		public static function set State(value:int):void
		{
			switch (value)
			{
				case None:
					_state = None;
				break;
				case Potato: 
					_state = Potato;
				break;
				case Clover:
					_state = Clover;
				break;
				case Sunflower:
					_state = Sunflower;
				break;				
				default:
					_state = None;
			}
		}
		
		// Gets state value.
		public static function get State():int
		{
			return _state;
		}
		
		// Represents string value of currently state
		public static function stateToString():String
		{
			switch (_state)
			{
				case Potato:
					return "potato";
				break;
				case Clover:
					return "clover";
				break;
				case Sunflower:
					return "sunflower";
				break;
				default:
					return 'None'
			} 	
		}		
	}
}