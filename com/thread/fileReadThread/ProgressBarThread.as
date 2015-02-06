package com.thread.fileReadThread
{
	import flash.display.MorphShape;
	import flash.display.MovieClip;
	import org.libspark.thread.Thread;
	import org.libspark.thread.utils.IProgress;
	import com.thread.fileReadThread.ThreadProcessCounter;
	
	/**
	 * このスレッドは、与えられた IProgress インターフェイスのインスタンスが示す進捗状況を、プログレスバーとして描画します。
	 */
	public class ProgressBarThread extends Thread
	{
		/**
		 * @param	progress	進捗状況
		 * @param	graphics	プログレスバーの描画先
		 * @param	width		プログレスバーの最大幅
		 */
		// graphics:Object, width:uint
		public function ProgressBarThread(progress:IProgress , inDisp:MovieClip , inThCnt:ThreadProcessCounter)
		{
			_progress 	= progress;
			_disp		= inDisp;
			_thCnt		= inThCnt;
			//_graphics = graphics;
			//_width = width;
			// 表示用
			//_displayWidth = 0;
		}
		
		private var _progress:IProgress;
		private var _disp:MovieClip;
		private var _thCnt:ThreadProcessCounter;
		
		private var _filePath:String = "";
		private var _graphics:Object;
		private var _width:uint;
		private var _displayWidth:Number;
		
		/**
		 * スレッドの処理は run メソッドをオーバーライドして記述します
		 */
		override protected function run():void
		{
			
			if(_progress.percent != 1){		//読み込み中であれば　
				
				//_disp._mes.text = "読み込み中… "+_thCnt.openFilePath+ "";
				
				//trace(_progress.percent , w , _disp._loadbar.x);
				
				// 仕事が完了/失敗/キャンセルされていて
				if (_progress.isCompleted || _progress.isFailed || _progress.isCanceled) {
					// プログレスバーが完全に伸びきっていたら終了します
					return;
				}
				
				// 次もまたこのメソッドを実行します
				if(_progress.percent != 1){
					next(run);
				}
			}else {
				return;
			}
			
			/*
			if (_filePath != _thCnt.openFilePath) {
				_filePath = _thCnt.openFilePath;
				_disp._filePath_txt.text = _thCnt.openFilePath;
			}
			
			//処理が完了したら、メッセージを表示。 (処理時間計測クラス (StopWatch.as)で処理時間計測が完了した場合)
			if (_thCnt.thInstruComplete) {
				_disp._filePath_txt.text 	= "処理完了";
				_disp._memory.text 			= "処理時間：" + _thCnt.thCompleteTime;
				return;
			}
			
			next(run);
			*/
			
			
			/*
			if(_graphics._bar.currentFrame == 1){		//読み込み中であれば　
				// 現在のプログレスバーの幅を算出します
				var w:Number = _width * _progress.percent;
				
				// 表示用の幅を算出します
				// これは、プログレスバーがだんだん伸びるアニメーションを実現するために必要です
				_displayWidth += (w - _displayWidth) / 3;
			
				_graphics._bar.width=_displayWidth;
				
				
				// 仕事が完了/失敗/キャンセルされていて
				if (_progress.isCompleted || _progress.isFailed || _progress.isCanceled) {
					// プログレスバーが完全に伸びきっていたら終了します
					if (_displayWidth == w) {
						return;
					}
				}
				
				// 次もまたこのメソッドを実行します
				if(_progress.percent != 1){
					next(run);
				}
			}else{
				//trace("(ProgressBarThread)中断又は完了の為、描画終了");
				return;
			}
			*/
		}
		
		override protected function finalize():void {
			/*
			_graphics._bar.width = _width;
			_progress=null;
			_graphics=null;
			_width=0;
			_displayWidth=0;
			*/
		}
	}
}