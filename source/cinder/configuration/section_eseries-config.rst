E-Series Configuration
======================

E-Series Prerequisites
----------------------

The prerequisites for NetApp E-Series are:

-  The driver requires the use of the NetApp SANtricity Web Services.
   Please refer to the table below for the required Web Services Proxy
   version.

-  The storage controller should have a firmware version installed that
   is supported by the NetApp SANtricity Web Services Proxy. Refer to
   the proxy documentation for the most recent list of firmware versions
   that are supported.

+------------+------------------------------+
| Release    | Web Services Proxy version   |
+============+==============================+
| Icehouse   | 1.0 or later                 |
+------------+------------------------------+
| Juno       | 1.1 or later                 |
+------------+------------------------------+
| Kilo       | 1.2 or later                 |
+------------+------------------------------+
| Liberty    | 1.3                          |
+------------+------------------------------+

Table 4.22. Required Web Services Proxy versions

Storage Networking Considerations
---------------------------------

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the network interfaces present on the E-Series controller.

2. Ensure there is network connectivity between the ``cinder-volume``
   nodes and the interfaces present on the node running the NetApp
   SANtricity Web Services Proxy software.

Nova Live Migration of Instances with Attached E-Series Volumes
---------------------------------------------------------------

Live migration of Nova instances with attached volumes hosted on
E-Series are disabled by default. Setting ``netapp_enable_multiattach``
to true will allow this operation, however, it is facilitated by mapping
to a host group on the E-Series array, and comes with some limitations:

-  There is a maximum of 256 Cinder volumes for this backend.

-  E-Series hosts representing Nova Compute nodes must not be assigned
   to a foreign E-Series host group.

Irrespective of this option, live migrations between hosts may fail due
to 'LUN id' collisions where the immutable attachment identifier of the
attached volume is already in use on the destination host.
