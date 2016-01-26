# Description
#   A hubot script returning you the traffic time between two points.
#
# Commands:
#   traffic home is <address> - set your home address in hubot brain
#   traffic work is <address> - set your work address in hubot brain
#   traffic mode is <driving, walking or bicycling> - set the way you commute
#   i wanna go home - returns the traffic time between work and home
# Author:
#   Florian Meskens <florian.meskens@gmail.com>

module.exports = (robot) ->
	api_key = process.env.HUBOT_DISTANCE_MATRIX_API_KEY or ''
	default_travel_mode = 'driving'
	robot.respond /traffic home is (.*)/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		@userbrain.home = msg.match[1]
		msg.send "Home is now set to #{msg.match[1]}"
	robot.respond /traffic work is (.*)/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		@userbrain.work = msg.match[1]
		msg.send "Work is now set to #{msg.match[1]}"
	robot.respond /traffic mode is (.*)/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		modes = ['driving', 'walking', 'bicycling', 'transit']
		if msg.match[1] in modes
			if msg.match is 'transit' and api_key is ''
				msg.send "Cannot set to transit without API key"
			@userbrain.mode = msg.match[1]
			msg.send "Mode is now set to #{msg.match[1]}"
		else
			msg.send "Mode has to either be driving,walking or bicycling"
	robot.respond /i wanna go home/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		if not @userbrain.mode
			@userbrain.mode = default_travel_mode
		if @userbrain.home and @userbrain.work
			msg.http("https://maps.googleapis.com/maps/api/distancematrix/json")
				.query({origins: "#{@userbrain.work}", destinations: "#{@userbrain.home}", mode: "#{@userbrain.mode}", departure_time: "now", key: api_key}, traffic_model: "best_guess")
				.header('Accept', 'application/json')
				.get() (err, res, body) ->
					if err
						msg.send "#{err}"
						return
					data = JSON.parse body
					if data.error_message
						msg.send "Error: #{data.error_message}"
					duration = if data.rows[0].elements[0].duration_in_traffic then data.rows[0].elements[0].duration_in_traffic.text else data.rows[0].elements[0].duration.text
					msg.send "From #{data.origin_addresses[0]} to #{data.destination_addresses[0]}, it will take #{duration}"
					return
		else
			msg.send "You need to set your home and work address in my brain, #{msg.message.user.name}"
	robot.respond /i wanna be home by ([\d]{1,2})(?:(?:h|:)([\d]{2}))?((?:a|p)m)?/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		if not @userbrain.mode
			@userbrain.mode = default_travel_mode
		if @userbrain.home and @userbrain.work
			if msg.match[3]
				arrival_hour = if msg.match[3].toLowerCase() == 'pm' then (parseInt(msg.match[1]) + 12) else msg.match[1]
			else
				arrival_hour = msg.match[1]
			arrival_minutes = if msg.match[2] then msg.match[2] else 0
			arrival_time = new Date()
			arrival_time.setHours(arrival_hour)
			arrival_time.setMinutes(arrival_minutes)
			arrival_time = Math.round(arrival_time / 1000)
			msg.http("https://maps.googleapis.com/maps/api/distancematrix/json")
				.query({origins: "#{@userbrain.work}", destinations: "#{@userbrain.home}", mode: "#{@userbrain.mode}", arrival_time: arrival_time, key: api_key})
				.header('Accept', 'application/json')
				.get() (err, res, body) ->
					if err
						msg.send "#{err}"
						return
					data = JSON.parse body
					if data.error_message
						msg.send "Error: #{data.error_message}"
					departure_time = new Date((arrival_time - (data.rows[0].elements[0].duration.value))*1000)
					msg.send "From #{data.origin_addresses[0]} to #{data.destination_addresses[0]}, you'll have to leave at #{departure_time.toLocaleTimeString()}"
					return
		else
			msg.send "You need to set your home and work address in my brain, #{msg.message.user.name}"
