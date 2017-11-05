# Step 1
# Click a selection on the image

# Coordinates of measurement
x1 = y1 = x2 = y2 = -1

$(document).ready ->
        $("#toggledebug").click (e) ->
                $("#debug").toggle()
        $("#click-object-img").click (e) ->
                x = Math.round(e.pageX - $(this).offset().left)
                y = Math.round(e.pageY - $(this).offset().top)
                $("input[name=x]").val(x)
                $("input[name=y]").val(y)
        $("#measure-object-img").click (e) ->
                # Case 1: Selecting 1st point
                if x1 is -1
                        x1 = Math.round(e.pageX - $(this).offset().left)
                        y1 = Math.round(e.pageY - $(this).offset().top)
                # Case 2: Selecting 2nd point (need to calc dist)
                else
                        x2 = Math.round(e.pageX - $(this).offset().left)
                        y2 = Math.round(e.pageY - $(this).offset().top)
                        x_term = Math.pow(x2 - x1, 2)
                        y_term = Math.pow(y2 - y1, 2)
                        x1 = y1 = x2 = y2 = -1
                        dist = Math.sqrt(x_term + y_term)
                        $("input[name=length").val(Math.round(dist))
