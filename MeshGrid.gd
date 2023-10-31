extends MeshInstance2D

var grid_size = 10
var grid_step = 100
var triangulation_dict = null
var owner_id = null

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


func generateTriangleMesh() -> ArrayMesh:
	set_grid()
	build_triangulation_dict()
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
			var triangle_list = []
			for tri in triangulation_dict[square]:
				indices.append(index_count)
				index_count += 1
				triangle_list.append(# self.get_parent().position + # TODO: WTF fix this - was caused by Top Level setting
				(tri * self.grid_step) + Vector2(x * self.grid_step, y * self.grid_step))
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

# Called when the node enters the scene tree for the first time.
func _ready():
	set_grid()	
	self.mesh = generateTriangleMesh()

	#	%MeshCollider.set_polygon(PackedVector2Array(self.mesh.surface_get_arrays(self.mesh.ARRAY_VERTEX)[0]))
		#%MeshCollider.set_polygon(PackedVector2Array([Vector2(100, 100), Vector2(100, 200), Vector2(200,100), Vector2(200,200)]))



func regenerate(v):
	self.mesh = generateTriangleMesh()
	var point_cloud = []
	#if self.mesh != null:
		#for p in self.mesh.create_trimesh_shape().get_faces():
		#	point_cloud.append(Vector2(p.x, p.y))
		#%MeshCollider.set_polygon(PackedVector2Array(point_cloud))
	if self.mesh != null:
		var body = self.get_parent()
		if self.owner_id != null:
			body.shape_owner_clear_shapes(self.owner_id)
		else:
			self.owner_id = body.create_shape_owner(body)
		
		var points = self.mesh.surface_get_arrays(self.mesh.ARRAY_VERTEX)[0]
		var i = 0
		while i < (points.size() / 3):
			#var line1 = SegmentShape2D.new()
			#var line2 = SegmentShape2D.new()
			#var line3 = SegmentShape2D.new()
			#line1.a = points[3*i]
			#line1.b = points[(3*i)+1]
			#line2.a = points[3*i]
			#line2.b = points[(3*i)+2]
			#line3.a = points[(3*i)+1]
			#line3.b = points[(3*i)+2]
			
			#body.shape_owner_add_shape(self.owner_id, line1)
			#body.shape_owner_add_shape(self.owner_id, line2)
			#body.shape_owner_add_shape(self.owner_id, line3)
			var s = ConvexPolygonShape2D.new()
			s.set_point_cloud(PackedVector2Array(Array([points[3*i], points[(3*i)+1], points[(3*i)+2]])))
			body.shape_owner_add_shape(self.owner_id, s)
			i += 1

		print(body.get_shape_owners())
		print(body.shape_owner_get_shape_count(self.owner_id))

func set_grid():
	var root_node = get_tree().get_root()
	var root_grid_size = root_node.get("grid_size")
	if root_grid_size != null:
		self.grid_size = root_grid_size
	var root_grid_step = root_node.get("grid_step")
	if root_grid_step != null:
		self.grid_step = root_grid_step


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
