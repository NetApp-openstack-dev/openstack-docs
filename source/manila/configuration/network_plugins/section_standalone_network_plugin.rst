.. _standalone_network_plugin:

Manila Network Plugins: Standalone Network Plugin
-------------------------------------------------

-  *Standalone Network Plugin*: Use this plugin in stand-alone
   deployments of OpenStack Manila, and in deployments where you don't
   desire to manage the storage network with Neutron. IP settings
   (address range, subnet mask, gateway, version) are all defined
   through configuration options within the driver-specific stanza. This
   network can either be segmented (VLAN) or non-segmented (FLAT).
   Overlay networks (VxLAN, GRE, Geneve) are not supported by the NetApp
   driver.

   Tenants *must not* specify Neutron network information when creating
   share network objects. Values for segmentation protocol, IP address,
   netmask and gateway are obtained from ``manila.conf`` when creating a
   new share server.

The network plugin is chosen by setting the value of the network_api_class 
configuration option within the driver-specific stanza of the manila.conf 
configuration file.

To set up the standalone network plugin, the following options should be
added to the driver-specific stanza within the Manila configuration file
(``manila.conf``)::

   network_api_class = manila.network.standalone_network_plugin.StandaloneNetworkPlugin
   standalone_network_plugin_allowed_ip_ranges = 10.0.0.10-10.0.0.254
   standalone_network_plugin_ip_version = 4
   standalone_network_plugin_segmentation_id = 314
   standalone_network_plugin_network_type = vlan
   standalone_network_plugin_mask = 255.255.255.0
   standalone_network_plugin_gateway = 10.0.0.1

`table\_title <#manila.configuration.network.standalone.options>`__
lists the configuration options available for the standalone network
plugin:

+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                                                                        | Type       | Default Value   | Description                                                                                                                                                                                                                                                                                                                                        |
+===============================================================================+============+=================+====================================================================================================================================================================================================================================================================================================================================================+
| ``standalone_network_plugin_gateway``                                         | Required   |                 | Specify the gateway IP address that should be configured on the data LIF through which the share is exported. A Vserver static route is configured using this gateway.                                                                                                                                                                             |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``standalone_network_plugin_mask``                                            | Required   |                 | Specify the subnet mask that should be configured on the data LIF through which the share is exported. You can specify the CIDR suffix (without the slash, e.g. ``24``) or the full netmask (e.g. ``255.255.255.0``).                                                                                                                              |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``standalone_network_plugin_segmentation_id``                                 | Optional   |                 | Specify the segmentation ID that should be assigned to data LIFs through which shares can be exported. This option is not necessary if the ``standalone_network_plugin_network_type is set to ``flat``                                                                                                                                             |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``standalone_network_plugin_allowed_ip_ranges``                               | Optional   |                 | Specify the range of IP addresses that can be used on data LIFs through which shares can be exported. An example of a valid range would be ``10.0.0.10-10.0.0.254``.                                                                                                                                                                               |
|                                                                               |            |                 | If this value is not specified, the entire range of IP addresses within the network computed by applying the value of ``standalone_network_plugin_mask`` to the value of                                                                                                                                                                           |
|                                                                               |            |                 | standalone_network_plugin_gateway``. In this case, the broadcast, network, and gateway addresses are automatically excluded.                                                                                                                                                                                       |                               |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``standalone_network_plugin_ip_version```                                     | Optional   | 4               | Specify the IP version for the network that should be configured on the data LIF through which the share is exported. Valid values are ``4`` or ``6``.                                                                                                                                                                                             |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``standalone_network_plugin_network_type``                                    | Optional   | flat            | Specify the network type as one of ``flat`` or ``vlan``. If unspecified, the driver assumes the network is non-segmented. If using ``vlan``, specify the ``standalone_network_plugin_segmentation_id`` option as well.                                                                                                                             |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Configuration options for Standalone Network Plugin
