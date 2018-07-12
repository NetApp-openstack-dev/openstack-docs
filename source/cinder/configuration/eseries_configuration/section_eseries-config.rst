E-Series Configuration
======================

* E-Series drivers are being deprecated and will be removed after the S
  release

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


SANtricity Web Services Proxy
-----------------------------

The NetApp SANtricity Web Services Proxy provides access through
standard HTTPS mechanisms to configuring management services for
E-Series storage arrays. You can install Web Services Proxy on either
Linux or Windows. As Web Services Proxy satisfies the client request by
collecting data or executing configuration change requests to a target
storage array, the Web Services Proxy module issues SYMbol requests to
the target storage arrays. Web Services Proxy provides a Representative
State Transfer (REST)-style API for managing E-Series controllers. The
API enables you to integrate storage array management into other
applications or ecosystems.

When Cinder is used with a NetApp E-Series system, use of the SANtricity
Web Services Proxy is currently required. The SANtricity Web Services
Proxy may be deployed in a highly-available topology using an
active/passive strategy.

While WFA can be utilized in conjunction with the NetApp unified Cinder
driver, a deployment of Cinder and WFA does introduce additional
complexity, management entities, and potential points of failure within
a cloud architecture. If you have an existing set of workflows that are
written within the WFA framework, and are looking to leverage them in
lieu of the default provisioning behavior of the Cinder driver operating
directly against a FAS system, then it may be desirable to use the
intermediated mode.

.. important::

   As of the Mitaka release, only NetApp SANtricity Web Services Proxy
   version 1.4 and greater are supported by the E-Series Cinder driver.
   If an older version is installed, the user will be notified that an
   upgrade is required upon starting the Cinder-Volume service.

.. important::

   Unless you have a significant existing investment with OnCommand
   Workflow Automator that you wish to leverage in an OpenStack
   deployment, it is recommended that you start with the *direct* mode
   of operation when deploying Cinder with a NetApp FAS system. When
   Cinder is used with a NetApp E-Series system, use of the SANtricity
   Web Services Proxy in the *intermediated* mode is currently
   required. The SANtricity Web Services Proxy may be deployed in a
   highly-available topology using an active/passive strategy.

Storage Networking Considerations
---------------------------------

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the network interfaces present on the E-Series controller.

2. Ensure there is network connectivity between the ``cinder-volume``
   nodes and the interfaces present on the node running the NetApp
   SANtricity Web Services Proxy software.

.. _nova-live:

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
