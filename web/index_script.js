cgi_link = '../cgi-bin/';
get_state_preload_link = 'get_state_preload.py';
do_shutdown_link = 'shutdown.py';
do_reboot_link = 'reboot.py';

window.onload = function(){
	//state preload
	var ap_data;
	fetch(cgi_link + get_state_preload_link).then(function(res){
		if(res.ok){
			res.json().then(data => {
				ap_data = data;
				console.log(data);
				document.getElementById("nav_id").textContent = ap_data[1]["hostname"];
			})
		}
	})

	document.getElementById('do_shutdown').onclick = function(){
		console.log('shutdown');
		fetch(cgi_link + do_shutdown_link).then(function(res){
			if(res.ok){
			}else{
				console.log('shutdown');
			}
		})
	}

	document.getElementById('do_reboot').onclick = function(){
		console.log('reboot');
		setTimeout(reload,90000);
		fetch(cgi_link + do_reboot_link).then(function(res){
			if(res.ok){
			}else{
				console.log('reboot');
			}
		})
	}

}

function reload(){
	location.reload()
}