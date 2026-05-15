# Recovery

Put the Xavier into Force Recovery mode, then from the host:

## 1. Boot recovery initrd

```bash
lsusb | grep 0955:7019                                                                        # expect: NVIDIA Corp. APX
cd ~/nvidia/nvidia_sdk/JetPack_5.1.6_Linux_JETSON_AGX_XAVIER_TARGETS/Linux_for_Tegra
sudo ./tools/l4t_flash_prerequisites.sh                                                       # one-time
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --initrd jetson-agx-xavier-devkit <partition>   # <partition> inert with --initrd (RAM boot); any value works, e.g. nvme0n1p1
```

## 2. Clear stale host key (only if needed)

```bash
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "fe80::1%eth0"  # only if ssh below fails with host-key warning, then retry ssh
```

## 3. SSH into recovery shell

```bash
ssh root@fe80::1%eth0  # password: root
```

In the recovery shell:

```bash
mkdir -p /mnt/root                                                              # create mountpoint for the rootfs
lsblk -f                                                                        # find <rootfs-partition> (APP label) — eMMC: mmcblk0p1, microSD: mmcblk1p1, NVMe: nvme0n1p1
mount /dev/<rootfs-partition> /mnt/root                                         # mount rootfs read-write; e.g. /dev/nvme0n1p1
rm -f /mnt/root/etc/systemd/system/*.wants/llama-cpp-*.service                  # disable services under any target.wants/ dir
sync                                                                            # flush writes to disk
umount /mnt/root                                                                # unmount cleanly
reboot -f                                                                       # initrd has no systemd, plain `reboot` may hang
# then immediately unplug USB-C to prevent re-entering recovery mode
```
