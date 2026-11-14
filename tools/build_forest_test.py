"""Deterministically author Task 5 text scenes; never invokes Godot or edits PNGs."""
from pathlib import Path
import json, math, random
ROOT=Path(__file__).resolve().parents[1]
def write(name,text):
 p=ROOT/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text,encoding='utf-8')
def v(a): return 'Vector2('+', '.join(map(str,a))+')'
rng=random.Random(510)
# Hand-authored ground footprints (width, depth), independent of image canvas.
specs={
'tree_ancient':('trees',96,128,28,18), 'tree_young':('trees',64,96,18,14),
'tree_dead':('trees',96,128,22,16),'tree_charred':('trees',96,128,24,16),
'forest_rock_cluster':('props',64,64,40,24),'prop_boulder_small':('props',32,32,22,16),
'prop_fallen_log':('props',64,32,52,14),'prop_workbench_small':('props',64,32,46,20),
'prop_crate':('props',32,32,24,20),'prop_crate_broken':('props',32,32,22,16),
'prop_barrel':('props',32,32,20,18),'prop_barrel_damaged':('props',32,32,20,16),
'forest_brambles':('vegetation',64,64,42,24),'forest_broken_trunk':('vegetation',64,64,30,18),
'forest_roots':('vegetation',64,64,36,12),'forest_stump':('vegetation',64,64,28,18),
'forest_ferns':('vegetation',64,64,0,0),'forest_bush':('vegetation',64,64,0,0),
'forest_withered_shrub':('vegetation',64,64,0,0),'prop_wood_debris_charred':('props',32,32,0,0)}
for name,(folder,w,h,cw,ch) in specs.items():
 solid=cw>0
 s=f'[gd_scene load_steps={3 if solid else 2} format=3]\n\n[ext_resource type="Texture2D" path="res://assets/environments/forest/{folder}/{name}.png" id="texture"]\n'
 if solid:s+=f'\n[sub_resource type="RectangleShape2D" id="footprint"]\nresource_local_to_scene = true\nsize = {v((cw,ch))}\n'
 s+=f'\n[node name="{name}" type="{"StaticBody2D" if solid else "Node2D"}"]\n'
 if solid:s+='collision_layer = 1\ncollision_mask = 0\n'
 s+=f'\n[node name="Sprite" type="Sprite2D" parent="."]\ntexture = ExtResource("texture")\noffset = {v((0,-h/2+8))}\n'
 if solid:s+='\n[node name="Collision" type="CollisionShape2D" parent="."]\nshape = SubResource("footprint")\n'
 write(f'scenes/props/forest/{name}.tscn',s)
centers={'SpawnClearing':(288,256),'DarkTrail':(768,224),'AbandonedCamp':(1248,384),'DamagedForest':(1184,800),'ObstacleZone':(448,800)}
route=[(288,256),(512,256),(640,192),(768,224),(960,224),(1088,352),(1248,384),(1280,576),(1184,800),(960,832),(704,768),(448,800),(256,672),(224,480),(288,256)]
def segdist(p,a,b):
 dx=b[0]-a[0];dy=b[1]-a[1];t=max(0,min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dy)/(dx*dx+dy*dy)))
 return math.hypot(p[0]-a[0]-t*dx,p[1]-a[1]-t*dy)
def distance(p):return min(segdist(p,a,b) for a,b in zip(route,route[1:]))
def clearing(p):return min(math.hypot(p[0]-c[0],p[1]-c[1]) for c in centers.values())
placements=[]
def add(name,x,y,group='Obstacles'):
 placements.append(dict(name=name,position=[x,y],group=group))
for y in range(112,1010,64):
 for x in range(64,1500,64):
  px=x+rng.randint(-12,12);py=y+rng.randint(-10,10)
  if distance((px,py))<100 or clearing((px,py))<152:continue
  damaged=px>980 and py>640
  add(rng.choice(['tree_charred','tree_dead'] if damaged else ['tree_ancient','tree_ancient','tree_young']),px,py)
  if rng.random()<.28:add('forest_withered_shrub' if damaged else 'forest_ferns',px+20,py+22,'Decorations')
# Camp arranged around an open center; supplies do not cross either exit.
for name,x,y in [('prop_workbench_small',1216,288),('prop_crate',1280,292),('prop_crate',1312,320),('prop_barrel',1344,352),('prop_barrel_damaged',1344,416),('prop_crate_broken',1184,456),('prop_wood_debris_charred',1216,468)]:add(name,x,y,'EnvironmentalProps')
for name,x,y in [('forest_broken_trunk',1096,736),('forest_stump',1280,832),('forest_roots',1088,864),('forest_withered_shrub',1216,704),('prop_wood_debris_charred',1248,736),('forest_brambles',1328,736)]:add(name,x,y,'Decorations' if specs[name][3]==0 else 'Obstacles')
# Two parallel obstacle rows leave a 100+ px passage and bypasses at both ends.
for x in [352,448,544,640]:
 add('forest_rock_cluster',x,656)
 add('prop_fallen_log' if x in [448,640] else 'forest_roots',x,896)
add('prop_boulder_small',576,832)
add('forest_brambles',352,864)
for _ in range(130):
 x=rng.randrange(80,1460);y=rng.randrange(120,960)
 if distance((x,y))>66 and clearing((x,y))>96:add(rng.choice(['forest_ferns','forest_bush','forest_withered_shrub']),x,y,'Decorations')
ids=[]
for y in range(32):
 for x in range(48):
  p=(x*32+16,y*32+16);dist=distance(p);c=clearing(p)
  # Low-frequency moss patches, limited dirt variation; no unverified transition tiles.
  source=0 if (x//4+y//3)%4 else 8
  if dist<56 or c<104:source=17 if (x+y)%7 else 18
  if p[0]>1040 and p[1]>672 and dist>62 and c>92 and (x*7+y*13)%23==0:source=58
  ids.append(source)
write('scripts/forest_terrain.gd','''extends TileMapLayer
## Deterministic visual cells only; no adjacency rules or gameplay.
@export var map_size: Vector2i = Vector2i(48, 32)
@export var source_ids: PackedInt32Array = PackedInt32Array()

func _ready() -> void:
	assert(source_ids.size() == map_size.x * map_size.y)
	for y in range(map_size.y):
		for x in range(map_size.x):
			set_cell(Vector2i(x, y), source_ids[y * map_size.x + x], Vector2i.ZERO, 0)
''')
used=sorted({p['name'] for p in placements});s=f'[gd_scene load_steps={len(used)+5} format=3]\n\n'
s+='[ext_resource type="TileSet" path="res://assets/environments/forest/terrain/forest_visual_tileset.tres" id="tiles"]\n[ext_resource type="Script" path="res://scripts/forest_terrain.gd" id="terrain_script"]\n'
for n in used:s+=f'[ext_resource type="PackedScene" path="res://scenes/props/forest/{n}.tscn" id="{n}"]\n'
s+='\n[sub_resource type="RectangleShape2D" id="horizontal"]\nsize = Vector2(1536, 32)\n\n[sub_resource type="RectangleShape2D" id="vertical"]\nsize = Vector2(32, 1024)\n'
s+='\n[node name="WhisperingForestTest" type="Node2D"]\n\n[node name="Terrain" type="TileMapLayer" parent="."]\nmodulate = Color(0.66, 0.76, 0.74, 1)\ntile_set = ExtResource("tiles")\nscript = ExtResource("terrain_script")\nsource_ids = PackedInt32Array('+', '.join(map(str,ids))+')\n'
s+='\n[node name="WorldObjects" type="Node2D" parent="."]\ny_sort_enabled = true\nmodulate = Color(0.72, 0.80, 0.78, 1)\n'
for group in ['Decorations','Obstacles','EnvironmentalProps']:
 s+=f'\n[node name="{group}" type="Node2D" parent="WorldObjects"]\ny_sort_enabled = true\n'
for i,p in enumerate(placements):s+=f'\n[node name="{p["name"]}_{i:03}" parent="WorldObjects/{p["group"]}" instance=ExtResource("{p["name"]}")]\nposition = {v(p["position"])}\n'
s+='\n[node name="Boundary" type="StaticBody2D" parent="."]\ncollision_layer = 1\ncollision_mask = 0\n'
for name,pos,shape in [('North',(768,-16),'horizontal'),('South',(768,1040),'horizontal'),('West',(-16,512),'vertical'),('East',(1552,512),'vertical')]:s+=f'\n[node name="{name}" type="CollisionShape2D" parent="Boundary"]\nposition = {v(pos)}\nshape = SubResource("{shape}")\n'
s+='\n[node name="SpawnMarker" type="Marker2D" parent="."]\nposition = Vector2(288, 256)\n\n[node name="VisibleMarker" type="Polygon2D" parent="SpawnMarker"]\nz_index = 10\ncolor = Color(0.65, 0.78, 0.75, 1)\npolygon = PackedVector2Array(0, -10, 7, 0, 0, 10, -7, 0)\n\n[node name="LightingHooks" type="Node2D" parent="."]\n\n[node name="Camp" type="Marker2D" parent="LightingHooks"]\nposition = Vector2(1248, 384)\n\n[node name="Corruption" type="Marker2D" parent="LightingHooks"]\nposition = Vector2(1184, 800)\n'
write('scenes/levels/whispering_forest_test.tscn',s)
write('scenes/main.tscn','''[gd_scene load_steps=2 format=3]

[ext_resource type="PackedScene" path="res://scenes/levels/whispering_forest_test.tscn" id="forest"]

[node name="Main" type="Node2D"]

[node name="Forest" parent="." instance=ExtResource("forest")]

[node name="Overview" type="Camera2D" parent="."]
position = Vector2(768, 512)
zoom = Vector2(0.34, 0.34)
position_smoothing_enabled = false
''')
write('resources/forest_test_layout.json',json.dumps(dict(size=[1536,1024],centers=centers,route=route,placements=placements,footprints={n:list(s[3:]) for n,s in specs.items()},terrain_sources=sorted(set(ids))),indent=2)+'\n')
print(f'Authored {len(placements)} objects, {len(used)} reusable prefabs and 1536 terrain cells.')

