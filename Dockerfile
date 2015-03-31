FROM phusion/baseimage:0.9.16

MAINTAINER Alex Lynham "alex@swirrl.com"

RUN apt-get update

# Install Nginx and rvm/Rails dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common && \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx tar wget curl nano git nodejs npm automake bison && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Install Memcached
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libevent-dev libsasl2-2 sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules memcached
RUN export PATH=/bin:/usr/bin:/sbin:/usr/sbin

# Install Redis.
RUN \
  cd /tmp && \
  wget http://download.redis.io/redis-stable.tar.gz && \
  tar xvzf redis-stable.tar.gz && \
  cd redis-stable && \
  make && \
  make install && \
  cp -f src/redis-sentinel /usr/local/bin && \
  mkdir -p /etc/redis && \
  cp -f *.conf /etc/redis && \
  rm -rf /tmp/redis-stable* && \
  sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
  sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

# Add site conf to nginx
ADD docker/site.conf /etc/nginx/sites-enabled/site.conf
RUN rm /etc/nginx/sites-enabled/default

# for rvm
RUN gpg --allow-non-selfsigned-uid --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 BF04FF17
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install 2.1.2'
RUN /bin/bash -l -c 'rvm use 2.1.2 --default'

# No documentation for each gem
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Bundler please
RUN /bin/bash -l -c 'gem install bundler --no-ri --no-rdoc'

# Copy the Gemfile and Gemfile.lock into the image.
# Temporarily set the working directory to where they are.
RUN mkdir /artsapi
WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN /bin/bash -l -c "bundle install"

# Add start-server script
ADD docker/start-server-production.sh /usr/bin/start-server-production
ADD docker/replace-mongoid-yml.sh /usr/bin/replace-mongoid-yml

# Add rails files from current directory
ADD ./ /artsapi

# Permissions
RUN chmod +x /artsapi
RUN chmod +x /usr/bin/start-server-production
RUN chmod +x /usr/bin/replace-mongoid-yml

# Make a place for Unicorn pids and sockets to go
RUN mkdir -p /artsapi/tmp/unicorn/pids
RUN mkdir /artsapi/tmp/unicorn/sockets

# Make a place for sidekiq logs
RUN /bin/bash -l -c "touch /artsapi/log/sidekiq.log"

# Set working directory
WORKDIR /artsapi

# Symlink node and nodejs
RUN /bin/bash -l -c "ln -s /usr/bin/nodejs /usr/bin/node"

# Precompile assets
RUN /bin/bash -l -c "bundle exec rake assets:precompile RAILS_ENV=production RAILS_GROUPS=assets"

# Mount nginx volumes
VOLUME ["/data", "/etc/nginx/sites-enabled", "/var/log/nginx", "/artsapi/log"]

# serve nginx
EXPOSE 80 

# Start the unicorn server and start nginx
CMD ["/usr/bin/start-server-production"]