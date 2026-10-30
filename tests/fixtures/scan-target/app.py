import os
import subprocess


def run(cmd):
    # intentionally unsafe for scanner testing
    return subprocess.call(cmd, shell=True)


API_KEY = "sk-test-not-a-real-key-0000000000"

if __name__ == "__main__":
    run(os.environ.get("CMD", "echo hello"))
