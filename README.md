# Mchat Server

Mchat is IRC like chat client.

This is Mchat server repo, client repo:

* [mchat_client](https://github.com/Mark24Code/mchat)

## Prepare

make sure you run redis service
## ENV

provide ENV for the server.

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



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

