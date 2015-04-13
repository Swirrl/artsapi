![ArtsAPI Logo](https://github.com/Swirrl/artsapi/blob/master/app/assets/images/aa-logo.png?raw=true "ArtsAPI Logo")

# ArtsAPI

This is the main application for the ArtsAPI project.

NB: Every time `$` is seen in a code snippet, you should type this into a terminal.

## Development

1. Install Fuseki.
2. Copy the `fuseki_config.ttl` file from the `/config` folder.
3. In the file, change the value next to `tdb:location` to the location of your tdb folder, for example `/Users/<your-user>/tdb_data/artsapi-dev`.
4. Add `alias fuseki_artsapi="cd $HOME/jena-fuseki-1.0.1 ; ./fuseki-server --config=fuseki_config.ttl"` to your shell to start Fuseki using `$ fuseki-artsapi`. Change `jena-fuseki-1.0.1` in the previous command to the version and folder of your installed version of Fuseki.
5. Install redis and run it.
6. Use `bundle exec sidekiq` to bring up sidekiq for background processing.

## Deployment

Deploy using Docker. Setup a Redis, Mongo and Fuseki instance before linking them to this container.

#### Set up server for Docker

1. Use the Docker docs' advice to set up swap, or running the other containers will not work:

    1. Log into Ubuntu as a user with sudo privileges.

    2. Edit the `/etc/default/grub` file.

    3. Set the `GRUB_CMDLINE_LINUX` value as follows:

        `GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"`

    4. Save and close the file.

    5. Update GRUB.

        `$ sudo update-grub`

    6. Reboot your system.

2. Use the iptables rules in the `/docker` folder in this repo to set up the firewall.

3. Install Nginx on the host

4. Install Docker edge (for other installation options, see [the  Docker docs](http://docs.docker.com/installation/ubuntulinux/)):

    `$ curl -s https://get.docker.io/ubuntu/ | sudo sh`

#### Start services

1. Start a Fuseki instance. If you have any TDB data to mount, mount it internally so it sits in the `/tdb_data/artsapi` folder inside the Fuseki Docker container. You will also need to mount the config file found in this repo at `config/production_config.ttl`. Some examples:

    - Assuming the config file has been saved to /var/lib/fuseki-config/config.ttl and no TDB data exists:

      `$ sudo docker run -d --name artsapi-fuseki -v /var/lib/fuseki-config:/opt/fuseki/config thefrey/fuseki:latest`

    - Assuming the config file has been saved to /var/lib/fuseki-config/config.ttl and TDB data exists at /var/lib/artsapi-data/database

      `$ sudo docker run -d --name artsapi-fuseki -v /var/lib/fuseki-config:/opt/fuseki/config -v /var/lib/artsapi-data/database:/data/artsapi thefrey/fuseki:latest`

2. Start a MongoDB instance.

    `$ sudo docker run --name artsapi-mongo -d mongo`

3. Start the application

    `$ sudo docker run -d --name artsapi-test --link artsapi-mongo:mongodb --link artsapi-fuseki:artsapi-fuseki -p 127.0.0.1:1955:80 <artsapi-image>`

4. Make sure you have secured your server! In the example above, you would want Nginx on the host to proxy to `http://localhost:1955`.

    - The `nginx.conf` in the `/docker` directory contains some good defaults
    - To use this, first generate a stronger DHE parameter using `$ cd /etc/ssl/certs && openssl dhparam -out dhparam.pem 2048`
    - You can then copy the file over the existing `nginx.conf` in `/etc/nginx` and `$ sudo service nginx restart`

NB: Remember, to inspect running containers, you can use `sudo docker exec -i -t <container-name> /bin/bash -l`.

## Services Required

- Fuseki
- MongoDB

### Seed data

You will need to upload the concept scheme for keywords; this is in the [ArtsAPI Grafter Project](https://github.com/Swirrl/artsapi-email-processing-tool), in the `doc` folder. Upload these to the named graph of the concept scheme using Fuseki's `s-put` tool. 

1. `cd` into your Fuseki installation directory
2. Load the concept scheme resources `./s-put http://localhost:3030/artsapi-dev/data 'http://data.artsapi.com/graph/keywords' '/path/to/artsapi-graft/doc/keywords_concept_scheme.ttl'`
3. Load the keyword resources `./s-put http://localhost:3030/artsapi-dev/data 'http://data.artsapi.com/graph/keywords' '/path/to/artsapi-graft/doc/keywords_resources.ttl'`

## Licence

MIT - see the LICENCE file.
