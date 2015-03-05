# ArtsAPI

Foo

## Development

1. Install Fuseki.
2. Copy the `fuseki_config.ttl` file from the `/config` folder.
3. In the file, change the value next to `tdb:location` to the location of your tdb folder, for example `/Users/<your-user>/tdb_data/artsapi-dev`.
4. Add `alias fuseki_artsapi="cd $HOME/jena-fuseki-1.0.1 ; ./fuseki-server --config=fuseki_config.ttl"` to your shell to start Fuseki using `$ fuseki-artsapi`. Change `jena-fuseki-1.0.1` in the previous command to the version and folder of your installed version of Fuseki.

### Seed data

You will need to upload the concept scheme for keywords; this is in the [ArtsAPI Grafter Project](), in the `doc` folder. Upload these to the named graph of the concept scheme using Fuseki's `s-put` tool. 

1. `cd` into your Fuseki installation directory
2. Load the concept scheme resources `./s-put http://localhost:3030/artsapi-dev/data 'http://artsapi.com/def/arts/keywords/keywords' '/path/to/artsapi-graft/doc/keywords_concept_scheme.ttl'`
3. Load the keyword resources `./s-put http://localhost:3030/artsapi-dev/data 'http://artsapi.com/def/arts/keywords/keywords' '/path/to/artsapi-graft/doc/keywords_resources.ttl'`
