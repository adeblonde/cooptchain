var mining_threads = 1;
var checkTimeout = null;

function checkWork() {
    if (eth.getBlock("pending").transactions.length > 0) {
        if (eth.mining) return;
        console.log("** Transactions en attente ! Mining...");
        miner.start(mining_threads);
    } else {
        miner.stop();
        console.log("** Pas de transactions. En attente...");
    }
	
	checkTimeout = setTimeout(function(){
		checkWork();
	    }, 1000);
}

function stopChecking() {
    clearTimeout(checkTimeout);
	return true;
}

eth.filter("latest", function(err, block) { checkWork(); });
eth.filter("pending", function(err, block) { checkWork(); });

checkWork();
