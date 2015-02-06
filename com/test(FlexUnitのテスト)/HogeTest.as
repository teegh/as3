package com.test
{
	import org.flexunit.Assert; // テストするためのstaticメソッドが用意されているAssertクラスをインポートする
	
	public class HogeTest
	{
		public function HogeTest():void{
			add();
		}
		
		// ※重要※ この[Test]メタタグがテスト用メソッドであることを示す
		[Test]
		public function add():void 
		{
			// テストに使用するためのHogeインスタンスを作成する
			var hoge:Hoge = new Hoge();
			
			// このassertEqualsメソッドが実際のテストのためのコード
			// 1つ目の引数「7」と、2つ目の引数「hoge.add(3, 4)」（の戻り値）が、同じ（Equals）であることを意味する
			Assert.assertEquals(7, hoge.add(3, 4));
		}
	}
}