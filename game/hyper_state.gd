extends Node

var _on_peer_socket_cb = JavaScriptBridge.create_callback(_on_peer_socket)
func _init():
	print('RUN1: Godot Loading')
	var console = JavaScriptBridge.get_interface("console")
	if console != null:
		console.log('Godot State starting...')
		var loader = JavaScriptBridge.get_interface("bootloader")
		loader.joinTopic("Hello", _on_peer_socket_cb)
		print("RUN2: Joining SWARM")
	else:
		print("No js-runtime detected")

func _on_peer_socket (args):
	print("Peer Joined", args)
