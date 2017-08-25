Key Concepts
============

Instance
--------

An instance is the fundamental resource unit allocated by the OpenStack
Compute service. It represents an allocation of compute capability (most
commonly but not exclusively a virtual machine), along with optional
ephemeral storage utilized in support of the provisioned compute
capacity.

.. caution::

   Unless a root disk is sourced from Cinder (see
   ":ref:`disk-choices`", the disks associated with VMs are
   "ephemeral," meaning that (from the user's point of view) they
   effectively disappear when a virtual machine is terminated.

Instances can be identified uniquely through a UUID assigned by the Nova
service at the time of instance creation. An instance may also be
optionally referred to by a human-readable name, though this string is
not guaranteed to be unique within a single tenant or deployment of
Nova.

Flavor
------

Virtual hardware templates are called "flavors" in OpenStack, defining
sizes for RAM, disk, number of cores, and so on. The default install
provides five flavors, and are configurable by admin users.

Flavors define a number of parameters, resulting in the user having a
choice of what type of virtual machine to run—just like they would have
if they were purchasing a physical server. The table lists the elements
that can be set. Flavors may also contain extra\_specs, which can be
used to define free-form characteristics, giving a lot of flexibility
beyond just the size of RAM, CPU, and Disk in determining where an
instance is provisioned.

Root (and Ephemeral) Disks
--------------------------

Each instance needs at least one root disk (that contains the bootloader
and core operating system files), and may have optional ephemeral disk
(per the definition of the flavor selected at instance creation time).
The content for the root disk either comes from an image stored within
the Glance repository (and copied to storage attached to the destination
hypervisor) or from a persistent block storage volume (via Cinder). For
more information on the root disk strategies available during instance
creation, refer to the section called ":ref:`disk-choices`".
