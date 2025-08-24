# FreshRSS with built-in extensions

This is a Docker image built from the official FreshRSS base image, which includes built-in extensions:

- Image Proxy (to add a HTTP prefix URL for all images in a feed)
- Reading Time (to add estimated reading time for a feed item)
- GReader Redate (use published time rather than the fetching time)
- TranslateTitlesCN (to translate titles into Chinese)

## Why we need this

FreshRSS extensions need to be available on this default path in container: `/var/www/FreshRSS/extensions`. But fly.io doesn’t support having same mount for mulitple directories, or having multiple mounts. If we try mount the parent path `/var/www/FreshRSS`, it'll led to _kernel panic_. So I want it works on fly.io when I'm only able to mount the data path with `/var/www/FreshRSS/data`. See `fly.toml` file.
