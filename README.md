# hubot-traffic-status

A hubot script returning you the traffic time between two points.

See [`src/traffic-status.coffee`](src/traffic-status.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-traffic --save`

Then add **hubot-traffic** to your `external-scripts.json`:

```json
[
  "hubot-traffic"
]
```

## Sample Interaction

```
user1>> hubot traffic home is Where the Hatred is
hubot>> Home is set to Where the Hatred is

user1>> hubot traffic work is Where the Love is
hubot>> Work is set to Where the Love is

user1>> hubot i wanna go home
hubot>> From Where the Love is to Where the Hatred is, it will take 34 mins
```
