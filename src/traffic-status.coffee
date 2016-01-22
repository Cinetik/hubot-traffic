# Description
#   A hubot script returning you the traffic time between two points.
#
# Commands:
#   traffic home is <address> - set your home address in hubot brain
#   traffic work is <address> - set your work address in hubot brain
#   i wanna go home - returns the traffic time between work and home
#
# Author:
#   Florian Meskens <florian.meskens@gmail.com>

module.exports = (robot) ->

	robot.respond /traffic home is (.*)/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		@userbrain.home = msg.match[1]
		msg.send "Home is now set to #{msg.match[1]}"
	robot.respond /traffic work is (.*)/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		@userbrain.work = msg.match[1]
		msg.send "Work is now set to #{msg.match[1]}"
	robot.respond /i wanna go home/i, (msg) ->
		@userbrain = robot.brain.userForName(msg.message.user.name)
		if @userbrain.home and @userbrain.work
			msg.http("https://maps.googleapis.com/maps/api/distancematrix/json")
				.query({origins: "#{@userbrain.work}", destinations: "#{@userbrain.home}", mode: "driving", departure_time: "now"})
				.header('Accept', 'application/json')
				.get() (err, res, body) ->
					if err
						msg.send "#{err}"
						return
					data = JSON.parse body
					msg.send "From #{data.origin_addresses[0]} to #{data.destination_addresses[0]}, it will take #{data.rows[0].elements[0].duration.text}"
					return
		else
			msg.send "You need to set your home and work address in my brain, #{msg.message.user.name}"
