# Step 1
# Click a selection on the image

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
        $("#toggledebug").click (e) ->
                $("#debug").toggle()
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
        if $("#measure-length-img").length
                drawLine(x1,y1,x2,y2)
        $("#measure-length-canvas").click (e) ->
                # Case 1: Selecting 1st point
                if x1 is -1
                        click_x = e.pageX
                        click_y = e.pageY
                        x1 = Math.round(click_x - $(this).offset().left)
                        y1 = Math.round(click_y - $(this).offset().top)
                        $("#measure-length-next").hide();
                # Case 2: Selecting 2nd point (need to calc dist)
                else
                        x2 = Math.round(e.pageX - $(this).offset().left)
                        y2 = Math.round(e.pageY - $(this).offset().top)
                        x_term = Math.pow(x2 - x1, 2)
                        y_term = Math.pow(y2 - y1, 2)
                        dist = Math.sqrt(x_term + y_term)
                        if dist is 0
                                dist = 1
                        $("input[name=length").val(Math.round(dist))
                        drawLine(x1,y1,x2,y2)
                        x1 = y1 = x2 = y2 = -1
                        $("#measure-length-next").show()
                $("#measure-length-canvas").mousemove (e) ->
                        if (x1 isnt -1) and (x2 is -1)
                                drawLine(x1,y1,e.pageX - $(this).offset().left, e.pageY - $(this).offset().top)
                        
        $('input[name=video]').change (e) ->
                if e.target.files.length
                        $("#upload-next").show()
                else
                        $("#upload-next").hide()
        $("#measure-length-next").click (e) ->
                $('#loading-screen').show()
