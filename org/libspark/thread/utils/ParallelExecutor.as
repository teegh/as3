﻿/*
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
package org.libspark.thread.utils
{
	import org.libspark.thread.Thread;
	import org.libspark.thread.ThreadState;

	/**
	 * ParallelExecutor は複数のスレッドを並列して実行するためのユーティリティクラスです.
	 * 
	 * <p>同時に全てのスレッドを開始し、全てのスレッドの実行が終了するとこのスレッドも終了します。</p>
	 * 
	 * <p>このスレッドに対して割り込みがかけられた場合、追加されている全てのスレッドに対して同じように割り込みを掛けた上で
	 * 全てのスレッドの終了を待ちます。</p>
	 * 
	 * <p>実行中のスレッドで例外が発生した場合、このスレッドは特に何もせず、例外を親に伝播させます。</p>
	 * 
	 * @author	yossy:beinteractive
	 */
	public class ParallelExecutor extends Executor
	{
		private var _index:uint;
		private var _isInterrupted:Boolean = false;
		
		/**
		 * @private
		 */
		override protected function run():void
		{
			// 全てのスレッドを開始
			for each (var thread:Thread in _threads) {
				if (thread.state == ThreadState.NEW) {
					thread.start();
				}
			}
			
			// 次に終了を待つスレッドのインデックス
			_index = 0;
			
			waitThreads();
		}
		
		/**
		 * @private
		 */
		private function waitThreads():void
		{
			// 全てのスレッドが終了するまで待つ、本当のマルチスレッドで言えば
			//
			// for each (var thread:Thread in threads) {
			//    thread.join();
			// }
			//
			// を行っている
			while (_index < _threads.length) {
				// 終了待ちをするスレッドを取得
				var thread:Thread = Thread(_threads[_index++]);
				// スレッドの終了を待つ
				if (thread.join()) {
					// join の戻り値が true の場合、待機状態になったということなので
					// 次にまたこのメソッドが実行されるよう設定してリターンする
					next(waitThreads);
					// 割り込み処理
					interrupted(interruptThreads);
					return;
				}
			}
			
			// ここまで到達した場合全てのスレッドの実行が終了している
		}
		
		/**
		 * 割り込み処理
		 * 
		 * @private
		 */
		private function interruptThreads():void
		{
			// はじめての割り込みである場合
			if (!_isInterrupted) {
				// 全てのスレッドに対して割り込み処理をかける
				for each (var thread:Thread in _threads) {
					thread.interrupt();
				}
				_isInterrupted = true;
			}
			// すべてのスレッドの終了を待つ
			waitThreads();
		}
	}
}