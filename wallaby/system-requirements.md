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
- 1024 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
  - Adapter 3: NAT network **provider**
- disks:
  - disk1: 10GB (sda)

## **controller** node:
- 4 vCPU
- 8192 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
  - Adapter 3: NAT network **provider**, Advanced -> Promiscuous Mode: Allow All
- disks:
  - disk1: 100GB (sda)

## **compute1** node:
- 1 vCPU
- 1024 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
  - Adapter 3: NAT network **provider**, Advanced -> Promiscuous Mode: Allow All
- disks:
  - disk1: 10GB (sda)

## **compute2** node:
- 1 vCPU
- 1024 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
  - Adapter 3: NAT network **provider**, Advanced -> Promiscuous Mode: Allow All
- disks:
  - disk1: 10GB (sda)

## **storage1** node:
- 1 vCPU
- 1024 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
- disks:
  - disk1: 10GB (sda)
  - disk2: 80GB (sdb)

## **storage2** node:
- 1 vCPU
- 1024 MB vRAM
- networks:
  - Adapter 1: NAT
  - Adapter 2: Host-only, network #2
- disks:
  - disk1: 10GB (sda)
  - disk2: 50GB (sdb)
