"""Dependency-free smoke check for the changed Hermes startup notice."""
import importlib.util
from pathlib import Path
from unittest.mock import MagicMock


root = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("superpowers_hermes", root / ".hermes-plugin/__init__.py")
plugin = importlib.util.module_from_spec(spec)
spec.loader.exec_module(plugin)
ctx = MagicMock()
hooks = {}
skills = {}
ctx.register_hook.side_effect = lambda name, fn: hooks.__setitem__(name, fn)
ctx.register_skill.side_effect = lambda name, path: skills.__setitem__(name, path)
plugin.register(ctx)
expected_skills = {path.parent.name for path in (root / "skills").glob("*/SKILL.md")}
assert set(skills) == expected_skills
assert "finishing-a-development-branch" not in skills
assert all(isinstance(path, Path) and path.is_file() for path in skills.values())
hook = hooks["pre_llm_call"]
args = dict(session_id="fixture", user_message="hello", conversation_history=[], model="fixture", platform="cli")
notice = hook(is_first_turn=True, **args)["context"]
policy = (root / "skills/using-superpowers/references/invocation-policy.md").read_text(encoding="utf-8").strip()
assert policy in notice
assert "Follow it now" not in notice
assert "does not invoke a skill" in notice
assert len(notice) < 10000
assert hook(is_first_turn=False, **args) is None
print(f"Hermes: {len(skills)} skills registered; startup notice, size limit, and later-turn behavior passed")
