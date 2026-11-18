"""Probe an installed BetterGood plugin through the native Codex app-server protocol."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess


def run(args):
    profile = args.profile.resolve(strict=True)
    if profile == (Path.home() / ".codex").resolve():
        raise ValueError("Use a disposable test profile.")
    workspace = args.workspace.resolve()
    workspace.mkdir(parents=True, exist_ok=False)
    subprocess.run(["git", "init", "--quiet", str(workspace)], check=True)
    env = {**os.environ, "CODEX_HOME": str(profile)}
    records = []
    with subprocess.Popen(
        [str(args.cli), "--disable", "remote_plugin", "--disable", "apps", "app-server"],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True, encoding="utf-8",
        env=env, cwd=workspace,
    ) as proc:
        serial = 0

        def send(msg):
            proc.stdin.write(json.dumps(msg) + "\n")
            proc.stdin.flush()

        def receive():
            line = proc.stdout.readline()
            if not line:
                raise RuntimeError("app-server closed its output")
            msg = json.loads(line)
            if "method" in msg and "id" in msg:
                raise RuntimeError("Unexpected client request: " + msg["method"])
            method = msg.get("method")
            if method in ("item/completed", "turn/completed", "error", "model/rerouted"):
                records.append(msg)
            return msg

        def rpc(method, params):
            nonlocal serial
            serial += 1
            send({"id": serial, "method": method, "params": params})
            while True:
                msg = receive()
                if msg.get("id") == serial:
                    if "error" in msg:
                        raise RuntimeError(str(msg["error"]))
                    return msg["result"]

        try:
            rpc("initialize", {"clientInfo": {"name": "bettergood-eval", "version": "1"},
                               "capabilities": {"experimentalApi": True}})
            send({"method": "initialized"})
            inventory = rpc("skills/list", {"cwds": [str(workspace)], "forceReload": True})
            skills = inventory["data"][0]["skills"]
            picks = [s for s in skills if s["name"].split(":")[-1] == "brainstorming"
                     and s.get("enabled", True)]
            if len(picks) != 1:
                raise ValueError("Expected one enabled brainstorming skill. Found " +
                                 str([(s["name"], s["path"]) for s in picks]))
            skill = picks[0]
            cache_file = Path(skill["path"]).resolve(strict=True)
            cache_file.relative_to(profile / "plugins" / "cache" / "bettergood" / "superpowers-gpt6")
            expected = args.payload / "skills" / "brainstorming" / "SKILL.md"
            if cache_file.read_bytes() != expected.read_bytes():
                raise ValueError("Installed brainstorming differs from the package")
            plugin_root = cache_file.parents[2]
            plan_skill = Path("skills/writing-plans/SKILL.md")
            if (plugin_root / plan_skill).read_bytes() != (args.payload / plan_skill).read_bytes():
                raise ValueError("Installed writing-plans differs from the package")
            records.append({"skill": skill["name"], "path": str(cache_file),
                            "sha256": hashlib.sha256(cache_file.read_bytes()).hexdigest()})
            start = rpc("thread/start", {"cwd": str(workspace), "model": "gpt-6.2-astra",
                        "approvalPolicy": "never", "sandbox": "workspace-write",
                        "config": {"model_reasoning_effort": "medium"}})
            thread = start["thread"]["id"]
            records.append({"model": start.get("model"), "thread": thread})
            if start.get("model") != "gpt-6.2-astra":
                raise ValueError("Unexpected resolved model")

            def turn(prompt, mention=False):
                records.append({"prompt": prompt, "skillMention": mention})
                inputs = [{"type": "text", "text": prompt}]
                if mention:
                    inputs.append({"type": "skill", "name": skill["name"], "path": skill["path"]})
                rpc("turn/start", {"threadId": thread, "input": inputs, "effort": "medium"})
                while True:
                    msg = receive()
                    if msg.get("method") == "turn/completed":
                        if msg["params"]["turn"]["status"] != "completed":
                            raise RuntimeError(str(msg["params"]["turn"].get("error")))
                        return

            if args.case == "plain":
                turn("Let's make a react todo list")
            elif args.case == "namespace":
                turn("$" + skill["name"] + " Design a React todo list. Wait for my design approval.", True)
            else:
                turn("Use brainstorming to design a React todo list. Do not implement until I approve the design.")
                turn("My goal is to remember my own tasks across browser reloads. I want a single local "
                     "list with add, complete and delete, using localStorage, no accounts and no sync. "
                     "Please present the short design for approval. Wait for my approval before building.")
                last_answer = next(
                    event["params"]["item"]["text"] for event in reversed(records)
                    if event.get("params", {}).get("item", {}).get("type") == "agentMessage"
                )
                if not all(word in last_answer.lower() for word in ("add", "localstorage", "complet")):
                    raise ValueError("No design covering the agreed scope was presented for approval")
                records.append({"filesBeforeApproval": sorted(str(p.relative_to(workspace))
                                for p in workspace.rglob("*") if p.is_file()
                                and ".git" not in p.relative_to(workspace).parts)})
                turn("I approve that design. Write the implementation plan only. Do not implement it.")
            records.append({"filesAfterFinalTurn": sorted(
                str(p.relative_to(workspace)) for p in workspace.rglob("*")
                if p.is_file() and not {".git", "node_modules"}.intersection(p.relative_to(workspace).parts)
            )})
        finally:
            args.output.write_text(json.dumps(records, ensure_ascii=False, indent=2), encoding="utf-8")
            proc.stdin.close()
            proc.terminate()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("cli", "profile", "workspace", "payload", "output"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--case", choices=["plain", "namespace", "design"], required=True)
    run(parser.parse_args())
