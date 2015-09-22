center = (elem) ->
	elem.anchor.set 0.5

isSmallScreen = ->
	game.scale.width <= 400

load = 
	preload: ->
		game.load.image 'sky', 'assets/game_sky_large.png'
		game.load.image 'birdy', 'assets/game_birdy.png'
		game.load.image 'cloud', 'assets/game_cloud.png'
		game.load.image 'submit-btn', 'assets/game_submit_btn.png'
		game.load.image 'replay-btn', 'assets/game_restartbtn.png'
		game.load.image 'start-btn', 'assets/game_startbtn.png'
		game.load.audio 'soundtrack', ['assets/Fireflies.m4a', 'assets/Fireflies.ogg']
	create: ->
		game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL
		game.scale.minWidth = 400
		game.scale.minHeight = 300
		game.scale.maxWidth = 1200
		game.scale.maxHeight = 900
		game.scale.refresh()
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
		root.style.font = '20px "Source Sans Pro"' if game.world.width < 500
		if game.elapsedTime > 0
			center(game.add.text centerX, centerY - 35, 
				"Game Over! You survived for " + game.elapsedTime + " seconds", style)
			center(game.add.button centerX, centerY + 45, 'replay-btn', 
				this.start, this, 2, 1, 0)
		else 
			center(game.add.text centerX, centerY - 35, 'Press the Up Arrow to Jump!', style)
			center(game.add.button centerX, centerY + 45, 'start-btn', 
				this.start, this, 2, 1, 0)
		game.input.maxPointers = 1
		if not game.device.desktop
			game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL
			game.scale.maxWidth = window.screen.width * window.devicePixelRatio
			game.scale.maxHeight = window.screen.height * window.devicePixelRatio
			game.scale.refresh()

	start: ->
		game.time.reset()
		music.play "", 0, 1, true, true
		game.state.start 'play'

play = 
	create: ->
		game.physics.startSystem Phaser.Physics.ARCADE
		game.add.sprite 0, 0, 'sky'
		game.physics.setBoundsToWorld false, false, true, false
		xPos = if isSmallScreen() then 20 else 100
		root.birdy = game.add.sprite xPos, 200, 'birdy'
		game.physics.arcade.enable(birdy)
		birdy.anchor.setTo -.2, .5
		root.clouds = game.add.group()
		clouds.enableBody = true
		clouds.physicsBodyType = Phaser.Physics.ARCADE
		callCloudLoop = if isSmallScreen() then 2.5 else 3
		this.loop_through_clouds
		game.time.events.loop Phaser.Timer.SECOND*callCloudLoop, this.loop_through_clouds, this
		game.displayTime = game.elapsedTime = 0
		root.setTime = game.add.text 5, game.height-30, "Elapsed time: " + game.displayTime, 
			{font: "20px Source Sans Pro", fontWeight: "300"}
		game.input.keyboard.addKeyCapture 38
		game.input.keyboard.addKeyCapture 40
		birdy.body.gravity.y = 800
		birdy.body.collideWorldBounds = true
		game.physics.arcade.checkCollision.down = false
		root.cursors = game.input.keyboard.createCursorKeys()
	update: ->
		this.game_over() if not birdy.inWorld
		game.displayTime = Math.floor(game.time.totalElapsedSeconds() * 1)/1
		setTime.setText "Elapsed time: " + game.displayTime
		birdy.angle += 1 if birdy.angle < 20
		game.physics.arcade.overlap(birdy, clouds, this.hit_cloud, null, this)
		if cursors.up.isDown or game.input.pointer1.isDown
			this.jump()
	jump: ->
		return if not birdy.alive
		birdy.body.velocity.y = -250
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
		addCloud.checkWorldBounds = true
		addCloud.outOfBoundsKill = true
	loop_through_clouds: ->
		maxX = Math.floor(game.width/100)
		minX = maxX - 3
		numClouds = 4
		yPos = []
		yRange = Math.floor(game.scale.height / 100)
		for i in [0...numClouds]
			x = Math.floor((Math.random() * (maxX - minX) + minX) * 100)
			newY = (Math.floor(Math.random() * 6)) * 100
			while (yPos.indexOf newY) > -1
				newY = (Math.floor(Math.random() * 6)) * 100
			yPos.push newY
			y = newY
			this.add_a_cloud x, y
	hit_cloud: (birdy, cloud) ->
		return if (not birdy.alive) or (game.physics.arcade.distanceBetween(birdy, cloud) > 88)
		birdy.alive = false
		clouds.visible = false

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



