# With fixes for Windows, docker, and 0.0.0.0
# https://tonyho.net/jekyll-docker-windows-and-0-0-0-0/

#docker run -it --rm -p 4000:4000 -e "JEKYLL_ENV=docker" -v "$PWD`:/srv/jekyll" devblackops.io jekyll serve --watch --force_polling --incremental --strict_front_matter --drafts --future --config _config.yml,_config_docker.yml
docker run -it --rm -p 4000:4000 -e "JEKYLL_ENV=docker" -v "$PWD`:/srv/jekyll" jekyll/jekyll:3.8 jekyll serve --watch --force_polling --incremental --strict_front_matter --drafts --future --config _config.yml,_config_docker.yml
