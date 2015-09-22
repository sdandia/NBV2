center = (elem) ->
	elem.anchor.set 0.5

load = 
	preload: ->
		game.load.image 'sky', 'assets/game_sky.png'
		game.load.image 'birdy', 'assets/game_birdy.png'
		game.load.image 'cloud', 'assets/game_cloud.png'
		game.load.image 'submit-btn', 'assets/game_submit_btn.png'
		game.load.image 'replay-btn', 'assets/game_restartbtn.png'
		game.load.image 'start-btn', 'assets/game_startbtn.png'
		game.load.audio 'soundtrack', ['assets/Fireflies.m4a', 'assets/Fireflies.ogg']
	create: ->
		game.stage.backgroundColor = bgColor
		game.state.start 'menu'

menu = 
	create: ->
		game.add.sprite 0, 0, 'sky'
		root.music = game.add.audio 'soundtrack'
		centerX = game.world.width/2
		centerY = game.world.height/2
		root.style = 
			font: '32px "Source Sans Pro"'
			fontWeight: '300' 
			fill: textColor
			align: 'center'
		if game.elapsedTime > 0
			center(game.add.text centerX, centerY - 35, 
				"Game Over! You survived for " + game.elapsedTime + " seconds", style)
			center(game.add.button centerX, centerY + 45, 'replay-btn', 
				this.start, this, 2, 1, 0)
		else 
			center(game.add.text centerX, centerY - 35, 'Press the Up Arrow to Jump!', style)
			center(game.add.button centerX, centerY + 45, 'start-btn', 
				this.start, this, 2, 1, 0)
	start: ->
		game.time.reset()
		music.play "", 0, 1, true, true
		game.state.start 'play'

play = 
	create: ->
		game.physics.startSystem Phaser.Physics.ARCADE
		e = game.input.keyboard.addKey Phaser.Keyboard.UP
		e.onDown.add(this.jump, this)
		game.add.sprite 0, 0, 'sky'
		game.physics.setBoundsToWorld false, false, true, false
		root.birdy = game.add.sprite 100, 200, 'birdy'
		game.physics.arcade.enable(birdy)
		birdy.anchor.setTo -.2, .5
		root.clouds = game.add.group()
		clouds.enableBody = true
		clouds.physicsBodyType = Phaser.Physics.ARCADE
		clouds.createMultiple 20, 'cloud', 0, false
		this.loop_through_clouds
		game.time.events.loop Phaser.Timer.SECOND*2.5, this.loop_through_clouds, this
		game.displayTime = game.elapsedTime = 0
		root.setTime = game.add.text 5, game.height-30, "Elapsed time: " + game.displayTime, 
			{font: "20px Source Sans Pro", fontWeight: "300"}
	update: ->
		this.game_over() if not birdy.inWorld
		game.displayTime = Math.floor(game.time.totalElapsedSeconds() * 1)/1
		setTime.setText "Elapsed time: " + game.displayTime
		birdy.angle += 1 if birdy.angle < 20
		game.physics.arcade.overlap(birdy, clouds, this.hit_cloud, null, this)
		birdy.body.gravity.y = 800
		birdy.body.collideWorldBounds = true
		game.physics.arcade.checkCollision.down = false
	jump: ->
		return if not birdy.alive
		birdy.body.velocity.y = -350
		flappyMotion = game.add.tween birdy
		flappyMotion.to {angle: -20}, 45
		flappyMotion.start()
	game_over: ->
		birdy.body.velocity.x = birdy.body.velocity.y = 0
		game.elapsedTime = Math.floor(game.time.totalElapsedSeconds() * 1)/1
		clouds.destroy();
		game.time.reset()
		music.stop()
		game.input.keyboard.clearCaptures()
		game.state.start 'menu'
	add_a_cloud: (x, y) ->
		addCloud = clouds.create x, y, 'cloud'
		addCloud.body.velocity.x = -150
		addCloud.outOfBoundsKill = true
	loop_through_clouds: ->
		x = 300
		for i in [0...3]
			x = if x < 750 then x+150 else 450
			newY = (Math.floor(Math.random() * 6)) * 100
			while newY is y
				newY = (Math.floor(Math.random() * 6)) * 100
			y = newY
			this.add_a_cloud x, y
	hit_cloud: (birdy, cloud) ->
		return if (not birdy.alive) or (game.physics.arcade.distanceBetween(birdy, cloud) > 88)
		birdy.alive = false
		clouds.visible = false

window.addEventListener 'keydown', (e) ->
		if e.keyCode is 38
			e.preventDefault()
, false

root = exports ? this
game = new Phaser.Game 800, 600, Phaser.AUTO, 'game'
score = yVal = 0
game.elapsedTime = 0
bgColor = "#87DEF9"
textColor = "#000000"
game.state.add 'load', load
game.state.add 'menu', menu
game.state.add 'play', play
game.state.start 'load'



