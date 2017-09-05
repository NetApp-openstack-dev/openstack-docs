.. _netapp_ontap_unified_driver_overview:

Theory of Operation: NetApp Unified Driver Overview
==================================================================

NetApp drivers for ONTAP, Data ONTAP operating in 7-Mode, and E-Series 
are offered in a single, unified driver for the purpose of
provisioning and maintaining OpenStack block storage volumes.

Where to Obtain the Drivers
---------------------------

NetApp’s contribution strategy involves adding all new capabilities
directly into the upstream OpenStack Block Storage repositories, so all
the features are available regardless of which distribution you choose
when deploying OpenStack. Bug fixes are delivered into the appropriate
branches that represent the different releases of OpenStack.

On occasion, it may be necessary for NetApp to deliver capability to a
previous release of OpenStack that can not be accepted in the upstream
OpenStack repositories. In that case, we post the capability at the
NetApp Github repository - accessible at
https://github.com/NetApp/cinder. Be sure to choose the branch from this
repository that matches the release version of OpenStack you are
deploying with.

Multiple Deployment Options
---------------------------

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

-  :ref:`E-Series with iSCSI <eseries-iscsi>`

-  :ref:`E-Series with FCP <eseries-fc>`
