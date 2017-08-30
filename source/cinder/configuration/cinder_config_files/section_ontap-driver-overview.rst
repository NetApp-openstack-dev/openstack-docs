.. _netapp_ontap_unified_driver_overview:

NetApp ONTAP Unified Driver (Cinder): Overview
==================================================================

NetApp drivers for clustered Data ONTAP and Data ONTAP operating in
7-Mode are now offered in a single, unified driver. The unified driver
provides OpenStack with access to NetApp clustered Data ONTAP and Data
ONTAP operating in 7-Mode controllers for provisioning and maintaining
OpenStack block storage volumes.

Where to Obtain the Drivers
---------------------------

NetApp’s contribution strategy involves adding all new capabilities
directly into the upstream OpenStack Block Storage repositories, so all
the features are available regardless of which distribution you choose
when deploying OpenStack. Bug fixes are delivered into the appropriate
branches that represent the different releases of OpenStack (e.g.
``trunk``, ``stable/icehouse``, ``stable/havana``, etc).

On occasion, it may be necessary for NetApp to deliver capability to a
previous release of OpenStack that can not be accepted in the upstream
OpenStack repositories. In that case, we post the capability at the
NetApp Github repository - accessible at
https://github.com/NetApp/cinder. Be sure to choose the branch from this
repository that matches the release version of OpenStack you are
deploying with.

Multiple Deployment Options
---------------------------

A variety of OpenStack block storage deployment options for NetApp Data
ONTAP based systems are available in the Kilo OpenStack release and
involve making deployment choices between the following:

-  Clustered Data ONTAP or Data ONTAP operating in 7-Mode

-  iSCSI, Fibre Channel, or NFS storage protocol

While there are multiple supported deployment options, since the Havana
release there is a new, single NetApp unified driver that can be
configured to achieve any of the desired deployments. In Grizzly and
prior releases, there were multiple drivers segmented by storage family,
protocol, and integration with additional NetApp management software.
The previous drivers have all been deprecated since the Havana release;
see :ref:`deprecated_drivers` for more information on
the deprecated capabilities.

The following lists all of the individual options and subsequent
sections are intended to offer guidance on which configuration options
ought to be employed given varying use cases:

-  :ref:`NetApp clustered Data ONTAP with
   iSCSI <cdot-iscsi>`

-  :ref:`NetApp clustered Data ONTAP with
   NFS <cdot-nfs>`

-  :ref:`NetApp clustered Data ONTAP with Fibre
   Channel <cdot-fc>`

-  :ref:`NetApp Data ONTAP operating in 7-Mode with
   iSCSI <7mode-iscsi>`

-  :ref:`NetApp Data ONTAP operating in 7-Mode with
   NFS <7mode-nfs>`

-  :ref:`NetApp Data ONTAP operating in 7-Mode with Fibre
   Channel <7mode-fc>`
