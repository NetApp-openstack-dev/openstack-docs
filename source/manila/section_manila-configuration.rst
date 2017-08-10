Configuration
=============

Manila
------

Manila is configured by changing the contents of the ``manila.conf``
file and restarting all of the Manila processes. Depending on the
OpenStack distribution used, this may require issuing commands such as
``service openstack-manila-api restart`` or
``service manila-api restart``.

The ``manila.conf`` file contains a set of configuration options (one
per line), specified as ``option_name``\ =value. Configuration options
are grouped together into a stanza, denoted by ``[stanza_name]``. There
must be at least one stanza named ``[DEFAULT]`` that contains
configuration parameters that apply generically to Manila (and not to
any particular backend). Configuration options that are associated with
a particular Manila backend should be placed in a separate stanza.

    **Note**

    While it is possible to specify driver-specific configuration
    options within the ``[DEFAULT]`` stanza, you are unable to define
    multiple Manila backends within the ``[DEFAULT]`` stanza. NetApp
    strongly recommends that you specify driver-specific configuration
    in separate named stanzas, being sure to list the backends that
    should be enabled as the value for the configuration option
    ``enabled_share_backends``; for example:

    ::

        enabled_share_backends=clusterOne,clusterTwo
                        

    The ``enabled_share_backends`` option should be specified within the
    ``[DEFAULT]`` configuration stanza.

Manila Network Plugins
----------------------

    **Caution**

    The NetApp driver only supports provisioning share servers (ONTAP
    Vservers) on non-segmented (FLAT) networks and VLAN networks. While
    tenants may be deployed on overlay networks (GRE, VXLAN, GENEVE),
    Manila shares are only accessible over FLAT networks or VLAN
    networks.

    Your options are:

    -  *Overlay tenant network + Provider Network*: Deploy nova
       instances within a VXLAN tenant network dedicated to the tenant,
       access file shares over a FLAT or VLAN shared provider network.

    -  *VLAN tenant network*: In this case, tenant networks are VLAN
       networks. The networking service assigns a new VLAN segment when
       a tenant creates a private network. This dedicated private
       network can be used to deploy the tenant's Nova instances as well
       as access their file shares.

    **Note**

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

.. figure:: ../images/manila_hierarchical_port_binding.png
   :alt: Hierarchical Network Topology
   :width: 2.75000in

   Hierarchical Network Topology

The network plugin is chosen by setting the value of the ``
            network_api_class
        `` configuration option within the driver-specific stanza of the
``
            manila.conf
        `` configuration file.

To set up the standalone network plugin, the following options should be
added to the driver-specific stanza within the Manila configuration file
(``manila.conf``):

::

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
| ``standalone_network_plugin_segmentation_id                                   | Optional   |                 | Specify the segmentation ID that should be assigned to data LIFs through which shares can be exported. This option is not necessary if the ``standalone_network_plugin_network_type                                                                                                                                                                |
|                             ``                                                |            |                 |                             `` is set to ``flat``.                                                                                                                                                                                                                                                                                                 |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``                                                                            | Optional   |                 | Specify the range of IP addresses that can be used on data LIFs through which shares can be exported. An example of a valid range would be ``10.0.0.10-10.0.0.254``. If this value is not specified, the entire range of IP addresses within the network computed by applying the value of ``standalone_network_plugin_mask`` to the value of ``   |
|                                 standalone_network_plugin_allowed_ip_ranges   |            |                 |                                 standalone_network_plugin_gateway``. In this case, the broadcast, network, and gateway addresses are automatically excluded.                                                                                                                                                                                       |
|                             ``                                                |            |                 |                                                                                                                                                                                                                                                                                                                                                    |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``standalone_network_plugin_ip_version                                        | Optional   | 4               | Specify the IP version for the network that should be configured on the data LIF through which the share is exported. Valid values are ``4`` or ``6``.                                                                                                                                                                                             |
|                             ``                                                |            |                 |                                                                                                                                                                                                                                                                                                                                                    |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``standalone_network_plugin_network_type                                      | Optional   | flat            | Specify the network type as one of ``flat`` or ``vlan``. If unspecified, the driver assumes the network is non-segmented. If using ``vlan``, specify the ``standalone_network_plugin_segmentation_id                                                                                                                                               |
|                             ``                                                |            |                 |                             `` option as well.                                                                                                                                                                                                                                                                                                     |
+-------------------------------------------------------------------------------+------------+-----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Configuration options for Standalone Network Plugin

In this configuration, administrators set up a single neutron network
and specify the network information in ``
                manila.conf``. Manila will create network ports on the
network and gather details regarding the IP address, gateway, netmask
and MTU from this network. These details are used by the NetApp driver
to create Data Logical Interfaces (LIFs) for the Vserver created. In
this configuration, tenants need to create "empty" share network
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
the Neutron network is not configured within ``
                manila.conf
            `` by the administrator. Use of this plugin allows Manila to
derive network information from the Share Network objects created by the
tenants. To set up the configurable Neutron port binding network plugin,
the following options should be added to the driver-specific stanza
within the Manila configuration file (``manila.conf``). The Neutron
binding profile in this example is for a Cisco Nexus 9000 switch:

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

NetApp Data ONTAP Drivers for OpenStack File Share Storage (Manila)
-------------------------------------------------------------------

NetApp's Manila drivers for clustered Data ONTAP (with or without the
management of share servers) are offered in a single, unified driver.

NetApp’s contribution strategy involves adding all new capabilities
directly into the upstream OpenStack Shared File System service
repositories, so all the features are available regardless of which
distribution you choose when deploying OpenStack. Bug fixes are
delivered into the appropriate branches that represent the different
releases of OpenStack (e.g. ``trunk``, ``stable/juno``,
``stable/icehouse``, etc).

On occasion, it may be necessary for NetApp to deliver capability to a
previous release of OpenStack that can not be accepted in the upstream
OpenStack repositories. In that case, we post the capability at the
NetApp Github repository - accessible at
https://github.com/NetApp/manila. Be sure to choose the branch from this
repository that matches the release version of OpenStack you are
deploying with. There will be a ``README`` file in the root of the
repository that describes the specific changes that are merged into that
repository beyond what is available in the upstream repository.

A variety of OpenStack file share storage deployment options for NetApp
clustered Data ONTAP based systems are available in the Kilo OpenStack
release and involve making deployment choices between the presence or
absence of management of share servers (SVM or Vservers) by the driver.

The following lists all of the individual options and subsequent
sections are intended to offer guidance on which configuration options
ought to be employed given varying use cases:

-  `NetApp clustered Data ONTAP without share server
   management <#manila.cdot.single_svm.configuration>`__

-  `NetApp clustered Data ONTAP with share server
   management <#manila.cdot.multi_svm.configuration>`__

NetApp Unified Driver for Clustered Data ONTAP without Share Server management
------------------------------------------------------------------------------

The NetApp unified driver for clustered Data ONTAP without share server
management is a driver interface from OpenStack Manila to NetApp
clustered Data ONTAP storage controllers to accomplish provisioning and
management of shared file systems within the scope of a single SVM
(Vserver).

To set up the NetApp clustered Data ONTAP driver without Share Server
management, the following stanza should be added to the Manila
configuration file (``manila.conf``):

::

    [cdotSingleSVM] 
    share_backend_name=cdotSingleSVM
    share_driver = manila.share.drivers.netapp.common.NetAppDriver
    driver_handles_share_servers=False 
    netapp_storage_family=ontap_cluster
    netapp_server_hostname=hostname
    netapp_server_port=80
    netapp_login=admin_username
    netapp_password=admin_password
    netapp_vserver=svm_name
    netapp_transport_type=https
    netapp_aggregate_name_search_pattern=^((?!aggr0).)*$
                

-  Be sure that the value of the ``enabled_share_backends`` option in
   the ``[DEFAULT]`` stanza includes the name of the stanza you chose
   for the backend.

-  The value of ``driver_handles_share_servers`` **MUST** be set to
   ``False`` if you want the driver to operate without managing share
   servers.

`table\_title <#manila.cdot.single_svm.options>`__ lists the
configuration options available for the unified driver for a clustered
Data ONTAP deployment that does not manage share servers.

+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                                       | Type       | Default Value                                     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
+==============================================+============+===================================================+=====================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================+
| ``share_backend_name``                       | Required   |                                                   | The name used by Manila to refer to the Manila backend                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``share_driver``                             | Required   | manila.share.drivers.generic.GenericShareDriver   | Set the value to manila.share.drivers.netapp.common.NetAppDriver                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``driver_handles_share_servers``             | Required   |                                                   | Denotes whether the driver should handle the responsibility of managing share servers. This must be set to ``false`` if the driver is to operate without managing share servers.                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_server_hostname``                   | Required   |                                                   | The hostname or IP address for the storage system or proxy server. *The value of this option should be the IP address of either the cluster management LIF or the SVM management LIF.*                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_server_port``                       | Optional   |                                                   | The TCP port to use for communication with the storage system or proxy server. If not specified, Data ONTAP drivers will use 80 for HTTP and 443 for HTTPS.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_login``                             | Required   |                                                   | Administrative user account name used to access the storage system.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_password``                          | Required   |                                                   | Password for the administrative user account specified in the ``netapp_login`` option.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_transport_type``                    | Required   | ``http``                                          | Transport protocol for communicating with the storage system or proxy server. Valid options include ``http`` and ``https``.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_vserver``                           | Required   |                                                   | This option specifies the storage virtual machine (previously called a Vserver) name on the storage cluster on which provisioning of shared file systems should occur. This parameter is required if the driver is to operate without managing share servers (that is, be limited to the scope of a single SVM).                                                                                                                                                                                                                                                                                                                    |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_storage_family``                    | Required   | ``ontap_cluster``                                 | The storage family type used on the storage system; valid values are ``ontap_cluster`` for clustered Data ONTAP.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_volume_name_template``              | Optional   | ``share_%(share_id)s``                            | This option specifies a string replacement template that is applied when naming FlexVol volumes that are created as a result of provisioning requests.                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_volume_snapshot_reserve_percent``   | Optional   | ``5``                                             | This option specifies the percentage of share space set aside as reserve for snapshot usage. Valid values range from 0 to 90.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_aggregate_name_search_pattern``     | Optional   | ``(.*)``                                          | This option specifies a regular expression that is applied against all available aggregates related to the SVM specified in the ``netapp_vserver`` option. This filtered list will be reported to the Manila scheduler as valid pools for provisioning new shares.                                                                                                                                                                                                                                                                                                                                                                  |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``replication_domain``                       | Optional   |                                                   | This option specifies a string to identify a replication domain. Manila will allow all backends with the same replication domain to replicate to each other. If this is left blank, the backend will not support replication. If provided, all backends within the replication domain should have their configuration stanzas included in the backends configuration file. See `??? <#manila.examples.manila_conf.single_svm.replication>`__ for examples. Ensure all ONTAP clusters and SVMs within the replication domain are peered and have intercluster LIFs configured. See `section\_title <#manila.fas.configuration>`__.   |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_trace_flags``                       | Optional   |                                                   | This option is a comma-separated list of options (valid values include ``method`` and ``api``) that controls which trace info is written to the Manila logs when the debug level is set to ``True``.                                                                                                                                                                                                                                                                                                                                                                                                                                |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``migration_driver_continue_interval``       | Optional   | 60                                                | This option specifies the time interval in seconds at which Manila polls the backend for the progress and health of an ongoing migration.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
+----------------------------------------------+------------+---------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Configuration options for clustered Data ONTAP without Share
Server management

    **Caution**

    If you specify an account in the ``netapp_login`` option that only
    has SVM administration privileges (rather than cluster
    administration privileges), some advanced features of the NetApp
    unified driver will not work and you may see warnings in the Manila
    logs. See `simplesect\_title <#manila.cdot.account_permissions>`__
    for more details on the required access level permissions for an SVM
    admin account.

NetApp Unified Driver for Clustered Data ONTAP with Share Server management
---------------------------------------------------------------------------

The NetApp unified driver for clustered Data ONTAP with share server
management is a driver interface from OpenStack Manila to NetApp
clustered Data ONTAP storage controllers to accomplish provisioning and
management of shared file systems across the scope of the entire
cluster. This driver will create a new storage virtual machine (SVM) for
each share server that is requested by the Manila service. This driver
also creates new data logical interfaces (LIFs) that provide access for
clients on a specific share network to access shared file systems
exported from the share server.

    **Caution**

    An account with cluster administrator privileges must be used with
    the ``netapp_login`` option when using Share Server management.
    Share Server management creates SVMs, thus SVM administrator
    privileges are insufficient.

To set up the NetApp clustered Data ONTAP driver with Share Server
management, the following stanza should be added to the Manila
configuration file (``manila.conf``):

::

    [cdotMultipleSVM] 
    share_backend_name=cdotMultipleSVM
    share_driver=manila.share.drivers.netapp.common.NetAppDriver
    driver_handles_share_servers=True 
    netapp_storage_family=ontap_cluster
    netapp_server_hostname=hostname
    netapp_server_port=80
    netapp_login=admin_username
    netapp_password=admin_password
    netapp_transport_type=https
    netapp_root_volume_aggregate=aggr1
    netapp_aggregate_name_search_pattern=^((?!aggr0).)*$
                

-  Be sure that the value of the ``enabled_share_backends`` option in
   the ``[DEFAULT]`` stanza includes the name of the stanza you chose
   for the backend.

-  The value of ``driver_handles_share_servers`` **MUST** be set to
   ``True`` if you want the driver to manage share servers.

`table\_title <#manila.cdot.multi_svm.options>`__ lists the
configuration options available for the unified driver for a clustered
Data ONTAP deployment that manages share servers.

+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                                       | Type       | Default Value                                     | Description                                                                                                                                                                                            |
+==============================================+============+===================================================+========================================================================================================================================================================================================+
| ``share_backend_name``                       | Required   |                                                   | The name used by Manila to refer to the Manila backend                                                                                                                                                 |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``share_driver``                             | Required   | manila.share.drivers.generic.GenericShareDriver   | Set the value to manila.share.drivers.netapp.common.NetAppDriver                                                                                                                                       |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``driver_handles_share_servers``             | Required   |                                                   | Denotes whether the driver should handle the responsibility of managing share servers. This must be set to ``true`` if the driver is to manage share servers.                                          |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_server_hostname``                   | Required   |                                                   | The hostname or IP address for the storage system or proxy server. *The value of this option should be the IP address of the cluster management LIF.*                                                  |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_server_port``                       | Optional   |                                                   | The TCP port to use for communication with the storage system or proxy server. If not specified, Data ONTAP drivers will use 80 for HTTP and 443 for HTTPS.                                            |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_login``                             | Required   |                                                   | Administrative user account name used to access the storage system.                                                                                                                                    |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_password``                          | Required   |                                                   | Password for the administrative user account specified in the ``netapp_login`` option.                                                                                                                 |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_transport_type``                    | Required   | ``http``                                          | Transport protocol for communicating with the storage system or proxy server. Valid options include ``http`` and ``https``.                                                                            |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_storage_family``                    | Required   | ``ontap_cluster``                                 | The storage family type used on the storage system; valid values are ``ontap_cluster`` for clustered Data ONTAP.                                                                                       |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_root_volume_aggregate``             | Required   |                                                   | This option specifies name of the aggregate upon which the root volume should be placed when a new SVM is created to correspond to a Manila share server.                                              |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_root_volume_name``                  | Optional   | ``root``                                          | This option specifies name of the root volume that will be created when a new SVM is created to correspond to a Manila share server.                                                                   |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_vserver_name_template``             | Optional   | ``os_%s``                                         | This option specifies a string replacement template that is applied when naming SVMs that are created to correspond to a Manila share server.                                                          |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_lif_name_template``                 | Optional   | ``os_%(net_allocation_id)s``                      | This option specifies a string replacement template that is applied when naming data LIFs that are created as a result of provisioning requests.                                                       |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_volume_name_template``              | Optional   | ``share_%(share_id)s``                            | This option specifies a string replacement template that is applied when naming FlexVol volumes that are created as a result of provisioning requests.                                                 |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_volume_snapshot_reserve_percent``   | Optional   | ``5``                                             | This option specifies the percentage of share space set aside as reserve for snapshot usage. Valid values range from 0 to 90.                                                                          |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_aggregate_name_search_pattern``     | Optional   | ``(.*)``                                          | This option specifies a regular expression that is applied against all available aggregates. This filtered list will be reported to the Manila scheduler as valid pools for provisioning new shares.   |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_port_name_search_pattern``          | Optional   | ``(.*)``                                          | This option allows you to specify a regular expression for overriding the selection of network ports on which to create Vserver LIFs.                                                                  |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_enabled_share_protocols``           | Optional   | ``nfs3,nfs4.0``                                   | This option specifies the NFS protocol versions that will be enabled on new SVMs created by the driver. Valid values include nfs3, nfs4.0, nfs4.1.                                                     |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_trace_flags``                       | Optional   |                                                   | This option is a comma-separated list of options (valid values include ``method`` and ``api``) that controls which trace info is written to the Manila logs when the debug level is set to ``True``.   |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``migration_driver_continue_interval``       | Optional   | 60                                                | This option specifies the time interval in seconds at which Manila polls the backend for the progress and health of an ongoing migration.                                                              |
+----------------------------------------------+------------+---------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Configuration options for clustered Data ONTAP with Share Server
management

    **Caution**

    When defining Neutron subnets (Liberty or prior) with Clustered Data
    ONTAP, overlapping IP ranges should not be allowed. Using
    overlapping IP ranges in Neutron can cause a failure when a new
    Share Server is created.

Data ONTAP Configuration
------------------------

The prerequisites for Data ONTAP are:

-  The driver requires a storage controller running Clustered Data ONTAP
   8.2 or later.

-  The storage system should have the following licenses applied:

   -  Base

   -  NFS (if the NFS storage protocol is to be used)

   -  CIFS (if the CIFS/SMB storage protocol is to be used)

   -  SnapMirror (if share replication is to be enabled)

   -  FlexClone

When using the NetApp Manila driver in the mode where it does not manage
share servers, it is important to pay attention to the following
considerations:

1. Ensure the appropriate licenses (as described previously) are enabled
   on the storage system for the desired use case.

2. The SVM referenced in the ``netapp_vserver`` option must be created
   (and associated with aggregates) before it can be utilized as a
   provisioning target for Manila.

3. Data LIFs must be created and assigned to SVMs before configuring
   Manila.

4. If NFS is used as the storage protocol:

   1. Be sure to enable the NFS service on the SVM.

   2. Be sure to enable the desired version of the NFS protocol (e.g.
      ``v4.0, v4.1-pnfs``) on the SVM.

5. If CIFS is used as the storage protocol:

   1. Be sure to enable the CIFS service on the SVM.

   2. Be sure to set CIFS as the data protocol on the data LIF.

6. In order to support share replication:

   1. Ensure all ONTAP clusters with the same ``replication_domain`` are
      peered, have intercluster LIFs configured, and are of equal ONTAP
      versions.

   2. Ensure all SVMs with the same ``replication_domain`` are peered
      and have unique names.

   3. For more information about ONTAP data protection, please see the
      `ONTAP 8 Product
      Documentation <https://mysupport.netapp.com/documentation/productlibrary/index.html?productID=30092>`__.

When configuring NetApp's Manila drivers to interact with a clustered
Data ONTAP instance, it is important to choose the correct
administrative credentials to use. While an account with cluster-level
administrative permissions is normally utilized, it is possible to use
an account with reduced scope that has the appropriate privileges
granted to it. In order to use an SVM-scoped account with the Manila
driver and clustered Data ONTAP and have access to the full set of
features (including Manila Share Type Extra Specs support) availed by
the Manila driver, be sure to add the access levels for the commands
shown in `table\_title <#manila.cdot.permissions.common>`__,
`table\_title <#manila.cdot.permissions.with_share_server>`__, and
`table\_title <#manila.cdot.permissions.without_share_server.cluster_scoped>`__.

+-----------------------------+----------------+
| Command                     | Access Level   |
+=============================+================+
| ``cifs share``              | ``all``        |
+-----------------------------+----------------+
| ``event``                   | ``all``        |
+-----------------------------+----------------+
| ``network interface``       | ``readonly``   |
+-----------------------------+----------------+
| ``vserver export-policy``   | ``all``        |
+-----------------------------+----------------+
| ``volume snapshot``         | ``all``        |
+-----------------------------+----------------+
| ``version``                 | ``readonly``   |
+-----------------------------+----------------+
| ``system node``             | ``readonly``   |
+-----------------------------+----------------+
| ``version``                 | ``readonly``   |
+-----------------------------+----------------+
| ``volume``                  | ``all``        |
+-----------------------------+----------------+
| ``vserver``                 | ``readonly``   |
+-----------------------------+----------------+
| ``security``                | ``readonly``   |
+-----------------------------+----------------+

Table: Common Access Level Permissions Required with Any Manila Driver

+-------------------------+----------------+
| Command                 | Access Level   |
+=========================+================+
| ``cifs create``         | ``all``        |
+-------------------------+----------------+
| ``cifs delete``         | ``all``        |
+-------------------------+----------------+
| ``kerberos-config``     | ``all``        |
+-------------------------+----------------+
| ``kerberos-realm``      | ``all``        |
+-------------------------+----------------+
| ``ldap client``         | ``all``        |
+-------------------------+----------------+
| ``ldap create``         | ``all``        |
+-------------------------+----------------+
| ``license``             | ``readonly``   |
+-------------------------+----------------+
| ``dns create``          | ``all``        |
+-------------------------+----------------+
| ``network interface``   | ``all``        |
+-------------------------+----------------+
| ``network port``        | ``readonly``   |
+-------------------------+----------------+
| ``network port vlan``   | ``all``        |
+-------------------------+----------------+
| ``vserver``             | ``all``        |
+-------------------------+----------------+

Table: Access Level Permissions Required For Manila Driver for clustered
Data ONTAP with share server management - with Cluster-wide
Administrative Account

+-------------------------+----------------+
| Command                 | Access Level   |
+=========================+================+
| ``license``             | ``readonly``   |
+-------------------------+----------------+
| ``storage aggregate``   | ``readonly``   |
+-------------------------+----------------+
| ``storage disk``        | ``readonly``   |
+-------------------------+----------------+

Table: Access Level Permissions Required For Manila Driver for clustered
Data ONTAP without share server management - with Cluster-wide
Administrative Account

**Creating Role for Cluster-Scoped Account.**

To create a role with the necessary privileges required, with access via
ONTAP API only, use the following command syntax to create the role and
the cDOT ONTAP user:

1. Create role with appropriate command directory permissions (note you
   will need to execute this command for each of the required access
   levels as described in the earlier tables).

   ::

       security login role create –role openstack –cmddirname [required command from earlier tables] -access [Required Access Level]
                               

2. Command to create user with appropriate role

   ::

       security login create –username openstack –application ontapi –authmethod password –role openstack
                               

**Creating Role for SVM-Scoped Account.**

To create a role with the necessary privileges required, with access via
ONTAP API only, use the following command syntax to create the role and
the cDOT ONTAP user:

1. Create role with appropriate command directory permissions (note you
   will need to execute this command for each of the required access
   levels as described in the earlier tables).

   ::

       security login role create –role openstack -vserver [vserver_name] –cmddirname [required command from earlier tables] -access [Required Access Level]
                               

2. Command to create user with appropriate role

   ::

       security login create –username openstack –application ontapi –authmethod password –role openstack -vserver [vserver_name]
                               

    **Tip**

    For more information on how to grant access level permissions to a
    role, and then assign the role to an administrative account, please
    refer to the `System Administration Guide for Cluster
    Administrators <http://support.netapp.com>`__ document in the
    Clustered DATA ONTAP documentation.

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the Data LIF interfaces from Data ONTAP.

2. LIF assignment
