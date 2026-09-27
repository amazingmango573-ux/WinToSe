import os
import json

CONFIG_PATH = os.path.join("configs", "vm_config.json")

def generate_qemu_command():
    if not os.path.exists(CONFIG_PATH):
        print("Error: vm_config.json not found!")
        return
    
    with open(CONFIG_PATH, "r") as f:
        config = json.load(f)
    
    # Constructing the base QEMU arguments tailored for mobile ARM virtualization
    cmd = [
        "qemu-system-aarch64",
        "-machine", "virt,accel=hvf",  # Hardware Virtualization Framework for iOS/macOS
        "-cpu", config.get("cpu_model", "host"),
        "-smp", str(config.get("smp_cores", 2)),
        "-m", str(config.get("ram_allocation_mb", 2048)),
        "-drive", f"file={config['storage']['disk_image']},format=raw,id=hd0",
        "-device", "nvme,drive=hd0,serial=handheld_drive",
        "-display", "default,show-cursor=on"
    ]
    
    print("Generated QEMU Emulation Command:")
    print("-----------------------------------")
    print(" ".join(cmd))
    print("-----------------------------------")

if __name__ == "__main__":
    print("--- Phase 2: QEMU Execution Profiler ---")
    generate_qemu_command()