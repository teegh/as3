//クラスの仕様
//mp3のID3タグの画像バイナリデータを取得する。
//******************************************************************
//Id3Pic(filePath:String, filePos:int, id3FrameSize:int)
//[入力]　	filePath				:	mp3のファイルパス						(String)
//				filePos				:	歌詞を格納しているファイル位置	(int)
//				fileFrameSize		:	歌詞のID3フレームヘッダ				(int)

//[出力]　	getPicByteArr()	:	画像のバイナリデータ					(ByteArray)
//******************************************************************

package com.ID3.id3v2Reader{
	public class Id3v2Pic{
		
		import flash.filesystem.*;
		import flash.utils.ByteArray;
		
		private var fileStr = new FileStream();					//ファイルストリーム
		private var mp3File:File;										//mp3ファイルのFileオブジェクト
		private var byteArrPic:ByteArray=new ByteArray(); 	//フレーム本体
		
		//コンストラクタ
		public function Id3v2Pic(filePath:String, filePos:int, fileFrameSize:int){
			mp3File=new File(filePath);								//ファイルオブジェクト作成
			fileStr.open(mp3File, FileMode.READ);				//同期モードでファイルを開く
			id3TagRead(fileStr,filePos,fileFrameSize);			//(関数)id3タグの抽出
		}
		
		//ID3フレーム本体の抽出
		public function id3TagRead(fileStr:FileStream, filePos:int, fileFrameSize:int):void {
			fileStr.position=filePos;									//ファイル位置を歌詞のファイル位置に設定
			fileStr.readBytes(byteArrPic,0,fileFrameSize);		//byteArrPicに、ファイルストリームから画像バイナリデータ部分を読み取る。
			fileStr.close();													//ファイルストリームを閉じる
		}
		
		//画像バイナリデータのゲッターメソッド
		public function getPicByteArr():ByteArray{
			return byteArrPic;
		}
	}
}