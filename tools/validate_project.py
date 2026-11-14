"""Standard-library, read-only static checks. Never invokes Godot or network tools."""
import ast
import configparser
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def config(path, preamble=False):
    text = (ROOT / path).read_text(encoding="utf-8-sig")
    parser = configparser.ConfigParser(interpolation=None, strict=True)
    parser.optionxform = str
    parser.read_string(("[header]\n" if preamble else "") + text)
    return parser


def main():
    project = config("project.godot", preamble=True)
    assert project['header']['config_version'] == '5'
    assert project['application']['config/name'] == '"The Last Lightkeeper"'
    main_scene = project['application']['run/main_scene'].strip('"')
    assert main_scene == 'res://scenes/main.tscn'
    expected = {
        'window/size/viewport_width': '640', 'window/size/viewport_height': '360',
        'window/size/mode': '0', 'window/vsync/vsync_mode': '1',
        'window/stretch/mode': '"canvas_items"', 'window/stretch/aspect': '"keep"',
    }
    for key, value in expected.items():
        assert project['display'][key] == value, key
    assert project['rendering']['renderer/rendering_method'] == '"gl_compatibility"'
    assert project['rendering']['textures/canvas_textures/default_texture_filter'] == '0'
    for p in [ROOT / 'project.godot', *ROOT.glob('assets/**/*.tres'), *ROOT.glob('scenes/**/*.tscn')]:
        text = p.read_text(encoding='utf-8')
        for uri in re.findall(r'"(res://[^"\n]+)"', text):
            relative = uri[6:]
            assert '\\' not in relative and '..' not in relative.split('/'), uri
            path = ROOT / relative
            assert path.is_file(), uri
            assert path.relative_to(ROOT).as_posix() == relative, uri
    rows = json.loads((ROOT / 'assets/asset_manifest.json').read_text())['assets']
    assert len(rows) == 100
    for row in rows:
        assert hashlib.sha256((ROOT / row['path'][6:]).read_bytes()).hexdigest() == row['sha256'], row['path']
    export = config('export_presets.cfg')
    assert export['preset.0']['platform'] == '"Web"'
    assert export['preset.0']['name'] == '"Web"'
    assert export['preset.0.options']['variant/thread_support'] == 'false'
    assert export['preset.0.options']['variant/extensions_support'] == 'false'
    # JSON is a YAML subset accepted for GitHub workflows; no local packages needed.
    workflow = json.loads((ROOT / '.github/workflows/web.yml').read_text())
    assert workflow['env']['GODOT_VERSION'] == '4.5.2'
    assert workflow['on']['push']['branches'] == ['main']
    assert workflow['on']['workflow_dispatch']['inputs']['deploy_pages']['default'] is False
    deploy = workflow['jobs']['deploy']
    assert deploy['needs'] == 'build'
    for gate in ['workflow_dispatch', 'inputs.deploy_pages', "vars.ENABLE_PAGES == 'true'", 'refs/heads/main']:
        assert gate in deploy['if'], gate
    for job in workflow['jobs'].values():
        assert job['runs-on'] == 'ubuntu-24.04'
    for name in ['scenes/levels', 'scenes/characters', 'scenes/props', 'scripts', 'resources', 'tests']:
        assert (ROOT / name).is_dir(), name
    for p in (ROOT / 'tools').glob('*.py'):
        ast.parse(p.read_text(encoding='utf-8-sig'), filename=str(p))
    print('PASS: project settings, main/resource paths, 100 original PNG hashes, Web preset, workflow structure and deployment gates.')
    print('PASS: Python source syntax and required directories. No Godot execution or export validation performed locally.')


if __name__ == '__main__':
    main()
