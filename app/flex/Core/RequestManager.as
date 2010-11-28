package Core
{	
	// Namespaces
	import mx.collections.*;
	import mx.core.Application;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService; 
	
	// Represents logic that allows to communicate with Server and obtain data
	// It is wrapper of HTTPService object with additionally functions 
	public final class RequestManager	
	{
		// Method Type
		public static const METHOD_POST:String = "POST";		
		public static const METHOD_GET:String = "GET";
		// Custom URL queries 
		public static const RETURNSALLGIVES:String = "fields/indextoclient";
		public static const ADDGIVE:String = "fields/createtoserver";
		public static const GROWGIVES:String = "fields/growallfields";			
		public static const TAKEGIVES:String = "fields/takefield";
		public static const UPDATEGIVES:String = "fields/update";
		
		// HTTPService helps our to obtains data
		private var httprequest: HTTPService = new HTTPService();
		// Full request URL = server URL + Custom URL query
		private var requestURL:String = null;
		// Callback for result Handler
		private var resultHandler:Function;
		// Callback for fault Handler
		private var faultHandler:Function;
		// Request params. Determine the parameters in URL query
		private var requestParams:Object = null;
		
		// Constructor
		public function RequestManager(requestServerURL:String,
									 resulHandler:Function = null,
									 faultHandler:Function = null)
		{
			this.requestURL = requestServerURL;
			this.resultHandler = resulHandler;
			this.faultHandler = faultHandler;		
		}
		// Set request URL in accordance with passed values		
		public function requestQuery(reqType:String,
									 reqPar:Object = null,
									 reqMethod:String = METHOD_POST
									 ):void
		{		
			httprequest.url = configureURL(reqType);
			httprequest.method = reqMethod;
			requestParams = reqPar;
			httprequest.resultFormat = "e4x";
			
			if (resultHandler != null)
			{
				httprequest.addEventListener(ResultEvent.RESULT, resultHandler);
			}
			if (faultHandler != null)
			{								
				httprequest.addEventListener(FaultEvent.FAULT, faultHandler);	
			}																			
		}
		// Sent query
		public function requestSend():void
		{
			httprequest.send(requestParams);			
		}
		// Returns request URL = server URL + Custom URL query
		private function configureURL(requestName:String):String
		{
			return requestURL + requestName;
		}
		
		
	}
}