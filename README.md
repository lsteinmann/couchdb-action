# CouchDB GitHub Action for testing idaifieldR

This [GitHub Action](https://github.com/features/actions) sets up a CouchDB v2.3.1 database using the
default docker image. 

It is a modified version of [joelnb/couchdb-action](https://github.com/joelnb/couchdb-action) that sets up a database structure as used by the [iDAI.field 2 / Field Desktop database](https://github.com/dainst/idai-field) to allow me testing [idaifieldR](https://github.com/lsteinmann/idaifieldR) in a workflow using docs located at "inst/testdata/import.json" in the repository it is run in. Ignore it, is is not useful for anyone else.

# Usage

See [action.yml](action.yml) and [test.yml](.github/workflows/test.yml).

Basic:

```yaml
steps:
  - name: Set up CouchDB
    uses: "cobot/couchdb-action@master"
    with:
      couchdb version: '2.3.1'
  - name: Do something
    run: |
      curl http://127.0.0.1:5984/
```

# Contributions

- [Cobot](https://www.cobot.me)
- [CouchDB @ Neighbourhoodie Software](https://neighbourhood.ie/couchdb-support/)

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)
