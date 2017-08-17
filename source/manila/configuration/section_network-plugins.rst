Manila Network Plugins
----------------------

.. warning::

   The NetApp driver only supports provisioning share servers (ONTAP
   SVMs) on non-segmented (FLAT) networks and VLAN networks. While
   tenants may be deployed on overlay networks (GRE, VXLAN, GENEVE),
   Manila shares are only accessible over FLAT networks or VLAN
   networks.

   Your options are:

   - **Overlay tenant network + Provider Network**: Deploy nova instances
     within a VXLAN tenant network dedicated to the tenant access file
     shares over a FLAT or VLAN shared provider network.
   - **VLAN tenant network**: In this case, tenant networks are VLAN 
     networks. The networking service assigns a new VLAN segment when
     a tenant creates a private network. This dedicated private
     network can be used to deploy the tenant's Nova instances as well
     as access their file shares.

.. note::

   OpenStack's networking-as-a-service project is codenamed Neutron.
   Neutron offers self service networking APIs to tenants. Tenant
   networks are typically segmented virtual networks that are isolated
   between each other and provide east-west network routing within the
   OpenStack installation. For packets to flow into external networks,
   including the internet, routers are created and attached to the
   indicated networks as necessary. For in-flow, Network Address
   Translation (NAT) is employed and IP addresses in the tenant router
   namespace are mapped to IP addresses in the external network
   namespace.

   Aside from tenant networks, administrators can create "provider"
   networks on Neutron, and share them with their OpenStack tenants.
   Such networks can either be segmented or non-segmented (FLAT). On a
   FLAT network, everyone shares the same network segment and hence
   there isn't any isolation of network traffic. There's usually a very
   good reason to use FLAT networks in OpenStack, such as sharing a
   dedicated high bandwidth storage network with all tenants. In such
   scenarios, network traffic is usually encrypted end-to-end providing
   logical isolation of cross tenant traffic. Overlapping IP and subnet
   ranges is not possible in this networking model.

   Network segmentation is often accomplished using (VLANs).
   Administrators may allow tenants to create VLAN networks. In this
   case, each tenant network is assigned its own VLAN ID, and cross
   tenant traffic is isolated at layer-2. Subnets and IP ranges are
   allowed to safely overlap between tenant networks when the tenant
   networks are isolated in separate VLANs. OVS (Open vSwitch) has an
   ML2 plugin in Neutron that allocates internal VLANs on each compute
   host. OVS creates the tunnel bridges necessary to route packets
   between these VLAN networks. When combined with a hardware plugin
   such as the Cisco Nexus plugin, VLANs are allocated on the external
   hardware as well. Typically storage devices like NetApp ONTAP
   Fabric-Attached Storage (FAS) are configured on these hardware
   devices in a trunk configuration. VLANs are then created and managed
   with the help of the hardware switch vendor's ML2 plugin mechanism
   driver in Neutron.

   Keep in mind that VLANs are limited to the range of 1 to 4094. When
   using VLANs, no more than 4092 isolated networks can exist. Keep
   this scaling limitation in mind when designing your Openstack
   environment. Other encapsulation methodologies aim to solve this
   problem by encapsulating network packets with a larger virtual
   networking identifier. GRE (Generic Routing Encapsulation), GENEVE
   (Generic Network Virtualization Encapsulation) and VXLAN (Virtual
   Extensible LAN) are the popular standards used with OpenStack
   deployments.

   ONTAP does not natively support these layer-3 SDN network standards.    
   Deployers have the choice of using administrator configured
   VLAN-only provider networks or VLAN-only tenant networks if using
   Neutron.

As described in `??? <#manila.create_share_workflow.share_servers>`__,
there are a set of network plugins that provide for a variety of
integration approaches with Neutron and Standalone networks. These
plugins should only be used with the NetApp clustered Data ONTAP driver
when using share server management.

These are the valid network plugins:

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

-  *Simple Neutron Network Plugin*: This is like the Standalone Network
   Plugin, except that the network is managed by Neutron. Typically,
   data center administrators that own a dedicated storage network would
   want to manage such a network via Neutron so that virtual machines
   can have access to storage resources on the storage network. In this
   use case, an administrator creates a dedicated Neutron network and
   provides the network details in the backend stanza of ``manila.conf``
   providing the network ID and subnet ID. Note that you may only use
   FLAT or VLAN networks with the NetApp driver.

   Tenants *must not* specify Neutron network information when creating
   share network objects. Manila will derive values for segmentation
   protocol, IP address, netmask and gateway from Neutron when creating
   a new share server.

-  *Configurable Neutron Network Plugin*: This is like the Simple
   Network Neutron Plugin except that except that each share network
   object will use a tenant or provider network of the tenant's choice.
   Please keep in mind that provider networks are created by OpenStack
   administrators. For each tenant created share network, the NetApp
   driver will create a new Vserver with the segmentation protocol, IP
   address, netmask, protocol, and gateway obtained from Neutron. The
   NetApp driver only supports provisioning Vservers on non-segmented
   (FLAT) networks and VLAN networks.

   Tenants *must* specify Neutron network information when creating
   share network objects. Manila will derive values for segmentation
   protocol, IP address, netmask and gateway from Neutron when creating
   a new share server.

-  *Simple Neutron Port Binding Network Plugin*: This plugin is very
   similar to the simple Neutron network plugin, the only difference is
   that this plugin can enforce port-binding. Port binding profiles from
   the manila configuration file are sent to Neutron at the time of
   creating network ports for the purpose of creating ONTAP LIFs. This
   allows network agents to bind the ports based off these profiles.
   When using multiple top of the rack switches to connect different
   compute nodes, this plugin is also capable of performing Hierarchical
   Port Binding. Administrators would configure the VLAN-only neutron
   network to use in the backend stanza of the ``manila.conf`` and
   tenants must create their own share network objects to allow the
   NetApp driver to create VServers connected to this network.

   Tenants *must not* specify Neutron network information when creating
   share network objects. Manila will derive values for segmentation
   protocol, IP address, netmask and gateway from Neutron when creating
   a new share server.

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

.. figure:: ../../images/manila_hierarchical_port_binding.png
   :alt: Hierarchical Network Topology
   :width: 2.75000in

   Hierarchical Network Topology

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

In this configuration, administrators set up a single neutron network
and specify the network information in ``manila.conf``. Manila will create 
network ports on the network and gather details regarding the IP address,
gateway, netmask and MTU from this network. These details are used by the
NetApp driver to create Data Logical Interfaces (LIFs) for the SVM
created. In this configuration, tenants need to create "empty" share network
objects, without specifying any network information. To set up the
simple Neutron network plugin, the following options should be added to
the driver-specific stanza within the Manila configuration file
(``manila.conf``):

::

                        network_api_class = manila.network.neutron.neutron_network_plugin.NeutronSingleNetworkPlugin
                        neutron_net_id = 37fb9f7e-4ffe-4900-8dba-c6d4251e588e
                        neutron_subnet_id= 447732be-4cf2-42b0-83dc-4b6f4ed5368c
                    

`table\_title <#manila.configuration.network.neutron.options>`__ lists
the configuration options available for the Neutron network plugin:

+-------------------------+------------+-----------------+---------------------------------------------------------------------------+
| Option                  | Type       | Default Value   | Description                                                               |
+=========================+============+=================+===========================================================================+
| ``neutron_net_id``      | Required   |                 | Specify the ID of a Neutron network from which ports should be created.   |
+-------------------------+------------+-----------------+---------------------------------------------------------------------------+
| ``neutron_subnet_id``   | Required   |                 | Specify the ID of a Neutron subnet from which ports should be created.    |
+-------------------------+------------+-----------------+---------------------------------------------------------------------------+

Table: Configuration options for Neutron Network Plugin

In this configuration, tenants can specify network details in their own
share network objects. These network details can be from administrator
created Neutron provider networks or tenant created Neutron networks. To
set up the configurable Neutron network plugin, the following options
should be added to the driver-specific stanza within the Manila
configuration file (``manila.conf``):

::

                        network_api_class = manila.network.neutron.neutron_network_plugin.NeutronNetworkPlugin
                    

In this configuration, administrators set up a single neutron network,
and Manila will send any binding profiles configured in ``manila.conf``
to Neutron while creating ports on the network. As noted prior, Neutron
may be configured with a hardware switch to provide tenant networks with
access to devices connected to the hardware switch. You may use the
switch vendor's ML2 mechanism driver to dynamically allocate segments
corresponding to the segments created on the OpenStack compute hosts by
OVS. This port binding network plugin is crucial to ensure that port
binding occurs at the mechanism driver. Verify with your switch vendor
if they support binding profiles. While most vendors support port
binding, some may not support the "baremetal" vnic\_type. Use of this
plugin is preferable when using a hierarchical virtual network that uses
different network segments. These segments can be of different network
types (ex: VLAN within the rack and VXLAN between the top-of-rack and
core switches). To set up the simple Neutron port binding network
plugin, the following options should be added to the driver-specific
stanza within the Manila configuration file (``manila.conf``). The
Neutron binding profile in this example is for a Cisco Nexus 9000
switch:

::

                        network_api_class = manila.network.neutron.neutron_network_plugin.NeutronBindSingleNetworkPlugin
                        neutron_net_id = 37fb9f7e-4ffe-4900-8dba-c6d4251e588e
                        neutron_subnet_id = 447732be-4cf2-42b0-83dc-4b6f4ed5368c
                        neutron_host_id = netapp_lab42
                        neutron_vnic_type = baremetal
                        neutron_binding_profiles = phys1

                        [phys1]
                        neutron_switch_id = 10.63.152.254
                        neutron_port_id = 1/1-4
                        neutron_switch_info = switch_ip:10.63.152.254
                    

`table\_title <#manila.configuration.network.simple_neutron_bind.options>`__
lists the configuration options available for the Simple Neutron Port
Binding network plugin:

+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                         | Type       | Default Value               | Description                                                                                                                                                           |
+================================+============+=============================+=======================================================================================================================================================================+
| ``neutron_net_id``             | Required   |                             | Specify the ID of a Neutron network from which ports should be created.                                                                                               |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``neutron_subnet_id``          | Required   |                             | Specify the ID of a Neutron subnet from which ports should be created.                                                                                                |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``neutron_host_id``            | Optional   | Perceived system hostname   | Hostname of the node where the manila-share service is running, configured with the NetApp backend.                                                                   |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``neutron_vnic_type``          | Optional   | baremetal                   | Virtual NIC type for the ports created by Neutron on this network. Supported type is "baremetal"                                                                      |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``neutron_binding_profiles``   | Optional   |                             | Comma separated list of binding profile sections. Each of these sections can contain specific switch information and they can be shared amongst different backends.   |
+--------------------------------+------------+-----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Configuration options for Simple Neutron Port Binding Network
Plugin

In spirit this plugin works exactly like the Simple Neutron Port Binding
Network Plugin that is mentioned above. The only difference being that
the Neutron network is not configured within ``manila.conf`` by the 
administrator. Use of this plugin allows Manila to derive network information 
from the Share Network objects created by the tenants. To set up the configurable 
Neutron port binding network plugin, the following options should be added to 
the driver-specific stanza within the Manila configuration file (``manila.conf``). 
The Neutron binding profile in this example is for a Cisco Nexus 9000 switch:

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
