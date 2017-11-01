Deployment Choice: Utilizing Share Servers
==========================================

NetApp's Manila drivers for ONTAP (with or without the
management of share servers) are offered in a single, unified driver.

Where to Obtain the Drivers
---------------------------

NetApp’s contribution strategy involves adding all new capabilities
directly into the upstream OpenStack Shared File System service
repositories, so all the features are available regardless of which
distribution you choose when deploying OpenStack. Bug fixes are
delivered into the appropriate branches that represent the different
releases of OpenStack.

On occasion, it may be necessary for NetApp to deliver capability to a
previous release of OpenStack that can not be accepted in the
upstream OpenStack repositories. In that case, we post the capability
at the NetApp Github repository - accessible at
https://github.com/NetApp/manila. Be sure to choose the branch from
this repository that matches the release version of OpenStack you are
deploying with. There will be a ``README`` file in the root of the
repository that describes the specific changes that are merged into
that repository beyond what is available in the upstream repository.

Share Networks
--------------

Manila offers the capability for shares to be accessible through
tenant-defined networks (defined within Neutron). This is achieved by
defining a share network object, which provides the relationship to the
Neutron network and subnet from which an IP address should be allocated,
as well as configured on the backend storage (along with the appropriate
segmentation approach (e.g. VLAN, VXLAN, GRE, etc).

Share Servers
-------------

Offering this capability to end users places certain requirements on
storage platforms that are integrated with Manila to be able to
dynamically configure themselves. Share servers are an object defined by
Manila that manages the relationship between share networks and shares.
In the case of the reference driver implementation, a share server
corresponds to an actual Nova instance that provides the file system
service, with raw capacity provided through attached Cinder block
storage volumes. In the case of the Manila driver for NetApp
ONTAP, a share server corresponds to a storage virtual machine
(SVM), also referred to as a Vserver.

.. note::

   One share server is created by Manila for each share network that
   has shares associated with it.

.. important::

   When deploying Manila with NetApp ONTAP without share
   server management, NetApp requires that each Manila backend refer to
   a single SVM within a cluster through the use of the
   ``netapp_vserver`` configuration option.

With Share Server Management
----------------------------

Within the ONTAP driver with share server support, a
storage virtual machine will be created for each share server. While
this can provide some advantages with regards to secure multitenancy and
integration with a variety of network services within OpenStack, care
must be taken to ensure that the scale limits are enforced through
Manila quotas. It is a documented best practice to not exceed 200 SVMs
running on a single cluster at any given time to ensure consistent
performance and responsive management operations.

-  :ref:`NetApp Unified Driver for ONTAP with Share Server
   management <with-share>`

Without Share Server Management
-------------------------------

With the ONTAP driver without share server support, data
LIFs are reused and the provisioning of new Manila shares (i.e. FlexVol
volumes) is limited to the scope of a single SVM.

-  :ref:`NetApp Unified Driver for ONTAP without Share Server
   management <without-share>`

