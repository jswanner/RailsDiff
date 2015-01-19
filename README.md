# RailsDiff

## Generating files

This project makes extensive use of Rake. The default task generates all
the diff files, even for new version of Rails, but can take a very long
time to run:

```sh
rake
```

But, each generated file can be independently [re]generated:

```sh
rake index.html
rake 404.html
rake diff/v3.0.0/v4.0.0.beta1/index.html
rake diff/v3.0.0/v4.0.0.beta1/full/index.html
```

Thanks to Rake, these files will only be [re]generated if needed; and
essentially, what determines if the file needs to be [re]generated is:
the file is missing, or its template file has been updated.

So, to regenerate `index.html`, for example, you can either:

```sh
rm index.html
rake index.html
```

Or:

```sh
touch template/index.haml # or a more meaningful change to the file
rake index.html
```

For convenience, if you want to conditionally regenerate all the HTML
files, you can run:

```sh
rake regenerate_html
```
