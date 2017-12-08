Description of ONTAP
====================

NetApp’s ONTAP operating system delivers an industry-leading,
unified storage platform for unprecedented levels of scalability, and
data storage flexibility.

ONTAP 8.x provides two operating modes, ONTAP and
7-Mode. ONTAP operation enhances NetApp’s storage
efficiency value by introducing massive scalability and nondisruptive
operations. With ONTAP 8, two or more controllers (or
nodes) operate as one shared resource pool or storage cluster. The
storage cluster can be expanded, contracted, and subdivided
nondisruptively into one or more secure partitions, or NetApp Storage
Virtual Machine (SVM). A SVM is a logical storage container that
includes allocated storage resources from within the cluster as well as
security parameters, such as rights and permissions. Logical interfaces
allow clients to access data within a SVM from anywhere in the cluster.
To the application, a SVM presents a securely partitioned storage pool
that can be dynamically deployed and redeployed according to changing
business requirements.

ONTAP powers NetApp’s fabric-attached storage (FAS) hardware line, the 
Software defined Storage solution ONTAP Select, and the AWS and Azure 
based ONTAP Cloud.

ONTAP
-----

Scaling performance while controlling costs is one of the most
challenging efforts in the data center. High-performance, technical
computing, and digital media content applications place extreme demands
on storage systems. Compute clusters running these applications can
require multiple gigabytes per second of performance and many terabytes
— or even petabytes — of capacity. To maintain peak application
performance, users must be able to add storage and move data between
systems and tiers of storage without disrupting ongoing operations. At
the same time, to control costs, users must be able to effectively
manage the storage environment.

ONTAP addresses these challenges and provides
high-performance and high-capacity requirements. It enables
organizations to address faster time to market by providing massive
throughput and the scalability necessary to meet the demanding
requirements of high-performance computing and virtualization
infrastructures. These high-performance levels address the growing
demands of performance, manageability, and reliability for large Linux,
UNIX, Microsoft, or VMware clusters.

ONTAP is an operating system from NetApp that includes:

-  Nondisruptive operations based on a clustered file system hosted on
   interconnected nodes

-  Multinode scaling with global namespacing technologies

-  NetApp FlexVol for storage virtualization

-  NetApp backup and recovery solutions based on local Snapshot copies,
   replication, and mirroring

NetApp’s storage clustering feature within ONTAP provides a number
of key benefits, including the ability to:

**Accelerate Performance**

ONTAP uses a clustered file system technology to provide
maximum input/output (I/O) throughput and remove the bottlenecks that
affect production. Information can be striped as volumes across any or
all of the storage controllers and disks in the system, which enables
balanced levels of throughput for even a single file or volume and
allows technical teams to run multiple compute jobs concurrently. When
many compute nodes simultaneously require data, you can use
load-balancing mirrors within ONTAP with a clustering system or add
NetApp FlexCache storage accelerators in front of the system to deliver
much higher read throughput.

**Simplify Storage and Data Management**

ONTAP supports fully integrated storage solutions that
are easy to install, manage, and maintain. Enhancing this with its
global namespace capability, administrators can simplify client-side
management by mapping all data volumes in the cluster into a file system
tree structure that automatically maps or remaps servers to their data,
even if that data is moved. By offering a single system image across
multiple storage nodes, the global namespace eliminates the need for
complex automounter maps and symbolic link scripts.

**Improve Data Access**

Storage is virtualized at the file system level to enable all compute
nodes to mount a single file system, access all stored data, and
automatically accommodate physical storage changes that are fully
transparent to the compute cluster. Each client can access a huge pool
of information residing anywhere in the storage cluster through a single
mount point.

**Keep Resources in Balance Without Disrupting Operations**

As storage nodes are added to the cluster, physical resources, including
CPU, cache memory, network I/O bandwidth, and disk I/O bandwidth, are
kept in balance automatically. ONTAP enables you to add
storage and move data between storage controllers and tiers of storage
without disrupting users and applications. This ushers in a whole new
paradigm in which capacity increases, workload balancing, eliminating
storage I/O hotspots, and component deprecation become normal parts of
the data center without needing to schedule downtime. More importantly,
these tasks are accomplished without the need to remount shares, modify
client settings, or stop active workloads as is typically the case with
traditional or other high-performance computing storage systems.

**Simplify Installation and Maintenance**

Using standard Network File System (NFS) and Common Internet File System
(CIFS) protocols to access ONTAP systems without needing
to install special clients, network stack filters, or code on each
server in the compute cluster is the value of a unified storage product.
The ONTAP architecture also reduces or eliminates routine
capacity allocation and storage management tasks, resulting in more time
to address organizational goals and objectives and less time spent
managing storage.

**Meet High-Availability Requirements**

Along with stringent performance requirements, high reliability is
important for technical applications and cluster computing.
ONTAP leverages core NetApp software such as WAFL (Write Anywhere
File Layout), RAID-DP, and NetApp Snapshot. RAID-DP, a high-performance
implementation of RAID 6, protects against double-disk failures, and
transparent node failover automatically bypasses any failed components
with no interruption in data availability. In addition to having no
single point of failure, ONTAP supports the expansion or
reconfiguration of the storage infrastructure while online, enabling
applications to run uninterrupted as more storage capacity, processing
power, and/or throughput is added.

**Enable Continuous Operations**

ONTAP is configured for continuous operation with the use
of high-performance and modular NetApp storage components. Each system
consists of one or more FAS building blocks where each building block is
a high-availability pair of controllers (storage nodes). Multiple
controller pairs form a single, integrated cluster. ONTAP
uses Ethernet technology — Gigabit(Gb) and 10Gb — for server connections
and for interconnecting FAS controllers. Servers can also be connected
through InfiniBand through the use of a gateway device. Each controller
can support any mix of high-performance SAS and cost-effective SATA disk
drives. Data can move nondisruptively between nodes or between different
tiers of disk as performance requirements change. This capability makes
sure that data center and IT administrators can maximize performance
where needed while simultaneously improving capacity utilization.

ONTAP operating in 7-Mode
-------------------------

While ONTAP is the preferred operating mode for nearly
all new ONTAP installations, and is NetApp’s focal point for future
delivery of additional enhancement and innovation, there are a
significant number of 7-Mode based systems in existence and a variety of
valid operational considerations that require ongoing use. While NetApp
has provided Cinder driver enablement for 7-Mode systems, NetApp
recommends that ONTAP be used whenever possible.

.. important:: The NetApp unified driver in Cinder currently provides
   integration for two major generations of the ONTAP operating system:
   the current “clustered” ONTAP and the legacy 7-mode. NetApp’s “full
   support” for 7-mode ended in August of 2015 and the current “limited
   support” period will end in February of 2017 [1]_.

   In accordance with community policy [2]_, we are initiating the
   deprecation process for the 7-mode components of the Cinder NetApp
   unified driver set to conclude with their removal in the Queens
   release. This will apply to all three protocols currently supported
   in this driver: iSCSI, FC and NFS.

   - What is being deprecated: Cinder drivers for NetApp
     ONTAP 7-mode NFS, iSCSI, FC
   - Period of deprecation: 7-mode drivers will be around in
     stable/ocata and stable/pike and will be removed in the Queens
     release (All milestones of this release)
   - What should users/operators do: Follow the recommended
     migration path to upgrade to ONTAP [3]_ or get in
     touch with your NetApp support representative.

   .. [1]
      `Transition Fundamentals and Guidance <https://transition.netapp.com/>`_
 
   .. [2]
      `OpenStack Deprecation Policy <https://governance.openstack.org/tc/reference/tags/assert_follows-standard-deprecation.html>`_

   .. [3]
      `ONTAP for 7-Mode Administrators <https://mysupport.netapp.com/info/web/ECMP1658253.html>`_
