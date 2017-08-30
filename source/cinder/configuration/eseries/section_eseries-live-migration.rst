.. _nova-live:

Nova Live Migration of Instances with Attached E-Series Volumes
===============================================================

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
