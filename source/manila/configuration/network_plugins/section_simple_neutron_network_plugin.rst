.. _simple_neutron_network_plugin:

Manila Network Plugins: Simple Neutron Network Plugin
-----------------------------------------------------

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
