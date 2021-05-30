# Requirements for VirtualBox machines

## Networks:
1) Host-only network #2:
  - IP address: 10.0.0.1
  - Netmask: 255.255.255.0
  - DHCP disabled
2) NAT Network **provider**:
  - CIDR: 203.0.113.0/24
  - DHCP disabled

## **console** node:
- 1 vCPU
- 512 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
  - Adapter 3: NAT network **provider**
- disks:
  - disk1: 10GB (sda)

## **block1** node:
- 1 vCPU
- 512 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
- disks:
  - disk1: 10GB (sda)
  - disk2: 60GB (sdb)
  - disk3: 20GB (sdc)

## **compute1** node:
- 1 vCPU
- 1024 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
  - Adapter 3: NAT network **provider**
- disks:
  - disk1: 10GB (sda)

## **compute2** node:
- 1 vCPU
- 1024 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
  - Adapter 3: NAT network **provider**
- disks:
  - disk1: 10GB (sda)