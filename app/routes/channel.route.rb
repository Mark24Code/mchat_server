require_relative './status_code'

module ChannelConfig
  UserOnlineExpire = 960 # 必须大于轮询更新时间
  UserOnlineHeartCheck = 920 # 必须小于
  MessageExpire = 930
end

module SafeProtect
  refine String do
    def safe
      self.strip.dump[1 .. -2]
    end

    def escape
      self.dump[1 .. -2]
    end

    def unescape
      "\"#{self}\"".undump
    end
  end
end

using SafeProtect

App.define_routes do

  def boardcast_channel_message(content)

    new_message = {
      user_name: 'Mchat',
      content: content,
      timestamp: Time.now.to_i
    }

    msg_key = "mchat_channels:#{channel_name}/messages:#{user_name}/time:#{timestamp}"

    settings.redis.hmset(msg_key, *new_message)
    settings.redis.expire(msg_key, ChannelConfig::MessageExpire)
  end

  # 约定
  # prefix: mchat_channels  
  # Redis Data Structure:  <key:value>/<key:value>/
  get '/channels' do
    channels = settings.redis.smembers('mchat_channels')
    # 返回所有channel
    json({
      code: StatusCode::Success,
      message: "success",
      data: channels || []
    })
  end

  delete '/channels/:name' do
    begin
      channel_name = params[:name].safe
      
      #检查如果存在成员，则无法删除
      channel_active_users = settings.redis.keys("mchat_channels:#{channel_name}/users*")
      if channel_active_users.length > 0 
        return json({
          code: StatusCode::ServerError,
          message: "the channel have active users , cannot delete it",
          data: {
            active_user_count: channel_active_users.length
          }
        })
      end

      resp = settings.redis.srem('mchat_channels', channel_name)
      json({
        code: StatusCode::Success,
        message: "delete <mchat_channels:#{channel_name}> success",
        data: {
          channel_name: channel_name
        }
      })
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end

  post '/channels/:name' do
    # 创建频道
    begin
      channel_name = params[:name].safe
      
      channels = settings.redis.smembers("mchat_channels") || []
      # 检查如果存在成员，则无法重复创建
      if channels.any?(channel_name)
        return json({
        code: StatusCode::RecordHaveExist,
        message: "channel <mchat_channels:#{channel_name}> have exist",
        data: {
          channel_name: channel_name,
        }
      })
      end
  
      resp = settings.redis.sadd('mchat_channels', channel_name)
      json({
        code: StatusCode::Success,
        message: "create <mchat_channels:#{channel_name}> success",
        data: {
          channel_name: channel_name,
        }
      })
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end

  get '/channels/:channel_name' do
    # 频道信息
    # * 返回在线用户
    begin
      channel_name = params[:channel_name].safe
      channel_active_users = settings.redis.keys("mchat_channels:#{channel_name}/users*")
      json({
        code: StatusCode::Success,
        message: "success",
        data: {
          online_users: channel_active_users || [],
          total_users: channel_active_users.length || 0
        }
      })
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end

  post '/channels/:channel_name/join' do
    # 加入频道，注册用户
    begin
      channel_name = params[:channel_name].safe
      payload = JSON.parse(request.body.read)
      user_name = payload.fetch("user_name", "").safe

      if !user_name || !channel_name || ['mchat','admin','system','0','null','nil', ' '].any?(user_name.downcase)
        json({
          code: StatusCode::InvalidParams,
          message: "params are invalid",
          data: nil
        })
      end

      check_name = settings.redis.get("mchat_channels:#{channel_name}/users:#{user_name}")

      if check_name
        json({
          code: StatusCode::UserHaveExist,
          message: "user have exist",
          data: nil
        })
      else
        name_key = "mchat_channels:#{channel_name}/users:#{user_name}"

        create_name = settings.redis.set(name_key, user_name)
        settings.redis.expire(name_key, ChannelConfig::UserOnlineExpire)

        boardcast_channel_message("<#{user_name}> join the channel.")
        json({
          code: StatusCode::Success,
          message: "success",
          data: {
            user_name: create_name,
          }
        })
      end
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end

  post '/channels/:channel_name/leave' do
    # 离开频道，注销用户
    begin
      channel_name = params[:channel_name].safe
      payload = JSON.parse(request.body.read)
      user_name = payload.fetch("user_name", "").safe # form

      if !user_name || !channel_name
        json({
          code: StatusCode::InvalidParams,
          message: "params are invalid",
          data: nil
        })
      end

      check_name = settings.redis.get("mchat_channels:#{channel_name}/users:#{user_name}")

      if check_name
        del_user = settings.redis.del("mchat_channels:#{channel_name}/users:#{user_name}")
        
        # 注册离开信息
        boardcast_channel_message("<#{user_name}> leave the channel.")
        
        json({
          code: StatusCode::Success,
          message: "leave mchat_channels:#{channel_name}",
          data: del_user
        })
      else
        json({
          code: StatusCode::UserNotExist,
          message: "success",
          data: nil
        })
      end
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end

  post '/channels/:channel_name/ping' do
    # 更新在线状态

    begin
      channel_name = params[:channel_name].safe
      payload = JSON.parse(request.body.read)
      user_name = payload.fetch("user_name", "").safe # form

      name_key = "mchat_channels:#{channel_name}/users:#{user_name}"
      check_name = settings.redis.get(name_key)

      if check_name 
        settings.redis.expire(name_key, ChannelConfig::UserOnlineExpire)
        return json({
          code: StatusCode::Success,
          message: "success",
          data: {
            expire_at: Time.now.to_i + ChannelConfig::UserOnlineExpire,
            user_name: user_name
          }
        })
      else
        return json({
          code: StatusCode::UserNotExist,
          message: "error user not exist",
          data: { 
            user_name: user_name
          }
        })
      end
      
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end

  post '/channels/:channel_name/messages' do
    # 创建频道信息
    begin
      channel_name = params[:channel_name].safe
      payload = JSON.parse(request.body.read)

      user_name = payload.fetch("user_name", "").safe 
      content = payload.fetch("content", "").safe
      timestamp = Time.now.to_i
      new_message = {
        user_name: user_name,
        content: content,
        timestamp: timestamp
      }

      msg_key = "mchat_channels:#{channel_name}/messages:#{user_name}/time:#{timestamp}"

      settings.redis.hmset(msg_key, *new_message)
      settings.redis.expire(msg_key, ChannelConfig::MessageExpire)
      
      json({
        code: StatusCode::Success,
        message: "post new message success",
        data: {
          channel_name: channel_name
        }
      })
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end

  get '/channels/:channel_name/messages' do
    begin
      channel_name = params[:channel_name].safe
      # payload = JSON.parse(request.body.read)

      # 获得还未超时的所有记录
      all_pattern = "mchat_channels:#{channel_name}/messages*"

      # TODO 替换为 scan 提高性能
      messages_keys = settings.redis.keys(all_pattern)
      messages = messages_keys.map do |message_key|
        settings.redis.hgetall(message_key)
      end
      return json({
        code: StatusCode::Success,
        message: "success",
        data: {
          messages: messages || []
        }
      })
    rescue => exception
      json({
        code: StatusCode::ServerError,
        message: "error",
        data: exception
      })
    end
  end
end