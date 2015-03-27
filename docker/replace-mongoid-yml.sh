if [ -n "$MONGODB_PORT_27017_TCP_ADDR" ];
  then
    # We have mongo
    sed -i.bak "s/__PRODUCTION_MONGODB_HOST__/$MONGODB_PORT_27017_TCP_ADDR/g" /artsapi/config/mongoid.yml
    rm /artsapi/config/mongoid.yml.bak
fi