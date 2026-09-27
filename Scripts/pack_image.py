import os
import sys
import json
import subprocess

CONFIG_PATH = os.path.join("configs", "vm_config.json")
BUILD_DIR = "build"

def load_config():
    if not os.path.exists(CONFIG_PATH):
        print(f"Error: Configuration file not found at {CONFIG_PATH}. Run initialization first.")
        sys.exit(1)
    
    with open(CONFIG_PATH, "r") as f:
        return json.load(f)

def create_virtual_disk():
    config = load_config()
    os.makedirs(BUILD_DIR, exist_ok=True)
    
    disk_name = "windows_handheld_target.img"
    disk_path = os.path.join(BUILD_DIR, disk_name)
    
    # Target size: Let's default to a lean 20GB virtual drive for a stripped-down Windows build
    target_size_gb = 20
    size_bytes = target_size_gb * 1024 * 1024 * 1024
    
    print(f"Target Architecture: {config.get('target_architecture', 'x86_64')}")
    print(f"Allocating Virtual Disk: {disk_path} ({target_size_gb} GB)...")
    
    try:
        # Create a sparse/raw binary file filled with zeros to serve as our raw disk image
        with open(disk_path, "wb") as f:
            f.seek(size_bytes - 1)
            f.write(b"\0")
        print(f"Successfully generated base disk image at: {disk_path}")
    except Exception as e:
        print(f"Failed to create disk image: {e}")
        sys.exit(1)

if __name__ == "__main__":
    print("--- Phase 1: Virtual Disk Packaging Tool ---")
    create_virtual_disk()
    print("Phase 1 disk setup task complete. Ready for configuration mapping.")