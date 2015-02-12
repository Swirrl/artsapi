# ArtsAPI

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Development

1. Install Fuseki.
2. Copy the `fuseki_config.ttl` file from the `/config` folder.
3. Add `alias fuseki_artsapi="cd $HOME/jena-fuseki-1.0.1 ; ./fuseki-server --config=fuseki_config.ttl"` to your shell to start Fuseki using `$ fuseki-artsapi`. Change `jena-fuseki-1.0.1` in the previous command to the version and folder of your installed version of Fuseki.
