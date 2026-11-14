"""Read-only CPU validation. Requires Pillow; never invokes Godot."""
from pathlib import Path
from collections import Counter
import hashlib, json, re
from PIL import Image
ROOT = Path(__file__).resolve().parents[1]

def validate():
    rows = json.loads((ROOT / 'assets/asset_manifest.json').read_text(encoding='utf-8'))['assets']
    paths = set()
    for row in rows:
        uri = row['path']
        assert uri.startswith('res://assets/') and '\\' not in uri and '..' not in uri.split('/'), uri
        p = ROOT / uri[6:]
        assert p.is_file(), uri
        assert re.fullmatch(r'[a-z0-9_]+\.png', p.name), p
        assert hashlib.sha256(p.read_bytes()).hexdigest() == row['sha256'], p
        with Image.open(p) as im:
            im.verify()
        with Image.open(p) as im:
            im.load()
            assert list(im.size) == [row['width'], row['height']], p
            assert im.mode == row['mode'], p
            alpha = list(im.getchannel('A').getextrema()) if 'A' in im.getbands() else None
            assert alpha == row['alpha_extrema'], p
        paths.add(p.resolve())
    assert paths == {p.resolve() for p in ROOT.rglob('*.png')}, 'PNG inventory mismatch'
    assert not [n for n, count in Counter(p.name.lower() for p in paths).items() if count > 1], 'Duplicate PNG filenames'
    terrain = json.loads((ROOT / 'assets/environments/forest/terrain/terrain_manifest.json').read_text())['tiles']
    assert len(terrain) == 64
    assert {t['source_id'] for t in terrain} == set(range(64))
    for t in terrain:
        assert (t['width'], t['height']) == (32, 32)
        assert any(r['path'] == t['path'] and r['category'] == t['category'] for r in rows)
    resources = list(ROOT.rglob('*.tres')) + list(ROOT.rglob('*.tscn'))
    for p in resources:
        text = p.read_text(encoding='utf-8')
        assert 'format=3' in text.splitlines()[0], p
        for uri in re.findall(r'path="(res://[^"]+)"', text):
            assert (ROOT / uri[6:]).is_file(), (p, uri)
        for kind, decl in [('ExtResource', 'ext_resource'), ('SubResource', 'sub_resource')]:
            ids = re.findall(r'\[' + decl + r' [^\n]*id="([^"]+)"\]', text)
            assert len(ids) == len(set(ids)), p
            assert set(re.findall(kind + r'\("([^"]+)"\)', text)) <= set(ids), p
        ext_count = len(re.findall(r'^\[ext_resource ', text, re.M))
        sub_count = len(re.findall(r'^\[sub_resource ', text, re.M))
        assert int(re.search(r'load_steps=(\d+)', text)[1]) == ext_count + sub_count + 1, p
        # Check balanced delimiters outside string literals, not a Godot parser.
        stripped = re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
        stack = []
        for c in stripped:
            if c in '[{(': stack.append(c)
            if c in ']})': assert stack.pop() == {']':'[','}':'{',')':'('}[c], p
        assert not stack, p
    tile_text = (ROOT / 'assets/environments/forest/terrain/forest_visual_tileset.tres').read_text()
    for t in terrain:
        i = t['source_id']
        assert f'path="{t["path"]}" id="tex_{i}"' in tile_text
        assert f'sources/{i} = SubResource("atlas_{i}")' in tile_text
    assert tile_text.count('0:0/0 = 0') == 64
    aren = ROOT / 'assets/characters/player/aren'
    animations = json.loads((aren / 'animation_manifest.json').read_text())
    with Image.open(aren / 'idle/aren_idle_spritesheet.png') as sheet:
        for col, d in enumerate(animations['spritesheet']['columns']):
            with Image.open(aren / f'idle/aren_idle_{d}.png') as frame:
                assert frame.size == (64, 64)
                assert sheet.crop((col*64, 0, (col+1)*64, 64)).tobytes() == frame.tobytes(), d
    print(f'PASS: {len(rows)} PNGs decoded; hashes, dimensions, transparency, inventory and filenames verified.')
    print(f'PASS: {len(resources)} text resources checked for paths, IDs, load steps and delimiter balance; 64 terrain sources; Aren sheet matches direction order.')
    print('Static checks only. Godot import, parsing and rendering have NOT been tested.')

if __name__ == '__main__':
    validate()
