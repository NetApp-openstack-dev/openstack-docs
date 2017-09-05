.. _configurable_neutron_network_plugin:

Manila Network Plugins: Configurable Neutron Network Plugin
===========================================================

*Configurable Neutron Network Plugin*: This is like the Simple
Network Neutron Plugin except that each share network
object will use a tenant or provider network of the tenant's choice.
Please keep in mind that provider networks are created by OpenStack
administrators. For each tenant created share network, the NetApp
driver will create a new Vserver with the segmentation protocol, IP
address, netmask, protocol, MTU and gateway obtained from Neutron. The
NetApp driver only supports provisioning Vservers on non-segmented
FLAT) networks and VLAN networks.

Tenants *must* specify Neutron network information when creating
share network objects. Manila will derive values for segmentation
protocol, IP address, netmask and gateway from Neutron when creating
a new share server.

Table: Configuration options for Neutron Network Plugin

In this configuration, tenants can specify network details in their own
share network objects. These network details can be from administrator
created Neutron provider networks or tenant created Neutron networks. To
set up the configurable Neutron network plugin, the following options
should be added to the driver-specific stanza within the Manila
configuration file (``manila.conf``):

::

    network_api_class = manila.network.neutron.neutron_network_plugin.NeutronNetworkPlugin
