Packaging
=========

Packaging and Downloading Requirements
======================================

Refer to the following link for packaging and downloading requirements:
http://wiki.openstack.org/Getopenstack

Installation and Uninstallation
===============================

Refer to the following link for install/uninstall-related information:
http://wiki.openstack.org/Getopenstack

Refer to the following link for documentation on the E-Series SANtricity
software:
http://support.netapp.com/documentation/productlibrary/index.html?productID=61197

Refer to the following link for documentation on configuring
``dm-multipath`` on Linux:
https://library.netapp.com/ecmdocs/ECMP1217221/html/GUID-34FA2578-0A83-4ED3-B4B3-8401703D65A6.html

Upgrading and Reverting
=======================

Refer to the following link for upgrading/reverting-related information:
http://wiki.openstack.org/Getopenstack

Licensing
=========

OpenStack is released under the Apache 2.0 license.

Versioning
==========

Presently, there is no separate versioning system for NetApp’s Cinder
drivers, but are instead distinguished by the enclosing OpenStack
release’s versioning and release system.

Deprecated Drivers
==================

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

The NetApp unified driver in Cinder currently provides integration for
two major generations of the ONTAP operating system: the current
“clustered” ONTAP and the legacy 7-mode. NetApp’s “full support” for
7-mode ended in August of 2015 and the current “limited support” period
will end in February of 2017 [1].

In accordance with community policy [2], we are initiating the
deprecation process for the 7-mode components of the Cinder NetApp
unified driver set to conclude with their removal in the Queens release.
This will apply to all three protocols currently supported in this
driver: iSCSI, FC and NFS.

-  ``What is being deprecated:`` Cinder drivers for NetApp Data ONTAP
   7-mode NFS, iSCSI, FC

-  ``Period of deprecation:`` 7-mode drivers will be around in
   stable/ocata and stable/pike and will be removed in the Queens
   release (All milestones of this release)

-  ``What should users/operators do:`` Follow the recommended migration
   path to upgrade to Clustered Data ONTAP [3] or get in touch with your
   NetApp support representative.

1. `Transition Fundamentals and
   Guidance <https://transition.netapp.com/>`__

2. `OpenStack deprecation
   policy <https://governance.openstack.org/tc/reference/tags/assert_follows-standard-deprecation.html>`__

3. `Clustered Data ONTAP for 7-Mode
   Administrators <https://mysupport.netapp.com/info/web/ECMP1658253.html>`__
