package com.thread.fileReadThread
{
	import flash.display.MorphShape;
	import flash.display.MovieClip;
	import flash.utils.*;
	import flash.system.System;
	import flash.filesystem.File;
	import org.libspark.thread.Thread;
	import org.libspark.thread.utils.IProgress;
	import org.libspark.thread.utils.IProgressNotifier;
	import org.libspark.thread.utils.Progress;
	import org.libspark.thread.utils.SerialExecutor;
	import org.libspark.thread.utils.MultiProgress;
	import com.thread.fileReadThread.fileRead;					//ファイルの処理
	import com.thread.fileReadThread.fileReadThread;
	import com.thread.fileReadThread.ThreadProcessCounter;
	import com.DB.SQLiteControler.SQLiteINSERT;					//DB入力処理
	import com.utils.CheckKind;									//拡張子チェック
	
	//進捗状況を通知するためには、 IProgressNotifier インターフェイスを実装し、
	//pgoress プロパティを返すようにします。
	//progress プロパティは IProgress インターフェイスの実装クラスである必要があり、
	//Progress クラスを使用するのが最も簡単です。
	public class fileReadWorkerThread extends Thread implements IProgressNotifier
	{	
		public function fileReadWorkerThread(inFile:File ,
											inDisp:MovieClip ,
											inThCnt:ThreadProcessCounter ,
											inAddThreadWaitPath_arr:Array ,
											inAddThreadWaitPath_arr_length:uint ,
											inExecutor:SerialExecutor ,
											inProgress:MultiProgress ,
											inMyInsert:SQLiteINSERT) {
			
			_file					= inFile;
			_disp					= inDisp;
			_thCnt					= inThCnt;
			_addThreadWaitPath_arr 	= inAddThreadWaitPath_arr;
			_addThreadWaitPath_arr_length = inAddThreadWaitPath_arr_length;
			_executor				= inExecutor;
			_mProgress				= inProgress;
			_sqlInsert 				= inMyInsert;
		}
		
		//変数
		private var _file:File;									
		private var _disp:MovieClip;							// 読み込み状況を示すムービークリップ
		private var _thCnt:ThreadProcessCounter					// スレッドの処理数を格納するクラス。
		private var _addThreadWaitPath_arr:Array;
		private var _addThreadWaitPath_arr_length:uint;
		private var _executor:SerialExecutor;
		private var _mProgress:MultiProgress;
		private var _sqlInsert:SQLiteINSERT;
		private var _fileReadThread:fileReadThread;				
		private var _checkKind:CheckKind 	= new CheckKind(".JPG",".JPEG","jpg","jpeg",".png","PNG",".gif",".GIF");	
		private var _fileRead:fileRead 		= new fileRead();	
		private var _progress:Progress		= new Progress();
		private const _commit_atReadFile:Number = 2000;				//この値以上、ファイルを読み込んだら、メインスレッドの終了時にコミットする。
		
		
		// このプロパティは IProgressNotifier インターフェイスによって定義されます。
		// 進捗状況を通知可能にするために、 IProgress インターフェイスのインスタンスを返します。
		public function get progress():IProgress{
			return _progress;
		}
		
		// スレッドの処理
		override protected function run():void{
			_progress.start(1);							// 仕事の開始を通知します。引数には、行うべき仕事量の合計を渡します
			if (!_executor.isInterrupted) fileOpen();	// 次は実際に仕事をします。
		}
		
		// ファイルの読み込み
		private function fileOpen():void {
			//システムファイルについては処理を行わない。
			if (_file.nativePath.indexOf(":\\RECYCLER") == -1 && _file.nativePath.indexOf(":\\$RECYCLE.BIN") == -1 && _file.nativePath.indexOf(":\\System Volume Information") == -1) {
				
				//trace("[com.thread.fileReadThread.fileReadWorkerThread] fileOpen() ["+_folderDepth+"]: "+_file.nativePath);
				_thCnt.openFilePath = _file.nativePath;
				
				//ディレクトリである場合
				if(_file.isDirectory){
					
					if( check_addMainThread( _file )){		//メインスレッドで改めて実行するか判定
						mainThread_cmd(_file);				//メインスレッドに実行
					}else{
						openDirectoryAndAddThread();		//ディレクトリの展開後、スレッド追加や待機(後回し処理)
					}
					_thCnt.folder++;						//展開したフォルダ数をカウント
					
				//ファイルである場合
				}else{
					_thCnt.message = "ファイル読み込み中...\n"+_file.nativePath;
					work();
				}
			
			//入力ファイルがシステムフォルダである場合
			}else {
				//mp3ファイル以外ファイル数カウント
				_thCnt.notReadFile++;
			}
			
			//開いたファイルのディレクトリを保存
			//_thCnt.directryDepthAtOpenFile = getDirectryDepth(_file);
		}
		
		
		//------------------------------------
		//
		//	メインスレッドで実行　／　現在のスレッドに追加 
		//
		//------------------------------------
		// メインスレッド実行
		private function mainThread_cmd(inFile:File):void {
			
			//trace("fileReadWorkerThread (待機配列に追加): " + inFile.nativePath);
			
			//待機スレッドに追加。
			//ディレクトリーの展開。
			var files:Array = inFile.getDirectoryListing();		//ディレクトリ内のファイルを読み込む。
			for(var i:uint = 0; i < files.length; i++){			//ディレクトリのファイルの数分だけ処理。
				_addThreadWaitPath_arr.push([files[i]]);
			}	
		}
		
		// 現在実行中の直列スレッドに追加
		private function addThreadAtExecuter(inFile:File):void {
			_thCnt.thread++;
			
			//仕事スレッドに実行
			_executor.addThread(new fileReadWorkerThread( inFile , _disp , _thCnt , _addThreadWaitPath_arr , _addThreadWaitPath_arr_length ,  _executor , _mProgress , _sqlInsert ));
			_mProgress.addProgress(IProgressNotifier(_executor.getThreadAt(_executor.numThreads - 1)).progress, 1.0);
			
		}
		
		
		
		//------------------------------------
		//
		//	ディレクトリの展開
		//
		//------------------------------------
		// ディレクトリの展開後、スレッド追加や待機(後回し処理)
		private function openDirectoryAndAddThread():void{
			var i:uint = 0;
			
			//************************************************
			//ファイルとフォルダーの分離
			//************************************************
			//フォルダー・ファイルリストの配列
			var fileList:Array 		= new Array();
			var folderList:Array 	= new Array();
			
			//ディレクトリーの展開。フォルダーとファイルの分離を分離し、配列にそれぞれ格納する。
			var files:Array = _file.getDirectoryListing();	//ディレクトリ内のファイルを読み込む。
			for(i = 0; i < files.length; i++){				//ディレクトリのファイルの数分だけ処理。
				if(files[i].isDirectory){
					folderList.push(files[i]);		//フォルダー
				}else{
					fileList.push(files[i]);		//ファイル
				}
			}
			
			//************************************************
			//フォルダーの処理
			//************************************************
			//最初に取得するフォルダーと、それ以降のフォルダーを分ける
			var folderFirstListArr:Array 	= new Array();		//最初のフォルダー
			var folderLastListArr:Array 	= new Array();		//最初以外のフォルダー
			
			if(folderList.length > 0){
				for(i=0; i<folderList.length; i++){
					if(folderFirstListArr.length == 0){
						folderFirstListArr.push(folderList[i]);
					}else{
						folderLastListArr.push(folderList[i]);
					}
				}
			}
			
			//最初のフォルダー
			//現在のスレッドに追加
			if (folderFirstListArr.length != 0) {
				addThreadAtExecuter(folderFirstListArr[0]);
			}
			
			//最初以降のフォルダー
			//待機リスト(後回し)に追加
			var waitArr:Array = new Array();
			if(folderLastListArr.length != 0 ){
				//最初以外のフォルダがある場合は待機リストに追加する
				for(i=0; i<folderLastListArr.length; i++){
					waitArr.push(folderLastListArr[i]);
				}
			}
			
			
			//************************************************
			//ファイルの処理
			//************************************************
			//ファイルは待機リスト(後回し)に追加する
			var isAddFileWaitList:Boolean = false;
			if(folderLastListArr.length != 0 || (folderFirstListArr.length != 0 && check_addMainThread(folderFirstListArr[0]) ) ){
				if(fileList.length != 0){
					for(i=0; i<fileList.length; i++){
						waitArr.push(fileList[i]);
					}
					isAddFileWaitList = true;
				}
			}
			
			//ファイルが待機リストに登録されていなければ、仕事スレッドに追加する。
			if( !isAddFileWaitList){
				for (i = 0; i < fileList.length; i++) {
					addThreadAtExecuter(fileList[i]);
				}
			}
			
			
			//************************************************
			//待機リスト(後回し)に追加する
			//************************************************
			if (waitArr.length)_addThreadWaitPath_arr.push(waitArr);
			
			
			//************************************************
			//参照を外す
			//************************************************
			//解放
			fileList			= null;
			folderList			= null;
			folderFirstListArr 	= null;
			folderLastListArr 	= null;
			waitArr 			= null;
			files				= null;
		}
		
		
		
		
		//------------------------------------
		//
		//	フォルダー + その他条件 であれば、後回しの処理にする
		//
		//------------------------------------
		private function check_addMainThread(inFile:File):Boolean{
			
			// メインスレッドで実行しない
			if(!inFile.isDirectory)return false;					//ファイルであるとき
			
			// inFileがフォルダーを多く持っている場合。						
			var files:Array 	= inFile.getDirectoryListing();		//ディレクトリ内のファイルを読み込む。
			var fileLength:uint = files.length;						
			var folderCnt:uint 	= 0;								
			for(var i:uint = 0; i < fileLength; i++){				//ディレクトリのファイルの数分だけ処理。
				if(files[i].isDirectory){							
					folderCnt++;									
				}													
			}
			if (folderCnt >= 3) {
				_thCnt.clusterThreadCnt++;
				return true;
			}
			
			// 解放
			files = null;
			
			return false;
		}
		
		
		
		//------------------------------------
		//
		//	ファイルの処理
		//
		//------------------------------------
		private function work():void{
			//ファイルが存在するか？確認
			if (_file.exists) {								//ファイルの有無を確認
				//処理対象としたいファイル
				if(_checkKind.check(_file.nativePath)){		//処理したいファイルかどうか、拡張子チェック
					fileReadCmd(_file);						//ファイルの読み込み
					_thCnt.readFile++;						//ファイル数のカウント
				//処理対象外のファイル
				}else{
					_thCnt.notReadFile++;					//ファイル以外ファイル数カウント
				}
			//ファイルが存在しない
			}else{
				//trace("ファイルが存在しません。"+_file.nativePath);
			}
		}
		
		
		
		//------------------------------------
		//
		//	仕事内容　：　ファイルに対する処理 (fileReadクラス)
		//
		//------------------------------------
		protected function fileReadCmd(inFile:File):void {
			_fileRead.read(inFile,_sqlInsert,_thCnt);
		}
		
		
		
		
		//------------------------------------
		//
		//	待機しているファイルを、追加する
		//
		//------------------------------------
		private function waitThread_AddThread():void {
			
			//_commit_atReadFile以上のファイル読み込みを行った場合、
			//待機しているファイルを読み込まない。一度スレッドの終了とコミットを行う。
			if (_thCnt.readFile > _commit_atReadFile) return;
			
			//trace(_executor.numThreads + " = " + _thCnt.folder + " + " + _thCnt.readFile + " + " + _thCnt.notReadFile);
			if (_addThreadWaitPath_arr.length == 0) return;
			if (_executor.numThreads == _thCnt.folder + _thCnt.readFile + _thCnt.notReadFile){
				
				//_fileDataListは2次元配列になっている。例：[[File1,File2],[File3,File4],...]
				//末尾の要素を_fileDataListに格納し直し、残りの要素は_addThreadWaitPath_arrに格納する。
				var fileDataList:Array;				
				fileDataList = _addThreadWaitPath_arr.pop();
				
				for (var j:uint = 0; j < fileDataList.length; j++ ) {
					addThreadAtExecuter(fileDataList[j]);
				}
			}
			
		}
		
		
		
		//------------------------------------
		//
		//	終了フェーズ
		//
		//------------------------------------
		override protected function finalize():void{
			pComplete();	//仕事完了
		}
		
		
		
		//------------------------------------
		//
		//	仕事完了
		//
		//------------------------------------
		private function pComplete():void{
			_progress.progress(1);	// 仕事が進行したことを通知します
			_progress.complete();	// 仕事が完了したことを通知します
			waitThread_AddThread();
			dispose();
			return;
		}
		
		
		
		
		// 解放
		private function dispose():void {
			
			_file					 = null;
			_disp			 		 = null;
			//_thCnt					 = null;
			//_addThreadWaitPath_arr	= null;
			_executor				 = null;
			_mProgress				 = null;
			_sqlInsert				 = null;
			_fileReadThread			 = null;
			_checkKind				 = null;
			_fileRead		 		 = null;
			_progress		 		 = null;
		}
	}
}