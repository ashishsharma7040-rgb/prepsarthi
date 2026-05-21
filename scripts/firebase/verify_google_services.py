#!/usr/bin/env python3
import json
import sys
from pathlib import Path

EXPECTED_PACKAGE = "com.prepsarthi.app"


def fail(message: str) -> int:
    print(f"[FAIL] {message}")
    return 1


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: verify_google_services.py <path-to-google-services.json>")
        return 2

    path = Path(sys.argv[1])
    if not path.exists():
        return fail(f"Missing file: {path}")

    data = json.loads(path.read_text(encoding="utf-8"))
    project_id = data.get("project_info", {}).get("project_id")
    clients = data.get("client") or []

    matching_client = None
    for client in clients:
        package_name = (
            client.get("client_info", {})
            .get("android_client_info", {})
            .get("package_name")
        )
        if package_name == EXPECTED_PACKAGE:
            matching_client = client
            break

    if matching_client is None:
        return fail(f"No client found for package {EXPECTED_PACKAGE}")

    package_name = (
        matching_client.get("client_info", {})
        .get("android_client_info", {})
        .get("package_name")
    )
    oauth_clients = matching_client.get("oauth_client") or []
    android_oauth_clients = [
        client
        for client in oauth_clients
        if client.get("client_type") == 1
        and client.get("android_info", {}).get("package_name") == EXPECTED_PACKAGE
    ]
    web_oauth_clients = [
        client for client in oauth_clients if client.get("client_type") == 3
    ]
    certificate_hashes = [
        client.get("android_info", {}).get("certificate_hash")
        for client in android_oauth_clients
        if client.get("android_info", {}).get("certificate_hash")
    ]
    other_platform_clients = (
        matching_client.get("services", {})
        .get("appinvite_service", {})
        .get("other_platform_oauth_client")
        or []
    )
    other_platform_web_clients = [
        client for client in other_platform_clients if client.get("client_type") == 3
    ]

    print("[Firebase config report]")
    print(f"project_id: {project_id or 'missing'}")
    print(f"package_name: {package_name or 'missing'}")
    print(f"oauth_client_count: {len(oauth_clients)}")
    print(f"certificate_hash_count: {len(certificate_hashes)}")
    print(f"has_android_client_type_1: {bool(android_oauth_clients)}")
    print(f"has_web_client_type_3: {bool(web_oauth_clients)}")
    print(
        "has_other_platform_web_client: "
        f"{bool(other_platform_web_clients)}"
    )

    problems = []
    if package_name != EXPECTED_PACKAGE:
        problems.append(
            f"package_name mismatch: expected {EXPECTED_PACKAGE}, got {package_name}"
        )
    if not oauth_clients:
        problems.append("oauth_client is empty")
    if not android_oauth_clients:
        problems.append("missing Android OAuth client (client_type == 1)")
    if not certificate_hashes:
        problems.append("missing certificate_hash for Android OAuth client")
    if not web_oauth_clients:
        problems.append("missing Web OAuth client (client_type == 3)")

    if problems:
        print("[Problems]")
        for problem in problems:
            print(f"- {problem}")
        return 1

    print("[OK] google-services.json looks valid for Android Google Sign-In.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
