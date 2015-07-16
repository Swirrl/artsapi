FROM phusion/baseimage:0.9.16

MAINTAINER Alex Lynham "alex@swirrl.com"

RUN apt-get update

# Install rvm/Rails dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common && \
  apt-get update && \
  apt-get install -y tar wget curl nano git nodejs npm automake bison openjdk-7-jre-headless

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

# for rvm
RUN gpg --allow-non-selfsigned-uid --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 BF04FF17
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install 2.2.2'
RUN /bin/bash -l -c 'rvm use 2.2.2 --default'

# No documentation for each gem
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Bundler please
RUN /bin/bash -l -c 'gem install bundler --no-ri --no-rdoc'

# Grafter please - get the uberjar from Github
RUN mkdir artsapi-email-processing-tool
RUN chmod +rwx artsapi-email-processing-tool
ADD https://github.com/Swirrl/artsapi-email-processing-tool/releases/download/2.3.1/artsapi-graft-standalone.jar /artsapi-email-processing-tool/artsapi-graft-standalone.jar

RUN mkdir /artsapi

# Add start-server script
ADD docker/start-server-production.sh /usr/bin/start-server-production
ADD docker/replace-mongoid-yml.sh /usr/bin/replace-mongoid-yml

# Add rails files from current directory
ADD ./ /artsapi

# Remove capybara-webkit as we don't want to install QT etc
# Remove lockfile before bundling
RUN sed -i.bak "s/gem 'capybara-webkit'/#gem 'capybara-webkit'/g" /artsapi/Gemfile
RUN rm /artsapi/Gemfile.bak
RUN rm /artsapi/Gemfile.lock

# Add secrets file
ADD docker/secrets.yml /artsapi/config/secrets.yml

# Permissions
RUN chmod +x /artsapi
RUN chmod +x /artsapi-email-processing-tool
RUN chmod +x /usr/bin/start-server-production
RUN chmod +x /usr/bin/replace-mongoid-yml
RUN chmod +x /artsapi-email-processing-tool/artsapi-graft-standalone.jar

# Make a place for Unicorn pids and sockets to go
RUN mkdir -p /artsapi/tmp/unicorn/pids
RUN mkdir /artsapi/tmp/unicorn/sockets

# Make a place for sidekiq logs
RUN /bin/bash -l -c "touch /artsapi/log/sidekiq.log"

# Set working directory
WORKDIR /artsapi

# Bundle
RUN /bin/bash -l -c "bundle install"

# Symlink node and nodejs
RUN /bin/bash -l -c "ln -s /usr/bin/nodejs /usr/bin/node"

# Precompile assets
RUN /bin/bash -l -c "RAILS_ENV=production bundle exec rake assets:precompile RAILS_GROUPS=assets --trace"

# Make a place for them
RUN mkdir /artsapi-assets

# Mount nginx volumes
VOLUME ["/data", "/artsapi/log", "/artsapi-assets"]

# serve unicorn
EXPOSE 8080

# Start the unicorn server and start nginx
CMD ["/usr/bin/start-server-production"]