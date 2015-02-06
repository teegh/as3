package com.thread.fileReadThread
{
	
	import flash.display.MovieClip;
	import flash.system.System;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.utils.*;
	import org.libspark.thread.Thread;
	import org.libspark.thread.utils.EventDispatcherThread;
	import org.libspark.thread.utils.MultiProgress;
	import org.libspark.thread.utils.SerialExecutor;
	import org.libspark.thread.utils.IProgressNotifier;
	import com.thread.fileReadThread.fileReadWorkerThread;
	import com.thread.fileReadThread.ProgressBarThread;
	import com.thread.fileReadThread.ThreadProcessCounter;
	import com.DB.SQLiteControler.SQLiteINSERT;
	import com.thread.fileReadThread.fileReadThreadEvent;
	
	
	
	 //このスレッドは、複数の WorkerThread を実行すると共に、 ProgressBarThread を用いてその進捗状況をプログレスバーとして表示します。
	public class fileReadThread extends EventDispatcherThread {
		
		protected var _disp:MovieClip;								//読み込み状況を示すムービークリップ
		protected var _executor:SerialExecutor;						
		protected var _progress:MultiProgress 						//複数の進捗状況をひとつにまとめるための MultiProgress を作成します
		protected var _fileDataList:Array;							//ファイルを収めた配列 (複数ファイル)
		protected var _thCnt:ThreadProcessCounter 					//スレッドの処理数を格納するクラス。
		protected var _sqlInsert:SQLiteINSERT;						//データベースへの入力クラス
		protected var _addThreadWaitPath_arr:Array					//待機処理を納める配列 (処理を後回しにしたいファイル)									
		
		//内部で使う
		protected var _isAlreadyDirectoryThreadAdded:Boolean = false;
		
		
		
		//コンストラクタ
		//最初に実行するために必要なのはinFileDataListの値のみ。その他は再帰処理に利用される変数
		public function fileReadThread(inFileDataList:Array ,
										inDisp:MovieClip
										) {
											
			//初期化および、代入
			_disp					= inDisp;
			_fileDataList 			= inFileDataList;
			_executor 				= new SerialExecutor();
			_progress 				= new MultiProgress();
			_sqlInsert 				= new SQLiteINSERT("fileName","fileName");
			_addThreadWaitPath_arr 	= new Array();
			_thCnt					= new ThreadProcessCounter();
			
			
			//_fileDataListは２次元配列になっている。例：[[File1,File2],[File3,File4],...]
			//末尾の要素を_fileDataListに格納し直し、残りの要素は_addThreadWaitPath_arrに格納する。
			var tempArr:Array 	= new Array();
			tempArr 			= _fileDataList.pop();
			for (var i:uint = 0; i<_fileDataList.length; i++ ){
				_addThreadWaitPath_arr.push(_fileDataList[i]);
			}
			_fileDataList 		= tempArr;
			tempArr 			= null;			
		}
		
		
		// スレッドの処理は run メソッドをオーバーライドして記述します
		override protected function run():void {
			_thCnt.startStopWatch();		//処理時間計測開始
			fileReadCmd();
		}
		
		
		//ファイル読み込み処理
		private function fileReadCmd():void{
			
			var fileDataList_Length:uint = _fileDataList.length;	//ファイルリスト数取得
			for(var i:uint = 0; i<fileDataList_Length; i++){		//ファイルリスト分直列スレッドを追加します
				
				//ファイルの場合
				if (!_fileDataList[i].isDirectory) {
					addThreadAndProgress(_fileDataList[i]);			//(スレッド追加) ファイルを直列スレッドに追加する。
					
				//ディレクトリの場合
				}else {
					//一度処理もこの処理をしていないとき
					if(!_isAlreadyDirectoryThreadAdded ){
						addThreadAndProgress(_fileDataList[i]);		//(スレッド追加) ファイルを直列スレッドに追加する。
					}else {
						addArr_WaitThread(i, _fileDataList);		//(後回し)残りのファイルリストすべてを、後で処理するファイルリストに追加する。
						break;										//forループ抜ける		
					}
					_isAlreadyDirectoryThreadAdded = true;
				}
			}
			
			_executor.start();		// WorkerThraed開始
			_executor.join();		// 終了待機
			new ProgressBarThread(_progress , _disp , _thCnt).start();	// ProgressBarThread開始
			
			next(fileErrorCheck);	// 次の処理
			interrupted(stopTh);	// 割り込み
		}
		
		
		
		//(スレッド追加) ファイルを直列スレッドに追加する。
		protected function addThreadAndProgress(inFile:File):void {
			trace("[fileReadThread] (addThread): " + inFile.nativePath);
			_thCnt.thread++;
			_executor.addThread(new fileReadWorkerThread(inFile , _disp , _thCnt , _addThreadWaitPath_arr , _addThreadWaitPath_arr.length ,_executor , _progress , _sqlInsert));
			_progress.addProgress(IProgressNotifier(_executor.getThreadAt(_executor.numThreads-1)).progress, 1.0);
		}
		
		//(後回し) 残りのファイルリストすべてを、後で処理するファイルリストに追加する。
		private function addArr_WaitThread(inPosition:uint, inFileList:Array):void {
			var waitArr:Array = new Array();
			var fileListLength:uint = inFileList.length;
			for(var i:uint = inPosition; i < fileListLength; i++){
				waitArr.push(inFileList[i]);		//展開していない残りのファイルリストを、一時的な配列に移す。
			}
			_addThreadWaitPath_arr.push(waitArr); 	//後で処理する配列に、ファイルリストの配列を追加する。
		}
		
		
		private function fileErrorCheck():void{
			//SQLiteトランザクションをコミットする。
			//trace("[com.thread.fileReadThread fileReadThread fileErrorCheck()] commit()");
			//_sqlInsert.commit();
			
			/*
			//異常・警告ファイルをDBに格納する。
			if (errorArr.length != 0) {
				//trace("読み込み異常・警告"+errorArr.length+"件");
			}*/
			next(complete);
		}
		
		
		
		//一時停止処理
		private function stopTh():void{
			_executor.interrupt();
			_executor.join();
			next(interruptTh);
		}
		
		
		//割り込み処理
		private function interruptTh():void{
			trace("[com.thread.fileReadThread fileReadThread interruptTh()] commit()");
			//_sqlInsert.commit();	//SQLiteトランザクションをコミットする。
			next(complete);
			_addThreadWaitPath_arr = null;
		}
		
		
		/*
		//処理時間平均の計測
		private function dispAvrgTime():void {
			
			//平均処理時間を計測する方法
			var threadParInstrument:uint 	= 1000;
			var commitCnt:uint 				= uint((_thCnt.thread-_thCnt.thread % threadParInstrument)/threadParInstrument);		//コミットした回数
			
			if(_thCnt.thread % threadParInstrument == 0 && _thCnt.commitedCnt < commitCnt ){
				
				var processTime:uint 			= uint( getTimer() - _thCnt.beforeCommitedTime );
				var processTimeParCommit:uint 	= Math.floor(processTime/threadParInstrument);
				
				_thCnt.commitedCnt 			= commitCnt;
				_thCnt.beforeCommitedTime 	= getTimer();
				
				//読み込みステータスに表示
				trace( "[com.thread.fileReadThread fileReadWorkerThread instrumentProcessTime()] [" + String(_thCnt.commitedCnt) + "] " + String(processTimeParCommit) + " msec/処理 - 経過 " + String(Math.floor(processTime / 1000)) + " sec\n");	
			}
		}
		*/
		
		
		//処理完了後の処理
		private function complete():void {
			//スレッドがすべて仕事完了
			trace('[com.thread.fileReadThread fileReadThread complete()] コミット　' + " -> " +_fileDataList[0].nativePath);
			
			//コミットする
			_sqlInsert.commit();
			_sqlInsert 	= null;
			
			//コミット数をカウントアップする
			_thCnt.commitedCnt++;
			
			//処理時間計測停止。メインのスレッドでのみ実行する。stopStopWatch()は、ProgressBarThreadの動作を停止する条件となる。
			_thCnt.stopStopWatch();
			
			//処理完了のイベントを発行する。
			//まだ処理を終えていないタスクは_addThreadWaitPath_arrに格納されている。イベントクラスに渡す。
			//trace('[com.thread.fileReadThread] イベント発行　_addThreadWaitPath_arr' + " -> " +_addThreadWaitPath_arr.length);
			dispatchEvent(new fileReadThreadEvent(fileReadThreadEvent.Thread_Complete , _addThreadWaitPath_arr));
		}
		
		
		
		//終了フェーズ
		override protected function finalize():void {
			
			//解放
			_disp					= null;
			_fileDataList 			= null;
			_executor 				= null;
			_progress 				= null;
			_sqlInsert 				= null;
			_addThreadWaitPath_arr 	= null;
			_thCnt 					= null;
			
			System.gc();
    	}
	}
}