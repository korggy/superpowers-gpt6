"""Shared validation for source selections and the exact portable payload."""
import json
from pathlib import PurePosixPath
import posixpath
import re
from urllib.parse import unquote, urlsplit

try:
    import yaml
except ImportError as error:
    raise SystemExit('PyYAML is required. Run: python -m pip install -r requirements-dev.txt') from error

FILES_MANIFEST = 'packaging/codex-files.json'


class UniqueKeyLoader(yaml.SafeLoader):
    """Reject duplicate fields instead of silently accepting the last value."""


def construct_mapping(loader, node, deep=False):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if not isinstance(key, str) or key in result:
            raise ValueError('YAML mapping keys must be unique strings')
        result[key] = loader.construct_object(value_node, deep=deep)
    return result


UniqueKeyLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, construct_mapping)


def yaml_mapping(data, label):
    try:
        value = yaml.load(data, Loader=UniqueKeyLoader)
    except (yaml.YAMLError, ValueError) as error:
        raise ValueError(f'{label}: invalid YAML: {error}') from error
    if not isinstance(value, dict):
        raise ValueError(f'{label}: expected a YAML mapping')
    return value


def safe_path(name):
    if not isinstance(name, str) or not name or '\\' in name or ':' in name:
        raise ValueError(f'unsafe package path: {name!r}')
    path = PurePosixPath(name)
    if path.is_absolute() or '..' in path.parts or str(path) != name:
        raise ValueError(f'unsafe package path: {name}')
    return path


def selection(data):
    manifest = json.loads(data)
    if not isinstance(manifest, dict) or manifest.get('schema_version') != 1:
        raise ValueError('package file manifest requires schema_version 1')
    names = manifest.get('files')
    if not isinstance(names, list) or not names or any(not isinstance(n, str) for n in names):
        raise ValueError('package file manifest requires a nonempty files list')
    if len(names) != len(set(names)):
        raise ValueError('duplicate selected package file')
    for name in names:
        safe_path(name)
    if FILES_MANIFEST not in names:
        raise ValueError('package file manifest must include itself')
    references = manifest.get('resource_references', {})
    if not isinstance(references, dict):
        raise ValueError('resource_references must be a mapping')
    for source, targets in references.items():
        if source not in names or not isinstance(targets, list):
            raise ValueError(f'invalid resource source: {source}')
        for target in targets:
            safe_path(target)
            if target not in names:
                raise ValueError(f'{source}: resource is not selected: {target}')
    return names


def require(condition, message):
    if not condition:
        raise ValueError(message)


def local_reference(source, target, files):
    url = urlsplit(target.strip('<>'))
    if url.scheme or url.netloc or not url.path:
        return
    target = unquote(url.path)
    require(not target.startswith('/') and '\\' not in target, f'{source}: nonportable reference {target}')
    name = posixpath.normpath(posixpath.join(posixpath.dirname(source), target))
    safe_path(name)
    require(name in files, f'{source}: missing packaged reference {target}')


def validate_files(files):
    require(FILES_MANIFEST in files, f'missing package file manifest: {FILES_MANIFEST}')
    selected = selection(files[FILES_MANIFEST])
    require(set(selected) == set(files), 'package contents must match the explicit file manifest')
    for name in ('.codex-plugin/plugin.json', 'README.md', 'LICENSE', 'NOTICE.md'):
        require(name in files, f'missing package file: {name}')
    manifest = json.loads(files['.codex-plugin/plugin.json'])
    require(isinstance(manifest, dict), 'plugin manifest must be an object')
    require(isinstance(manifest.get('name'), str) and bool(manifest['name']), 'invalid plugin name')
    require(isinstance(manifest.get('version'), str) and bool(manifest['version']), 'invalid plugin version')
    require(manifest.get('skills') == './skills/', 'invalid skills path')
    interface = manifest.get('interface', {})
    require(isinstance(interface, dict), 'plugin interface must be an object')
    for key in ('logo', 'logoDark', 'composerIcon'):
        if interface.get(key):
            local_reference('plugin.json', interface[key], files)
    for asset in interface.get('screenshots', []):
        local_reference('plugin.json', asset, files)

    skills = [n for n in files if n.startswith('skills/') and len(PurePosixPath(n).parts) == 3 and n.endswith('/SKILL.md')]
    require(bool(skills), 'package has no skills')
    names = {PurePosixPath(n).parent.name for n in skills}
    for skill in skills:
        text = files[skill].decode('utf-8-sig')
        match = re.match(r'\A---\r?\n(.*?)\r?\n---(?:\r?\n|$)', text, re.S)
        require(match is not None, f'{skill}: missing frontmatter')
        frontmatter = yaml_mapping(match[1], skill)
        name = PurePosixPath(skill).parent.name
        require(frontmatter.get('name') == name and re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', name), f'{skill}: invalid skill name')
        require(isinstance(frontmatter.get('description'), str) and bool(frontmatter['description'].strip()), f'{skill}: missing description')
        metadata = str(PurePosixPath(skill).parent / 'agents/openai.yaml')
        require(metadata in files, f'missing skill metadata: {metadata}')
        config = yaml_mapping(files[metadata], metadata)
        require(set(config) <= {'interface', 'policy', 'dependencies'}, f'{metadata}: unsupported top-level fields')
        ui = config.get('interface')
        require(isinstance(ui, dict), f'{metadata}: interface must be a mapping')
        require(set(ui) <= {'display_name', 'short_description', 'default_prompt', 'icon_small', 'icon_large', 'brand_color'}, f'{metadata}: unsupported interface field')
        require(all(isinstance(v, str) for v in ui.values()), f'{metadata}: interface values must be strings')
        require(bool(ui.get('display_name', '').strip()), f'{metadata}: missing display_name')
        require(25 <= len(ui.get('short_description', '')) <= 64, f'{metadata}: short_description must be 25-64 characters')
        require('$' + name in ui.get('default_prompt', ''), f'{metadata}: default_prompt must name its skill')
        for key in ('icon_small', 'icon_large'):
            if ui.get(key):
                local_reference(skill, ui[key], files)
        if 'brand_color' in ui:
            require(re.fullmatch(r'#[0-9A-Fa-f]{6}', ui['brand_color']), f'{metadata}: invalid brand_color')
        if 'policy' in config:
            policy = config['policy']
            require(isinstance(policy, dict) and set(policy) <= {'allow_implicit_invocation'}, f'{metadata}: invalid policy')
            if 'allow_implicit_invocation' in policy:
                require(type(policy['allow_implicit_invocation']) is bool, f'{metadata}: allow_implicit_invocation must be boolean')
        if 'dependencies' in config:
            deps = config['dependencies']
            require(isinstance(deps, dict) and set(deps) == {'tools'} and isinstance(deps['tools'], list), f'{metadata}: invalid dependencies')
            for tool in deps['tools']:
                require(isinstance(tool, dict) and tool.get('type') == 'mcp' and isinstance(tool.get('value'), str), f'{metadata}: invalid tool dependency')

    markdown = [n for n in files if n.endswith('.md')]
    for name in markdown:
        text = files[name].decode('utf-8-sig')
        for reference in re.findall(r'superpowers-gpt6:([a-z0-9-]+)', text):
            require(reference in names, f'{name}: unknown skill {reference}')
        for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', text):
            local_reference(name, target, files)
    return manifest, len(skills), len(markdown)
