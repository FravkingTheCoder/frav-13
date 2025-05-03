import platform
import distro
import os

disid = distro.id()
disname = distro.name()

try:
    print("\n--- Using 'distro' package ---")
    print(f"ID:           {disid}")
    print(f"Name:         {disname}")
    if disid == "arch":
        print('ur on arch lol')
except ImportError:
    print("\n'distro' package not installed. Cannot get reliable distribution info.")
except Exception as e:
    print(f"\nError using 'distro' package: {e}")


