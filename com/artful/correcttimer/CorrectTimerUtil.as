package com.artful.correcttimer
{
	/*
	* Copyright(c) 2010 artful.jp
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
	* The MIT License
	* http://www.opensource.org/licenses/mit-license.php
	
		[プロパティ] 
		delay:Number
		秒単位で指定したタイマーイベント間の遅延です。(既存のTimerクラスのミリ秒単位とは違うので注意) 

		repeatCount:int 
		タイマーを実行する合計回数を設定します。 

		running:Boolean
		タイマーの現在の状態です。タイマーの実行中は true、それ以外は false です。 

		[メソッド] 
		Timer
		(delay:Number, repeatCount:int = 0) コンストラクタ 

		reset
		():void タイマーが実行されている場合はタイマーをリセットします(稼動中の場合は0から再カウント)。 

		start
		():void タイマーがまだ実行されていない場合は、タイマーを起動します。 

		stop
		():void タイマーを停止します。 

		[イベント] 
		TIMER
		delayプロパティで設定された時間間隔に達するたびに送出されます。 

		TIMER_COMPLETE
		repeatCountで設定された回数に達した際に送出されます。 
	*/
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	
	/**
	* カスタムタイマークラス
	*
	* @description 
	* @usage               
	*       <code>
	*       </code>
	* @author               Daisuke Funato
	* @since                Flash Player 10 (ActionScript 3.0)
	* @version              0.20100521
	* @history             
	*       20100521        作成
	*/
	
	public class CorrectTimerUtil extends EventDispatcher
	{
		private var _snd:Sound;
		private var SAMPLING_COUNT:int 		=	2205;	//0.05秒単位

		private var _cntTmp:int 			=	0;
		private var _repeatCountTmp:int		=	0;
		private var _repeatCount:int 		=	0; 
		private var _statusFlg:Boolean 		=	false;
		private var _cnt:int				=	0;

		public function CorrectTimerUtil(_delayInit:Number=1,_cntInit:int=1)
		{
			super();
			
			delay = _delayInit;
			repeatCount = _cntInit;
			
			initTimer();
		}
		
		private function initTimer():void{
			_snd = new Sound();
			_snd.addEventListener(SampleDataEvent.SAMPLE_DATA,sampleDataHandler);
		}
		
		private function sampleDataHandler(event:SampleDataEvent):void{
			//空の音声を流して時間を経過させる
			for (var i:int = 0; i < SAMPLING_COUNT; i++) 
			    { 
			        var n:Number = 0; 
			        event.data.writeFloat(n); //無音を挿入
			        event.data.writeFloat(n); //
			    }

				if(_repeatCountTmp <= _repeatCount){
					if(_cntTmp < _cnt ){
						_cntTmp++;
					}
					else{
						this.dispatchEvent(new Event("TIMER"));
						_cntTmp = 0;
						_repeatCountTmp++;
					}
				}
				else{
					this.dispatchEvent(new Event("TIMER_COMPLETE"));
					_repeatCountTmp = 0;
					this.stop();
				}
		}
		
		/** タイマースタート **/
		public function start():void{
			_statusFlg = true;
			_snd.play();

		}
		
		/** タイマーストップ **/
		public function stop(resetFlg:Boolean = false):void{
			_statusFlg = false;
			_snd.removeEventListener(SampleDataEvent.SAMPLE_DATA,sampleDataHandler);

			if(resetFlg){
				initTimer();
				start();
			}
		}
		
		/** タイマーリセット **/
		public function reset():void{
			_repeatCountTmp = 0;
			_cntTmp = 0;
			//単純に0にするだけだと現存のSAMPLE_DATA_EVENTが動いている場合があるため再生成
			this.stop(true);
		}
		
		
		/** タイマー粒度(単位：sec) 最小0.05秒(2205サンプル)刻みまで **/
		public function set delay(val:Number):void{
			_cnt = (val*44100 / 2205)-1;
		}

		/** タイマー回数 **/
		public function set repeatCount(val:int):void{
			_repeatCount = val;
		}

		/** タイマーが稼動しているかどうかを返す **/
		public function get running():Boolean{
			return _statusFlg;
		}

	}

}