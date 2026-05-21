#!/usr/bin/env python3
import sys
from pathlib import Path


def find_resource_paths(resource_name: str):
    roots = [Path("build/app"), Path("android/app/build")]
    matches = []
    for root in roots:
        if not root.exists():
            continue
        for file in root.rglob("*.xml"):
            try:
                text = file.read_text(encoding="utf-8", errors="ignore")
            except OSError:
                continue
            if f'name="{resource_name}"' in text:
                matches.append(file)
    return matches


def main() -> int:
    google_app_id_paths = find_resource_paths("google_app_id")
    default_web_client_id_paths = find_resource_paths("default_web_client_id")
    google_api_key_paths = find_resource_paths("google_api_key")

    print("[Generated Firebase resource report]")
    print(f"google_app_id files: {len(google_app_id_paths)}")
    print(f"default_web_client_id files: {len(default_web_client_id_paths)}")
    print(f"google_api_key files: {len(google_api_key_paths)}")

    if google_app_id_paths:
        print(f"google_app_id sample: {google_app_id_paths[0]}")
    if default_web_client_id_paths:
        print(f"default_web_client_id sample: {default_web_client_id_paths[0]}")
    if google_api_key_paths:
        print(f"google_api_key sample: {google_api_key_paths[0]}")

    problems = []
    if not google_app_id_paths:
        problems.append("google_app_id was not generated")
    if not default_web_client_id_paths:
        problems.append("default_web_client_id was not generated")

    if problems:
        print("[Problems]")
        for problem in problems:
            print(f"- {problem}")
        return 1

    print("[OK] Generated Firebase resources include google_app_id and default_web_client_id.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
