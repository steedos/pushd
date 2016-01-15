exports.server =
    redis_port: 6379
    redis_host: 'localhost'
    # redis_socket: '/var/run/redis/redis.sock'
    # redis_auth: 'password'
    tcp_port: 2001
    udp_port: 2001
    access_log: yes
    acl:
        # restrict publish access to private networks
        publish: ['127.0.0.1', '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']
#    auth:
#        # require HTTP basic authentication, username is 'admin' and
#        # password is 'password'
#        #
#        # HTTP basic authentication overrides IP-based authentication
#        # if both acl and auth are defined.
#        admin:
#            password: 'password'
#            realms: ['register', 'publish']

exports['web'] =
    enabled: yes
    webCourierURL: 'http://192.168.0.148/webcourier'
    class: require('./lib/pushservices/web').PushServiceWEB

exports['event-source'] =
    enabled: yes

exports['baidu|otask'] =
    enabled: yes
    class: require('./lib/pushservices/baidu').PushServiceBaidu
    api_key: 'qyFIVG4Zh6LsF7jWIFwyDNaH'
    secret_key: '0To4trs8yt9NqGlIKxDkPGgsw5yPtXdw'

exports['baidu|workflow'] =
    enabled: yes
    class: require('./lib/pushservices/baidu').PushServiceBaidu
    api_key: 'sDfG6F30DnSW0KjNDdGREqcY'
    secret_key: 'uOyudjcjUMBae9zb823eLhINFHQtnTFC'

exports['baidu|chat'] =
    enabled: yes
    class: require('./lib/pushservices/baidu').PushServiceBaidu
    api_key: 'p8o19OLLZE5yFaFMCS4uVV9Q'
    secret_key: '7P188OA54gcVLKDqM4pFy8jDwXXGAu1Y'

exports['apns|workflow'] =
    enabled: yes
    class: require('./lib/pushservices/apns').PushServiceAPNS
    # Convert cert.cer and key.p12 using:
    # $ openssl x509 -in cert.cer -inform DER -outform PEM -out apns-cert.pem
    # $ openssl pkcs12 -in key.p12 -out apns-key.pem -nodes
    cert: '../steedos-certs/push/apns-cert-workflow.pem'
    key: '../steedos-certs/push/apns-key-workflow.pem'
    cacheLength: 100
    # Selects data keys which are allowed to be sent with the notification
    # Keep in mind that APNS limits notification payload size to 256 bytes
    payloadFilter: ['messageFrom']
    # uncommant for dev env
    #gateway: 'gateway.sandbox.push.apple.com'
    #address: 'feedback.sandbox.push.apple.com'

exports['apns|chat'] =
    enabled: yes
    class: require('./lib/pushservices/apns').PushServiceAPNS
    # Convert cert.cer and key.p12 using:
    # $ openssl x509 -in cert.cer -inform DER -outform PEM -out apns-cert.pem
    # $ openssl pkcs12 -in key.p12 -out apns-key.pem -nodes
    cert: '../steedos-certs/push/apns-cert-chat.pem'
    key: '../steedos-certs/push/apns-key-chat.pem'
    cacheLength: 100
    # Selects data keys which are allowed to be sent with the notification
    # Keep in mind that APNS limits notification payload size to 256 bytes
    payloadFilter: ['messageFrom']
    # uncommant for dev env
    #gateway: 'gateway.sandbox.push.apple.com'
    #address: 'feedback.sandbox.push.apple.com'

exports['apns|otask'] =
    enabled: yes
    class: require('./lib/pushservices/apns').PushServiceAPNS
    # Convert cert.cer and key.p12 using:
    # $ openssl x509 -in cert.cer -inform DER -outform PEM -out apns-cert.pem
    # $ openssl pkcs12 -in key.p12 -out apns-key.pem -nodes
    cert: '../steedos-certs/push/apns-cert-otask.pem'
    key: '../steedos-certs/push/apns-key-otask.pem'
    cacheLength: 100
    # Selects data keys which are allowed to be sent with the notification
    # Keep in mind that APNS limits notification payload size to 256 bytes
    payloadFilter: ['messageFrom']
    # uncommant for dev env
    #gateway: 'gateway.sandbox.push.apple.com'
    #address: 'feedback.sandbox.push.apple.com'

# # Uncomment to use same host for prod and dev
# exports['apns-dev'] =
#     enabled: yes
#     class: require('./lib/pushservices/apns').PushServiceAPNS
#     # Your dev certificats
#     cert: 'apns-cert.pem'
#     key: 'apns-key.pem'
#     cacheLength: 100
#     gateway: 'gateway.sandbox.push.apple.com'

exports['gcm'] =
    enabled: yes
    class: require('./lib/pushservices/gcm').PushServiceGCM
    key: 'GCM API KEY HERE'

# # Legacy Android Push Service
# exports['c2dm'] =
#     enabled: yes
#     class: require('./lib/pushservices/c2dm').PushServiceC2DM
#     # App credentials
#     user: 'app-owner@gmail.com'
#     password: 'something complicated and secret'
#     source: 'com.yourcompany.app-name'
#     # How many concurrent requests to perform
#     concurrency: 10

exports['http'] =
    enabled: yes
    class: require('./lib/pushservices/http').PushServiceHTTP

exports['mpns-toast'] =
    enabled: yes
    class: require('./lib/pushservices/mpns').PushServiceMPNS
    type: 'toast'
    # Used for WP7.5+ to handle deep linking
    paramTemplate: '/Page.xaml?object=${data.object_id}'

exports['mpns-tile'] =
    enabled: yes
    class: require('./lib/pushservices/mpns').PushServiceMPNS
    type: 'tile'
    # Mapping defines where - in the payload - to get the value of each required properties
    tileMapping:
        # Used for WP7.5+ to push to secondary tiles
        # id: "/SecondaryTile.xaml?DefaultTitle=${event.name}"
        # count: "${data.count}"
        title: "${data.title}"
        backgroundImage: "${data.background_image_url}"
        backBackgroundImage: "#005e8a"
        backTitle: "${data.back_title}"
        backContent: "${data.message}"
        # param for WP8 flip tile (sent when subscriber declare a minimum OS version of 8.0)
        smallBackgroundImage: "${data.small_background_image_url}"
        wideBackgroundImage: "${data.wide_background_image_url}"
        wideBackContent: "${data.message}"
        wideBackBackgroundImage: "#005e8a"

exports['mpns-raw'] =
    enabled: yes
    class: require('./lib/pushservices/mpns').PushServiceMPNS
    type: 'raw'

exports['loglevel'] = 'verbose'
