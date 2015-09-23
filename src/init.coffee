$(document).ready ->
	# scroll to game 
	$("#playbtn").click ->
		$('html, body').animate {scrollTop: $('#game').offset().top}, 1000
	# send contact form
	$("#contact_form").submit (event) ->
		event.preventDefault()
		msgStr = 
			'name': $("#contact_name").val(),
			'email': $("#contact_email").val(),
			'message': $("#contact_msg").val()
		$.ajax 
			type: 'POST',
			url: 'sendmsg.php',
			data: msgStr,
			dataType: 'json',
			async: false,
			success: (data) ->
				if data.success
					$('#contact_send').val("Thanks!")
					$('#contact_send').prop('disabled', true)
			error: (data) ->
				$('#contact_send').addClass('btn-danger')
				$('#contact_send').val("Error sending message.")
				$('#contact_send').prop('disabled', true)


