# Description
#   A hubot script returning you the traffic time between two points.
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Florian Meskens <florian.meskens@gmail.com>

module.exports = (robot) ->
	robot.respond /traffic plz/i, (msg) ->
		msg.http("https://maps.googleapis.com/maps/api/distancematrix/json")
			.query({origins: "Chaussée de Bruxelles Wavre", destinations: "Ciney", mode: "driving", departure_time: "now"})
			.header('Accept', 'application/json')
			.get() (err, res, body) ->
				if err
					msg.send "#{err}"
				
				data = JSON.parse body
				msg.send "From #{data.origin_addresses[0]} to #{data.destination_addresses[0]}, it will take #{data.rows[0].elements[0].duration.text}"
				return
