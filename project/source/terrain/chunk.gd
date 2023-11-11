
extends MeshInstance3D

class_name TerrainChunk

@onready var object_tiles = {
	"plains_grass":preload("res://source/world/plains_grass.tscn"),
	
	"plains_tree":preload("res://source/world/plains_tree.tscn"),
	"coniferous_tree":preload("res://source/world/coniferous_tree.tscn"),
	"jungle_tree":preload("res://source/world/jungle_tree.tscn"),
	
	"beach_stone":preload("res://source/world/beach_stone.tscn"),
	}

@export_range(20, 400, 1) var terrain_size := 64
@export_range(1, 64, 1) var resolution := 64

@export var noise_level = 6
@export var noise_frequency = 0.03

var center_offset = 0.5
var noise_offset = 1

var chunk_lods = [8,16,32,48]
var position_coord = Vector2()

var set_collision = false

var biome_data = {
	"deep_ocean":{}, # 深海群系
	"ocean":{}, # 海洋群系
	"shoal":{}, # 浅滩群系
	
	"beach":{"beach_stone":0.01}, # 沙滩群系
	
	"jungle":{"jungle_tree":0.01}, # 热带雨林群系
	"plains":{"plains_tree":0.006}, # 平原群系
	"coniferous":{"coniferous_tree":0.01}, # 针叶林群系
	
	"desert":{}, # 沙漠群系
	"mushroom":{}, # 蘑菇群系
	"mountain":{}, # 山脉群系
}

func generate_terrain(noise:FastNoiseLite, coords:Vector2, size:float, initailly_visible:bool):
	var array_mesh = ArrayMesh.new()
	var surface_tool =SurfaceTool.new()
	# var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_frequency
	# noise.seed = randi()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in range(resolution + 1):
		for x in range(resolution + 1):
			var percent = Vector2(x, z) / resolution
			var point_on_mesh = Vector3((percent.x - center_offset), 0, (percent.y - center_offset))
			var vertex = point_on_mesh * terrain_size
			vertex.y = noise.get_noise_2d(vertex.x * noise_offset, vertex.z * noise_offset) * noise_level

			var uv = Vector2()
			uv.x = percent.x
			uv.y = percent.y

			surface_tool.set_uv(uv)
			surface_tool.add_vertex(vertex)

			#var tile_probability = randf()
			#if tile_probability <= biome_data["plains"]["plains_tree"]:
			#	var tree_instantiate = object_tiles["plains_tree"].instantiate()
			#	tree_instantiate.transform.origin = vertex
			#	tree_instantiate.rotation.y = randi_range(0, 360)
			#	add_child(tree_instantiate)
			
	var vert = 0
	for z in resolution:
		for x in resolution:
			surface_tool.add_index(vert+0)
			surface_tool.add_index(vert+1)
			surface_tool.add_index(vert+resolution+1)
			
			surface_tool.add_index(vert+resolution+1)
			surface_tool.add_index(vert+1)
			surface_tool.add_index(vert+resolution+2)
			
			vert += 1
		vert += 1
	
	surface_tool.generate_normals()
	array_mesh = surface_tool.commit()
	
	mesh = array_mesh
	
	if set_collision == true:
		create_collision_fn()
		
	set_chunk_visible(initailly_visible)

func update_chunk(view_pos:Vector2, max_view_dis):
	var viewer_distance = position_coord.direction_to(view_pos).length()
	var _is_visible = viewer_distance <= max_view_dis
	set_chunk_visible(_is_visible)
	
func update_lod(view_pos:Vector2):
	var viewer_distance = position_coord.direction_to(view_pos)
	var update_terrain = false
	var new_lod = 0
	if viewer_distance.length() > 1000:
		new_lod = chunk_lods[0]
	if viewer_distance.length() <= 1000:
		new_lod = chunk_lods[1]
	if viewer_distance.length() < 900:
		new_lod = chunk_lods[2]
	if viewer_distance.length() < 500:
		new_lod = chunk_lods[3]
		set_collision = true
		
	if resolution != new_lod:
		resolution = new_lod
		update_terrain = true
	
	return update_terrain
	
func set_chunk_visible(_is_visible):
	visible = _is_visible

func get_chunk_visible():
	return visible
	
func create_collision_fn():
	if get_child_count() > 0:
		for i in get_children():
			i.free()
	create_trimesh_collision()
