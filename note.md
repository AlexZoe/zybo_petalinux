# About

Use TFTP boot on Digilent Zybo z7 board.

Update:<br>
boot seems to work but device looks for an SD card rootfs.
How to change to use the one of the TFTP server?

## Petalinux

```
petalinux-create -t project -n zybo_goes_online_petalinux --template zynq
petalinux-config --get-hw-description=../zybo_goes_online_hw/
```

Menuconfig
```
- Image Packaging Configuration
    -> Root filesystem type
        -> (EXT (SD/eMMC/QSPI...))
- Yocto Settings
    -> [*] Enable Debu Tweaks
```

```
petalinux-config -c kernel
petalinux build
petalinux-package --prebuilt --fpga <bitstream>
```

## Server Setup

Install:
```
sudo apt install xinetd tftp tftpd -y
```

Create:
Create /etc/xinetd.d/tftp
```
service tftp
{
protocol        = udp
port            = 69
socket_type     = dgram
wait            = yes
user            = nobody
server          = /usr/sbin/in.tftpd
server_args     = tftpboot -s
disable         = no
}
```

## TFTP Boot

Rename bitstream to:
```
./pre-built/linux/implementation/download.bit
```

Run
```
petalinux-boot --jtag --prebuilt 2
```

## NFS Rootfs Petalinux

Steps to configure the PetaLinux for NFS boot and build the system image are as follows:

Change to root directory of your PetaLinux project.

```
$ cd <plnx-proj-root>
```

Launch the top level system configuration menu.

```
$ petalinux-config
```

Menuconfig
```
- Image Packaging Configuration
    -> Root File System Type.
    Select NFS as the RootFS type.
    Select Location of NFS root directory and set it to /tftpboot/nfsroot.
```

Exit menuconfig and save configuration settings. The boot arguments in the auto generated DTSI is automatically updated after the build. You can check <plnx-proj-root>/components/plnx_workspace/device-tree/device-tree/system-conf.dts.
Launch Kernel configuration menu.

```
$petalinux-config -c kernel
```

Menuconfig
```
- Select Networking support
    -> IP: kernel level configuration.
        IP:DHCP support
        IP:BOOTP support
        IP:RARP support
- Select File systems
    -> Network file systems > Root file systems on NFS.
```

Build the system image.


## NFS PC Setup

Instructions from [here](https://ubuntu.com/server/docs/service-nfs)

Installation:
```
sudo apt install nfs-kernel-server
```

Start:
```
sudo systemctl start nfs-kernel-server.service
```

Add to /etc/exports
```
/tftpboot/nfsroot *(rw,async,no_subtree_check,no_root_squash)
```

Apply new config
```
sudo exportfs -a
```