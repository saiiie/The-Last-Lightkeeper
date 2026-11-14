"""CPU-only scene footprint and route validation; no Godot invocation."""
from pathlib import Path
from collections import deque
import json,re
ROOT=Path(__file__).resolve().parents[1]
data=json.loads((ROOT/'resources/forest_test_layout.json').read_text())
scene=(ROOT/'scenes/levels/whispering_forest_test.tscn').read_text()
rects=[]
assets={a['path']:a for a in json.loads((ROOT/'assets/asset_manifest.json').read_text())['assets']}
for i,p in enumerate(data['placements']):
 name=p['name'];x,y=p['position']
 assert f'name="{name}_{i:03}"' in scene
 assert f'position = Vector2({x}, {y})' in scene
 prefab=(ROOT/f'scenes/props/forest/{name}.tscn').read_text()
 texture=re.search(r'path="(res://[^\"]+\.png)"',prefab)[1]
 asset=assets[texture];width,height=asset['width'],asset['height']
 assert 0<=x-width/2 and x+width/2<=1536 and y-height+8>=0 and y+8<=1024, f'Sprite outside map: {name}'
 match=re.search(r'size = Vector2\((\d+), (\d+)\)',prefab)
 if match:
  w,h=map(int,match.groups());assert [w,h]==data['footprints'][name]
  assert 'collision_layer = 1' in prefab and 'resource_local_to_scene = true' in prefab
  rects.append((x-w/2,y-h/2,x+w/2,y+h/2))
 else:assert data['footprints'][name]==[0,0]
# Conservative square 24x24 future actor, plus cell half-width for grid traversal.
margin=20;step=16
free=set()
for y in range(1,64):
 for x in range(1,96):
  px=x*step;py=y*step
  if px<margin or py<margin or px>1536-margin or py>1024-margin:continue
  if not any(a-margin<=px<=c+margin and b-margin<=py<=d+margin for a,b,c,d in rects):free.add((x,y))
start=tuple(n//step for n in data['centers']['SpawnClearing']);assert start in free
seen={start};queue=deque([start])
while queue:
 x,y=queue.popleft()
 for p in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
  if p in free and p not in seen:seen.add(p);queue.append(p)
for name,pos in data['centers'].items():assert tuple(n//step for n in pos) in seen,name
for a,b in zip(data['route'],data['route'][1:]):
 length=max(abs(a[0]-b[0]),abs(a[1]-b[1]))
 for i in range(length+1):
  x=a[0]+(b[0]-a[0])*i/length;y=a[1]+(b[1]-a[1])*i/length
  assert not any(l-12<=x<=r+12 and t-12<=y<=bt+12 for l,t,r,bt in rects),'Blocked loop segment'
assert data['route'][0]==data['route'][-1]
ids=list(map(int,re.search(r'source_ids = PackedInt32Array\(([^)]+)\)',scene)[1].split(',')))
assert len(ids)==48*32 and all(0<=i<64 for i in ids)
assert len(re.findall(r'type="CollisionShape2D" parent="Boundary"',scene))==4
print(f'PASS: {len(rects)} solid footprints; all five clearings reachable; entire closed loop clear for 24x24 footprint; {len(seen)} reachable grid samples; terrain and boundaries valid.')
