//クラスの仕様
//SQLに格納するmp3のID3タグ情報を取得する。
//(ID3v2 3.0 サポート )Roxio Record Now! によるmp3変換データに対応
//(ID3v2 2.0 サポート )itunes によるmp3変換データに対応
//******************************************************************
//[入力]　Id3SqlThrow(mp3File:File)		mp3File　:　mp3のFileオブジェクト		(File)

//[出力]	getArtist() プロパティ 		アーティストを返す。					(String)
//				getTrack()						トラック番号								(Uint)
//				getGenre()						ジャンル									(String)
//				getTitle()						タイトル									(String)
//				getYears()						年代										(String)
//				getComm()						コメント									(String)
//				getAlbum()						アルバム名								(String)
//				getPlayTime()					演奏時間								(String)  →  例 5:30
//				getPicFlg()						画像の有無								(Boolean)
//				getPicFilePos()				画像のファイル位置					(Uint)
//				getPicFrameSize()			画像のフレーム本体サイズ			(Uint)
//				getKashiFlg()					歌詞の有無								(Boolean)
//				getPicFilePos()				歌詞のファイル位置					(Uint)
//				getPicFrameSize()			歌詞のフレーム本体サイズ			(Uint)
//				getFileError()					ファイル異常の有無					(Boolean)
//				getFileErrorMessage()		異常内容								(String)

//備考：
//Id3タグが空値の場合の出力結果
//getYears()  :  1970/1/1 (初期値)
//getTrack()	:	0

//******************************************************************

package com.ID3.id3v2Reader{
	public class Id3v2SqlThrow{
		
		import flash.filesystem.*;
		import flash.display.*;
		import flash.utils.ByteArray;

		private var fileStr = new FileStream();			//ファイルストリーム
		
		//曲情報の初期化
		private var albumStr:	String	="";				//mp3から取得する　アルバム
		private var trackStr:	String	="";				//mp3から取得する　トラック番号
		private var genreStr:	String	="";				//mp3から取得する　ジャンル
		private var titleStr:		String	="";				//mp3から取得する　タイトル
		private var yearStr:	String	="";					//mp3から取得する　年代
		private var commStr:	String	="";				//mp3から取得する　コメント
		private var artistStr:	String	="";				//mp3から取得する　アーティスト
		
		private var playTimeStr:String	="";				//mp3から取得する　演奏時間
		private var filePathStr:String 	="";				//mp3から取得する　ファイルパス
		
		private var picFlg:		Boolean	=false;				//mp3から取得する　画像の有無
		private var picFilePos:		uint	=0;				//mp3から取得する　画像のファイルポジション(byte)
		private var picFrameSize:	uint	=0;				//mp3から取得する　画像のフレームヘッダーサイズ(byte)
		
		private var kashiFlg:		Boolean	=false;			//mp3から取得する　歌詞の有無
		private var kashiFilePos:	uint	=0;				//mp3から取得する　歌詞のファイルポジション(byte)
		private var kashiFrameSize:uint	=0;					//mp3から取得する　歌詞のフレームヘッダーサイズ(byte)
		
		private var fileError:Boolean	=false;				//ファイル異常の有無（true : 異常有）
		private var fileErrorMessage:String	="";			//異常内容
		
		private var gainError:Boolean = false;				//mp3Gainの未設定・設定値の誤りがある
		private var gainErrorMes:String = "";				//ゲインに関するエラーメッセージ
		
		private var fileStrByte:		uint	=0;			//ファイルストリームの全バイト数
		
		
		//■■■■■■■■■■■■■■■■■■■■■
		//処理内容トレース
		//■■■■■■■■■■■■■■■■■■■■■
		
		//trace("Id3SqlThrowクラス　処理内容をトレースします。 \n\n ");
		//trace("\n\nコード区分\tコード番号\t関数名\t関数の処理概要\t親関数\t");
		private function proccessTrace(codeArea:String, codeNo:String, funcName:String, funcCap:String, funcParent:String):void{
			if(codeNo != ""){	//表示したくないコメントを指定
				//trace(codeArea+"\t"+codeNo+"\t"+funcName+"\t"+funcCap+"\t"+funcParent);
			}
		}
		
		//■■■■■■■■■■■■■■■■■■■■■
		//[CO] コンストラクタ・初期起動
		//■■■■■■■■■■■■■■■■■■■■■
		
		//コンストラクタ
		public function Id3v2SqlThrow(mp3File:File){
			//ファイルパスを取得
			filePathStr=mp3File.nativePath;
			fileStr.open(mp3File, FileMode.READ);				//同期モードでファイルを開く
			fileStrByte=fileStr.bytesAvailable;						//ファイルストリームの全バイト数を取得
			id3TagRead(fileStr);											//(関数)id3タグの抽出
		}
		
		//TX-2
		//ID3タグの抽出
		public function id3TagRead(fileStr:FileStream):void {			
			proccessTrace("クラスId3SqlThrow","CL-2","id3TagRead","ID3タグの抽出","mp3LoadComplete");
			//TX-2-1
			
			//バイトストリームが10バイト以上存在するか？（ファイルエラーにより、.mp3拡張子でありながら、0[byte]のファイルが存在する為、確認する。）
			if(fileStr.bytesAvailable >10 ){
				//ID3v1のタグを抽出
				//------------------
				//ID3v1 の場合
				//------------------
				if (fileStr.readMultiByte(3, "shift_jis").match(/tag/i)) {						//格納されている文字がTAG, tagだったらid3v1と認識
					proccessTrace("クラスId3SqlThrow","CL-2-1","id3TagRead　分岐処理　階層1","└(バージョン不一致)id3v1です。タグ読み込み処理を無視しました。","");
					//警告表示　id3v1 はサポートしていない為、異常表示
					fileError=true;		//ファイル異常有り
					fileErrorMessage += "▼異常：ID3タグのバージョンがid3v1です。[修正方法]mp3ファイルのプロパティで曲情報を改めて入力し直してください。";		//異常内容
				} 
				
				//TX-2-2
				//ID3v2のタグを抽出
				//------------------
				//ID3v2 の場合
				//------------------
				fileStr.position = 0;																						//	ファイル位置を0に移動。
				//id3v2識別																								//	コメント解説： <>はバイト数を示す。
				if (fileStr.readMultiByte(3, "shift_jis").match(/id3/i)) {										//	<3> id3v2識別　 "id3"が含まれている場合id3v2であると判別できる。
						proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層1","ID3v2を認識。タグ抽出開始。","");
						
						//id3v2 バージョンを取得。
						var id3MjVersion:uint=binaryDecOutput(fileStr.readMultiByte(1, "shift_jis"));			//	<1> id3v2のメジャーバージョン	binaryDecカスタム関数でバイナリコード10進数を取得している。
						var id3ReversionNo:uint=binaryDecOutput(fileStr.readMultiByte(1, "shift_jis"));		//	<1> id3v2の改訂バージョン		〃
						
						//id3v2 3.0である場合、タグを読み込む。そうでない場合、以降の処理を無視する。
						proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層1","(判定)id3v2 メジャーバージョン、改訂番号","")
						

						//------------------
						//ID3v2 3.0 の場合
						//------------------
						if(id3MjVersion==3 && id3ReversionNo==0){
								proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","└(id3v2 3.0認識)id3v2 3.0 タグ読み込み処理を行います。","");
								
								//タグサイズを抽出
								//タグサイズはmp3同期ワードを回避した(0xFFを使わない)7ビットで表現する整数 :  シンクセーフ整数　で表現されている。
								fileStr.position=6;																										//	<4>offset:6  id3v2のタグサイズ
								var id3Size1:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　1バイト目を取り出す
								var id3Size2:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　2バイト目を取り出す
								var id3Size3:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　3バイト目を取り出す
								var id3Size4:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　4バイト目を取り出す
								var id3TagSize:uint=syncSafeOut(id3Size1, id3Size2, id3Size3, id3Size4);							//シンクセーフ整数→通常のバイナリ数値データに変換
			
								proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","id3v2 3.0認識後処理：タグサイズは "+String(id3TagSize)+" [Byte]  ( offset 10 Byte以降がタグデータ )","");
								
								//mp3本体(音声)のファイルサイズ	(タグを除いたおおよそのサイズ)
								var id3Mp3FileSize:uint=fileStrByte-(10+id3TagSize);
								id3Mp3FileSize = Math.floor(id3Mp3FileSize/(256000/8));
								var H:String=String(Math.floor(id3Mp3FileSize/60));
								var M:String=String(id3Mp3FileSize-Math.floor(id3Mp3FileSize/60)*60);
								M=(Number(M)<10) ? ("0"+M) : M;
								playTimeStr =H+":"+M;			//演奏時間
								proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","mp3の音声ファイルサイズは "+String(id3Mp3FileSize)+" [Byte]  / 演奏時間："+playTimeStr+"( タグを除いたおおよそのサイズ、256kbpsと仮定した場合 )","");
								
								//フレーム本体抽出
								while(fileStr.position < id3TagSize+10){																				//ファイルの位置がタグサイズ+10まで処理を続ける。
									if(fileStr.bytesAvailable >11){																							//フレームID<4>+フレーム本体サイズ<4>+フラグ<3>以上のバイトサイズが存在する場合、正常ファイルとみなす。
										//フレームヘッダーを抽出 																							//(ID<4>, フレーム本体サイズ<4>, フラグ<3>, 内容<サイズ>)を読み込み
										var id3FhId:String=fileStr.readMultiByte(4, "shift_jis");													//	<4>フレームヘッダー　ID
										//フレームヘッダの正規化マッチング
										var myRegExp:RegExp= /[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]/;									//フレームヘッダは大文字英数の4文字と決まりがある。
										var myRegBool:Boolean = myRegExp.test(id3FhId);														//上記にマッチする場合、フレームヘッダーIDと認識し、trueを返す。
										
										if(myRegBool == false){																							//フレームヘッダーIDが認識されない場合、whileループを終了します。
											break;
										}
										
										//フレームヘッダー　フレーム本体サイズ<4>
										var varByte:ByteArray=new ByteArray();
										fileStr.readBytes(varByte,0,4);
										var id3FhSize:uint = varByte.readInt();																			//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
										
										proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","id3v2 3.0認識後処理： ”"+id3FhId+"”フレーム本体サイズは "+String(id3FhSize)+" [Byte] です。 ( フレームヘッダーを除いたタグのデータサイズ )","");
										
										
										//フレーム本体を抽出
										fileStr.position+=3;																									//フレームヘッダー フラグ 3Byte分を移動
										var id3Fh:String="";																								//フレーム本体　を格納するid3Fhを初期化
										if( fileStr.bytesAvailable > id3FhSize){																			//取り出せるバイトストリームが、フレーム本体サイズより大きければ正常ファイルと見なす。
											//ジャケット画像ならば画像データを抽出 JPEG, PNG, BMP, GIF, JPGに対応。それ以外はファイル異常とみなす。
											var isImageGeted:Boolean = false;	//正常に画像データを取得できたか？
											var prevFhImageMimePos:uint = 0;	//戻るmimetypeの位置
											if(id3FhId=="APIC"){
												picFlg=true;
												var id3FhImageMime = fileStr.readMultiByte(10, "shift_jis");
												prevFhImageMimePos = 10;
												if(id3FhImageMime == "image/jpeg"){										//JPEG
													fileStr.position+=3;
													picFilePos=fileStr.position;												//画像のファイルポジションを取得
													picFrameSize=id3FhSize-1-(10+3);									//フレーム本体サイズを取得
													fileStr.position += id3FhSize-1 - (10 + 3);								//ファイル位置をフレーム本体(画像データ)分、移動する。
													isImageGeted = true;
												}else{
													fileStr.position-=10;														//一致しない場合、ファイル位置を戻す。
													id3FhImageMime = fileStr.readMultiByte(9, "shift_jis");
													prevFhImageMimePos = 9;
													if(id3FhImageMime == "image/gif"){									//GIF
														fileStr.position+=3;
														picFilePos=fileStr.position;											//画像のファイルポジションを取得
														picFrameSize=id3FhSize-1-(9+3);									//フレーム本体サイズを取得
														fileStr.position += id3FhSize-1 - (9 + 3);								//ファイル位置をフレーム本体(画像データ)分、移動する。
														isImageGeted = true;
													}else{
														fileStr.position-=9;														//一致しない場合、ファイル位置を戻す。
														id3FhImageMime = fileStr.readMultiByte(9, "shift_jis");
														prevFhImageMimePos = 9;
														if(id3FhImageMime == "image/png"){									//PNG
															fileStr.position+=3;
															picFilePos=fileStr.position;									//画像のファイルポジションを取得
															picFrameSize=id3FhSize-1-(9+3);									//フレーム本体サイズを取得
															fileStr.position += id3FhSize-1 - (9 + 3);						//ファイル位置をフレーム本体(画像データ)分、移動する。
															isImageGeted = true;
														}else{
															fileStr.position-=9;											//一致しない場合、ファイル位置を戻す。
															id3FhImageMime = fileStr.readMultiByte(9, "shift_jis");
															prevFhImageMimePos = 9;
															if(id3FhImageMime == "image/bmp"){								//BMP
																fileStr.position+=3;
																picFilePos=fileStr.position;								//画像のファイルポジションを取得
																picFrameSize=id3FhSize-1-(9+3);								//フレーム本体サイズを取得
																fileStr.position += id3FhSize-1 - (9 + 3);					//ファイル位置をフレーム本体(画像データ)分、移動する。
																isImageGeted = true;
															}else {
																fileStr.position-=9;										//一致しない場合、ファイル位置を戻す。
																id3FhImageMime = fileStr.readMultiByte(3, "shift_jis");
																prevFhImageMimePos = 3;
																if(id3FhImageMime == "JPG"){								//JPEG (規格外のデータ？)
																	fileStr.position+=3;
																	picFilePos=fileStr.position;							//画像のファイルポジションを取得
																	picFrameSize=id3FhSize - 1 -( 3 + 3 );					//フレーム本体サイズを取得
																	fileStr.position += id3FhSize-1 - ( 3 + 3 );			//ファイル位置をフレーム本体(画像データ)分、移動する。
																	isImageGeted = true;
																}
															}
														}
													}
												}
												//画像データのmimeTypeが上記に該当しない場合、ファイル異常とみなす。
												if (!isImageGeted) {
													fileStr.position -= prevFhImageMimePos;
													//警告表示
													fileError=true;		//ファイル警告有り
													fileErrorMessage += "▼警告：ジャケット画像が不明な形式で入力されています。[修正方法]iTunesを起動し、プロパティでジャケット画像を入力し後、削除をしてください。"+"\n";		//異常内容
												}
											
											//ジャケット画像以外の抽出
											}else{
												if(id3FhId=="COMM" || id3FhId=="USLT"){
													//歌詞、コメントの抽出
													fileStr.position+=4;
													if(id3FhId=="USLT"){
														kashiFilePos = fileStr.position;																	//歌詞のファイルポジションと、フレームサイズを取得
														kashiFrameSize = id3FhSize-1-4-4;
													}
													id3Fh=fileStr.readMultiByte(id3FhSize-1-4, "shift_jis");									//<フレーム本体サイズ> フレーム本体　を取り出す
												}else{
													//その他情報の抽出
													//***************************************
													//入力された文字がshift-jis か unicode Big-Endiaｎ か判別してエンコードする。
													//***************************************
													if(id3FhSize-1 > 2){
														var sampBArr1:ByteArray=new ByteArray();
														var sampBArr2:ByteArray=new ByteArray();
														
														fileStr.readBytes(sampBArr1 , 0 , 1);
														fileStr.readBytes(sampBArr2 , 0 , 1);
														fileStr.position-=2;
														//UnicodeかShift-jis判定
														if(sampBArr1[0]==parseInt("0xFF",16) && sampBArr2[0]==parseInt("0xFE",16)){		//タグ内容の2バイト分が"FF FE"であるとunicodeの可能性がある。
															//id3Fh=fileStr.readMultiByte(id3FhSize-1, "unicodeFFFE");		//unicode ビックエンディアンで読み込む
															id3Fh=fileStr.readMultiByte(id3FhSize-1, "unicode");					//unicode リトルエンディアンで読み込む (後々のExcel Unicodeと一致検索させる都合上、リトルエンディアンが良い)
														}else{
															id3Fh=fileStr.readMultiByte(id3FhSize-1, "shift_jis");
														}
													}else{
														id3Fh=fileStr.readMultiByte(id3FhSize-1, "shift_jis");
													}
												}
												
												//項目と一致するフレーム本体を、テキストフィールドに入力する。
												switch(id3FhId){
													case "TALB":						//アルバム
														albumStr=id3Fh;
														break;
													case "TRCK":					//トラック番号
														if(id3Fh.match(/\//i)){		//トラックに全体数が含まれる場合、トラック数を抽出する。　(例) 2/16　→ 2
															var trackSpl:Array=id3Fh.split("/");
															id3Fh=trackSpl[0];
														}
														trackStr=id3Fh;
														break;
													case "TCON":					//ジャンル
														if(id3Fh.match(/\([0-9][0-9]\)/i) || id3Fh.match(/\([0-9]\)/i)){		//ジャンルコードの場合、エラー表示させる。　例 (39)→エラー
															//ファイルの破損(フレームID部分以降の破損)
															//警告表示
															fileError=true;		//ファイル警告有り
															fileErrorMessage += "▼警告：ジャンルにジャンルコード(数値)が記入されています。[修正方法]mp3のプロパティで改めてジャンルを入力し直してください。";		//異常内容
														}
														genreStr=id3Fh;
														break;
													case "TIT2":						//タイトル
														titleStr=id3Fh;
														break;
													case "TYER":						//年代
														yearStr=id3Fh;
														break;
													case "COMM":					//コメント
														commStr=id3Fh;
														break;
													case "USLT":						//歌詞
														kashiFlg=true;
														break;
													case "TPE1":						//アーティスト
														artistStr=id3Fh;
														break;
													default:
														proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead switch default",id3FhId+" は想定していないフレームIDです。","");
												}
											}
										}else{
											fileError=true;		//ファイル異常有り
											fileErrorMessage += "▼異常：データが破損している可能性があります。フレームヘッダー部分以降の破損の為、タグ読み込み処理を無視しました。[修正方法]改めてリッピングし直してください。";		//異常内容
										}
										proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","id3v2 3.0認識後処理：フレーム本体は "+id3Fh,"");
									}else{
										//ファイルの破損(フレームID部分以降の破損)
										//異常表示
										proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead　分岐処理　階層0","└(解析無視)読み込んだmp3ファイルが破損している可能性があります。タグ読み込み処理を無視しました。","");
										fileError=true;		//ファイル異常有り
										fileErrorMessage += "▼異常：データが破損している可能性があります。フレームＩＤ部分以降の破損の為、タグ読み込み処理を無視しました。[修正方法]改めてリッピングし直してください。";		//異常内容
										break;					//whileループを終了。
									}
								}//while(fileStr.position < id3TagSize+10){
								
								//アーティスト名、曲名のいずれかが未入力の場合警告する。
								if(artistStr=="" || titleStr=="" ){
									//警告表示　id3v2 2.0 は正式サポートしていない為、警告表示
									fileError=true;		//ファイル異常有り
									fileErrorMessage += "▼警告：曲名またはアーティスト名が未入力です。[修正方法]mp3ファイルのプロパティから曲名とアーティスト名を入力してください。";		//異常内容
								}
								
								
								
								//------------------------------
								//mp3Gainの適用有無を確認する
								//------------------------------
								/*
									APETAGの有無と、入力値を確認する。
									通常はAPETAGの後ろにTAG(128Byte)とAPETAGのタグ情報(26Byte)が格納されている。
									Windowsの「プロパティ」でデータの編集が行われていない場合はTAGが追加されていないので、注意。
								*/
								
								gainError 	= true;										//mp3Gain漏れ
								var winPropTAG_length:uint = 128 + 32;					//Windowsの「プロパティ」でデータの編集された時に追加されるTAGの長さ(128Byte) + 末端APETAGタグと移行にあるAPETAGフレーム情報(32Byte)
								fileStr.position = fileStrByte- winPropTAG_length;		//MP3Gain APETAGフッターの先頭を指定。
								//APETAGの位置(候補は2箇所)を探す。
								if (! fileStr.readMultiByte(6, "shift_jis").match(/APETAG/i)) {
									fileStr.position += winPropTAG_length - 6 - (26+6);
									if (! fileStr.readMultiByte(6, "shift_jis").match(/APETAG/i)) {
										fileStr.position -= winPropTAG_length;
									}else {
										winPropTAG_length = 0 + 32;							//Windowsの「プロパティ」でデータの編集された時に追加されるTAGがない場合(0Byte) + 末端APETAGタグと移行にあるAPETAGフレーム情報(32Byte)
									}
								}
								fileStr.position -= 6;	//一旦元に戻す。
								
								//trace("▼position (end of): " + String(fileStrByte - fileStr.position));
								
								//APETAGの取得
								if (fileStr.readMultiByte(6, "shift_jis").match(/APETAG/i)){
									//APEタグの長さを取得。
									fileStr.position += 6;
									var tempByte:ByteArray=new ByteArray();
									var tempReplaceByte:ByteArray=new ByteArray();
									tempByte.length = 4;
									tempReplaceByte.length = 4;
									tempByte.position = 0;
									fileStr.readBytes(tempByte,2,2);
									//trace(tempByte[0]+":"+tempByte[1]+":"+tempByte[2]+":"+tempByte[3]);
									tempByte.readBytes(tempReplaceByte,0,4);		//ひっくり返す
									tempByte[2] = tempReplaceByte[3];
									tempByte[3] = tempReplaceByte[2];
									tempByte.position = 0;
									//trace(tempByte[0]+":"+tempByte[1]+":"+tempByte[2]+":"+tempByte[3]);
									var apeTagLength:uint = tempByte.readInt();																			//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
									
									//APEタグの数を取得。
									fileStr.position += 2;
									tempByte = new ByteArray();
									tempReplaceByte=new ByteArray();
									tempByte.length = 4;
									tempReplaceByte.length = 4;
									tempByte.position = 0;
									fileStr.readBytes(tempByte,2,2);
									tempByte.readBytes(tempReplaceByte,0,4);		//ひっくり返す
									tempByte[2] = tempReplaceByte[3];
									tempByte[3] = tempReplaceByte[2];
									tempByte.position = 0;
									var apeTagNum:uint = tempByte.readInt();																			//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
									
									//MP3Gain APETAGの内容を指定。
									fileStr.position = fileStrByte -winPropTAG_length -apeTagLength +32;
									var apeTagDataLength:uint = 0;
									
									//trace("▼apeTagNum: "+apeTagNum);
									//trace("▼apeTagLength: "+apeTagLength);
									
									//trace("▼apeTagLength : " + String(apeTagLength));
									
									for(var i:uint=0; i<apeTagNum; i++){
										
										//trace("->(Loop) position (end of): " + String(fileStrByte - fileStr.position));
										
										//APEタグデータ長を取得
										//apeTagDataLength = uint(fileStr.readMultiByte(1, "shift_jis"));
										tempByte = new ByteArray();
										tempReplaceByte=new ByteArray();
										tempByte.length = 4;
										tempReplaceByte.length = 4;
										tempByte.position = 0;
										fileStr.readBytes(tempByte,2,2);
										tempByte.readBytes(tempReplaceByte,0,4);		//ひっくり返す
										tempByte[2] = tempReplaceByte[3];
										tempByte[3] = tempReplaceByte[2];
										tempByte.position = 0;
										apeTagDataLength = tempByte.readInt();																			//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
									
										fileStr.position += 6;
										
										//trace("▼apeTagDataLength["+i+"]: "+apeTagDataLength);
										
										//APEタグのラベル名を取得
										var labelStr:String = "";
										var labelStr_s:String = fileStr.readMultiByte(1, "shift_jis");
										var checkLoop:uint = 0;
										while( labelStr_s != "" ){
											//trace("▼ - checkLoop:"+checkLoop);
											labelStr = labelStr + labelStr_s;
											labelStr_s = fileStr.readMultiByte(1, "shift_jis");
										}
										
										//trace("▼labelStr["+i+"]: "+labelStr);
										
										if (labelStr.match(/REPLAYGAIN_TRACK_GAIN/i) || labelStr.match(/replaygain_track_gain/i) ){
											
											//MP3Gain REPLAYGAIN_TRACK_GAINの設定値の位置を指定。Gain設定値の計算方法：89(デフォルト) - MP3Gain REPLAYGAIN_TRACK_GAIN値
											var replayTrackGain:Number = 89.0 - Number(fileStr.readMultiByte(apeTagDataLength-3, "shift_jis"));
											fileStr.position += 3;
											trace("▼replayTrackGain["+i+"]: "+replayTrackGain);
											if( replayTrackGain <= 92.200 || replayTrackGain >= 93.800){	//93dB ±0.8
												//trace("replayTrackGainが93dB以外の設定値になっています");
												fileErrorMessage		+= "▼異常：MP3Gainの設定値が誤っている可能性があります。MP3Gain設定値："+replayTrackGain+"[dB]。[修正方法]MP3Gainを適用し直してください。";		//異常内容
												gainErrorMes 			+= "　　→MP3Gainの設定値が誤っている可能性があります。\n　　現在のMP3Gain設定値： "+replayTrackGain+"[dB]\n";
											}else{
												gainError 	= false;		//mp3Gain適正値
											}
											break;
										}else{
											//APETAG ラベル名がREPLAYGAIN_TRACK_GAIN以外の場合
											fileStr.position += apeTagDataLength;
										}
									}
									if(gainError){
										fileErrorMessage		+= "▼異常：読み込んだmp3ファイルはMP3Gainを適用していますが、データが壊れている可能性があります。[修正方法]改めてMP3Gainを適用し直してください。";		//異常内容
										gainErrorMes 			+= "　　→MP3Gainが適用されていません。\n";
									}
									
								}else{
									fileErrorMessage		+= "▼異常：MP3Gainが適用されていない可能性があります。[修正方法]MP3Gainを適用してください。";		//異常内容
									gainErrorMes 			+= "　　→MP3Gainが適用されていません。\n";
								}
						}
						
						
						
						//------------------
						//ID3v2 2.0 の場合　(itunesなど)
						//------------------
						//	コメント解説： <>はバイト数を示す。
						else if(id3MjVersion==2 && id3ReversionNo==0){												//	<3> id3v2 2.0識別
							proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","└(id3v2 2.0認識)id3v2 2.0 タグ読み込み処理を行います。","");
								
								//タグサイズを抽出
								//タグサイズはmp3同期ワードを回避した(0xFFを使わない)7ビットで表現する整数 :  シンクセーフ整数　で表現されている。
								fileStr.position=6;																										//	<4>offset:6  id3v2のタグサイズ
								var id3m2Size1:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　1バイト目を取り出す
								var id3m2Size2:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　2バイト目を取り出す
								var id3m2Size3:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　3バイト目を取り出す
								var id3m2Size4:String=fileStr.readMultiByte(1, "shift_jis");													//	<1>〃　4バイト目を取り出す
								var id3m2TagSize:uint=syncSafeOut(id3m2Size1, id3m2Size2, id3m2Size3, id3m2Size4);			//シンクセーフ整数→通常のバイナリ数値データに変換
			
								proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","id3v2 2.0認識後処理：タグサイズは "+String(id3m2TagSize)+" [Byte]  ( offset 10 Byte以降がタグデータ )","");
								
								//mp3本体(音声)のファイルサイズ	(タグを除いたおおよそのサイズ)
								var id3m2Mp3FileSize:uint=fileStrByte-(10+id3m2TagSize);
								id3m2Mp3FileSize = Math.floor(id3m2Mp3FileSize/(256000/8));
								var Hm2:String=String(Math.floor(id3m2Mp3FileSize/60));
								var Mm2:String=String(id3m2Mp3FileSize-Math.floor(id3m2Mp3FileSize/60)*60);
								Mm2=(Number(Mm2)<10) ? ("0"+Mm2) : Mm2;
								playTimeStr =Hm2+":"+Mm2;			//演奏時間
								proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","mp3の音声ファイルサイズは "+String(id3m2Mp3FileSize)+" [Byte]  / 演奏時間："+playTimeStr+"( タグを除いたおおよそのサイズ、256kbpsと仮定した場合 )","");
							
							
								//フレーム本体抽出
								while(fileStr.position < id3m2TagSize+10){																			//ファイルの位置がタグサイズ+10まで処理を続ける。
									if(fileStr.bytesAvailable >7){																							//フレームID<3>+フレーム本体サイズ<3>+フラグ<1>以上のバイトサイズが存在する場合、正常ファイルとみなす。
										//フレームヘッダーを抽出 																								//(ID<3>, フレーム本体サイズ<3>, フラグ<1>, 内容<サイズ>)を読み込み
										var id3m2FhId:String=fileStr.readMultiByte(3, "shift_jis");													//	<3>フレームヘッダー　ID
										//フレームヘッダの正規化マッチング
										var myRegExpm2:RegExp= /[A-Z0-9][A-Z0-9][A-Z0-9]/;													//フレームヘッダは大文字英数の3文字と決まりがある。
										var myRegBoolm2:Boolean = myRegExpm2.test(id3m2FhId);														//上記にマッチする場合、フレームヘッダーIDと認識し、trueを返す。
										
										if(myRegBoolm2 == false){																							//フレームヘッダーIDが認識されない場合、whileループを終了します。
											break;
										}
										
										
										//フレームヘッダー　フレーム本体サイズ<3>
										//3バイトByteArray　を10進数整数に変換する。readInt()メソッドは4バイトByteArrayに対して実行可能である。そこで1バイト分0x00を格納し、4バイト分のデータにする。
										var varBytem2:ByteArray=new ByteArray();			//整数変換するByteArray
										varBytem2[0]=0;												//0を格納する。
										varBytem2.position=1;										//ファイル位置を1にする。
										
										var varByteCo:ByteArray=new ByteArray();		//3バイトデータを読み込むBytearray
										fileStr.readBytes(varByteCo,0,3);					//ファイルストリームから3バイト読み込み
										varBytem2.writeBytes(varByteCo,0,3);				//読み込んだデータをvarByteに書き込む。
										varBytem2.position=0;										//ファイル位置を0に戻す。
					
										var id3m2FhSize:uint = varBytem2.readInt();			//<4>取得したByteArrayオブジェクト32bit分をの32bit整数値に変換する。
										proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","id3v2 2.0認識後処理： ”"+id3m2FhId+"”フレーム本体サイズは "+String(id3m2FhSize)+" [Byte] です。 ( フレームヘッダーを除いたタグのデータサイズ )","");
										
										
										//フレーム本体を抽出
										fileStr.position+=1;																//フレームヘッダー フラグ 1Byte分を移動
										var id3m2Fh:String="";														//フレーム本体　を格納するid3Fhを初期化
										if( fileStr.bytesAvailable > id3m2FhSize){								//取り出せるバイトストリームが、フレーム本体サイズより大きければ正常ファイルと見なす。
										
											//ジャケット画像ならば画像データを抽出。　(10/30)画像表示可能かまで、動作チェックしていない。
											if(id3m2FhId=="PIC"){
												
												//picFlg=true;
												picFlg=false;																	//ID3v2 2.0ではジャケット画像表示をサポートしない。
												fileStr.position+=4;															//イメージMIMEの情報分、ファイル位置を移動
												fileStr.position+=2;															//フラグ分、ファイル位置を移動
												picFilePos=fileStr.position;												//画像のファイルポジションを取得
												picFrameSize=id3m2FhSize-1-(4+2);									//フレーム本体サイズを取得
												fileStr.position+=id3m2FhSize-1-(4+2);								//ファイル位置をフレーム本体(画像データ)分、移動する。
												
											//ジャケット画像以外の抽出
											}else{
			
												if(id3m2FhId=="ULT"){
													//歌詞、コメントの抽出
													fileStr.position+=4;
													kashiFilePos = fileStr.position;																	//歌詞のファイルポジションと、フレームサイズを取得
													kashiFrameSize = id3m2FhSize-1-4-4;
													id3m2Fh=fileStr.readMultiByte(id3m2FhSize-1-4, "shift_jis");									//<フレーム本体サイズ> フレーム本体　を取り出す
													
												}else{
													//その他情報の抽出
													//id3m2Fh=fileStr.readMultiByte(id3m2FhSize-1, "shift_jis");										//<フレーム本体サイズ> フレーム本体　を取り出す
													
													//***************************************
													//入力された文字がshift-jis か unicode Big-Endiaｎ か判別してエンコードする。
													//***************************************
													if(id3m2FhSize-1 > 2){
														sampBArr1=new ByteArray();
														sampBArr2=new ByteArray();
														 fileStr.readBytes(sampBArr1 , 0 , 1);
														 fileStr.readBytes(sampBArr2 , 0 , 1);
														 fileStr.position-=2;
														 //UnicodeかShift-jisかの判定
														if(sampBArr1[0]==parseInt("0xFF",16) && sampBArr2[0]==parseInt("0xFE",16)){		//タグ内容の2バイト分が"FF FE"であるとunicodeの可能性がある。
															//id3m2Fh=fileStr.readMultiByte(id3m2FhSize-1, "unicodeFFFE");		//unicode ビックエンディアンで読み込む
															id3m2Fh=fileStr.readMultiByte(id3m2FhSize-1, "unicode");					//unicode リトルエンディアンで読み込む (後々のExcel Unicodeと一致検索させる都合上、リトルエンディアンが良い)
															trace("(unicode):"+id3m2Fh);
														}else{
															id3m2Fh=fileStr.readMultiByte(id3m2FhSize-1, "shift_jis");
															trace("(shift-jis):"+id3m2Fh);
														}
													}else{
														id3m2Fh=fileStr.readMultiByte(id3m2FhSize-1, "shift_jis");
														trace("(shift-jis2以下):"+id3m2Fh);
													}
												}
												
												//項目と一致するフレーム本体を、テキストフィールドに入力する。
												switch(id3m2FhId){
													case "TAL":						//アルバム
														albumStr=id3m2Fh;
														break;
													case "TRK":						//トラック番号
														if(id3m2Fh.match(/\//i)){		//トラックに全体数が含まれる場合、トラック数を抽出する。　(例) 2/16　→ 2
															var trackSplm2:Array=id3m2Fh.split("/");
															id3m2Fh=trackSplm2[0];
														}
														trackStr=id3m2Fh;
														break;
													case "TCO":						//ジャンル														
														if(id3m2Fh.match(/\([0-9][0-9]\)/i) || id3m2Fh.match(/\([0-9]\)/i)){		//ジャンルコードの場合、エラー表示させる。　例 (39)→エラー
															//ファイルの破損(フレームID部分以降の破損)
															//警告表示
															fileError=true;		//ファイル警告有り
															fileErrorMessage += "▼警告：ジャンルにジャンルコード(数値)が記入されています。[修正方法]mp3のプロパティで改めてジャンルを入力し直してください。";		//異常内容
														}
														genreStr=id3m2Fh;
														break;
													case "TT2":						//タイトル
														titleStr=id3m2Fh;
														break;
													case "TYE":						//年代
														yearStr=id3m2Fh;
														break;
													case "COM":						//コメント
														commStr="(エラー)ID3v2 2.0の為、コメント表示を行いません。";
														//commStr=id3m2Fh;
														break;
													case "ULT":						//歌詞
														kashiFlg=true;
														break;
													case "TP1":						//アーティスト
														artistStr=id3m2Fh;
														break;
													default:
														proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead switch default",id3m2FhId+" は想定していないフレームIDです。","");
												}
											}
										}else{
											fileError=true;		//ファイル異常有り
											fileErrorMessage += "▼異常：データが破損している可能性があります。フレームヘッダー部分以降の破損の為、タグ読み込み処理を無視しました。[修正方法]改めてリッピングし直してください。";		//異常内容
										}
										proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead 分岐処理　階層2","id3v2 3.0認識後処理：フレーム本体は "+id3m2Fh,"");
									}else{
										//ファイルの破損(フレームID部分以降の破損)
										//異常表示
										proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead　分岐処理　階層0","└(解析無視)読み込んだmp3ファイルが破損している可能性があります。タグ読み込み処理を無視しました。","");
										fileError=true;		//ファイル異常有り
										fileErrorMessage += "▼異常：データが破損している可能性があります。フレームＩＤ部分以降の破損の為、タグ読み込み処理を無視しました。[修正方法]改めてリッピングし直してください。";		//異常内容
										break;					//whileループを終了。
									}
								}//while(fileStr.position < id3m2TagSize+10){
								
								//アーティスト名、曲名のいずれかが未入力の場合警告する。
								if(artistStr=="" || titleStr=="" ){
									//警告表示　id3v2 2.0 は正式サポートしていない為、警告表示
									fileError=true;		//ファイル異常有り
									fileErrorMessage += "▼警告：曲名またはアーティスト名が未入力です。[修正方法]mp3ファイルのプロパティから曲名とアーティスト名を入力してください。";		//異常内容
								}

								//警告表示　id3v2 2.0 は正式サポートしていない為、警告表示
								fileError=true;		//ファイル異常有り
								fileErrorMessage += "▼警告：ID3タグのバージョンがid3v2 2.0です。[修正方法]mp3ファイルのプロパティから改めて曲情報を入力し直してください。";		//異常内容
						}						
						else{
							//id3v2のバージョンが未知のものであるとき。タグは抽出しない。
							//異常表示
							proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead　分岐処理　階層2","└(想定外のID3タグ)id3v2のメジャーバージョンと改訂番号が未知です。バージョンはid3v2 "+id3MjVersion+"."+id3ReversionNo+"です。タグ読み込み処理を無視しました。","");
							fileError=true;		//ファイル異常有り
							fileErrorMessage += "▼異常：id3v2のメジャーバージョンと改訂番号が未知です。→バージョンはid3v2 " + id3MjVersion + "." + id3ReversionNo + "です。タグ読み込み処理を無視しました。開発者にご連絡ください。";		//異常内容
						}
				}
			}else{
				//ファイルの破損(タグヘッダー部分以降の破損)
				//異常表示
				proccessTrace("クラスId3SqlThrow","CL-2-2","id3TagRead　分岐処理　階層0","└(解析無視)読み込んだmp3ファイルが破損している可能性があります。タグ読み込み処理を無視しました。","");
				fileError=true;		//ファイル異常有り
				fileErrorMessage += "▼異常：データが破損している可能性があります。タグヘッダー部分以降の破損の為、タグ読み込み処理を無視しました。[修正方法]改めてリッピングし直してください。";		//異常内容
			}
			fileStr.close();					//ファイルストリーミングを閉じる
		}
		
		//TX-FUNC
		//シンクセーフ整数→通常のバイナリ数値データに変換
		//[シンクセーフ整数] : タグサイズはmp3同期ワードを回避した(0xFFを使わない)7ビットで表現する整数で表現されている。
		private function syncSafeOut(... char1Byte:Array):uint{
			proccessTrace("クラスId3SqlThrow","CL-FUNC","syncSafeOut(.... char1Byte:String):Array","シンクセーフ整数→通常のバイナリ数値データに変換","");
			var binaryDec		:uint=0;																		//計算結果を格納する変数
			var binaryDecOut:uint=0;																		//returnする16進数を10進数に変換した結果
			var bitMask			:uint=0;																		//ビットマスク(指定した桁を取り出す為に使用)
			var maskedBinary:uint=0;																		//マスクされる1バイト文字

			for (var i:uint=0; i<char1Byte.length; i++){
				binaryDec=char1Byte[char1Byte.length-(i+1)].charCodeAt(0);				//1バイト文字列を10進数値に変換
				binaryDec=NaN?0:binaryDec;																//NaN(00がNaNになる)の場合、0を格納する。
				
				if( char1Byte.length-(i+2) >= 0){														//マスクされるバイト数値を用意。
					maskedBinary=char1Byte[char1Byte.length-(i+2)].charCodeAt(0);		//マスクされる1バイト数値
					maskedBinary=NaN?0:maskedBinary;												//NaN(00がNaNになる)の場合、0を格納する。
				}else{
					maskedBinary=0;
				}
				
				bitMask+=Math.pow(2,i);																	//マスクに用いるビットパターンの生成
				binaryDec=(binaryDec >> i ) | ((maskedBinary & bitMask) << (8-(i+1)) );	//演算
				binaryDecOut+=binaryDec*Math.pow(256 , i);										//計算例　8桁(4バイト)の16進数→10進数に変換： 00 00 1F 76 (16進数) →　00 00 31 118 (10進数) ⇒ 00*256^3 + 00*256^2 + 31*256^1 + 118*256^0 = 8054 (8桁16進数をの10進数に変換)

				//trace(" / マスクされるバイト文字["+String(char1Byte.length-(i+2))+"]："+String(maskedBinary)+" / マスク結果："+String(binaryDec));
				
				//計算例
				// 00 03 0B 04 (バイナリ)　の場合
				// 0000 0000 / 0000 0011 / 0000 1011 / 0000 0100 (2進数)
				// 000 0000 / 000 0011 / 000 1011 / 000 0100 (2進数の8ビット目を削除)
				// 0000 0000 / 0000 0000 / 1100 0101 / 1000 0100 (右に詰める)
			}
			return binaryDecOut;
		}
		
		//TX-FUNC
		//複数桁のバイナリコードに対し、10進数値(int)として返す。
		private function binaryDecOutput(... char1Byte:Array):uint{							//複数引数 に対して処理を行う。　引数は1バイトの文字列(バイナリコードがshift-jisに文字セットされ1バイト文字となっている)。
			proccessTrace("クラスId3SqlThrow","CL-FUNC","binaryDecOutput(... char1Byte:String):uint","複数桁のバイナリコードに対し、10進数値(int)として返す。","");
			var binaryDec:uint=0;
			var binaryDecOut:uint=0;
			for (var i:uint=0; i<char1Byte.length; i++){
				binaryDec=char1Byte[i].charCodeAt(0);											//1バイト文字列を10進数値に変換
				binaryDec=NaN?0:binaryDec;															//NaN(00がNaNになる)の場合、0を格納する。
				binaryDecOut+=binaryDec*Math.pow(256 , char1Byte.length-1-i);		//計算例　8桁(4バイト)の16進数→10進数に変換： 00 00 1F 76 (16進数) →　00 00 31 118 (10進数) ⇒ 00*256^3 + 00*256^2 + 31*256^1 + 118*256^0 = 8054 (8桁16進数をの10進数に変換)
			}
			return binaryDecOut;
		}
			
		
		//ゲッターメソッド
		public function getArtist():String{
			return artistStr;						//アーティスト
		}
		public function getTrack():uint{
			return Number(trackStr);				//トラック番号
		}
		public function getGenre():String{
			return genreStr;						//ジャンル
		}
		public function getTitle():String{
			return titleStr;						//タイトル
		}
		public function getYears():String{
			return yearStr;							//年代
		}
		public function getComm():String{
			return commStr;							//コメント
		}
		public function getAlbum():String{
			return albumStr;						//アルバム
		}
		public function getFilePath():String{
			return filePathStr;						//ファイルパス
		}		
		public function getPlayTime():String{
			return playTimeStr;						//演奏時間
		}
		public function getPicFlg():Boolean{
			return picFlg;							//画像の有無
		}
		public function getPicFilePos():uint{
			return picFilePos;						//画像のファイルポジション
		}
		public function getPicFrameSize():uint{
			return picFrameSize;					//画像のフレームヘッダーサイズ
		}
		public function getKashiFlg():Boolean{
			return kashiFlg;						//歌詞の有無
		}
		public function getKashiFilePos():uint{
			return kashiFilePos;					//歌詞のファイルポジション
		}
		public function getKashiFrameSize():uint{
			return kashiFrameSize;					//歌詞のフレームヘッダーサイズ
		}
		public function getFileError():Boolean{
			return fileError;						//ファイル異常の有無
		}
		public function getFileErrorMessage():String{
			return fileErrorMessage;				//ファイル異常内容
		}
		public function getGainError():Boolean{
			return gainError;						//mp3gain漏れ・設定値誤り
		}
		public function getGainErrorMes():String{
			return gainErrorMes;					//mp3Gainエラーメッセージ
		}
	}
}