package events {
    import flash.events.Event;
    
    public class LogoutEvent extends Event {
        public static const LOGOUT:String = "logout";

        public function LogoutEvent(type:String) { 
            super(type, true);
        }
    }
}