extends GraphEdit


signal node_added(node)
signal node_deleted(node)
signal params_changed
signal connections_changed(connections)


class Sorter:
	static func sort(a,b)->bool:
		return a["option"]<b["option"]


enum{
	GEN_SINE,GEN_SAW
}
const MENU:Array=[
	"unsorted",
	{"option":"NODED_MENU_GENERATORS","submenu":[
		{"option":"NODED_MENU_SINE","id":GEN_SINE},
		{"option":"NODED_MENU_SAW","id":GEN_SAW}
	]},
	{"separator":true},
	{"option":"NODED_MENU_TRANSFORMS","submenu":[
	]}
]
const NODES:Dictionary={
	GEN_SINE:preload("res://ui/wave_designer/node_designer/nodes/generators/sine_node.tscn"),
	GEN_SAW:preload("res://ui/wave_designer/node_designer/nodes/generators/saw_node.tscn")
}
const NODES_CLASS:Dictionary={
	OutputNodeComponent.NODE_TYPE:preload("res://ui/wave_designer/node_designer/nodes/output_node.tscn"),
	SineNodeComponent.NODE_TYPE:NODES[GEN_SINE],
	SawNodeComponent.NODE_TYPE:NODES[GEN_SAW]
}


var new_menu:PopupMenu
var add_position:Vector2
var node_graph:Dictionary={}
var reverse_graph:Dictionary={}
var size_po2:int=0


func _ready() -> void:
	new_menu=create_menu(MENU)
	get_parent().call_deferred("add_child",new_menu)
	get_zoom_hbox().hide()


func _on_gui_input(ev:InputEvent)->void:
	if ev is InputEventMouseButton and not ev.pressed and ev.button_index==2:
		add_position=ev.position
		new_menu.rect_position=ev.global_position
		new_menu.popup()


func create_menu(menu:Array)->PopupMenu:
	var m:PopupMenu=PopupMenu.new()
	m.connect("id_pressed",self,"_on_add_node")
	if menu.empty():
		return m
	var menu2:Array=menu.duplicate()
	if typeof(menu2[0])==TYPE_DICTIONARY:
		menu2.sort_custom(Sorter,"sort")
	else:
		menu2=menu2.slice(1,-1)
	for op in menu2:
		if "option" in op:
			if "submenu" in op:
				var m2:PopupMenu=create_menu(op["submenu"])
				m.add_child(m2)
				m.add_submenu_item(op["option"],m2.name,-1)
			else:
				m.add_item(op["option"],op.get("id",-1))
		elif "separator" in op:
			m.add_separator("",-1)
	return m


func _on_add_node(type:int)->void:
	var nn:NodeController=NODES[type].instance()
	nn.connect("params_changed",self,"_on_params_changed")
	nn.connect("about_to_close",self,"_on_node_about_to_close")
	nn.offset=add_position
	nn.set_parameters()
	nn.set_size_po2(size_po2)
	add_child(nn)
	emit_signal("node_added",nn.node)


func regen_editor_nodes(wave:NodeWave)->void:
	set_block_signals(true)
	for c in get_connection_list():
		disconnect_node(c.from,c.from_port,c.to,c.to_port)
	for n in get_children():
		if n is NodeController:
			n.queue_free()
	if wave==null:
		return
	var nodes:Dictionary={}
	for n in wave.components:
		var nn:NodeController=NODES_CLASS[n.NODE_TYPE].instance()
		nn.node=n
		nn.connect("params_changed",self,"_on_params_changed")
		nn.connect("about_to_close",self,"_on_node_about_to_close")
		nn.set_parameters()
		add_child(nn)
		nodes[n]=nn
	for node in nodes:
		var to_node:String=nodes[node].name
		for input_slot in node.inputs.size():
			for connection in node.inputs[input_slot]:
				connect_node(nodes[connection].name,0,to_node,input_slot)
	update_connection_graph()
	set_block_signals(false)
	emit_signal("params_changed")


func update_connection_graph()->void:
	reverse_graph.clear()
	for n in get_children():
		if n is GraphNode:
			reverse_graph[n.name]={}
			node_graph[n.name]={}
	for con in get_connection_list():
		reverse_graph[con["to"]][con["from"]]=false
		node_graph[con["from"]][con["to"]]=false


func is_cyclic(node:String,visited:Dictionary,stack:Dictionary)->bool:
	visited[node]=true
	stack[node]=true
	for n in reverse_graph[node]:
		if not visited.get_or_add(n,false):
			if is_cyclic(n,visited,stack):
				return true
		elif stack.get_or_add(n,false):
			return true
	stack[node]=false
	return false


func invalidate_dependants(to:String)->void:
	var connections:Dictionary={}
	for con in get_connection_list():
		if not con["from"] in connections:
			connections[con["from"]]={}
		connections[con["from"]][con["to"]]=false
	var dependants:Array=[]
	find_dependants(to,dependants,node_graph)
	for dep in dependants:
		get_node(dep).invalidate()


func find_dependants(to:String,dependants:Array,connections:Dictionary)->void:
	dependants.append(to)
	for dep in connections[to]:
		find_dependants(dep,dependants,connections)


func _on_connection_request(from:String,from_slot:int,to:String,to_slot:int)->void:
	update_connection_graph()
	var new_rconn:bool=not to in reverse_graph[to]
	reverse_graph[to][from]=false
	if new_rconn:
		for n in reverse_graph:
			if is_cyclic(n,{},{}):
				reverse_graph[to].erase(from)
				return
	node_graph[from][to]=false
	connect_node(from,from_slot,to,to_slot)
	get_node(to).connect_node(get_node(from),to_slot)
	invalidate_dependants(to)
	emit_signal("connections_changed",get_connections_map())


func _on_disconnection_request(from:String,from_slot:int,to:String,to_slot:int)->void:
	disconnect_node(from,from_slot,to,to_slot)
	update_connection_graph()
	get_node(to).disconnect_node(get_node(from),to_slot)
	invalidate_dependants(to)
	emit_signal("connections_changed",get_connections_map())


func get_connections_map()->Array:
	var conns:Array=[]
	for con in get_connection_list():
		con.from=get_node(con.from).node
		con.to=get_node(con.to).node
		conns.append(con)
	return conns


func _on_node_about_to_close(node:NodeController)->void:
	for conn in get_connection_list():
		if conn.from==node.name:
			disconnect_node(conn.from,conn.from_port,conn.to,conn.to_port)
			get_node(conn.to).disconnect_node(node,conn.to_port)
			invalidate_dependants(conn.to)
		elif conn.to==node.name:
			disconnect_node(conn.from,conn.from_port,conn.to,conn.to_port)
			get_node(conn.from).disconnect_node(node,conn.from_port)
			invalidate_dependants(conn.to)
	update_connection_graph()
	emit_signal("node_deleted",node.node)
	node.queue_free()


func _on_params_changed(node:NodeController)->void:
	invalidate_dependants(node.name)
	emit_signal("params_changed")
