@tool     # makes script run from within the editor
extends EditorScript    # gives you access to editor functions



func _run():   # this is the main function
	var selection = EditorInterface.get_selection() # the selected node. In your case, select the AnimationPlayer
	selection = selection.get_selected_nodes()  # get the actual AnimationPlayer node
	if selection.size()!=1 and not selection is AnimationPlayer: # if the wrong node is selected, do nothing
		return
	else:
		interpolation_change(selection) # run the funstion in question



func interpolation_change(selection):
	var anim_track_1 = selection[0].get_animation("run") # get the Animation that you are interested in (change "default" to your Animation's name)
	var count  = anim_track_1.get_track_count() # get number of tracks (bones in your case)
	print(count)
	for i in count:
		
		anim_track_1.track_set_interpolation_type(i, Animation.INTERPOLATION_NEAREST) # change interpolation mode for every track
		print(anim_track_1.track_get_interpolation_type(i))
