
#!/usr/bin/env python3

import json
import socket
import sys

HOST = "127.0.0.1"
PORT = 47832
BUFFER_SIZE = 1024 * 1024


def main():
    server = socket.socket(
        socket.AF_INET,
        socket.SOCK_DGRAM
    )

    server.bind((HOST, PORT))

    print(
        json.dumps({
            "type": "bridge_started",
            "host": HOST,
            "port": PORT
        }),
        flush=True
    )

    while True:
        try:
            data, address = server.recvfrom(BUFFER_SIZE)

            if address[0] != "127.0.0.1":
                continue

            try:
                message = json.loads(data.decode("utf-8"))

                if not isinstance(message, dict):
                    continue

                print(
                    json.dumps(message, ensure_ascii=False),
                    flush=True
                )

            except (UnicodeDecodeError, json.JSONDecodeError) as error:
                print(
                    f"[Sky-1 Bridge] Invalid packet: {error}",
                    file=sys.stderr,
                    flush=True
                )

        except KeyboardInterrupt:
            break

        except OSError as error:
            print(
                f"[Sky-1 Bridge] Socket error: {error}",
                file=sys.stderr,
                flush=True
            )
            break

    server.close()


if __name__ == "__main__":
    main()
