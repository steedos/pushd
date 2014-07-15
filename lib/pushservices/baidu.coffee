BCM = require 'baidu-push-sdk'

class PushServiceBaidu
  tokenFormat: /^[0-9_]+$/
  validateToken: (token) ->
    @logger.info "token: " + token
    if PushServiceBaidu::tokenFormat.test(token)
      return token.toLowerCase()

  constructor: (conf, @logger, tokenResolver) ->
    @logger.verbose "api_key: " + conf.api_key
    @logger.verbose "secret_key: " + conf.secret_key
    opt =
      ak: conf.api_key
      sk: conf.secret_key

    @bcm = new BCM(opt)

  push: (subscriber, subOptions, payload) ->
    # token的格式: channelId + "_" + userId
    # info {"proto":"baidu|otask","token":"4421797412868072244_1021458100439220363","updated":1405307999,"created":1405072050}
    subscriber.get (info) =>
      @logger.info "Baidu push: " + JSON.stringify(info)

      messageCallback = (err, result) =>
        @logger.verbose "Baidu push message callback: " + err
        @logger.verbose "Baidu push message callback: " + JSON.stringify(result)

      notifCallback = (err, result) =>
        @logger.verbose "Baidu push notification callback: " + err
        @logger.verbose "Baidu push notification callback: " + JSON.stringify(result)

      ts = info.token.split("_")
      now = new Date
      now = now.getTime() + ""
      msg = payload.msg.default
      # 去掉换行符
      msg = msg.replace(/\n/g, "")

      @logger.info "Baidu push title: " + payload.title.default
      @logger.info "Baidu push description: " + msg
      @logger.info "Baidu push badge: " + payload.badge

      # # 发送推送消息
      # @bcm.pushMsg({
      #   push_type: 1,
      #   device_type: 4,
      #   user_id: ts[1],
      #   channel_id: ts[0],
      #   message_type: 0,
      #   msg_keys: JSON.stringify([now]),
      #   messages: JSON.stringify({
      #     description: payload.msg.default,
      #     badge: payload.badge
      #   }),
      # }, messageCallback)

      # 发送通知
      @bcm.pushMsg({
        push_type: 1,
        device_type: 4,
        user_id: ts[1],
        channel_id: ts[0],
        message_type: 1,
        msg_keys: JSON.stringify([now]),
        messages: JSON.stringify({
          title: payload.title.default, 
          description: msg,
          notification_builder_id: 0,
          notification_basic_style: 4,
          open_type: 2,
          custom_content: {
            badge: payload.badge
          }
        })
      }, notifCallback)

exports.PushServiceBaidu = PushServiceBaidu