db.runCommand( { enableSharding : "test" } )
use test
db.test_collection.ensureIndex({number:1})
use admin
db.runCommand( { shardCollection : "test.test_collection", key : {"number":1} })
use test
db.stats()
db.printShardingStatus()

sh.addShardTag("shard0000", "NYC")
sh.addShardTag("shard0001", "NYC")
sh.addShardTag("shard0002", "SFO")
sh.addShardTag("shard0002", "NRT")

sh.removeShardTag("shard0002", "NRT")

sh.addTagRange("records.users", { zipcode: "10001" }, { zipcode: "10281" }, "NYC")
sh.addTagRange("records.users", { zipcode: "11201" }, { zipcode: "11240" }, "NYC")
sh.addTagRange("records.users", { zipcode: "94102" }, { zipcode: "94135" }, "SFO")

use config
db.tags.remove({ _id: { ns: "records.users", min: { zipcode: "10001" }}, tag: "NYC" })

use config
db.shards.find({ tags: "NYC" })

use config
db.tags.find({ tags: "NYC" })

db.runCommand( { shardCollection : "test.users" , key : { email : 1 } , unique : true } )

db.proxy.ensureIndex( { "email" : 1 }, {unique : true} )

use config
db.settings.update( { _id : "balancer" }, { $set : { activeWindow : { start : "6:00", stop : "23:00" } } }, true )

use config
db.settings.update({ _id : "balancer" }, { $unset : { activeWindow : true } })

sh.stopBalancer()
sh.startBalancer()

use config
db.settings.update( { _id: "balancer" }, { $set : { stopped: true } } , true );
db.settings.update( { _id: "balancer" }, { $set : { stopped: false } } , true );

use config
db.settings.save( { _id:"chunksize", value: <size> } )

db.runCommand( { removeShard: "mongodb0" } )

db.runCommand( { movePrimary: "products", to: "mongodb1" })

use config
db.locks.find( { _id : "balancer" } ).pretty()

db.accounts.save({name: "A", balance: 1000, pendingTransactions: []})
db.accounts.save({name: "B", balance: 1000, pendingTransactions: []})
db.transactions.save({source: "A", destination: "B", value: 100, state: "initial"})
t = db.transactions.findOne({state: "initial"})
db.transactions.update({_id: t._id}, {$set: {state: "pending"}})
db.accounts.update({name: t.source, pendingTransactions: {$ne: t._id}}, {$inc: {balance: -t.value}, $push: {pendingTransactions: t._id}})
db.accounts.update({name: t.destination, pendingTransactions: {$ne: t._id}}, {$inc: {balance: t.value}, $push: {pendingTransactions: t._id}})
db.transactions.update({_id: t._id}, {$set: {state: "committed"}})
db.accounts.update({name: t.source}, {$pull: {pendingTransactions: t._id}})
db.accounts.update({name: t.destination}, {$pull: {pendingTransactions: t._id}})
db.transactions.update({_id: t._id}, {$set: {state: "done"}})

db.transactions.update({_id: t._id}, {$set: {state: "canceling"}})
db.accounts.update({name: t.source, pendingTransactions: t._id}, {$inc: {balance: t.value}, $pull: {pendingTransactions: t._id}})
db.accounts.update({name: t.destination, pendingTransactions: t._id}, {$inc: {balance: -t.value}, $pull: {pendingTransactions: t._id}})
db.transactions.update({_id: t._id}, {$set: {state: "canceled"}})

t = db.transactions.findAndModify({query: {state: "initial", application: {$exists: 0}},
                                   update: {$set: {state: "pending", application: "A1"}},
                                                                      new: true})
db.transactions.find({application: "A1", state: "pending"})

db.foo.update( { field1 : 1 , $isolated : 1 }, { $inc : { field2 : 1 } } , { multi: true } )

db.people.findAndModify( {
    query: { name: "Tom", state: "active", rating: { $gt: 10 } },
        sort: { rating: 1 },
            update: { $inc: { score: 1 } }
                } );

db.log.events.ensureIndex( { "status": 1 }, { expireAfterSeconds: 3600 } )

db.mycollection.find( { attrib: { $elemMatch : { k: "color", v: "blue" } } } )

db.books.findAndModify ( {
   query: {
               _id: 123456789,
                   available: { $gt: 0 }
                                     },
        update: {
             $inc: { available: -1 },
              $push: { checkout: { by: "abc", date: new Date() } }
         }
 } )


{ "$ref" : <value>, "$id" : <value>, "$db" : <value> }
Consider a document from a collection that stored a DBRef in a creator field:

{
  "_id" : ObjectId("5126bbf64aed4daf9e2ab771"),
    // .. application fields
      "creator" : {
	            "$ref" : "creators",
    	          "$id" : ObjectId("5126bc054aed4daf9e2ab772"),
                "$db" : "users"
        }
}



db.log.events.ensureIndex( { "status": 1 }, { expireAfterSeconds: 3600 } )

Sparse Indexes
Sparse indexes only contain entries for documents that have the indexed field. [5] Any document that is missing the field is not indexed. The index is “sparse” because of the missing documents when values are missing.

By contrast, non-sparse indexes contain all documents in a collection, and store null values for documents that do not contain the indexed field. Create a sparse index on the xmpp_id field, of the members collection, using the following operation in the mongo shell:

db.addresses.ensureIndex( { "xmpp_id": 1 }, { sparse: true } )

Hashed Index¶
New in version 2.4.

Hashed indexes maintain entries with hashes of the values of the indexed field. The hashing function collapses sub-documents and computes the hash for the entire value but does not support multi-key (i.e. arrays) indexes.

MongoDB can use the hashed index to support equality queries, but hashed indexes do not support range queries.

You may not create compound indexes that have hashed index fields or specify a unique constraint on a hashed index; however, you can create both a hashed index and an ascending/descending (i.e. non-hashed) index on the same field: MongoDB will use the scalar index for range queries.

Warning hashed indexes truncate floating point numbers to 64-bit integers before hashing. For example, a hashed index would store the same value for a field that held a value of 2.3, 2.2 and 2.9. To prevent collisions, do not use a hashed index for floating point numbers that cannot be consistently converted to 64-bit integers (and then back to floating point.) hashed indexes do not support floating point values larger than 253.
Create a hashed index using an operation that resembles the following:

db.active.ensureIndex( { a: "hashed" } )


db.accounts.ensureIndex( { username: 1 }, { unique: true, dropDups: true } )

Background Construction
By default, creating an index is a blocking operation. Building an index on a large collection of data can take a long time to complete. To resolve this issue, the background option can allow you to continue to use your mongod instance during the index build.

For example, to create an index in the background of the zipcode field of the people collection you would issue the following:

db.people.ensureIndex( { zipcode: 1}, {background: true} )
By default, background is false for building MongoDB indexes.

You can combine the background option with other options, as in the following:

db.people.ensureIndex( { zipcode: 1}, {background: true, sparse: true } )


db.createCollection("mycoll", {capped:true, size:100000})


db.cappedCollection.find().sort( { $natural: -1 } )
Check if a Collection is Capped
Use the db.collection.isCapped() method to determine if a collection is capped, as follows:

db.collection.isCapped()
Convert a Collection to Capped
You can convert a non-capped collection to a capped collection with the convertToCapped command:

db.runCommand({"convertToCapped": "mycoll", size: 100000});


db.createCollection("log", { capped : true, size : 5242880, max : 5000 } )

db.system.js.save(
                   { _id: "echoFunction",
                    value : function(x) { return x; }
                   }
)

db.eval( "echoFunction( 'test' )" )


db.loadServerScripts();
echoFunction(3);
myAddFunction(3, 5);


db.quotes.runCommand( "text", { search: "TOMORROW" } )
db.quotes.runCommand( "text", { search: "tomorrow",
                                project: { "src": 1 } } )

db.quotes.runCommand( "text", { search: "tomorrow",
                                filter: { speaker : "macbeth" } } )

db.quotes.runCommand( "text", { search: "amor", language: "spanish" } )

{ _id: 1, language: "portuguese", quote: "A sorte protege os audazes" }
{ _id: 2, language: "spanish", quote: "Nada hay más surreal que la realidad." }
{ _id: 3, language: "english", quote: "is this a dagger which I see before me" }

db.quotes.ensureIndex( { quote: "text" } )

db.quotes.runCommand( "text", { search: "que", language: "spanish" } )

db.quotes.ensureIndex( { quote : "text" },
                       { language_override: "idioma" } )


db.quotes.runCommand( "text", { search: "que", language: "spanish" } )

Append scalar index fields to a text index, as in the following example which specifies an ascending index key on username:
db.collection.ensureIndex( { comments: "text",
                             username: 1 } )
                             Warning You cannot include multi-key index field or geospatial index field.
                             Use the project option in the text to return only the fields in the index, as in the following:
                             db.quotes.runCommand( "text", { search: "tomorrow",
                                                 project: { username: 1,
                                                                _id: 0
                                                 }
                                       }
                               )

db.inventory.runCommand( "text", {
                                   search: "green",
                                  filter: { dept : "kitchen" }
                               }
)

