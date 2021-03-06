Description of ONTAP
====================

NetApp’s ONTAP operating system delivers an industry-leading,
unified storage platform for unprecedented levels of scalability, and
data storage flexibility.

ONTAP operation enhances NetApp’s storage
efficiency value by introducing massive scalability and nondisruptive
operations. ONTAP 9 introduced support for encryption of data at rest
with NetApp Volume Encryption (NVE). NVE is a software-based technology
which makes it possible to encrypt data at rest, one volume at a time.
It is also easier to form peering relationships between clusters and
SVMs; ONTAP 9.3 provides an option to generate a passphrase, which
can be used to create a peer relationship with a cluster without knowing
its intercluster LIF address. A SVM is a logical storage container that
includes allocated storage resources from within the cluster as well as
security parameters, such as rights and permissions. Logical interfaces
allow clients to access data within a SVM from anywhere in the cluster.
To the application, a SVM presents a securely partitioned storage pool
that can be dynamically deployed and redeployed according to changing
business requirements.

ONTAP powers NetApp’s fabric-attached storage (FAS) and All Flash FAS
(AFF) storage arrays, FlexPod Converged Infrastructure solutions, FlexArray
storage virtualization for heterogeneous environments, NetApp Private Storage
for Cloud,the Software Defined Storage implementation called ONTAP Select,
and the AWS or Azure available Cloud Volumes ONTAP.

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

-  Support for deployment across a wide range of architectures, such as
   All Flash FAS (AFF) systems and hybrid-flash FAS systems, converged
   infrastructure solutions (FlexPod), on commodity servers as SDS (ONTAP
   Select), using third-party arrays (FlexArrays), near cloud deployments
   (NetApp Private Storage) and in cloud deployments (ONTAP Cloud)

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
consists of one or more FAS/AFF building blocks where each building block is
a high-availability pair of controllers (storage nodes). Multiple
controller pairs form a single, integrated cluster. ONTAP
uses Ethernet technology — Gigabit(Gb) and 10Gb — for server connections
and for interconnecting controllers. Servers can also be connected
through InfiniBand through the use of a gateway device. Each controller
can support any mix of high-performance SAS and cost-effective SATA disk
drives. Data can move nondisruptively between nodes or between different
tiers of disk as performance requirements change. This capability makes
sure that data center and IT administrators can maximize performance
where needed while simultaneously improving capacity utilization.

**Integrated Data Protection**

ONTAP makes it possible to provide data protection to safeguard business operations
and keep them running smoothly. Space-efficient Snapshots ensure business continuity
and near-instant recovery from disasters. Asynchronous mirroring of volumes from one
SVM to another, even across different clusters is provided using SnapMirror. Encryption
of data at-rest is easy and efficient using NetApp Volume Encryption that is built into
ONTAP. There is no requirement for special encrypting disks.

ONTAP Select
------------

NetApp ONTAP Select provides the flexibility for customers to leverage the benefits of
Software Defined Storage (SDS) economics, while enjoying enterprise-grade features
and efficient data protection. ONTAP Select offers robust enterprise storage
services that are deployed on commodity hardware from the comfort of a data center. It
combines the best of the cloud, in terms of agility and granular capacity scaling, with
the flexibility, resilience, and locality of on-premises storage. ONTAP Select software
can be deployed in a data center or a remote office, with a flexible capacity-based
license structure. Key benefits include:

**Flexible Deployment**

It is possible to deploy on your desired choice of commodity server, hypervisor, and media.
You can also leverage your existing server infrastructure, HCI configurations,
and external arrays for enterprise data services. Simplify operations and lower
training requirements with uniform management across all storage based on ONTAP.

**Cloudlike Agility**

Spin up storage resources with cloudlike agility, from procurement to deployment
in a day. It is also possible to easily move and replicate data non-
disruptively across the hybrid cloud.

**Enterprise Level Functionality**

By using SDS built on ONTAP, the industry-leading data management platform,
enterprise-class data reduction and data protection for NAS and SAN workloads
can be obtained. Non-disruptive scaling and balancing of workloads can be done
dynamically.
