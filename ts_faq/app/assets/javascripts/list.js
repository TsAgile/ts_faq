function AddTableRows(){
	// 行追加
	var table1 = document.getElementById("listTable");
	var row1 = table1.insertRow(-1);
	var cell1 = row1.insertCell(0);
	var cell2 = row1.insertCell(1);
	var cell3 = row1.insertCell(2);
	var cell4 = row1.insertCell(3);

    // ケースID
    caseid_clone = document.getElementById("caseid_").cloneNode(true);
    caseid_clone.value= "99";
    cell1.appendChild(caseid_clone);
    
    // ケース名
    casename_clone = document.getElementById("casename_").cloneNode(true);
    casename_clone.value= "";
    cell1.appendChild(casename_clone);

    // 削除
    change_clone = document.getElementById("delete").cloneNode(true); 
    cell2.appendChild(change_clone);

    // 手順
    procedurename_clone = document.getElementById("procedurename_").cloneNode(true);
    procedurename_clone.value= "";
    cell3.appendChild(procedurename_clone);
    
	// 参照情報
    reference_clone = document.getElementById("reference_").cloneNode(true);
    reference_clone.value= "";
    cell4.appendChild(reference_clone);
	
    // セル結合       
    MergeCells(table1);

}

function DelTableRows(o){

	var table1 = document.getElementById("listTable");
    var tr = o.parentNode.parentNode;
    // 2件以上ある場合
	if (table1.rows.length > 2) {
      // 1行目の場合
      if (tr.sectionRowIndex == 1 ){
		//ID、項目名、登録者を保存
        var HTML1 = tr.cells[0].innerHTML;
        var HTML2 = tr.cells[1].innerHTML;
        var HTML3 = tr.cells[2].innerHTML;
        
        // 行削除
        table1.deleteRow(tr.sectionRowIndex);
       
        // 1行目にセル追加
        var row1 = table1.rows[1]
        var cell1 = row1.insertCell(0);
		var cell2 = row1.insertCell(1);
		var cell3 = row1.insertCell(2);
		
		// セルに値をセット
		cell1.innerHTML = HTML1;
		cell2.innerHTML = HTML2;
		cell3.innerHTML = HTML3;
        
        // セル結合       
        MergeCells(table1);

      } else {
      // 1行目以外の場合
        // 行削除
        table1.deleteRow(tr.sectionRowIndex);
      }
    
    //最後の1件の場合
    } else {
      // データクリア
      document.getElementById("casename_").value = "";
      document.getElementById("procedurename_").value = "";
      document.getElementById("reference_").value = "";
    } 
}

function MergeCells(table){
    // セル結合
    var row = table.getElementsByTagName("tr")[1];
	var col1 = row.getElementsByTagName("td")[0];
	var col2 = row.getElementsByTagName("td")[1];
	var col3 = row.getElementsByTagName("td")[2];
	col1.rowSpan = (table.rows.length - 1);
	col2.rowSpan = (table.rows.length - 1);
	col3.rowSpan = (table.rows.length - 1);
}

function CheckSelectFile(){
    // ファイル選択チェック
    var item_file_path = document.getElementById("item_file").value
    var case_file_path = document.getElementById("case_file").value
    var procedure_file_path = document.getElementById("procedure_file").value
    if(item_file_path == "" || case_file_path == "" || procedure_file_path == "") {
      alert("インポートする場合はファイルを全て選択してください。");          
      return false;        
    }else {          
      return true;
    }
}
