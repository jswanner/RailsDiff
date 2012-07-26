[![Build Status](https://secure.travis-ci.org/jswanner/RailsDiff.png)](http://travis-ci.org/jswanner/RailsDiff)

# RailsDiff

## TODO:

1. Have rake tasks to generate diffs.
2. Style landing page.

## To run the application locally

```sh
jekyll
```

Open browser to `http://localhost:8080/`.

### To generate diff files and html

```sh
rake gen_diffs
```

This will only generate files that are missing, if you want to
regenerate a file, `rm` it first.
