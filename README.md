# Mchat Server

Lightweight web framework codebase. Just clone and develop on it.

Tech component: Rack+Sinatra+Sequel and default use Postgresql database.

Add rails-like migration command line helpers.


## ENV

`REDIS_URL`

## Find helpful rake tasks

`rake` or  `rake -T`

all tasks in `config/tasks`, you can edit by yourself.

## Run server & develop

`rake server:dev`

## Production Server & deploy

`rake server:prod`

you can also use docker

`docker built -t <what your docker image label>  .`
