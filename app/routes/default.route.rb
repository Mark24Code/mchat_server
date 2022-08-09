App.define_routes do

  get '/' do
    json({
      message: 'Hello mchat!'
    })
  end

  get '/timestamp' do
    json({
      code: 200,
      message: "success",
      data: {
        timestamp: Time.now.to_i
      }
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

  get '/ping' do
    # 30s 的低频心跳
    json({
      code: 200,
      message: "success",
      data: "pong"
    })
  end

  get '/channel' do
    
    # 返回所有channel
    json({
      code: 200,
      message: "success",
      data: ["ch01", "ch02"]
    })
  end
end