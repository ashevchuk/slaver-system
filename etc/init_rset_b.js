db.runCommand({"replSetInitiate" :
    {"_id" : "b", "members" : [
	{"_id" : 0, "host" : "node0b0.slayer:10004", "priority" : 100},
	{"_id" : 1, "host" : "node0b1.slayer:10005", "priority" : 50},
	{"_id" : 2, "host" : "node0b2.slayer:10006", "priority" : 1}
]}})
