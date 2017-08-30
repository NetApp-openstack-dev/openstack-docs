.. _santricity_web_services_proxy:

SANtricity Web Services Proxy
=============================

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
