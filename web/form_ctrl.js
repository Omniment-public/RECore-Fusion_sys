cgi_link = '../cgi-bin/';
get_ap_ssid_link = 'get_ap_ssid.py';
set_ap_ssid_link = 'set_ap_ssid.py';
get_scan_ssid_list_link = 'get_scan_ssid_list.py';
get_registered_ssid_list_link = 'get_registered_ssid_list.py';
set_sta_ssid_link = 'set_sta_ssid.py'
del_registered_ssid_link = 'del_registered_ssid.py';
get_wlan_mode_link = 'get_wlan_mode.py';
set_wlan_mode_link = 'set_wlan_mode.py';
get_host_name_link = 'get_host_name.py';
set_host_name_link = 'set_host_name.py';

get_state_preload_link = 'get_state_preload.py';

window.onload = function(){
	//state preload
	var ap_data;
	fetch(cgi_link + get_state_preload_link).then(function(res){
		if(res.ok){
			res.json().then(data => {
				ap_data = data;
				console.log(data);
				document.getElementById("ap_ssid").value = ap_data[0]["ap_ssid"];
				document.getElementById("hostname").value = ap_data[1]["hostname"];
				document.getElementById("nav_id").textContent = ap_data[1]["hostname"];
			})
		}
	})

	//sta scan
	document.getElementById('open_set_sta').onclick = function(){
		scan_ssid();
		get_registered_ssid();
	}

	//ap ssid設定
	document.getElementById('set_ap_ssid_button').onclick = function(){
		//メッセージ非表示
		document.getElementById("set_ap_success").style.display='none';
		var data_list = {};
		data_list['ssid'] = document.getElementById("ap_ssid").value;
		data_list['pass'] = document.getElementById("ap_pass").value;
		var send_json = JSON.stringify(data_list);
		if(data_list['ssid'] == "" | data_list['pass'] == ""){
			return;
		}

		console.log(send_json);

		fetch(cgi_link + set_ap_ssid_link,{method:'POST',headers:{'Content-Type': 'application/json'},body: send_json}).then(function(res){
			if(res.ok){
				document.getElementById("set_ap_success").style.display='block';
			}
		})
	}

	//sta ssid 追加
	document.getElementById('add_sta_ssid_button').onclick = function(){
		//メッセージ非表示
		document.getElementById("add_sta_success").style.display='none';

		var ssid_list = document.getElementById("find_sta_ssid_list");
		var pass_input = document.getElementById("ssid_password");

		var data_list = {};
		data_list['ssid'] = ssid_list.value;
		data_list['pass'] = pass_input.value;
		var send_json = JSON.stringify(data_list);

		if(data_list['ssid'] == ''){
			return;
		}

		console.log(send_json);

		fetch(cgi_link + set_sta_ssid_link,{method:'POST',headers:{'Content-Type': 'application/json'},body: send_json}).then(function(res){
			if(res.ok){
				document.getElementById("add_sta_success").style.display='block';
				ssid_list.remove(ssid_list.selectedIndex);
				pass_input.value = "";
				get_registered_ssid();
			}
		})
	}

	//ssid 削除
	document.getElementById('del_sta_ssid_button').onclick = function(){
		var registered_list = document.getElementById("registered_ssid_list");

		//メッセージ非表示
		document.getElementById("del_sta_success").style.display='none';
		
		//データ作成
		var data_list = {};
		data_list['del_num'] = registered_list.selectedIndex;
		
		if(data_list['del_num'] == '-1'){
			return;
		}

		var send_json = JSON.stringify(data_list);
		console.log(send_json);
		
		fetch(cgi_link + del_registered_ssid_link,{method:'POST',headers:{'Content-Type': 'application/json'},body: send_json}).then(function(res){
			if(res.ok){
				registered_list.remove(registered_list.selectedIndex);
				document.getElementById("del_sta_success").style.display='block';
			}
		})

	}

	//switch
	//状態取得
	document.getElementById('open_set_switch').onclick = function(){
		var mode_ap = document.getElementById('switch_wlan_ap');
		var mode_sta = document.getElementById('switch_wlan_sta');

		//style clear
		mode_sta.style.backgroundColor="transparent"
		mode_ap.style.backgroundColor="transparent"
		
		fetch(cgi_link + get_wlan_mode_link).then(function(res){
			if(res.ok){
				res.json().then(data =>{
					set_state = data;
					console.log(set_state);
					if(set_state[0]["wlan_mode"] == 0){
						//sta
						mode_sta.style.backgroundColor="mediumspringgreen"
					}else{
						//ap
						mode_ap.style.backgroundColor="mediumspringgreen"
					}

				})
			}
		})
	}

	document.getElementById('switch_wlan_ap').onclick = function(){
		var mode_ap = document.getElementById('switch_wlan_ap');
		var mode_sta = document.getElementById('switch_wlan_sta');

		//style clear
		mode_sta.style.backgroundColor="transparent"
		mode_ap.style.backgroundColor="transparent"

		//データ作成
		var data_list = {};
		//ap only = 1
		data_list['wlan_mode'] = 1;
		
		var send_json = JSON.stringify(data_list);
		console.log(send_json);

		fetch(cgi_link + set_wlan_mode_link,{method:'POST',headers:{'Content-Type': 'application/json'},body: send_json}).then(function(res){
			if(res.ok){
				mode_ap.style.backgroundColor="mediumspringgreen"
			}
		})
	}
	document.getElementById('switch_wlan_sta').onclick = function(){
		var mode_ap = document.getElementById('switch_wlan_ap');
		var mode_sta = document.getElementById('switch_wlan_sta');

		//style clear
		mode_sta.style.backgroundColor="transparent"
		mode_ap.style.backgroundColor="transparent"

		//データ作成
		var data_list = {};
		//ap only = 0
		data_list['wlan_mode'] = 0;
		
		var send_json = JSON.stringify(data_list);
		console.log(send_json);

		fetch(cgi_link + set_wlan_mode_link,{method:'POST',headers:{'Content-Type': 'application/json'},body: send_json}).then(function(res){
			if(res.ok){
				mode_sta.style.backgroundColor="mediumspringgreen"
			}
		})
	}

	//hostname設定
	document.getElementById('set_hostname_button').onclick = function(){
		//メッセージ非表示
		document.getElementById("set_hostname_success").style.display='none';
		var data_list = {};
		data_list['hostname'] = document.getElementById("hostname").value;
		if(data_list['hostname'] == ""){
			return;
		}

		var send_json = JSON.stringify(data_list);

		console.log(send_json);

		fetch(cgi_link + set_host_name_link,{method:'POST',headers:{'Content-Type': 'application/json'},body: send_json}).then(function(res){
			if(res.ok){
				document.getElementById("set_hostname_success").style.display='block';
			}
		})
	}
	
}

function scan_ssid(){
	var sta_ssid_list;

	//リスト消去
	var find_ssid_list  = document.getElementById("find_sta_ssid_list");
	while(find_ssid_list.firstChild){
		find_ssid_list.removeChild(find_ssid_list.firstChild);
	}

	var make_option = document.createElement('option');
	make_option.value = '';
	var append_text = document.createTextNode('検索中...');
	make_option.appendChild(append_text);
	find_ssid_list.appendChild(make_option);

	fetch(cgi_link + get_scan_ssid_list_link).then(function(res){
		if(res.ok){
			res.json().then(data => {
				sta_ssid_list = data;
				console.log(data);
				
				//リスト再消去
				while(find_ssid_list.firstChild){
					find_ssid_list.removeChild(find_ssid_list.firstChild);
				}

				var list_len = sta_ssid_list.length;
				for(let i = 0; i < list_len; i++){
					var make_li = make_scan_ssid_list(sta_ssid_list[i]["ssid"]);
					find_ssid_list.appendChild(make_li);
				}
				
			})
		}
	})
}

function make_scan_ssid_list(ssid_name){
	//リスト要素作成
	var make_option = document.createElement('option');
	make_option.value = ssid_name;
	//make_option.className = 'list_ssid';
	var append_text = document.createTextNode(ssid_name);
	make_option.appendChild(append_text);

	return make_option;
}

function get_registered_ssid(){
	var registered_ssid_list;

	//リスト消去
	var registered_list = document.getElementById("registered_ssid_list");
	while(registered_list.firstChild){
		registered_list.removeChild(registered_list.firstChild);
	}

	fetch(cgi_link + get_registered_ssid_list_link).then(function(res){
		if(res.ok){
			res.json().then(data => {
				registered_ssid_list = data;
				console.log(data);

				//再消去
				while(registered_list.firstChild){
					registered_list.removeChild(registered_list.firstChild);
				}

				var list_len = registered_ssid_list.length;
				for(let i = 0; i < list_len; i++){
					var make_li = make_scan_ssid_list(registered_ssid_list[i]["registered_ssid"]);
					registered_list.appendChild(make_li);
				}
				
			})
		}
	})
}

