people = ["Marc", "Bill", "George", "Eliot", "Matt", "Trey", "Tracy", "Greg", "Steve", "Kristina", "Katie", "Jeff"];

for(var i=0; i<1000000; i++){
                             name = people[Math.floor(Math.random()*people.length)];
                             user_id = i;
                             boolean = [true, false][Math.floor(Math.random()*2)];
                             added_at = new Date();
                             number = Math.floor(Math.random()*i);
                             db.test_collection.save({"name":name, "user_id":user_id, "boolean": boolean, "added_at":added_at, "number":number });
                            }

