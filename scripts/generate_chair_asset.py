"""Build Original Office Chair v2 and render that exact exported USDZ.

Run through Tools/launch_blender_safe.sh from the RoomPlan workspace, never
launch the Blender executable directly from the Codex sandbox.
"""

import argparse
import hashlib
import json
import math
import os
import sys

import bpy
from mathutils import Vector


def parse_arguments():
    script_args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    return parser.parse_args(script_args)


def material(name, color, metallic=0.0, roughness=0.45):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    return result


def finish_mesh(obj, mat, smooth=True, bevel=0.0, bevel_segments=2):
    obj.data.materials.append(mat)
    if smooth:
        for polygon in obj.data.polygons:
            polygon.use_smooth = True
    if bevel > 0:
        modifier = obj.modifiers.new(name="Edge Softening", type="BEVEL")
        modifier.width = bevel
        modifier.segments = bevel_segments
        modifier.limit_method = "ANGLE"
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(False)
    return obj


def rounded_box(name, location, dimensions, mat, bevel=0.03, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish_mesh(obj, mat, smooth=True, bevel=bevel, bevel_segments=3)


def cylinder(name, location, radius, depth, mat, vertices=24, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radius,
        depth=depth,
        location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    return finish_mesh(obj, mat, smooth=True, bevel=min(radius * 0.18, 0.008), bevel_segments=2)


def sphere(name, location, scale, mat, segments=24, rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=segments,
        ring_count=rings,
        location=location,
    )
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish_mesh(obj, mat, smooth=True)


def beam(name, start, end, radius, mat, vertices=16):
    start_vector = Vector(start)
    end_vector = Vector(end)
    direction = end_vector - start_vector
    midpoint = (start_vector + end_vector) / 2
    obj = cylinder(
        name=name,
        location=midpoint,
        radius=radius,
        depth=direction.length,
        mat=mat,
        vertices=vertices,
    )
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direction.to_track_quat("Z", "Y")
    return obj


def torus(name, location, major_radius, minor_radius, mat, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(
        major_radius=major_radius,
        minor_radius=minor_radius,
        major_segments=20,
        minor_segments=8,
        location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    return finish_mesh(obj, mat, smooth=True)


def upholstered_pad(name, location, dimensions, mat, rotation=(0, 0, 0)):
    """A rounded cushion volume, not a beveled thin cube with square corners."""
    segments, rings = 48, 12
    vertices = [(0, 0, -dimensions[2] / 2)]
    faces = []
    signed_power = lambda value, exponent: math.copysign(abs(value) ** exponent, value)
    for ring in range(1, rings):
        latitude = -math.pi / 2 + math.pi * ring / rings
        radius = math.cos(latitude) ** 0.32
        for segment in range(segments):
            angle = 2 * math.pi * segment / segments
            vertices.append((
                dimensions[0] / 2 * radius * signed_power(math.cos(angle), 0.38),
                dimensions[1] / 2 * radius * signed_power(math.sin(angle), 0.38),
                dimensions[2] / 2 * signed_power(math.sin(latitude), 0.7),
            ))
    top = len(vertices)
    vertices.append((0, 0, dimensions[2] / 2))
    for segment in range(segments):
        following = (segment + 1) % segments
        faces.append((0, 1 + following, 1 + segment))
        for ring in range(rings - 2):
            a, b = 1 + ring * segments + segment, 1 + ring * segments + following
            faces.append((a, b, b + segments, a + segments))
        last = 1 + (rings - 2) * segments
        faces.append((last + segment, last + following, top))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.location, obj.rotation_euler = location, rotation
    return finish_mesh(obj, mat)


def curved_back_panel(name, mat, rear=False):
    rows = (
        (0.59, 0.160, 0.170),
        (0.63, 0.148, 0.206),
        (0.70, 0.133, 0.222),
        (0.78, 0.142, 0.225),
        (0.87, 0.180, 0.238),
        (0.97, 0.224, 0.245),
        (1.065, 0.265, 0.226),
        (1.115, 0.280, 0.190),
    )
    columns = 9
    vertices = []
    faces = []

    for z, center_y, half_width in rows:
        for column in range(columns):
            horizontal = -1.0 + 2.0 * column / (columns - 1)
            x = (half_width + (0.012 if rear else 0)) * horizontal
            # The side edges wrap slightly toward the seated user, producing a
            # generic ergonomic curve without copying the reference topology.
            y = center_y - 0.040 * abs(horizontal) ** 1.7 + (0.026 if rear else 0)
            vertices.append((x, y, z))

    for row in range(len(rows) - 1):
        for column in range(columns - 1):
            lower_left = row * columns + column
            lower_right = lower_left + 1
            upper_left = lower_left + columns
            upper_right = upper_left + 1
            faces.append((lower_left, lower_right, upper_right, upper_left))

    mesh = bpy.data.meshes.new(f"{name} Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)

    for polygon in obj.data.polygons:
        polygon.use_smooth = True

    subdivision = obj.modifiers.new(name="Gentle Back Curve", type="SUBSURF")
    subdivision.subdivision_type = "CATMULL_CLARK"
    subdivision.levels = 2
    subdivision.render_levels = 2
    solidify = obj.modifiers.new(name="Back Thickness", type="SOLIDIFY")
    solidify.thickness = 0.016 if rear else 0.036
    solidify.offset = 0.0
    bevel = obj.modifiers.new(name="Back Edge Softening", type="BEVEL")
    bevel.width = 0.012
    bevel.segments = 2

    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    for modifier in tuple(obj.modifiers):
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.select_set(False)
    return obj


def parent_objects(parent):
    for obj in list(bpy.context.scene.objects):
        if obj != parent and obj.parent is None and obj.type in {"MESH", "CURVE", "EMPTY"}:
            obj.parent = parent


def create_chair():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

    frame = material("Graphite Shell", (0.055, 0.073, 0.090), metallic=0.12, roughness=0.42)
    metal = material("Satin Aluminum", (0.62, 0.69, 0.76), metallic=0.72, roughness=0.3)
    fabric = material("Ocean Upholstery", (0.025, 0.22, 0.32), metallic=0.0, roughness=0.82)
    rubber = material("Soft Black Rubber", (0.022, 0.030, 0.040), metallic=0.0, roughness=0.65)
    accent = material("Coral Adjustment", (0.9, 0.18, 0.07), metallic=0.0, roughness=0.42)

    bpy.ops.object.empty_add(type="PLAIN_AXES", location=(0, 0, 0))
    root = bpy.context.object
    root.name = "OriginalOfficeChair"
    root["asset_front_blender"] = "-Y"
    root["asset_front_usd"] = "+Z"
    root["units"] = "meters"
    root["design"] = "Original Office Chair v2: contoured upholstery and integrated shell"

    # Five-star base and paired casters. The lowest wheel point is exactly Z=0.
    hub_height = 0.105
    cylinder("Base Hub", (0, 0, hub_height), 0.075, 0.10, metal, vertices=32)
    cylinder("Gas Lift Lower", (0, 0, 0.235), 0.036, 0.26, rubber, vertices=24)
    cylinder("Gas Lift Upper", (0, 0, 0.365), 0.025, 0.28, metal, vertices=24)

    base_radius = 0.305
    wheel_radius = 0.036
    for index in range(5):
        angle = math.radians(90 + index * 72)
        direction = Vector((math.cos(angle), math.sin(angle), 0))
        tangent = Vector((-direction.y, direction.x, 0))
        inner = direction * 0.055 + Vector((0, 0, 0.12))
        outer = direction * (base_radius - 0.045) + Vector((0, 0, 0.065))
        # Flat tapered spokes replace the old round tubes.
        spoke_direction = outer - inner
        spoke = upholstered_pad(f"Base Spoke {index + 1}", (inner + outer) / 2,
                                (spoke_direction.length + 0.04, 0.047, 0.032), metal)
        spoke.rotation_euler = (0, math.atan2(inner.z - outer.z, spoke_direction.xy.length), angle)

        caster_center = direction * base_radius + Vector((0, 0, wheel_radius))
        beam(
            f"Caster Fork {index + 1}",
            outer,
            caster_center + Vector((0, 0, 0.025)),
            0.012,
            frame,
            vertices=12,
        )
        wheel_rotation = (math.pi / 2, 0, angle)
        for side, offset in (("L", -0.018), ("R", 0.018)):
            location = caster_center + tangent * offset
            cylinder(
                f"Caster {index + 1}{side}",
                location,
                wheel_radius,
                0.024,
                rubber,
                vertices=20,
                rotation=wheel_rotation,
            )

    # Under-seat mechanism is intentionally simplified for a lightweight tutorial asset.
    rounded_box("Tilt Mechanism", (0, 0.035, 0.425), (0.26, 0.22, 0.09), frame, bevel=0.025)
    cylinder("Adjustment Dial", (0.155, 0.015, 0.425), 0.025, 0.055, accent, vertices=20, rotation=(0, math.pi / 2, 0))
    beam("Adjustment Lever", (0.11, -0.02, 0.43), (0.235, -0.08, 0.42), 0.012, frame, vertices=12)
    sphere("Adjustment Grip", (0.245, -0.085, 0.418), (0.035, 0.018, 0.018), rubber, segments=16, rings=8)

    # Seat layers: a supportive shell and a softer upholstered top.
    upholstered_pad("Seat Shell", (0, -0.01, 0.497), (0.50, 0.475, 0.052), frame)
    upholstered_pad("Seat Cushion", (0, -0.020, 0.537), (0.485, 0.465, 0.073), fabric)

    # Back support frame. Front is toward -Y; the upper back reclines toward +Y.
    back_angle = math.radians(-12)
    curved_back_panel("Back Shell", frame, rear=True)
    curved_back_panel("Back Cushion", fabric)
    upholstered_pad(
        "Upper Back Crest",
        (0, 0.245, 1.105),
        (0.335, 0.075, 0.100),
        fabric,
        rotation=(back_angle, 0, 0),
    )

    # One connected rear support avoids visually detached rods near the headrest.
    beam("Back Lower Spine", (0, 0.12, 0.44), (0, 0.225, 0.64), 0.026, frame, vertices=20)
    for side, x in (("L", -0.15), ("R", 0.15)):
        beam(f"Back Y Support {side}", (0, 0.225, 0.64), (x, 0.260, 0.85), 0.021, frame, vertices=16)

    # Arm supports and soft pads use a simple T profile, distinct from the reference product.
    for side, x in (("L", -0.285), ("R", 0.285)):
        beam(f"Arm Lower Support {side}", (x * 0.67, 0.08, 0.47), (x, 0.08, 0.54), 0.019, frame, vertices=18)
        cylinder(f"Arm Upright {side}", (x, 0.08, 0.635), 0.016, 0.21, metal, vertices=20)
        upholstered_pad(
            f"Arm Pad {side}",
            (x, 0.005, 0.750),
            (0.080, 0.235, 0.038),
            rubber,
        )

    parent_objects(root)
    return root


def add_render_setup():
    world = bpy.context.scene.world
    world.color = (0.03, 0.03, 0.03)
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.035, 0.04, 0.045, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.65

    bpy.ops.mesh.primitive_plane_add(size=6, location=(0, 0, -0.002))
    floor = bpy.context.object
    floor.name = "Render Floor"
    floor.data.materials.append(material("Render Floor Material", (0.09, 0.10, 0.11), roughness=0.82))
    floor.hide_render = False

    for name, location, energy, size in (
        ("Key", (-2.1, -2.3, 2.7), 420, 2.2),
        ("Fill", (2.2, -0.8, 1.8), 260, 1.8),
        ("Rim", (0.4, 2.0, 2.5), 340, 1.5),
    ):
        bpy.ops.object.light_add(type="AREA", location=location)
        light = bpy.context.object
        light.name = name
        light.data.energy = energy
        light.data.shape = "DISK"
        light.data.size = size
        direction = Vector((0, 0, 0.58)) - light.location
        light.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()

    bpy.ops.object.camera_add()
    camera = bpy.context.object
    camera.name = "Preview Camera"
    camera.data.lens = 54
    bpy.context.scene.camera = camera

    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = 1200
    scene.render.resolution_y = 1200
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.view_settings.look = "AgX - Medium High Contrast"
    return camera, floor


def point_camera(camera, location, target=(0, 0.02, 0.60)):
    camera.location = location
    direction = Vector(target) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def render_previews(output_dir, camera, floor):
    views = {
        "preview-front.png": (1.45, -1.75, 1.25),
        "preview-rear.png": (-1.45, 1.75, 1.35),
        "preview-side.png": (1.95, 0.15, 1.12),
        "preview-three-quarter.png": (-1.55, -1.65, 1.32),
    }
    for filename, location in views.items():
        point_camera(camera, location)
        bpy.context.scene.render.filepath = os.path.join(output_dir, filename)
        bpy.ops.render.render(write_still=True)

    camera.hide_render = True
    floor.hide_render = True
    for obj in bpy.context.scene.objects:
        if obj.type == "LIGHT":
            obj.hide_render = True


def mesh_statistics():
    depsgraph = bpy.context.evaluated_depsgraph_get()
    vertices = 0
    triangles = 0
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH" or obj.name == "Render Floor":
            continue
        evaluated = obj.evaluated_get(depsgraph)
        mesh = evaluated.to_mesh()
        mesh.calc_loop_triangles()
        vertices += len(mesh.vertices)
        triangles += len(mesh.loop_triangles)
        evaluated.to_mesh_clear()
    return vertices, triangles


def chair_bounds():
    minimum = Vector((math.inf, math.inf, math.inf))
    maximum = Vector((-math.inf, -math.inf, -math.inf))
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH" or obj.name == "Render Floor":
            continue
        evaluated = obj.evaluated_get(depsgraph)
        for corner in evaluated.bound_box:
            world_corner = evaluated.matrix_world @ Vector(corner)
            minimum.x = min(minimum.x, world_corner.x)
            minimum.y = min(minimum.y, world_corner.y)
            minimum.z = min(minimum.z, world_corner.z)
            maximum.x = max(maximum.x, world_corner.x)
            maximum.y = max(maximum.y, world_corner.y)
            maximum.z = max(maximum.z, world_corner.z)
    return minimum, maximum


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main():
    args = parse_arguments()
    output_dir = os.path.abspath(args.output_dir)
    os.makedirs(output_dir, exist_ok=True)

    bpy.context.scene.unit_settings.system = "METRIC"
    bpy.context.scene.unit_settings.scale_length = 1.0

    create_chair()
    vertices, triangles = mesh_statistics()
    bounds_min, bounds_max = chair_bounds()
    blender_size = bounds_max - bounds_min
    print(f"CHAIR_STATS vertices={vertices} triangles={triangles}")
    print(f"CHAIR_BOUNDS blender_min={tuple(bounds_min)} blender_max={tuple(bounds_max)}")

    # Export only the chair hierarchy. Blender converts its -Y front to USD +Z,
    # matching the identity orientation used by FurnitureModelProvider.
    for obj in bpy.context.scene.objects:
        obj.select_set(False)
    root = bpy.data.objects["OriginalOfficeChair"]
    root.select_set(True)
    for child in root.children_recursive:
        child.select_set(True)

    usd_path = os.path.join(output_dir, "Chair.usdz")
    bpy.ops.wm.usd_export(
        filepath=usd_path,
        selected_objects_only=True,
        export_animation=False,
        export_hair=False,
        export_uvmaps=True,
        export_normals=True,
        export_materials=True,
        export_armatures=False,
        export_shapekeys=False,
        use_instancing=False,
        evaluation_mode="RENDER",
        generate_preview_surface=True,
        convert_orientation=True,
        export_global_forward_selection="Z",
        export_global_up_selection="Y",
        export_textures_mode="NEW",
        overwrite_textures=True,
        relative_paths=True,
        root_prim_path="/Chair",
        export_custom_properties=True,
        export_meshes=True,
        export_lights=False,
        export_cameras=False,
        triangulate_meshes=True,
        usdz_downscale_size="KEEP",
        merge_parent_xform=False,
        convert_scene_units="METERS",
        meters_per_unit=1.0,
    )

    blend_path = os.path.join(output_dir, "OriginalOfficeChair-v2.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)

    # Render the re-imported deliverable, not a richer Blender-only material.
    # This prevents the website showcase drifting from the shipped USDZ.
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.wm.usd_import(filepath=usd_path)
    camera, floor = add_render_setup()
    render_previews(output_dir, camera, floor)

    report = {
        "asset": "OriginalOfficeChair-v2",
        "design": "Contoured cushions, integrated rear shell, satin-metal base and slim arms",
        "render_source": "Reimported Chair.usdz; studio lighting only",
        "source_images_used_for": "General office-chair proportions only",
        "units": "meters",
        "blender": {
            "up_axis": "+Z",
            "front_axis": "-Y",
            "bounds_min": list(bounds_min),
            "bounds_max": list(bounds_max),
            "size_xyz": list(blender_size),
        },
        "usd": {
            "up_axis": "+Y",
            "front_axis": "+Z",
            "expected_size_xyz": [blender_size.x, blender_size.z, blender_size.y],
            "meters_per_unit": 1,
            "default_prim": "Chair",
        },
        "geometry": {"vertices": vertices, "triangles": triangles},
        "files": {
            "blend": {"name": os.path.basename(blend_path), "sha256": sha256(blend_path)},
            "usdz": {"name": os.path.basename(usd_path), "sha256": sha256(usd_path)},
        },
    }
    report_path = os.path.join(output_dir, "asset-report.json")
    with open(report_path, "w", encoding="utf-8") as file:
        json.dump(report, file, indent=2)
    print(f"CHAIR_OUTPUT blend={blend_path}")
    print(f"CHAIR_OUTPUT usdz={usd_path}")
    print(f"CHAIR_OUTPUT report={report_path}")


if __name__ == "__main__":
    main()
