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
6. Use `bundle exec sidekiq -c 1` to bring up sidekiq for background processing.
7. Fill in the correct details in `/db/seeds.example`, rename the file to `seeds.rb` and use `rake db:seed` to generate a user.

NB: You *must* be running Fuseki on port 3030 if you do not want to modify the multiple tenancy code. If you want to use the Dropbox upload features, you will also need a copy of the [ArtsAPI Grafter project](https://github.com/Swirrl/artsapi-email-processing-tool) on your hard drive so that the Rails app can call leiningen to run pipelines. Put the absolute path to this directory (e.g. `/Users/jeff/artsapi-email-processing-tool`) in the `grafter_config.example` file and then rename it `grafter_config.rb`.

In production, you will use env vars to declare dropbox credentials. In development, you will need to find the file in `/config/initializers` called `dropbox.example` - add your credentials for Dropbox in here and rename it `dropbox.rb`. Make sure you do not commit this, as you will have to change `production.rb` to not expect env vars with the locations provided (see the Docker/Deployment) section below.

### Foreman

If you wish to use Foreman to manage development (we encourage this), then add the locations into the `Procfile.example` file, and rename it `Procfile`. Then, change out of this directory and `$ gem install foreman`; you will now be able to use `foreman start` to bring up development dependencies. Make sure you have development unicorn configuration at `./config/unicorn_development.rb`

### Thread Safety (Important!)
Although effort has been made to try and make the application thread-safe, we cannot guarantee thread safety; hence you will need to pass the `-c 1` option to Sidekiq when running.

## Deployment

Deploy using Docker. Setup a Redis, Mongo and Fuseki instance before linking them to this container.


### Dropbox

In order to run the application and create uploads, the env vars `DROPBOX_APP_KEY` and `DROPBOX_APP_SECRET` need to be set. Pass these in when running the container using the `-e` Docker flag. You will need to make sure you have registered for the Dropbox API in order to get these. 

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

3. Start the application. Note that you can also set `ADMIN_MAILER_PASSWORD` in `production.rb` and `SENTRY_KEY` in `sentry.rb` and thus avoid having to pass them through.

    ```
    $ sudo docker run -d --name artsapi-test \
        --link artsapi-mongo:mongodb \
        --link artsapi-fuseki:artsapi-fuseki \
        -v /var/lib/artsapi-assets:/artsapi-assets \
        -p 127.0.0.1:1955:8080 \
        -e DROPBOX_APP_KEY=<dropbox-app-key> \
        -e DROPBOX_APP_SECRET=<dropbox-app-secret> \
        -e ADMIN_MAILER_PASSWORD=<mandrill-password-here> \
        -e SENTRY_KEY=<sentry-key> \
        <artsapi-image>
    ```

4. Make sure you have secured your server! In the example above, you would want Nginx on the host to proxy to `http://localhost:1955`.

    - The `nginx.conf` in the `/docker` directory contains some good defaults
    - To use this, first generate a stronger DHE parameter using `$ cd /etc/ssl/certs && openssl dhparam -out dhparam.pem 2048`
    - You can then copy the file over the existing `nginx.conf` in `/etc/nginx` and `$ sudo service nginx restart`

NB: Remember, to inspect running containers, you can use `sudo docker exec -i -t <container-name> /bin/bash -l`.

## Services Required

- Fuseki
- MongoDB

Accounts needed:

1. [Dropbox](https://www.dropbox.com)
2. [Mandrill](https://www.mandrill.com)
3. [Sentry](https://getsentry.com)

### Seeding Users

In development, `rake db:seed` will create an example user; however, the data bootstrap task will try to infer the logged-in user's organisation in the data using the registered email, so if the organisation whose data is in the system is called WidgetCorp, with a URL of `http://www.widgetcorp.org` and a mailserver at the same host, you will want to create a user on the command line (using an email `@widgetcorp.org`) rather than using the rake task, as this will allow you to use the data bootstrapping/background processing class methods on Organisation.

In production, you will need to make sure you have correctly set up your Fuseki config and then ensure that the user's email matches the host that their data will use in the system. See the development instructions above for more details on that.

### Seed data

In production, so long as you have seeded your User correctly for each tenant on the system, the bootstrap data tasks will seed the database with the concept schemes and resources you require.

In development, you will need to upload the concept scheme for keywords; this is in the [ArtsAPI Grafter Project](https://github.com/Swirrl/artsapi-email-processing-tool), in the `doc` folder. Upload these to the named graph of the concept scheme using Fuseki's `s-put` tool. 

1. `cd` into your Fuseki installation directory
2. Load the concept scheme resources `./s-put http://localhost:3030/artsapi-dev/data 'http://data.artsapi.com/graph/keywords' '/path/to/artsapi-graft/doc/keywords_concept_scheme.ttl'`
3. Load the keyword resources `./s-put http://localhost:3030/artsapi-dev/data 'http://data.artsapi.com/graph/keywords' '/path/to/artsapi-graft/doc/keywords_resources.ttl'`
4. Load the SIC resources and extensions `./s-put http://localhost:3030/artsapi-dev/data 'http://data.artsapi.com/graph/sic' '/path/to/artsapi/lib/sic2007.ttl'`

## Licence

MIT - see the LICENCE file.
