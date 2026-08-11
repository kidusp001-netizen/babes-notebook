#!/usr/bin/env python3
"""Set a GitHub Actions secret (requires PyNaCl)."""
import base64
import json
import sys
import urllib.request

from nacl import encoding, public


def encrypt(public_key: str, secret_value: str) -> str:
    pk = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(pk)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return base64.b64encode(encrypted).decode("utf-8")


def main() -> None:
    if len(sys.argv) != 6:
        print("Usage: set_github_secret.py TOKEN OWNER REPO SECRET_NAME SECRET_VALUE")
        sys.exit(1)

    token, owner, repo, name, value = (
        sys.argv[1],
        sys.argv[2],
        sys.argv[3],
        sys.argv[4],
        sys.argv[5],
    )

    key_url = f"https://api.github.com/repos/{owner}/{repo}/actions/secrets/public-key"
    req = urllib.request.Request(key_url, headers={"Authorization": f"token {token}"})
    with urllib.request.urlopen(req) as resp:
        key_data = json.load(resp)

    encrypted = encrypt(key_data["key"], value)

    body = json.dumps({"encrypted_value": encrypted, "key_id": key_data["key_id"]}).encode()
    put_url = f"https://api.github.com/repos/{owner}/{repo}/actions/secrets/{name}"
    put_req = urllib.request.Request(
        put_url,
        data=body,
        method="PUT",
        headers={
            "Authorization": f"token {token}",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(put_req) as resp:
        print(f"Set secret {name}: HTTP {resp.status}")


if __name__ == "__main__":
    main()
