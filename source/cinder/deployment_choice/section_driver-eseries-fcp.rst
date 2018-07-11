Theory of Operation: NetApp Unified Driver for E-Series with Fibre Channel
==========================================================================

* E-Series drivers are being deprecated and will be removed after the S
  release

In order for Fibre Channel to be set up correctly, you also need to set up
Fibre Channel zoning for your backends. See the section called :ref:`fc-switch`
for more details on configuring Fibre Channel zoning.

As described in the section called ":ref:`theory-op`", Cinder
with NetApp E-Series requires the use of the NetApp SANtricity Web
Services Proxy server deployed as an intermediary between Cinder and the
E-Series storage system. A common deployment topology with Cinder, Nova,
and an E-Series controller with the SANtricity Web Services Proxy can be
seen below in Figure 4.8, “Cinder & E-Series Deployment Topology”.

.. figure:: ../../images/cinder_eseries_fc_deployment_topology.png
   :alt: Cinder & E-Series Deployment Topology
   :scale: 100

   Figure 4.8. Cinder & E-Series Deployment Topology

.. tip::

   Installation instructions for the NetApp SANtricity Web Services
   Proxy server are available for download at
   https://library.netapp.com/ecm/ecm_download_file/ECMLP2428355, and
   the User Guide is available for download at
   https://library.netapp.com/ecm/ecm_download_file/ECMLP2428357.

Dynamic disk pools (as described in the section called ":ref:`ef-series`) and
volume groups are the supported disk collection strategies when
utilizing the Cinder E-Series driver. For more information on the
capabilities of the E-Series storage systems, visit
http://support.netapp.com.

.. important::

   The use of multipath and DM-MP are required when using the OpenStack
   Block Storage driver for E-Series.


.. important::

   In order for Fibre Channel to be set up correctly, you also need to
   set up Fibre Channel zoning for your backends. See ":ref:`fc-switch`"
   for more details on configuring Fibre Channel zoning.

.. important::

   In order for OpenStack Block Storage and OpenStack Compute to take
   advantage of multiple paths, the following configuration options
   must be correctly configured:

   -  The ``use_multipath_for_image_xfer`` should be set to ``True`` in
      ``cinder.conf`` within the driver stanza.
