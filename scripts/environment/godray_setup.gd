extends MultiMeshInstance3D

## Drives the godray_v2 shader. Start with num_slices = 1 on the shader and
## instance_count = 1 here to validate step 1 (one plane, full-screen quad)
## before scaling up to step 2 (many slices).

@export var target: Node3D          # player or camera - whatever the rays should center on
@export var num_slices: int = 1     # keep in sync with the shader's num_slices uniform
@export var quad_mesh: QuadMesh     # a plain 1x1 QuadMesh, no subdivisions
@export var directional_light : DirectionalLight3D

## How far (in world units) the vertex shader might push a vertex away from
## godray_anchor. Needs to comfortably cover: half the total slice spread
## (num_slices * slice_spacing / 2) plus roughly depth_fade_far, since a slice
## nearly edge-on to the camera can place vertices far along the view ray.
## Generous and cheap to over-estimate - this only affects culling, not what
## actually gets drawn.
@export var cull_margin: float = 600.0


func _ready() -> void:
	var mm := MultiMesh.new()
	mm.use_custom_data = true
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = num_slices
	mm.mesh = quad_mesh
	multimesh = mm

	# Instance transforms don't matter for the geometry anymore - the vertex
	# shader derives world position entirely from INSTANCE_ID, the camera,
	# and godray_anchor. We still need *an* instance to exist per slice, so
	# leave them at identity.
	for i in num_slices:
		multimesh.set_instance_transform(i, Transform3D.IDENTITY)

	multimesh.mesh.surface_get_material(0).set_shader_parameter("num_slices", num_slices)

	# Godot culls draw calls using the mesh's ORIGINAL bounding box, computed
	# before the vertex shader runs - it has no idea the shader is about to
	# push vertices out to the screen edges. A tiny 1x1 quad's default AABB
	# will get culled the moment the camera looks away from world origin.
	# custom_aabb overrides that with a box big enough to always contain
	# wherever the shader will actually place vertices. It's defined in this
	# node's LOCAL space, so as we move the node itself in _process below,
	# this box moves with it.
	var extent := Vector3.ONE * cull_margin
	custom_aabb = AABB(-extent, extent * 2.0)

func _process(_delta: float) -> void:
	var mat := multimesh.mesh.surface_get_material(0) as ShaderMaterial

	if target:
		# Move the node itself to follow the target too, not just the
		# shader's anchor uniform - this keeps custom_aabb (which is
		# relative to the node) centered on wherever the player actually is,
		# instead of needing an enormous fixed-size box to cover the whole
		# level.
		global_position = target.global_position
		mat.set_shader_parameter("godray_anchor", target.global_position)

		mat.set_shader_parameter("light_direction",
			-directional_light.global_transform.basis.z)

	# Keep this in sync with however you already update light_direction from
	# your DirectionalLight3D - unchanged from your current setup.
