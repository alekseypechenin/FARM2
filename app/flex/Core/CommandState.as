package Core
{
	// Determines possible Game state.
	public final class CommandState
	{	
		// None state. Just views game field.
		public static const None:int=0;
		// Take state. The game should takes object that have alredy growed.
		public static const Take:int=1;
		// Give state. The game should add field object that is determined by GivesState
		public static const Give:int=2;
		// Give state. The game should grow all field objects
		public static const Grow:int=3;
		
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
				case Take: 
					_state = Take;
				break;
				case Give:
					_state = Give;
				break;
				case Grow:
					_state = Grow;
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
	}
}