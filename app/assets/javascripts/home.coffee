# Step 1
# Click a selection on the image
$(document).ready ->
    $("#click-object-img").click (e) ->
        x = Math.round(e.pageX - $(this).offset().left)
        y = Math.round(e.pageY - $(this).offset().top)
        $("input[name=x]").val(x)
        $("input[name=y]").val(y)