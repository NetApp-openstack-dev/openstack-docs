.. _manila_network_plugin_overview:

Deployment Choice: Manila Network Plugin
========================================

.. warning::

   The NetApp driver only supports provisioning share servers (ONTAP
   SVMs) on non-segmented (FLAT) networks and VLAN networks. While
   tenants may be deployed on overlay networks (GRE, VXLAN, GENEVE),
   Manila shares are only accessible over FLAT networks or VLAN
   networks.

   Your deployment options are:

   - **Overlay tenant network + Provider Network**: Deploy nova instances
     within a VXLAN tenant network dedicated to the tenant, but access file
     shares over a FLAT or VLAN shared provider network.
   - **VLAN tenant network**: In this case, tenant networks are VLAN
     networks. In this case, the networking service assigns a new VLAN segment when
     a tenant creates a private network. This dedicated private
     network can be used to deploy the tenant's Nova instances as well
     as access their file shares.

Neutron Overview
----------------

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

Network Types
-------------

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

Network Segmentation
--------------------

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

Network Plugins
---------------

As described in :ref:`figure-6.2`, there are a set of network plugins
that provide for a variety of integration approaches with Neutron and
Standalone networks. These plugins should only be used with the NetApp
clustered Data ONTAP driver when using share server management.

These are the valid network plugins:

-  :ref:`Standalone Network Plugin:<standalone_network_plugin>`
   Use this plugin in stand-alone deployments of OpenStack Manila,
   and in deployments where you don't desire to manage the storage
   network with Neutron.

-  :ref:`Simple Neutron Network Plugin:<simple_neutron_network_plugin>`
   This is like the Standalone Network Plugin, except that the network
   is managed by Neutron.

-  :ref:`Configurable Neutron Network Plugin:
   <configurable_neutron_network_plugin>` This is like the Simple
   Network Neutron Plugin except that except that each share network
   object will use a tenant or provider network of the tenant's
   choice.

-  :ref:`Simple Neutron Port Binding Network Plugin:
   <simple_neutron_port_binding_network_plugin>`
   This plugin is very similar to the simple Neutron network
   plugin, the only difference is that this plugin can enforce
   port-binding.

-  :ref:`Configurable Neutron Port Binding Network Plugin:
   <configurable_neutron_port_binding_network_plugin>`
   This plugin is very similar to the configurable neutron
   network plugin, the only difference is that this plugin
   can enforce port-binding.


The network plugin is chosen by setting the value of the network_api_class
configuration option within the driver-specific stanza of the manila.conf
configuration file.
