Theory of Operation: NetApp Unified Driver for E-Series with iSCSI
==================================================================

* E-Series drivers are being deprecated and will be removed after the S 
  release

As described in the section called ":ref:`theory-op`", Cinder
with NetApp E-Series requires the use of the NetApp SANtricity Web
Services Proxy server deployed as an intermediary between Cinder and the
E-Series storage system. A common deployment topology with Cinder, Nova,
and an E-Series controller with the SANtricity Web Services Proxy can be
seen below in Figure 4.7, “Cinder & E-Series Deployment Topology”.

.. figure:: ../../images/cinder_eseries_deployment_topology.png
   :alt: Cinder & E-Series Deployment Topology
   :scale: 50

   Figure 4.7. Cinder & E-Series Deployment Topology

.. tip::

   Installation instructions for the NetApp SANtricity Web Services
   Proxy server are available for download at
   https://library.netapp.com/ecm/ecm_download_file/ECMLP2428355, and
   the User Guide is available for download at
   https://library.netapp.com/ecm/ecm_download_file/ECMLP2428357.

.. tip::

   The default http port for SANtricity Web Services Proxy is 8080.
   This port can be changed if necessary to avoid conflicts with
   another service, such as Swift. See Web Services Proxy documentation
   for instructions.

Dynamic disk pools (as described in the section called ":ref:`ef-series`")
and volume groups are the supported disk collection strategies when
utilizing the Cinder E-Series driver. For more information on the
capabilities of the E-Series storage systems, visit
http://support.netapp.com.

.. tip::

   While formally introduced in the Icehouse release of OpenStack,
   NetApp has backported the E-Series driver to the Grizzly and Havana
   releases of OpenStack, accessible at
   https://github.com/NetApp/cinder. Be sure to choose the branch from
   this repository that matches the release version of OpenStack you
   are deploying with.

.. important::

   The use of multipath and DM-MP are required when using the OpenStack
   Block Storage driver for E-Series. Ensure that all unconfigured
   iSCSI host ports on the E-Series array are disabled for both IPv4
   and IPv6 in order for multipath to function properly.

.. important::

   Cinder volumes provisioned through the E-Series driver will not be
   mapped to LUN 0, as LUN 0 is reserved for special use with E-Series
   arrays.

.. important::

   In order for OpenStack Block Storage and OpenStack Compute to take
   advantage of multiple paths, the following configuration options
   must be correctly configured:

   -  The ``use_multipath_for_image_xfer`` should be set to ``True`` in
      ``cinder.conf`` within the driver stanza.

   -  The ``iscsi_use_multipath`` should be set to ``True`` in
      ``nova.conf`` within the ``[libvirt]`` stanza.
