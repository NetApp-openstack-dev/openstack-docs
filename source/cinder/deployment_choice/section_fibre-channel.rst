.. _fc-switch:

Fibre Channel Switch Fabric with Cinder
=======================================

Cinder includes a Fibre Channel zone manager facility for configuring
zoning in Fibre Channel fabrics, specifically supporting Cisco and
Brocade Fibre Channel switches. The user is required to configure the
zoning parameters in the Cinder configuration file (``cinder.conf``). An
example configuration using Brocade is given below::

    zoning_mode=fabric 

    [fc-zone-manager]
    fc_fabric_names=fabricA,fabricB
    zoning_policy=initiator-target
    brcd_sb_connector=cinder.zonemanager.drivers.brocade.brcd_fc_zone_client_cli.BrcdFCZoneClientCLI
    fc_san_lookup_service=cinder.zonemanager.drivers.brocade.brcd_fc_san_lookup_service.BrcdFCSanLookupService
    zone_driver=cinder.zonemanager.drivers.brocade.brcd_fc_zone_driver.BrcdFCZoneDriver

    [fabricA] 
    fc_fabric_address=hostname
    fc_fabric_user=username
    fc_fabric_password=password
    principal_switch_wwn=00:00:00:00:00:00:00:00

    [fabricB] 
    fc_fabric_address=hostname
    fc_fabric_user=username
    fc_fabric_password=password
    principal_switch_wwn=00:00:00:00:00:00:00:00
                

-  This option will need to be set in the ``DEFAULT`` configuration
   stanza and its value must be ``fabric``.

-  Be sure that the name of the stanza matches one of the values given
   in the ``fc_fabric_names`` option in the ``fc-zone-manager``
   configuration stanza.

-  Be sure that the name of the stanza matches the other value given in
   the ``fc_fabric_names`` option in the ``fc-zone-manager``
   configuration stanza.

.. important::

   While OpenStack has support for several Fibre Channel fabric switch
   vendors, NetApp has validated their drivers with the use of Brocade
   switches. For more information on other vendors, refer to the
   `upstream
   documentation <http://docs.openstack.org/trunk/config-reference/content/section_fc-zoning.html>`__.
