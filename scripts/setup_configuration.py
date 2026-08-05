#!/usr/bin/env python3

# Copyright 2017 - 2026 Riigi Infosüsteemi Amet
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


# Download and verify the app's default central configuration.

import base64
import datetime
import json
import os
import subprocess
import sys
import tempfile
import urllib.request

DEFAULT_CONFIG_BASE_URL = "https://id.eesti.ee"
DEFAULT_UPDATE_INTERVAL = 4
DEFAULT_TSL_URL = "https://ec.europa.eu/tools/lotl/eu-lotl.xml"

CONFIG_DIRECTORY = os.path.join(
    "Modules", "ConfigLib", "Sources", "ConfigLib", "Resources", "config"
)


def log(message):
    timestamp = datetime.datetime.now().strftime("%H:%M:%S")
    print(f"[{timestamp}] {message}", flush=True)


def fetch_data(url):
    with urllib.request.urlopen(url) as response:
        return response.read().decode("utf-8")


def digest_for_public_key(public_key_pem):
    der_body = "".join(
        line for line in public_key_pem.splitlines() if "-----" not in line
    )
    der = base64.b64decode(der_body)
    length = len(der)
    if 80 <= length <= 100:
        return "sha256"
    if 110 <= length <= 130:
        return "sha384"
    if 150 <= length <= 170:
        return "sha512"
    raise ValueError(f"Unknown public key size: {length} bytes")


def verify_signature(config_data, public_key_pem, signature_base64):
    if not config_data or not public_key_pem or not signature_base64:
        raise ValueError("Missing data for signature verification")

    digest = digest_for_public_key(public_key_pem)
    signature_der = base64.b64decode(signature_base64)

    with tempfile.TemporaryDirectory() as tmp:
        pub_path = os.path.join(tmp, "config.ecpub")
        sig_path = os.path.join(tmp, "config.ecc")
        data_path = os.path.join(tmp, "config.json")

        with open(pub_path, "w", encoding="utf-8") as pub_file:
            pub_file.write(public_key_pem)
        with open(sig_path, "wb") as sig_file:
            sig_file.write(signature_der)
        with open(data_path, "wb") as data_file:
            data_file.write(config_data.encode("utf-8"))

        result = subprocess.run(
            [
                "openssl", "dgst", f"-{digest}",
                "-verify", pub_path,
                "-signature", sig_path,
                data_path,
            ],
            capture_output=True,
            text=True,
        )

    if result.returncode != 0 or "Verified OK" not in result.stdout:
        raise ValueError(
            f"Signature verifying failed: {result.stdout.strip()} {result.stderr.strip()}"
        )
    log("Signature verified successfully!")


def create_default_configuration(config_base_url, update_interval, version_serial):
    download_date = datetime.datetime.now(datetime.timezone.utc).strftime(
        "%Y-%m-%d %H:%M:%S"
    )
    return (
        f"central-configuration-service.url={config_base_url}\n"
        f"configuration.update-interval={update_interval}\n"
        f"configuration.version-serial={version_serial}\n"
        f"configuration.download-date={download_date}"
    )


def save_file(file_name, content):
    os.makedirs(CONFIG_DIRECTORY, exist_ok=True)
    file_path = os.path.join(CONFIG_DIRECTORY, file_name)
    with open(file_path, "w", encoding="utf-8") as output_file:
        output_file.write(content)
    log(f"File saved: {os.path.abspath(file_path)}")


def setup_configuration(config_base_url, update_interval, config_tsl_url):
    log("Starting configuration setup...")
    log(f"Config Base URL: {config_base_url}")
    log(f"Update Interval: {update_interval} hours")
    log(f"Config TSL URL: {config_tsl_url}")

    log("1 / 4 - Downloading configuration data...")
    config_data = fetch_data(f"{config_base_url}/config.json")
    public_key = fetch_data(f"{config_base_url}/config.ecpub")
    signature = fetch_data(f"{config_base_url}/config.ecc")

    log("2 / 4 - Verifying signature...")
    verify_signature(config_data, public_key, signature)

    log("3 / 4 - Creating default configuration file...")
    version_serial = json.loads(config_data)["META-INF"]["SERIAL"]
    default_configuration = create_default_configuration(
        config_base_url, update_interval, version_serial
    )

    log("4 / 4 - Saving and moving files...")
    save_file("default-config.json", config_data)
    save_file("default-config.ecpub", public_key)
    save_file("default-config.ecc", signature)
    save_file("configuration.properties", default_configuration)

    log("Default configuration initialized successfully!")


def main():
    args = sys.argv
    config_base_url = args[1] if len(args) > 1 else DEFAULT_CONFIG_BASE_URL
    config_tsl_url = args[3] if len(args) > 3 else DEFAULT_TSL_URL

    try:
        update_interval = int(args[2]) if len(args) > 2 else DEFAULT_UPDATE_INTERVAL
        setup_configuration(config_base_url, update_interval, config_tsl_url)
    except Exception as error:
        log(f"Error: {error}")
        sys.exit(1)


if __name__ == "__main__":
    main()
