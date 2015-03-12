cd /tmp
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.0-rc11.tgz -O mongo.tar.gz
tar -zxvf mongo.tar.gz
cp /tmp/mongodb-linux-x86_64-3.0.0-rc11/bin/* /home/developer/bin/
rm -rf ./mongodb-linux-x86_64-3.0.0-rc11
rm -f mongo.tar.gz
/home/developer/bin/mongo --version
