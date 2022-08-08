App.define_routes do

  get '/' do
    name = settings.redis.get("mark")
    json({
      message: 'hello world' + name
    })
  end

  get '/startup' do
    json({
      code: 200,
      message: "success",
      data: {
        timestamp: Time.now.to_i,
        uid: "Mchat",
        content: "Welcome to Mchat. Connect server success! :D"
      }
    })
  end
end