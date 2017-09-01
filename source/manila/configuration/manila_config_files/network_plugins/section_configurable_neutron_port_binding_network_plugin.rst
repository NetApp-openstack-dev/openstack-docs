.. _configurable_neutron_port_binding_network_plugin:

Manila Network Plugins: Configurable Neutron Port Binding Network Plugin
---------------------------------------------------------------------------

-  *Configurable Neutron Port Binding Network Plugin*: This plugin is
   very similar to the configurable neutron network plugin, the only
   difference is that this plugin can enforce port-binding. Port binding
   profiles from the manila configuration file are sent to Neutron at
   the time of creating network ports for the purpose of creating ONTAP
   LIFs. This allows network agents to bind the ports based off these
   profiles. When using multiple top of the rack switches to connect
   different compute nodes, this plugin is also capable of performing
   Hierarchical Port Binding. Share networks can be defined with VLAN
   shared provider networks or VLAN tenant networks. Administrators are
   required to define one or more binding profiles in ``manila.conf``
   per backend configured with this plugin. Manila consumes bound
   network ports and invokes the NetApp driver to create LIFs assigned
   to the network segment and IP address as chosen.

   Tenants *must* specify Neutron network information when creating
   share network objects. Manila will derive values for segmentation
   protocol, IP address, netmask and gateway from Neutron when creating
   a new share server..

In spirit this plugin works exactly like the Simple Neutron Port Binding
Network Plugin. The only difference being that the Neutron network is not 
configured within ``manila.conf`` by the administrator. Use of this plugin 
allows Manila to derive network information from the Share Network objects 
created by the tenants. To set up the configurable Neutron port binding 
network plugin, the following options should be added to the driver-specific 
stanza within the Manila configuration file (``manila.conf``). 
The Neutron binding profile in this example is for a Cisco Nexus 9000 switch:


.. figure:: ../../../../images/manila_hierarchical_port_binding.png
   :alt: Hierarchical Network Topology
   :width: 10in

   Hierarchical Network Topology

::

                        network_api_class = manila.network.neutron.neutron_network_plugin.NeutronBindNetworkPlugin
                        neutron_host_id = netapp_lab42
                        neutron_vnic_type = baremetal
                        neutron_binding_profiles = phys1

                        [phys1]
                        neutron_switch_id = 10.63.152.254
                        neutron_port_id = 1/1-4
                        neutron_switch_info = switch_ip:10.63.152.254
                    

`table\_title <#manila.configuration.network.neutron_bind.options>`__
lists the configuration options available for the configurable Neutron
Port Binding network plugin:

+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                         | Type       | Default Value               | Description                                                                                                                                                           |
+================================+============+=============================+=======================================================================================================================================================================+
| ``neutron_host_id``            | Optional   | Perceived system hostname   | Hostname of the node where the manila-share service is running, configured with the NetApp backend.                                                                   |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``neutron_vnic_type``          | Optional   | baremetal                   | Virtual NIC type for the ports created by Neutron on the given network. Supported type is "baremetal"                                                                 |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``neutron_binding_profiles``   | Optional   |                             | Comma separated list of binding profile sections. Each of these sections can contain specific switch information and they can be shared amongst different backends.   |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Configuration options for the tenant configurable Neutron Port
Binding Network Plugin
