#!/usr/bin/env python3
"""
CGI endpoint **set_ap_ssid.py**
=================================
Updates the Wi‑Fi Access‑Point profile **`recore-ap`** by calling the helper
script **`make_ap_profile.sh` that sits in the *same directory* as this CGI
file**.

Why this design?
----------------
* The heavy lifting (nmcli commands, deletion / creation of the profile,
  IPv4‑sharing settings, etc.) already lives in Bash.  Re‑using it avoids
  duplicating logic in Python.
* By keeping the Bash and CGI files together (e.g. `/lib/cgi-bin/`), we avoid
  PATH issues and Docker dependencies.  The CGI simply resolves its own
  directory and executes the script directly.

Input payload (JSON via STDIN)
------------------------------
```json
{
  "ssid": "MyAP",          // 1‑32 printable ASCII bytes (required)
  "pass": "secretpass",   // 8‑63 printable ASCII (optional; empty → open)
  "chan": 6                // 1 | 6 | 11  (defaults to 6 if omitted)
}
```

HTTP responses
--------------
* **204 No Content** – update succeeded.
* **400 Bad Request** – validation failed.
* **500 Internal Server Error** – script execution failed.

The body is empty on success; on error the final line of the Bash script’s
output is logged to stderr and a generic 500 is returned to the client.
"""

import json
import os
import re
import subprocess
import sys
from html import escape
from pathlib import Path

# -----------------------------------------------------------
# Constants
# -----------------------------------------------------------
SCRIPT_PATH = Path(__file__).resolve().with_name("make_ap_profile.sh")
DEFAULT_CHAN = "6"

SSID_RE = re.compile(rb"^[\x20-\x7e]{1,32}$")   # printable ASCII 1‑32 bytes
PASS_RE = re.compile(r"^[\x20-\x7e]{8,63}$")    # printable ASCII 8‑63 chars
CHAN_OK = {"1", "6", "11"}

# -----------------------------------------------------------
# CGI helpers
# -----------------------------------------------------------

def http_response(status: str, body: str = "", content_type: str = "text/plain"):
    sys.stdout.write(f"Status: {status}\r\n")
    sys.stdout.write(f"Content-Type: {content_type}; charset=utf-8\r\n\r\n")
    if body:
        sys.stdout.write(body)
    sys.exit(0)


def bad_request(msg: str):
    http_response("400 Bad Request", msg + "\n")


def server_error(msg: str):
    print("[set_ap_ssid] ERROR:", msg, file=sys.stderr)
    http_response("500 Internal Server Error", "Internal error\n")

# -----------------------------------------------------------
# Parse JSON input
# -----------------------------------------------------------
try:
    payload_raw = sys.stdin.read()
    data = json.loads(payload_raw or "{}")
except json.JSONDecodeError as e:
    bad_request(f"Invalid JSON: {e}")

ssid = data.get("ssid", "")
password = data.get("pass", "")
chan = str(data.get("chan", DEFAULT_CHAN))

# -----------------------------------------------------------
# Validate
# -----------------------------------------------------------
if not ssid:
    bad_request("'ssid' is required")
if not SSID_RE.fullmatch(ssid.encode()):
    bad_request("SSID must be 1–32 printable ASCII bytes")

if password:
    if not PASS_RE.fullmatch(password):
        bad_request("Passphrase must be 8–63 printable characters")
else:
    # empty → open network
    pass

if chan not in CHAN_OK:
    bad_request("'chan' must be 1, 6 or 11")

# -----------------------------------------------------------
# Ensure helper script exists & is executable
# -----------------------------------------------------------
if not SCRIPT_PATH.is_file():
    server_error(f"Helper script not found: {SCRIPT_PATH}")
if not os.access(SCRIPT_PATH, os.X_OK):
    server_error(f"Helper script is not executable: {SCRIPT_PATH}")

# -----------------------------------------------------------
# Build command and execute
# -----------------------------------------------------------
cmd = ["sudo", str(SCRIPT_PATH), ssid, password, chan]

try:
    proc = subprocess.run(cmd, capture_output=True, text=True)
except Exception as exc:
    server_error(str(exc))

if proc.returncode != 0:
    # show the last stderr line for debugging
    snippet = (proc.stderr or proc.stdout).splitlines()[-1:]  # list slice
    server_error("make_ap_profile failed: " + " ".join(snippet))

# Success
http_response("204 No Content")