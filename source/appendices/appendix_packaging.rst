Packaging
*********

Installation and Uninstallation
===============================

Refer to the following link for install/uninstall-related information:
http://wiki.openstack.org/Getopenstack

Refer to the following link for documentation on configuring
``dm-multipath`` on Linux:
https://library.netapp.com/ecmdocs/ECMP1217221/html/GUID-34FA2578-0A83-4ED3-B4B3-8401703D65A6.html

Upgrading and Reverting
=======================

Refer to the following link for upgrading/reverting-related information:
https://docs.openstack.org/operations-guide/ops-upgrades.html

Licensing
=========

OpenStack is released under the Apache 2.0 license.

Versioning
==========

Presently, there is no separate versioning system for NetApp’s Cinder
drivers, but are instead distinguished by the enclosing OpenStack
release’s versioning and release system.

.. _deprecated_drivers:

Deprecated Drivers
==================

OpenStack Havana
----------------

In the OpenStack Havana release, NetApp deprecated a variety of
management-integrated drivers that had been available in previous
OpenStack releases. The driver names include:

::

    cinder.volume.drivers.netapp.iscsi.NetAppCmodeISCSIDriver
    cinder.volume.drivers.netapp.nfs.NetAppCmodeNfsDriver
    cinder.volume.drivers.netapp.iscsi.NetAppISCSIDriver
    cinder.volume.drivers.netapp.nfs.NetAppNfsDriver

The direct (and now unified) driver available in the Havana release
provides equivalent functionality to these drivers for the various
OpenStack services, but without the complex configuration and
requirements to operate additional management software and
infrastructure.

In situations where it is necessary to leverage the
management-integrated drivers in a Havana-based OpenStack deployment,
NetApp has ported the drivers to the Havana code base and made them
available for download from a separate git repository located at
https://github.com/NetApp/cinder/tree/stable/havana.

OpenStack Ocata
---------------

The NetApp unified driver in Cinder currently provides integration for
two major generations of the ONTAP operating system: the current
“clustered” ONTAP and the legacy 7-mode. NetApp’s “full support” for
7-mode ended in August of 2015 and the current “limited support” period
will end in February of 2017 [1]_.

In accordance with community policy [2]_, we are initiating the
deprecation process for the 7-mode components of the Cinder NetApp
unified driver set to conclude with their removal in the Queens release.
This will apply to all three protocols currently supported in this
driver: iSCSI, FC and NFS.

-  ``What is being deprecated:`` Cinder drivers for NetApp ONTAP
   7-mode NFS, iSCSI, FC

-  ``Period of deprecation:`` 7-mode drivers will be around in
   stable/ocata and stable/pike and will be removed in the Queens
   release (All milestones of this release)

-  ``What should users/operators do:`` Follow the recommended migration
   path to upgrade to ONTAP [3]_ or get in touch with your
   NetApp support representative.

OpenStack Stein
---------------

Cinder drivers for NetApp E-Series are removed from the Stein release, in
accordance with community policy [2]_. This will apply for the following
protocols: iSCSI and FC.
Any Cinder E-series deployers are encouraged to get in touch with NetApp
via the community #openstack-netapp IRC channel on freenode or via the
#OpenStack Slack channel on http://netapp.io. We encourage migration to
the LVM driver for continued use of E-series systems in most cases via
Cinder’s migrate facility [4]_.

.. [1]
   `Transition Fundamentals and
   Guidance <https://transition.netapp.com/>`__

.. [2]
   `OpenStack deprecation
   policy <https://governance.openstack.org/tc/reference/tags/assert_follows-standard-deprecation.html>`__

.. [3]
   `ONTAP for 7-Mode
   Administrators <https://mysupport.netapp.com/info/web/ECMP1658253.html>`__

.. [4]
   'OpenStack Cinder Volume Migration guide
   https://docs.openstack.org/admin-guide/blockstorage-volume-migration.html`__
