async = require 'async'
util = require 'util'
logger = require 'winston'
settings = require '../settings'

uuid = require './uuid'

generateResponse = (req, res, subscriber) ->
    subscriber.getSubscriptions (subs) ->
        if subs?
            result = {}
            result.pushToken = subscriber.id
            result.pushTokenTTL = 6000
            result.registeredTopics = []

            for sub in subs
                result.registeredTopics.push(sub.event.name.split("|")[0])

            if (settings.web.webCourierURL)
                result.webCourierURL = settings.web.webCourierURL
            else
                result.webCourierURL = "https://pushws.steedos.com/webcourier"
            res.json result


exports.setup  = (app, createSubscriber, getEventFromId, authorize, testSubscriber, eventPublisher, getSubscriberFromId) ->
    authorize ?= (realm) ->


    app.post '/getState', authorize('register'), (req, res) ->

        logger.verbose "getState: " + JSON.stringify(req.body)
        try
            states = []
            if req.body.pushTopics?
                events = {}
                c = 0
                for topic in req.body.pushTopics
                    eventName = topic
                    if req.param("steedosId")?
                        eventName = eventName + "|" + req.param("steedosId").replace("@", "_").replace(".", "_")
                    events[topic] = {}
                    events[topic].pushTopic = topic
                    events[topic].data = {}
                    event = getEventFromId(eventName)
                    event.info (info, name) ->
                        if info?
                            events[name.split("|")[0]].data.badge = info.badge
                            states.push(events[name.split("|")[0]])
                        c = c + 1
                        if (c >= req.body.pushTopics.length)
                            res.json {states: states}, 200

        catch error
            logger.error "Creating token failed: #{error.message}"
            res.json error: error.message, 400

    app.post '/getToken', authorize('register'), (req, res) ->


        logger.verbose "getToken: " + JSON.stringify(req.body)
        try
            fields = {}

            if req.body.proto?
                fields.proto = req.body.proto
            else
                fields.proto = "web"

            if req.body.pushToken?
                fields.token = req.body.pushToken
            else
                fields.token = uuid()

            createSubscriber fields, (subscriber, created) ->
                subscriber.get (info) ->
                    info.id = subscriber.id
                    if req.body.pushTopics?
                        events = {};
                        for topic in req.body.pushTopics
                            eventName = topic
                            if req.param("steedosId")?
                                eventName = eventName + "|" + req.param("steedosId").replace("@", "_").replace(".", "_")
                            events[eventName] = {}
                        subscriber.addSubscriptions events, (r) ->
                            generateResponse(req, res, subscriber)

        catch error
            logger.error "Creating token failed: #{error.message}"
            res.json error: error.message, 400


    app.post '/registerAPNS', authorize('register'), (req, res) ->

        logger.verbose "registerAPNS: " + JSON.stringify(req.body)
        try
            fields = {}
            fields.proto = "apns"
            fields.token = req.body.pushToken
            createSubscriber fields, (subscriber, created) ->
                subscriber.get (info) ->
                    info.id = subscriber.id
                    if req.body.pushTopics?
                        events = {};
                        for topic in req.body.pushTopics
                            eventName = topic
                            if req.param("steedosId")?
                                eventName = eventName + "|" + req.param("steedosId").replace("@", "_").replace(".", "_")
                            events[eventName] = {}
                        subscriber.addSubscriptions events, (r) ->
                            generateResponse(req, res, subscriber)

        catch error
            logger.error "Creating token failed: #{error.message}"
            res.json error: error.message, 400


    app.post '/registerGCM', authorize('register'), (req, res) ->

        logger.verbose "registerGCM: " + JSON.stringify(req.body)
        try
            fields = {}
            fields.proto = "gcm"
            fields.token = req.body.pushToken
            createSubscriber fields, (subscriber, created) ->
                subscriber.get (info) ->
                    info.id = subscriber.id
                    if req.body.pushTopics?
                        events = {};
                        for topic in req.body.pushTopics
                            eventName = topic
                            if req.param("steedosId")?
                                eventName = eventName + "|" + req.param("steedosId").replace("@", "_").replace(".", "_")
                            events[eventName] = {}
                        subscriber.addSubscriptions events, (r) ->
                            generateResponse(req, res, subscriber)

        catch error
            logger.error "Creating token failed: #{error.message}"
            res.json error: error.message, 400


    app.post '/registerTopics', authorize('register'), (req, res) ->

        logger.verbose "registerTopics: " + JSON.stringify(req.body)
        try
            if req.body.pushToken?
                req.subscriber = getSubscriberFromId(req.body.pushToken)
            else
                throw new Error("pushToken not found")

            if req.body.pushTopics?
                events = {};
                for topic in req.body.pushTopics
                    eventName = topic
                    if req.param("steedosId")?
                        eventName = eventName + "|" + req.param("steedosId").replace("@", "_").replace(".", "_")
                    events[eventName] = {}
                req.subscriber.addSubscriptions events, (r) ->
                    generateResponse(req, res, req.subscriber)

        catch error
            logger.error "registerTopics failed: #{error.message}"
            res.json error: error.message, 400


    app.post '/unregisterTopics', authorize('register'), (req, res) ->

        logger.verbose "unregisterTopics: " + JSON.stringify(req.body)
        try
            if req.body.pushToken?
                req.subscriber = getSubscriberFromId(req.body.pushToken)
            else
                throw new Error("pushToken not found")

            if req.body.pushTopics?
                events = {};
                for topic in req.body.pushTopics
                    eventName = topic
                    if req.param("steedosId")?
                        eventName = eventName + "|" + req.param("steedosId").replace("@", "_").replace(".", "_")
                    events[eventName] = {}
                req.subscriber.removeSubscriptions events, (r) ->
                    generateResponse(req, res, req.subscriber)

        catch error
            logger.error "registerTopics failed: #{error.message}"
            res.json error: error.message, 400



    app.post '/message', authorize('publish'), (req, res) ->

        logger.verbose "message: " + JSON.stringify(req.body)
        res.send 204
        try
            if req.body.pushTopic?
                if req.body.toUsers?
                    for user in req.body.toUsers
                        eventName = req.body.pushTopic + "|" + user.replace("@", "_").replace(".", "_")
                        event = getEventFromId(eventName)
                        message = {}
                        if req.body.data?
                            if req.body.data.alertTitle?
                                message.title = req.body.data.alertTitle
                            if req.body.data.alert?
                                message.msg = req.body.data.alert
                            if req.body.data.badge?
                                message.badge = req.body.data.badge + ""
                            if req.body.data.sound?
                                message.sound = req.body.data.sound
                            if req.body.data.data?
                                message.data = req.body.data.data

                        eventPublisher.publish(event, message)

        catch error
            logger.error "send message failed: #{error.message}"



    app.post '/webcourier', authorize('listen'), (req, res) ->

        tok = req.param("tok")
        subscriber =  getSubscriberFromId(tok)
        subscriber.getSubscriptions (subs) ->
            if subs?
                eventNames = []
                for sub in subs
                    eventNames.push(sub.event.name)

                if req.param("ttl")
                    req.socket.setTimeout(req.param("ttl"));
                req.socket.setNoDelay(true);
                res.set
                    'Content-Type': 'text/plain',
                    'Cache-Control': 'no-cache',
                res.write('\n')

                if req.get('User-Agent')?.indexOf('MSIE') != -1
                    # Work around MSIE bug preventing Progress handler from behing thrown before first 2048 bytes
                    # See http://forums.adobe.com/message/478731
                    res.write new Array(2048).join('\n')

                sendEvent = (event, payload) ->
                    data =
                        pushTopic: event.name.split("|")[0]
                        alertTitle: payload.title.default
                        alert: payload.msg.default
                        badge: payload.badge
                        sound: payload.sound

                    res.write(JSON.stringify(data))
                    res.end()

                antiIdleInterval = setInterval ->
                    res.write "\n"
                , 10000

                res.socket.on 'close', =>
                    clearInterval antiIdleInterval
                    for eventName in eventNames
                        eventPublisher.removeListener eventName, sendEvent

                for eventName in eventNames
                    eventPublisher.addListener eventName, sendEvent