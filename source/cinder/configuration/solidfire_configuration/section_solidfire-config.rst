SolidFire Configuration
=======================

SolidFire Prerequisites
-----------------------
The prerequisites for NetApp SolidFire are:

- The driver requires a cluster admin account to use with the OpenStack
  software to manage the storage cluster. Optionally, you can use an
  existing cluster admin account for integration.

- MVIP and SVIP are required to properly configure the SolidFire storage
  system driver.

MVIP and SVIP
-------------
Administrators and hosts can access the cluster using virtual IP addresses.
Any node in the cluster can host the virtual IP addresses. The Management
Virtual IP (MVIP) enables cluster management through a 1GbE connection,
while the Storage Virtual IP (SVIP) enables host access to storage through
a 10GbE connection. These virtual IP addresses enable consistent connections
regardless of the size or makeup of a SolidFire cluster. If a node hosting
a virtual IP address fails, another node in the cluster begins hosting the
virtual IP address.

Cluster Admin Account
---------------------

NetApp recommends creating a cluster admin account for each OpenStack
software instance to help audit API requests from the OpenStack. It
is also a good security practice to limit account access to only necessary
services. OpenStack instances do not need access to individual
SF-Series nodes or drives.
