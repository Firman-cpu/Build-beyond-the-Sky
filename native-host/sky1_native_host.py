#!/usr/bin/python3
#!/usr/bin/env python3

import json
import socket
import struct
import sys

UDP_HOST = "127.0.0.1"
UDP_PORT = 47832

MAX_MESSAGE_SIZE = 1024 * 1024


def read_exact(size):
    """Read exactly size bytes from browser stdin."""
    data = bytearray()

    while len(data) < size:
        chunk = sys.stdin.buffer.read(size - len(data))

        if not chunk:
            return None

        data.extend(chunk)

    return bytes(data)


def read_message():
    header = read_exact(4)

    if header is None:
        return None

    message_size = struct.unpack("<I", header)[0]

    if message_size <= 0 or message_size > MAX_MESSAGE_SIZE:
        raise ValueError("Invalid message size")

    raw_message = read_exact(message_size)

    if raw_message is None:
        return None

    return json.loads(raw_message.decode("utf-8"))


def send_response(payload):
    """Send a framed JSON response to the browser."""
    raw = json.dumps(payload).encode("utf-8")
    sys.stdout.buffer.write(struct.pack("<I", len(raw)))
    sys.stdout.buffer.write(raw)
    sys.stdout.buffer.flush()


def forward_message(message):
    if not isinstance(message, dict):
        raise ValueError("Message must be a JSON object")

    required_fields = ("title", "artist", "pageUrl")

    for field in required_fields:
        if field not in message:
            raise ValueError(f"Missing field: {field}")

    payload = json.dumps(
        message,
        ensure_ascii=False
    ).encode("utf-8")

    if len(payload) > MAX_MESSAGE_SIZE:
        raise ValueError("Payload too large")

    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.sendto(payload, (UDP_HOST, UDP_PORT))


def main():
    while True:
        try:
            message = read_message()

            if message is None:
                break

            forward_message(message)

            send_response({
                "ok": True
            })

        except Exception as error:
            print(
                f"[Sky-1 Native Host] {error}",
                file=sys.stderr,
                flush=True
            )

            send_response({
                "ok": False,
                "error": str(error)
            })


if __name__ == "__main__":
    main()
