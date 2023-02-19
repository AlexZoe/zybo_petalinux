# About

Use TFTP boot on Digilent Zybo z7 board.

Update:<br>
boot seems to work but device looks for an SD card rootfs.
How to change to use the one of the TFTP server?

## HW

``
connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]

write_hw_platform -fixed -force  -include_bit -file /home/alex/github_repos/zybo_petalinux/zybo_goes_online_hw/design_1_wrapper.xsa
```


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
