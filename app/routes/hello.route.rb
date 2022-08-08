App.define_routes do

  get '/' do
    name = settings.redis.get("mark")
    json({
      message: 'hello world' + name
    })
  end
end