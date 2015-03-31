#!/bin/bash

# replace the mongoid settings.
/usr/bin/replace-mongoid-yml

cd /artsapi
source /etc/profile.d/rvm.sh

# memcached up
memcached -d -I 10m -m 1024

# daemonize redis
sed -i.bak "s/# daemonize no/daemonize yes/g" /etc/redis/redis.conf
rm /etc/redis/redis.conf.bak
redis-server /etc/redis/redis.conf

# start sidekiq
bundle exec sidekiq -d -L /artsapi/log/sidekiq.log -e production

# unicorn daemonised so we can run nginx
bundle exec unicorn_rails -D -c ./config/unicorn.rb -E production

# unicorn behind nginx so we can serve static assets
nginx