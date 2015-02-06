//クラスの仕様
//歌詞を取得
//******************************************************************
//Id3Kashi(filePath:String, filePos:int, id3FrameSize:int)
//[入力]　	filePath			:	mp3のファイルパス						(String)
//				filePos			:	歌詞を格納しているファイル位置	(int)
//				fileFrameSize	:	歌詞のID3フレームヘッダ				(int)

//[出力]　	getKashi()			歌詞										(String)
//******************************************************************

package com.ID3.id3v2Reader{
	public class Id3v2Kashi{
		
		import flash.filesystem.*;
		import flash.utils.ByteArray;
		
		private var fileStr = new FileStream();		//ファイルストリーム
		private var mp3File:File;							//mp3ファイルのFileオブジェクト
		private var id3Fh:String; 							//フレーム本体
		
		//コンストラクタ
		public function Id3v2Kashi(filePath:String, filePos:int, fileFrameSize:int){
			mp3File=new File(filePath);								//ファイルオブジェクト作成
			fileStr.open(mp3File, FileMode.READ);				//同期モードでファイルを開く
			id3TagRead(fileStr,filePos,fileFrameSize);			//(関数)id3タグの抽出
		}
		
		//ID3フレーム本体の抽出
		private function id3TagRead(fileStr:FileStream, filePos:int, fileFrameSize:int):void {
			fileStr.position=filePos;												//ファイル位置を歌詞のファイル位置に設定
			
			
			
			//***************************************
			//入力された文字がshift-jis か unicode Big-Endiaｎ か判別してエンコードする。
			//***************************************
			if(fileFrameSize-1 > 2){
				
				fileStr.position-=1;
				
				var sampBArr1:ByteArray=new ByteArray();
				var sampBArr2:ByteArray=new ByteArray();
				fileStr.readBytes(sampBArr1 , 0 , 1);
				fileStr.readBytes(sampBArr2 , 0 , 1);
				
				//UnicodeかShift-jis判定
				if(sampBArr1[0]==parseInt("0xFF",16) && sampBArr2[0]==parseInt("0xFE",16)){		//タグ内容の2バイト分が"FF FE"であるとunicodeの可能性がある。
					fileStr.position +=4;
					
					/*//末尾２ビットの数値確認
					var sampBArr3:ByteArray=new ByteArray();
					var sampBArr4:ByteArray=new ByteArray();
					fileStr.readBytes(sampBArr3 , 0 , 1);
					fileStr.readBytes(sampBArr4 , 0 , 1);
					trace("[3]:"+sampBArr3[0]);
					trace("[4]:"+sampBArr4[0]);
					fileStr.position -=2;
					*/
					
					id3Fh=fileStr.readMultiByte(fileFrameSize-1, "unicode");					//unicode リトルエンディアンで読み込む
				}else{
					fileStr.position-=1;
					id3Fh=fileStr.readMultiByte(fileFrameSize+4, "shift_jis");
				}
			}else{
				fileStr.position-=1;
				id3Fh=fileStr.readMultiByte(fileFrameSize+4, "shift_jis");
			}
			
			
			//改行削除
			id3Fh=id3Fh.replace(/\r\n/g,"\n");
			fileStr.close();																//ファイルストリームを閉じる
		}
		
		//歌詞データのゲッターメソッド
		public function getKashi():String{
			return id3Fh;
		}
	}
}