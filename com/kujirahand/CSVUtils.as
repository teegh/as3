/**
 *  Excel 準拠の CSV ファイルを配列変数に変換するクラス
 */

package com.kujirahand
{
    import mx.collections.ArrayCollection;
    
    /**
     * CSV ファイル(Excel準拠)のテキストを、Array や ArrayCollection に変換するもの。
     * @author クジラ飛行机(http://kujirahand.com)
     * @langversion ActionScript 3.0
     * @example CSV形式のテキストを配列に変換する
     * <listing version="3.0" >
     *    var csv_str = "name, value\naaa,30\nbbbb,50\ncccc,30\n";
     *    var csv_ary:Array = CSVUtils.CsvToArray(csv_str); // CSV→Array
     *    trace( CSVUtils.ArrayToCsv(csv_ary) ); // Array→CSV
     * </listing>
     * @example DataGrid に CSVテキストを表示する
     * <listing version="3.0" >
     *    // &lt;mx:DataGrid id="data_grid"&gt;
     *    //    &lt;mx:DataGridColumn dataField="name"/&gt;
     *    //    &lt;mx:DataGridColumn dataField="tel"/&gt;
     *    //    &lt;mx:DataGridColumn dataField="memo"/&gt;
     *    // &lt;/mx:DataGrid&gt;
     *    var csv_str = "name, tel, memo\naaa,03-xxx-xxxx,memo\nbbbb,03-xxx-xxxx\n";
     *    var csv_ary:Array = CSVUtils.CsvToArray(csv_str); // CSV→Array
     *    var mapping:Array = ['name', 'tel', 'memo'];
     *    var csv_ac:ArrayCollection;
     *    csv_ac = CSVUtils.ArrayToArrayCollection(csv_ary, mapping, true);
     *    data_grid.dataProvider = csv_ac; // set to DataGrid
     * </listing>
     * @see http://snippets.libspark.org/svn/kujirahand/as3/com/kujirahand/CSVUtils.as   最新版ダウンロード(SVNリポジトリ)
     * @see http://kujirahand.com/as3/com/kujirahand/CSVUtils.html ASDoc
     */ 
    public class CSVUtils
    {
        // 静的メソッド
        /**　CSV　の列の区切り記号(1文字のみ対応) */  
        public static var DEFAULT_SPLITTER:String = ",";
        /** 行の区切り記号は　\n で固定 */
        public static const LINE_SPLLITER:String = "\n";
        
        /** CSV を配列に変換する関数
         * @param csv_str   CSV文字列
         * @return   二次元配列変数
         */
        public static function CsvToArray(csv_str:String):Array {
            return CsvToArray_spl(csv_str, DEFAULT_SPLITTER);
        }
        
        /**
         * TSVを配列に変換する関数
         * @param tsv_str    TSV文字列
         * @return         二次元配列変数
         */
        public static function TsvToArray(tsv_str:String):Array {
            return CsvToArray_spl(tsv_str, "\t");
        }
        
        /** 任意の区切り記号のCSVを配列に変換する関数 */
        public static function CsvToArray_spl(csv_str:String, splitter:String):Array {
            var csv:CSVUtils = new CSVUtils();
            return csv.split(csv_str, splitter);
        }
        
        public static function replaceStr(str:String, a:String, b:String):String {
            var o:Array = str.split(a);
            return o.join(b);
        }
        /**
        * CSVファイルをデータグリッドに表示するために、ArrayCollectionに変換する
        * @param    csv_ary    二次元配列変数
        * @param    mapping     マッピングするフィールド名の配列
        * @param    topline_is_header １行目をヘッダとして利用しているなら true にすると削る
        * @return    変換された ArrayCollection
        */
        public static function ArrayToArrayCollection(csv_ary:Array,
            mapping:Array, topline_is_header:Boolean = false):ArrayCollection {
            if (topline_is_header) { // １行目をヘッダとして使うなら削る
                csv_ary.splice(0, 1);
            }
            var result_ary:ArrayCollection = new ArrayCollection();
            for (var row:int = 0; row < csv_ary.length; row++) {
                var cols:Array = csv_ary[row];
                var col_obj:Object = {};
                for (var col:int = 0; col < mapping.length; col++) {
                    var field_name:String = mapping[col];
                    var col_str:String = cols[col];
                    if (field_name == ""||field_name == null) continue;
                    col_obj[field_name] = col_str;
                }
                result_ary.addItem(col_obj);
            }
            return result_ary;
        }
        /**
        * 二次元配列をCSV形式に変換する
        * @param csv_ary        配列変数
        * @param splitter        区切り記号
        * @param use_escape    必ず ダブルコーテーションで囲う場合
        * @return CSV形式の文字列
        */
        public static function ArrayToCsv(csv_ary:Array, splitter:String,
            use_escape:Boolean = false):String {
            var res:String = "";
            for (var row:int = 0; row < csv_ary.length; row++) {
                var cols:Array = csv_ary[row];
                for (var col:int = 0; col <  cols.length; col++) {
                    var cell:String = cols[col];
                    if (use_escape || hasEscapeChar(cell, splitter)) {
                        cell = escapeCell(cell);
                    }
                    res += cell + splitter;
                }
                if (cols.length > 0) res = res.substr(0, res.length -1);
                res += LINE_SPLLITER;
            }
            if (csv_ary.length > 0) res = res.substr(0, res.length - 1);
            return res;
        }
        /**
        * 文字列を ".." で括る必要があるかチェックする
        */
        public static function hasEscapeChar(cell:String, splitter:String):Boolean {
            if (cell.indexOf('"') >= 0) return true;
            if (cell.indexOf("\n") >= 0) return true;
            if (cell.indexOf("\r") >= 0) return true;
            if (cell.indexOf("\t") >= 0) return true;
            if (cell.indexOf(" ") >= 0) return true;
            if (cell.indexOf(splitter) >= 0) return true;
            return false;
        }
        /**
        * CSVのセル(文字列)を ".." で括ってエスケープする
        */
        public static function escapeCell(cell:String):String {
            cell = replaceStr(cell, '"', '""');
            cell = '"' + cell + '"';
            return cell;
        }
        // ------------------
        // CSVUtils クラス
        private var csv_str:String;
        private var splitter:String;
        private var index:int;
        
        public function split(csv_str:String, splitter:String):Array {
            // 改行を統一する
            csv_str = replaceStr(csv_str, "\r\n", LINE_SPLLITER);
            csv_str = replaceStr(csv_str, "\r", LINE_SPLLITER);
            //
            this.csv_str = csv_str;
            this.splitter = splitter;
            //
            return splitLoop();
        }
        private function splitLoop():Array {
            var result:Array = [];
            while (csv_str.length > 0) {
                var cols:Array = getCols();
                result.push(cols);
            }
            return result;
        }
        private function getCols():Array {
            var cols:Array = [];
            index = 0;
            while (index < csv_str.length) {
                var c:String = csv_str.charAt(index);
                var col:String;
                if (c == LINE_SPLLITER) {
                    index++;
                    break;
                }
                if (c == '"') {
                    col = getColStr();
                }
                else {
                    col = getColSimple();  
                }
                skipSpace();
                cols.push(col);
            }
            // 切り取る
            csv_str = csv_str.substr(index);
            return cols;
        }
        private function getColSimple():String {
            var col:String = "";
            while (index < csv_str.length) {
                if (csv_str.substr(index, 2) == '""') {
                    col += '"';
                    index += 2;
                    continue;
                }
                var c:String = csv_str.charAt(index);
                if (c == splitter) {
                    index++;
                    break;
                }
                if (c == LINE_SPLLITER) {
                    break;
                }
                col += c;
                index++;                
            }
            return col;
        }
        private function getColStr():String {
            // "str" の文字列
            index++; // skip '"'
            var col:String = "";
            while (index < csv_str.length) {
                if (csv_str.substr(index, 2) == '""') {
                    col += '"';
                    index += 2;
                    continue;
                }
                var c:String = csv_str.charAt(index);
                if (c == '"') { // 終端 '"' の可能性
                    index++;
                    skipSpace();
                    // 終端のはず、もし違えば、壊れた形式の可能性があるが継続する
                    if (csv_str.charAt(index) == ",") {
                        index++;
                    }
                    break;
                }
                col += c;
                index++;                
            }
            return col;
        }
        private function skipSpace():void {
            if (csv_str.charAt(index) == " ") {
                index++;
            }
        }
    }
}

