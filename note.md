# About

Use TFTP boot + NFS rootfs on Digilent Zybo z7 board.

## 1 Prerequisites
### 1.1 TFTP Server Setup on Host PC

Install:

```
sudo apt install xinetd tftp tftpd -y
```

Create /etc/xinetd.d/tftp and write the following contents to it.

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

Create the tftpboot directory and set its permissions.

```
cd $HOME
mkdir -p tftpboot
sudo mv tftpboot /
sudo chmod 777 /tftpboot
```

<br>

### 1.2 NFS Setup on Host PC

Instructions from [here](https://ubuntu.com/server/docs/service-nfs)

Installation:

```
sudo apt install nfs-kernel-server
```

Add to /etc/exports

```
/tftpboot/nfsroot 192.168.11.0(rw,async,no_subtree_check,no_root_squash)
```

Restart nfs-kernel-server

```
sudo systemctl restart nfs-kernel-server.service
```

Create the nfsroot directory (assumes [TFTP Server Setup on Host PC](#11-tftp-server-setup-on-host-pc) has been carried out already).

```
mkdir tftpboot/nfsroot
```

<br>

### 1.3 Network Setup on Host PC

Create a new ethernet connection with `nm-connection-editor`.
Under *IPv4 Settings* choose *Shared to other computers*.
This project uses the IP address *192.168.11.6* with *24* as its netmask.

<br>
<br>

## 2 How the Project was set up
### 2.1 Hardware Project

Use the *Makefile* at the toplevel of the repository to generate the hardware project.
This step is required before the [Petalinux Configuration](#22-petalinux-configuration) step.

<br>

### 2.2 Petalinux Configuration

Create a new project using the following commands:

```
petalinux-create -t project -n zybo_goes_online_petalinux --template zynq
petalinux-config --get-hw-description=../zybo_goes_online_hw/
```

The `petalinux-config` command opens up a menuconfig.
Choose the following settings.

```
- Image Packaging Configuration
    -> Root File System Type.
    Select NFS as the RootFS type.
    Select Location of NFS root directory and set it to /tftpboot/nfsroot.
- Yocto Settings
    -> [*] Enable Debu Tweaks
```

The boot arguments in the auto generated DTSI is automatically updated after the build. You can check <plnx-proj-root>/components/plnx_workspace/device-tree/device-tree/system-conf.dts.

Next the kernel is configured.

```
petalinux-config -c kernel
```

Choose the following configurations in the menuconfig.

```
- Select Networking support
    -> IP: kernel level configuration.
        IP:DHCP support
        IP:BOOTP support
        IP:RARP support
- Select File systems
    -> Network file systems
        -> Root file systems on NFS.
```

Build the project

```
petalinux build
```

For jtag boot, the bootloader and bitstream have to be exported.

```
petalinux-package --prebuilt --fpga <bitstream>
```

Rename bitstream at *./pre-built/linux/implementation/* to:

```
./pre-built/linux/implementation/download.bit
```

Extract the *rootfs.tar.gz* to */tftpboot/nfsroot*

```
tar -xf /tftpboot/rootfs.tar.gz -C /tftpboot/nfsroot
```

<br>
<br>

## 3 TFTP Boot

Set the jumper configuration to *JTAG*.
Power on the board and turn on the network connection.
Connect to the serial port of the board.

```
picocom -b 115200 /dev/ttyUSB1
```

From the host PC run the following command from within the *zybo_goes_online_petalinux* directory.

```
./boot.sh
```

On the serial console abort autoboot on zybo and set the following:
```
setenv bootargs console=ttyPS0,115200 earlyprintk root=/dev/nfs nfsroot=192.168.11.6:/tftpboot/nfsroot,nfsvers=3,hard,tcp ip=192.168.11.233:192.168.11.6:192.168.11.1:255.255.255.0:arty rw
```

Replace `192.168.11.233` with the IP address of the target.
The IP address is obtained via DHCP and can be printed with the following command.

```
print ipaddr
```

Once the steps above have been completed, boot the board on the serial console with the command shown below.

```
run netboot
```