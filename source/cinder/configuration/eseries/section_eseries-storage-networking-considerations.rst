Storage Networking Considerations
=================================

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the network interfaces present on the E-Series controller.

2. Ensure there is network connectivity between the ``cinder-volume``
   nodes and the interfaces present on the node running the NetApp
   SANtricity Web Services Proxy software. See ":ref:`santricity_web_services_proxy`"
