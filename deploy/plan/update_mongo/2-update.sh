cd /tmp
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian71-3.1.0.tgz -O mongo.tar.gz
tar -zxvf mongo.tar.gz
cp /tmp/mongodb-linux-x86_64-debian71-3.1.0/bin/* /home/developer/local/bin/
rm -rf ./mongodb-linux-x86_64-debian71-3.1.0
rm -f mongo.tar.gz
/home/developer/local/bin/mongo --version
