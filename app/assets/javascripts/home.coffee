# Coordinates of measurement
x1 = y1 = x2 = y2 = -1

drawLine = (x1,y1,x2,y2) ->
        img = new Image()
        img.src = document.getElementById('measure-length-img').src
        img.onload = () ->
                canvas = document.getElementById('measure-length-canvas')
                canvas.height = img.height
                canvas.width = img.width
                ctx = canvas.getContext('2d')
                ctx.clearRect(0, 0, canvas.width, canvas.height)
                ctx.drawImage(img,0,0)
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.strokeStyle = '#00ff00'
                ctx.lineWidth = 5
                ctx.stroke()

$(document).ready ->
	$("#click-object-img").click (e) ->
                x = Math.round(e.pageX - $(this).offset().left)
                y = Math.round(e.pageY - $(this).offset().top)
                $("input[name=x]").val(x)
                $("input[name=y]").val(y)
                $("#click-object-next").show()
	$("#click-object-next").click (e) ->
                $("#click-object").hide()
                $("#measure-length").show()
                document.body.scrollTop = document.documentElement.scrollTop = 0
	$("#measure-length-canvas").mousemove (e) ->
                 if (x1 isnt -1) and (x2 is -1)
                         drawLine(x1,y1,e.pageX - $(this).offset().left, e.pageY - $(this).offset().top)
	$("#measure-length-canvas").mousedown (e) ->
                #  Selecting 1st point
                click_x = e.pageX
                click_y = e.pageY
                x1 = Math.round(click_x - $(this).offset().left)
                y1 = Math.round(click_y - $(this).offset().top)
                $("#measure-length-next").hide();
	if $("#measure-length-img").length
	        drawLine(x1,y1,x2,y2)
	$("#measure-length-canvas").mouseup (e) ->
                # Selecting 2nd point (need to calc dist)
		x2 = Math.round(e.pageX - $(this).offset().left)
		y2 = Math.round(e.pageY - $(this).offset().top)
		if (x1 == x2) and (y1 == y2)
		   drawLine(x1,y1,x2,y2)
		   x1 = x2 = y1 = y2 = -1
		   return
		x_term = Math.pow(x2 - x1, 2)
		y_term = Math.pow(y2 - y1, 2)
		dist = Math.sqrt(x_term + y_term)
		if dist is 0
                        dist = 1
                $("input[name=length]").val(Math.round(dist))
                drawLine(x1,y1,x2,y2)
                x1 = y1 = x2 = y2 = -1
                $("#measure-length-next").show()
	$('input[name=video]').change (e) ->
		if e.target.files.length
		        $("#upload-next").show()
		else
		        $("#upload-next").hide()
	$("#measure-length-next").click (e) ->
		$('#loading-screen').show()
	$("#upload-to-isense").click (e) ->
                $("#isense-form").show()
        $("#isense-cancel").click (e) ->
                $("#isense-form").hide()
        $("#isense-submit").click (e) ->
                $("#isense-form").hide()
                for elt in $('input')
                        if !elt.value
                                alert "Not everything filled out!"
                                return
                # Get key information
                project = $("#isense-pid").val()
                key = $("#isense-key").val()
                title = $("#isense-dset").val()
                yourname = $("#isense-name").val()
                # Field matching
                field_matching = [$("#t").val(), $("#x").val(), $("#y").val(), $("#vx").val(), $("#vy").val(), $("#ax").val(), $("#ay").val()]
                urlProject = 'http://isenseproject.org/api/v1/projects/' + project
                responseProject = $.ajax({ type: "GET", url: urlProject, async: false, dataType: "JSON"}).responseText
                fields = JSON.parse(responseProject).fields
                fids = {}
                for field in fields
                        name = field.name
                        idx = field_matching.indexOf(name)
                        fids[idx] = field.id.toString()
                # Format data for iSENSE
                data = {}
                data[fids[0]] = $('#data-table td:nth-child(1)').map(() -> return $(this).text()).get()
                data[fids[1]] = $('#data-table td:nth-child(2)').map(() -> return $(this).text()).get()
                data[fids[2]] = $('#data-table td:nth-child(3)').map(() -> return $(this).text()).get()
                data[fids[3]] = $('#data-table td:nth-child(4)').map(() -> return $(this).text()).get()
                data[fids[4]] = $('#data-table td:nth-child(5)').map(() -> return $(this).text()).get()
                data[fids[5]] = $('#data-table td:nth-child(6)').map(() -> return $(this).text()).get()
                data[fids[6]] = $('#data-table td:nth-child(7)').map(() -> return $(this).text()).get()
                console.log data
                # Perform the upload
                apiUrl = 'https://isenseproject.org/api/v1/projects/' + project + '/jsonDataUpload'
                upload = {
                        'title': title,
                        'contribution_key': key,
                        'contributor_name': yourname,
                        'data': data
                }
                $.post(apiUrl, upload, () -> alert "Sweet, it worked!").error(() -> alert "It failed... please check your details, they must be exact!")
