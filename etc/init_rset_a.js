db.runCommand({"replSetInitiate" :
    {"_id" : "a", "members" : [
	{"_id" : 0, "host" : "node0a0.slayer:10001", "priority" : 100},
	{"_id" : 1, "host" : "node0a1.slayer:10002", "priority" : 50},
	{"_id" : 2, "host" : "node0a2.slayer:10003", "priority" : 1}
]}})
