# Mchat Server

Mchat is IRC like chat client.

This is Mchat server repo, client repo:

* [mchat_client](https://github.com/Mark24Code/mchat)

[Doc: 用Ruby打造一个命令行Slack](https://mark24code.github.io/ruby/2022/08/15/%E7%94%A8Ruby%E6%89%93%E9%80%A0%E4%B8%80%E4%B8%AA%E5%91%BD%E4%BB%A4%E8%A1%8CSlack.html)

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

