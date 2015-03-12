cp /home/developer/mnt/data/data/MongoDBx.tar.gz /tmp/MongoDBx.tar.gz
cd /tmp
tar -zxvf MongoDBx.tar.gz
cd ./MongoDBx-Class-1.030002
cpanm -n -f MongoDB
cpanm -n -f ./
cd /tmp
rm -rf /tmp/MongoDBx-Class-1.030002
