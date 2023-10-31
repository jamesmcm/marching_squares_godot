extends MeshInstance2D

var grid_size = null
var grid_step = null
var triangulation_dict = null
var owner_id = null
var current_collider_shapes_points = {}
var shape_add_count = 0

func build_triangulation_dict(): 
	var triangulation_dict = {
	Vector4(false, false, false, false) : [],
	Vector4(true, false, false, false) : [Vector2(0.0, 0.0), Vector2(0.5, 0.0), Vector2(0.0, 0.5)],
	Vector4(true, true, false, false) : [Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 0.5),
		Vector2(1.0, 0.0), Vector2(1.0, 0.5), Vector2(0.0, 0.5),],
	Vector4(true, false, false, true) : [Vector2(0.0, 0.0), Vector2(0.5, 0.0), Vector2(0.0, 0.5),
	Vector2(1.0, 1.0), Vector2(0.5, 1.0), Vector2(1.0, 0.5)],

	
	Vector4(true, true, true, true) : [Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(1.0, 1.0),
		Vector2(0.0, 1.0), Vector2(1.0, 1.0), Vector2(0.0, 0.0),],
		
	Vector4(true, true, true, false) : [Vector2(0.0, 0.0), Vector2(0.0, 1.0), Vector2(0.5, 1.0),
	Vector2(0.0, 0.0), Vector2(1.0, 0.5), Vector2(0.5, 1.0),
	Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(1.0, 0.5),
	]
		}
		
	triangulation_dict[Vector4(false, true, true, true)] = triangulation_dict[Vector4(true, true, true, false)].map(func(pos): return (Vector2(-1,-1)*pos) + Vector2(1,1))
	triangulation_dict[Vector4(true, false, true, true)] = triangulation_dict[Vector4(true, true, true, false)].map(func(pos): return (Vector2(1,-1)*pos) + Vector2(0,1))
	triangulation_dict[Vector4(true, true, false, true)] = triangulation_dict[Vector4(true, true, true, false)].map(func(pos): return (Vector2(-1,1)*pos) + Vector2(1,0))
	triangulation_dict[Vector4(false, false, true, true)] = triangulation_dict[Vector4(true, true, false, false)].map(func(pos): return (Vector2(1,-1)*pos) + Vector2(0,1))
	
	triangulation_dict[Vector4(false, true, false, false)] = triangulation_dict[Vector4(true, false, false, false)].map(func(pos): return (Vector2(-1,1)*pos) + Vector2(1,0))
	triangulation_dict[Vector4(false, false, true, false)] = triangulation_dict[Vector4(true, false, false, false)].map(func(pos): return (Vector2(1,-1)*pos) + Vector2(0,1))
	triangulation_dict[Vector4(false, false, false, true)] = triangulation_dict[Vector4(true, false, false, false)].map(func(pos): return (Vector2(-1,-1)*pos) + Vector2(1,1))
	
	triangulation_dict[Vector4(false, true, true, false)] = triangulation_dict[Vector4(true, false, false, true)].map(func(pos): return (Vector2(-1,1)*pos) + Vector2(1,0))
	
	triangulation_dict[Vector4(true, false, true, false)] = [Vector2(0.0, 0.0), Vector2(0.0, 1.0), Vector2(0.5, 1.0),
		Vector2(0.5, 1.0), Vector2(0.0, 0.0), Vector2(0.5, 0.0),]
		
	triangulation_dict[Vector4(false, true, false, true)] = triangulation_dict[Vector4(true, false, true, false)].map(func(pos): return pos + Vector2(0.5,0))
	triangulation_dict[Vector4(false, false, true, true)] = triangulation_dict[Vector4(true, true, false, false)].map(func(pos): return pos + Vector2(0,0.5))
	self.triangulation_dict = triangulation_dict


# TODO: Iterative generate mesh
# Given modified points and existing mesh, delete and regenerate only affected points

func generateTriangleMesh() -> ArrayMesh:
	set_grid()
	build_triangulation_dict()
	var body = self.get_parent()
	var index_count = 0
	var indices = PackedInt32Array()
	var all_triangles = []
	for y in range(0, self.grid_size - 1):
		for x in range(0, self.grid_size - 1):
			# print(y, x)
			var square = Vector4(%Points.points_status[(y*self.grid_size) + x],
			%Points.points_status[(y*self.grid_size) + x + 1],
			%Points.points_status[((y+1)*self.grid_size) + x],
			%Points.points_status[((y+1)*self.grid_size) + x + 1]
			)
			var triangle_list = PackedVector2Array()
			
			for tri in triangulation_dict[square]:
				indices.append(index_count)
				index_count += 1
				var new_tri = (tri * self.grid_step) + Vector2(x * self.grid_step, y * self.grid_step)
				
				triangle_list.append(new_tri)
			all_triangles.append_array(triangle_list)
			
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector2Array()
	# print(self.position)
	# print(self.global_position)
	# print(all_triangles)
	if all_triangles.size() == 0:
		return null
	
	verts.append_array(all_triangles)
	arr[Mesh.ARRAY_VERTEX] = verts
	# arr[Mesh.ARRAY_TEX_UV] = uvs
	# arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return mesh

func create_collider_shape(points):
	var s = ConvexPolygonShape2D.new()
	s.points = points # Does this copy?
	return s
# Called when the node enters the scene tree for the first time.
func _ready():
	set_grid()	
	self.mesh = generateTriangleMesh()

	#	%MeshCollider.set_polygon(PackedVector2Array(self.mesh.surface_get_arrays(self.mesh.ARRAY_VERTEX)[0]))
		#%MeshCollider.set_polygon(PackedVector2Array([Vector2(100, 100), Vector2(100, 200), Vector2(200,100), Vector2(200,200)]))

func clear_shapes(b, owner):
	# b.shape_owner_clear_shapes(owner)
	b.remove_shape_owner(self.owner_id)
	self.owner_id = b.create_shape_owner(b)

func get_new_collider_shapes_set():
	if self.mesh == null:
		return {}
	var points = self.mesh.surface_get_arrays(self.mesh.ARRAY_VERTEX)[0]
	if points.size() == 0:
		return {}
	var i = 0
	var points_set = {}
	while i < (points.size() / 3):
		# var s = ConvexPolygonShape2D.new()
		# s.points = PackedVector2Array(Array([points[3*i], points[(3*i)+1], points[(3*i)+2]]))
		#body.shape_owner_add_shape(self.owner_id, s)
		points_set[[points[3*i], points[(3*i)+1], points[(3*i)+2]]] = true
		i += 1
	return points_set

func set_difference(d1, d2):
	return d1.keys().filter(func(k): return !d2.has(k))

func regenerate(v):
	var body = self.get_parent()
	#if self.owner_id != null:
	#	self.clear_shapes(body, self.owner_id)
	if self.owner_id == null:
		self.owner_id = body.create_shape_owner(body)
	self.mesh = generateTriangleMesh()
	
	var new_set = get_new_collider_shapes_set()
	# print(new_set)
	var new_tris = set_difference(new_set, self.current_collider_shapes_points)
	var deleted_tris = set_difference(self.current_collider_shapes_points, new_set)
	
	for new_tri in deleted_tris:
		var id = self.current_collider_shapes_points[new_tri]
		body.shape_owner_remove_shape(self.owner_id, id)
		self.current_collider_shapes_points.erase(new_tri)
		# TODO: WTF - can we avoid this?
		self.shape_add_count -= 1
		for k in self.current_collider_shapes_points.keys():
			if self.current_collider_shapes_points[k] >= id:
				self.current_collider_shapes_points[k] = self.current_collider_shapes_points[k] - 1
		print(body.shape_owner_get_shape_count(self.owner_id))

	for new_tri in new_tris:
		print(body.shape_owner_get_shape_count(self.owner_id))
		var s = ConvexPolygonShape2D.new()
		s.points = PackedVector2Array(new_tri)
		body.shape_owner_add_shape(self.owner_id, s)
		self.current_collider_shapes_points[new_tri] = self.shape_add_count #s.get_rid().get_id()
		self.shape_add_count += 1
		# s.get_instance_id()  # Is this shape_id ?
	# print(self.current_collider_shapes_points)
		
		
		
	#print("New points " + str(new_points))
	#print("Deleted points " + str(deleted_points))
	#var point_cloud = []
	#if self.mesh != null:
		#for p in self.mesh.create_trimesh_shape().get_faces():
		#	point_cloud.append(Vector2(p.x, p.y))
		#%MeshCollider.set_polygon(PackedVector2Array(point_cloud))
		
		#var points = self.mesh.surface_get_arrays(self.mesh.ARRAY_VERTEX)[0]
		#var i = 0
		#while i < (points.size() / 3):
			#var s = ConvexPolygonShape2D.new()
			## s.set_point_cloud(PackedVector2Array(Array([points[3*i], points[(3*i)+1], points[(3*i)+2]])))
			#s.points = PackedVector2Array(Array([points[3*i], points[(3*i)+1], points[(3*i)+2]]))
			#body.shape_owner_add_shape(self.owner_id, s)
			#i += 1

		# print(body.get_shape_owners())
		# print(body.shape_owner_get_shape_count(self.owner_id))

func set_grid():
	var root_node = get_tree().get_root().get_child(0)
	var root_grid_size = root_node.get("grid_size")
	if root_grid_size != null:
		self.grid_size = root_grid_size
	var root_grid_step = root_node.get("grid_step")
	if root_grid_step != null:
		self.grid_step = root_grid_step


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
