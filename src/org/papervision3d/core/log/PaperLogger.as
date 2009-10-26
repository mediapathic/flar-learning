package org.papervision3d.core.log
{
	import flash.events.EventDispatcher;
	
	import org.papervision3d.core.log.event.PaperLoggerEvent;
	
	/**
	 * @author Ralph Hauwert
	 */
	public class PaperLogger extends EventDispatcher
	{	
		private static var instance:PaperLogger;
		
		public var traceLogger:PaperTraceLogger;
		
		public function PaperLogger()
		{
			if(instance){
				throw new Error("Don't call the PaperLogger constructor directly");
			}else{
				traceLogger = new PaperTraceLogger();
				registerLogger(traceLogger);
			}
			
		}
		
		public function log(msg:String, object:Object = null, ...arg):void
		{
			var vo:PaperLogVO = new PaperLogVO(LogLevel.LOG, msg, object, arg);
			var ev:PaperLoggerEvent = new PaperLoggerEvent(vo);
			dispatchEvent(ev);
		}
		
		public function info(msg:String, object:Object = null, ...arg):void
		{
			var vo:PaperLogVO = new PaperLogVO(LogLevel.INFO, msg, object, arg);
			var ev:PaperLoggerEvent = new PaperLoggerEvent(vo);
			dispatchEvent(ev);
		}
		
		public function debug(msg:String, object:Object = null, ...arg):void
		{
			var vo:PaperLogVO = new PaperLogVO(LogLevel.DEBUG, msg, object, arg);
			var ev:PaperLoggerEvent = new PaperLoggerEvent(vo);
			dispatchEvent(ev);
		}
		
		public function error(msg:String, object:Object = null, ...arg):void
		{
			var vo:PaperLogVO = new PaperLogVO(LogLevel.ERROR, msg, object, arg);
			var ev:PaperLoggerEvent = new PaperLoggerEvent(vo);
			dispatchEvent(ev);
		}
		
		public function warning(msg:String, object:Object = null, ...arg):void
		{
			var vo:PaperLogVO = new PaperLogVO(LogLevel.WARNING, msg, object, arg);
			var ev:PaperLoggerEvent = new PaperLoggerEvent(vo);
			dispatchEvent(ev);
		}
		
		public function registerLogger(logger:AbstractPaperLogger):void
		{
			logger.registerWithPaperLogger(this);
		}
		
		public function unregisterLogger(logger:AbstractPaperLogger):void
		{
			logger.unregisterFromPaperLogger(this);
		}
		
		public static function log(msg:String, object:Object = null, ...arg):void
		{
			getInstance().log(msg);
		}
		
		public static function warning(msg:String, object:Object = null, ...arg):void
		{
			getInstance().warning(msg);
		}
		
		public static function info(msg:String, object:Object = null, ...arg):void
		{
			getInstance().info(msg);
		}
		
		public static function error(msg:String, object:Object = null, ...arg):void
		{
			getInstance().error(msg);	
		}
		
		public static function debug(msg:String, object:Object = null, ...arg):void
		{
			getInstance().debug(msg);
		}
		
		public static function getInstance():PaperLogger
		{
			if(!instance){
				instance = new PaperLogger();
			}
			return instance;
		}

	}
}