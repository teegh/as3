/*
 * ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *                    Spark project  (www.libspark.org)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */
package org.libspark.thread
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * @author	yossy:beinteractive
	 * @private
	 */
	internal class EventHandler
	{
		public function EventHandler(dispatcher:IEventDispatcher, type:String, listener:Function, func:Function, useCapture:Boolean, priority:int, useWeakReference:Boolean)
		{
			this.dispatcher = dispatcher;
			this.type = type;
			this.listener = listener;
			this.func = func;
			this.useCapture = useCapture;
			this.priority = priority;
			this.useWeakReference = useWeakReference;
		}
		
		public var dispatcher:IEventDispatcher;
		public var type:String;
		public var listener:Function;
		public var func:Function;
		public var useCapture:Boolean;
		public var priority:int;
		public var useWeakReference:Boolean;
		
		public function register():void
		{
			dispatcher.addEventListener(type, handler, useCapture, priority, useWeakReference);
		}
		
		public function unregister():void
		{
			dispatcher.removeEventListener(type, handler, useCapture);
		}
		
		private function handler(e:Event):void
		{
			listener(e, this);
		}
	}
}