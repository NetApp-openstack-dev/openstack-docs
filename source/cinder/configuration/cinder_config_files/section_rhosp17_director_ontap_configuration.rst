Deploying NetApp ONTAP Cinder driver in a Red Hat OpenStack Platform 17 and 17.1
================================================================================

.. _ontap-ontap-rhosp17:

Overview
--------

This guide shows how to configure and deploy NetApp ONTAP Cinder driver in a
**Red Hat OpenStack Platform (RHOSP) 17** Overcloud and **Red Hat OpenStack Platform (RHOSP) 17.1**
Overcloud using RHOSP Director. After reading this, you'll be able to define the proper environment files and
deploy single or multiple ONTAP Cinder back ends in RHOSP Overcloud Controller nodes. **The guide 
shares examples of RHOSP 17, and they work same for RHOSP 17.1 unless explicitly called out.** 

.. note::

  For more information about RHOSP, please refer to its `documentation pages
  <https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/17.1>`_.

.. warning::

  RHOSP17 and RHOSP17.1 are based on OpenStack Wallaby release. Features included after Wallaby
  release are not available in RHOSP17. The release RHOSP17.1 has additional backport fixes from upstream. 

Requirements
------------

In order to deploy NetApp Cinder back ends, you should have the following
requirements satisfied:

- NetApp ONTAP storage controllers deployed and ready to be used as Cinder
  back ends. See :ref:`data-ontap-config` for more details.

- RHOSP Director user credentials to deploy Overcloud.

- RHOSP Overcloud Controller nodes where Cinder services will be installed.

.. note::

  The driver supports FCP, but it is not certified for RHOSP17 and RHOSP 17.1.

Deployment Steps
----------------

Prepare the environment files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

RHOSP makes use of **TripleO Heat Templates (THT)**, which allows you to define
the Overcloud resources by creating environment files.

Single back end configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure a single NetApp Cinder back end, define an environment file as in
the following example:

- ``/home/stack/templates/cinder-netapp-nfs-backend1.yaml``

  .. code-block:: yaml
    :name: tripleo-netapp-nfs-backend1.yaml

    resource_registry:
      OS::TripleO::Services::CinderBackendNetApp: /usr/share/openstack-tripleo-heat-templates/deployment/cinder/cinder-backend-netapp-puppet.yaml

    parameter_defaults:
      CinderEnableIscsiBackend: false
      CinderEnableNetappBackend: true
      CinderNetappBackendName: 'tripleo_netapp_nfs1'
      CinderNetappMultiConfig: {}
      CinderNetappLogin: 'admin' #Default value for NetApp login      
      CinderNetappPassword: 'secret_password'
      CinderNetappServerHostname: 'hostname'
      CinderNetappServerPort: '80'
      CinderNetappSizeMultiplier: '1.2'
      CinderNetappStorageFamily: 'ontap_cluster'
      CinderNetappStorageProtocol: 'nfs'
      CinderNetappTransportType: 'http'
      CinderNetappVfiler: ''
      CinderNetappVserver: 'vserver_name'
      CinderNetappPartnerBackendName: ''
      CinderNetappNfsShares: 'lif1_ip:/flexvol_1'
      CinderNetappNfsSharesConfig: '/etc/cinder/nfs_shares'
      CinderNetappNfsMountOptions: 'context=system_u:object_r:container_file_t:s0'
      CinderNetappCopyOffloadToolPath: ''
      CinderNetappControllerIps: ''
      CinderNetappSaPassword: ''
      CinderNetappPoolNameSearchPattern: '(.+)'
      CinderNetappHostType: ''
      CinderNetappWebservicePath: '/devmgr/v2'
  
  Alternatively user can define a simplified environment file as in 
  the following example:    
  
- ``/home/stack/templates/cinder-netapp-nfs-backend1.yaml``

  .. code-block:: yaml
    :name: tripleo-netapp-nfs-backend.yaml

    resource_registry:
      OS::TripleO::Services::CinderBackendNetApp: /usr/share/openstack-tripleo-heat-templates/deployment/cinder/cinder-backend-netapp-puppet.yaml

    parameter_defaults:
      CinderEnableNetappBackend: true
      CinderNetappBackendName: 'tripleo_netapp_nfs_1'
      CinderNetappLogin: 'admin_username'
      CinderNetappPassword: 'admin_password'
      CinderNetappServerHostname: 'hostname'
      CinderNetappServerPort: '80'
      CinderNetappStorageFamily: 'ontap_cluster'
      CinderNetappStorageProtocol: '<nfs/iscsi>'
      CinderNetappTransportType: 'http'
      CinderNetappVserver: 'vserver_name'
      CinderNetappNfsShares: 'lif1_ip:/flexvol_1'
      CinderNetappNfsSharesConfig: '/etc/cinder/nfs_shares'

  Modify the parameter values according to your NetApp ONTAP back end
  configuration.

.. note::

  Most THT Configuration Parameters correspond to a Cinder Configuration
  Option.  See :ref:`Table 8.1, "NetApp Cinder THT Configuration
  Parameters" <table-8.1>` for a complete list of the THT Configuration
  Parameters and their correspondence to Cinder Configuration Options.

.. note::

  There are some Cinder Configuration Options that have no correspondent THT
  Configuration Parameter. If you need to set such options, you can define
  Custom Configuration Parameters.

  You can define arbitrary Custom Configurations using the following syntax:

  .. code-block:: yaml
      :name: custom-config.yaml

      parameter_defaults:
        ControllerExtraConfig:
          cinder::config::cinder_config:
            <backend_name>/<configuration_name>:
              value: <value>

  Each configuration will be rendered in ``cinder.conf`` file as:

  .. code-block::
      :name: cinder.conf

      [backend_name]
      configuration_name=value

  See `Configuration options for ONTAP with NFS (Wallaby)
  <https://netapp-openstack-dev.github.io/openstack-docs/wallaby/cinder/configuration/cinder_config_files/unified_driver_ontap/section_cinder-conf-nfs.html#table-4-20>`_
  and `Configuration options for ONTAP with iSCSI (Wallaby)
  <https://netapp-openstack-dev.github.io/openstack-docs/wallaby/cinder/configuration/cinder_config_files/unified_driver_ontap/section_cinder-conf-iscsi.html#table-4-21>`_
  for a complete list of the available Cinder Configuration Options.

.. warning::

  RHOSP17 is based on OpenStack Wallaby release. Features and Configuration
  Options included after Wallaby release are not available in RHOSP17. The release RHOSP17.1 has additional 
  backport fixes from upstream. 

Most THT Configuration Parameters correspond to a Cinder Configuration Option.
The following table maps each THT Configuration Parameter to the corresponding
Cinder Configuration Option:

.. _table-8.1:

+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| THT Parameter Name                               |  Cinder Configuration Option               | Required/Optional | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
+==================================================+============================================+===================+==============================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================+
| ``CinderNetappBackendName``                      | ``volume_backend_name``                    | Required          | The name used by Cinder to refer to the Cinder backend.                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappLogin``                            | ``netapp_login``                           | Required          | Administrative user account name used to access the storage system.                                                                                                                                                                                                                                                                                                                                                                                                                                          |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappPassword``                         | ``netapp_password``                        | Required          | Password for the administrative user account specified in the ``netapp_login`` option.                                                                                                                                                                                                                                                                                                                                                                                                                       |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappServerHostname``                   | ``netapp_server_hostname``                 | Required          | The hostname or IP address for the storage system or proxy server. *The value of this option should be the IP address of the cluster management LIF.*                                                                                                                                                                                                                                                                                                                                                        |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappServerPort``                       | ``netapp_server_port``                     | Optional          | The TCP port to use for communication with the storage system or proxy server. If not specified, ONTAP drivers will use 80 for HTTP and 443 for HTTPS.                                                                                                                                                                                                                                                                                                                                                       |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappStorageFamily``                    | ``netapp_storage_family``                  | Required          | The storage family type used on the storage system; valid values are ``ontap_cluster`` for ONTAP.                                                                                                                                                                                                                                                                                                                                                                                                            |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappStorageProtocol``                  | ``netapp_storage_protocol``                | Required          | The storage protocol to be used. Valid options are ``nfs``, ``iscsi``, or ``fc``.                                                                                                                                                                                                                                                                                                                                                                                                                            |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappTransportType``                    | ``netapp_transport_type``                  | Required          | Transport protocol for communicating with the storage system or proxy server. Valid options include ``http`` and ``https``.                                                                                                                                                                                                                                                                                                                                                                                  |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappVserver``                          | ``netapp_vserver``                         | Required          | This option specifies the storage virtual machine (previously called a Vserver) name on the storage cluster on which provisioning of block storage volumes should occur.                                                                                                                                                                                                                                                                                                                                     |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappNfsSharesConfig``                  | ``nfs_shares_config``                      | Optional          | The file referenced by this configuration option will contain a list of NFS shares specified by ``CinderNetappNfsShares`` THT Parameter, each on their own line, to which the driver should attempt to provision new Cinder volumes into.                                                                                                                                                                                                                                                                    |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappNfsMountOptions``                  | ``nfs_mount_options``                      | Optional          | For NFS protocol only. Mount options passed to the nfs client. See section of the nfs man page for details.                                                                                                                                                                                                                                                                                                                                                                                                  |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappCopyOffloadToolPath``              | ``netapp_copyoffload_tool_path``           | Optional          | For NFS protocol only. This option specifies the path of the NetApp copy offload tool binary. Ensure that the binary has execute permissions set which allow the effective user of the ``cinder-volume`` process to execute the file.                                                                                                                                                                                                                                                                        |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappHostType``                         | ``netapp_host_type``                       | Optional          | This option defines the type of operating system for all initiators that can access a LUN. This information is used when mapping LUNs to individual hosts or groups of hosts. Default is 'linux'.                                                                                                                                                                                                                                                                                                            |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappPoolNameSearchPattern``            | ``netapp_pool_name_search_pattern``        | Optional          | This option is only utilized when the Cinder driver is configured to use iSCSI off Fibre Channel. It is used to restrict provisioning to the specified FlexVol volumes. Specify the value of this option as a regular expression which will be applied to the names of FlexVol volumes from the storage backend which represent pools in Cinder. ``^`` (beginning of string) and ``$`` (end of string) are implicitly wrapped around the regular expression specified before filtering. Default is ``(.+)``. |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``CinderNetappAvailabilityZone``                 | ``backend_availability_zone``              | Optional          | Availability zone for this volume backend. If not set, the storage_availability_zone option value is used as the default for all backends.                                                                                                                                                                                                                                                                                                                                                                   |
+--------------------------------------------------+--------------------------------------------+-------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 8.1. NetApp Cinder THT Configuration Parameters


Multiple back end configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure multiple NetApp Cinder backends, define an environment file as in
the following example:

- ``/home/stack/templates/cinder-netapp-nfs-backend1.yaml``

  This file defines the multiple Cinder volume backends
  ``tripleo_netapp_nfs_1``, ``tripleo_netapp_nfs_2`` and 
  ``tripleo_netapp_iscsi_1`` and their parameters.

  .. code-block:: yaml
    :name: cinder-netapp-nfs-backend1.yaml

    resource_registry:
      OS::TripleO::Services::CinderBackendNetApp: /usr/share/openstack-tripleo-heat-templates/deployment/cinder/cinder-backend-netapp-puppet.yaml

    parameter_defaults:
      CinderEnableIscsiBackend: false
      CinderEnableNetappBackend: true
      CinderNetappLogin: 'admin'#Default value for the Netapp backends'
      CinderNetappPassword: 'secret_password'
      CinderNetappServerHostname: 'hostname'
      CinderNetappServerPort: '80'
      CinderNetappSizeMultiplier: '1.2'
      CinderNetappStorageFamily: 'ontap_cluster'
      CinderNetappStorageProtocol: 'nfs'
      CinderNetappTransportType: 'http'
      CinderNetappVfiler: ''
      CinderNetappVserver: 'vserver_name'
      CinderNetappPartnerBackendName: ''
      CinderNetappNfsShares: 'lif_ip:/flexvol'
      CinderNetappNfsSharesConfig: '/etc/cinder/nfs_shares'
      CinderNetappNfsMountOptions: 'context=system_u:object_r:container_file_t:s0'
      CinderNetappCopyOffloadToolPath: ''
      CinderNetappControllerIps: ''
      CinderNetappSaPassword: ''
      CinderNetappPoolNameSearchPattern: '(.+)'
      CinderNetappHostType: ''
      CinderNetappWebservicePath: '/devmgr/v2'
      CinderNetappBackendName:
        - tripleo_netapp_nfs_1
        - tripleo_netapp_nfs_2  
        - tripleo_netapp_iscsi_1
      CinderNetappMultiConfig:
        tripleo_netapp_nfs_1:
          CinderNetappPassword: 'secret_password_1'
          CinderNetappNfsSharesConfig: '/etc/cinder/nfs_shares1'
        tripleo_netapp_nfs_2:
          CinderNetappPassword: 'secret_password_2'
          CinderNetappServerHostname: 'hostname2'
          CinderNetappVserver: 'vserver_name_2'
          CinderNetappNfsShares: 'lif_ip2:/flexvol2'
          CinderNetappNfsSharesConfig: '/etc/cinder/nfs_shares2'
          CinderNetappStorageProtocol: 'nfs'
        tripleo_netapp_iscsi_1:
          CinderNetappPassword: 'secret_password_3'
          CinderNetappServerHostname: 'hostname3'
          CinderNetappVserver: 'vserver_name_3'
          CinderNetappStorageProtocol: 'iscsi'

  Modify the parameter values according to your NetApp ONTAP back end
  configuration.

.. note::

  Each Netapp backend's CinderNetappNfsSharesConfig must be unique.
  In the above example, tripleo_netapp_nfs_1's CinderNetappNfsSharesConfig 
  ('/etc/cinder/nfs_shares1') will be configured with the content copied 
  from default CinderNetappNfsShares. For the backend tripleo_netapp_nfs_2, 
  CinderNetappNfsSharesConfig ('/etc/cinder/nfs_shares2') will have content 
  of CinderNetappNfsShares in the same block if mentioned,  otherwise it will 
  have default CinderNetappNfsShares.

Deploy Overcloud
^^^^^^^^^^^^^^^^

Now that you have the Cinder back end environment file defined, you can run
the command to deploy RHOSP Overcloud. Run the following command as ``stack``
user in the RHOSP Director command line, specifying the YAML file(s) you
defined:

.. code-block:: bash
  :name: overcloud-deploy

   (undercloud) [stack@rhosp17-undercloud ~]$ openstack overcloud deploy \
   --templates \
   -e /home/stack/containers-prepare-parameter.yaml \
   -e /home/stack/templates/cinder-netapp-nfs-backend1.yaml \
   -n /home/stack/templates/no-network/network_data.yaml \
   -e /home/stack/templates/overcloud-networks-deployed.yaml \
   -e /home/stack/templates/overcloud-vip-deployed.yaml \
   -e /home/stack/templates/overcloud-baremetal-deployed.yaml \
   --stack overcloud

.. note::

  Alternatively, you can use ``--environment-directory`` parameter and specify
  the whole directory to the deployment command. It will consider all the YAML
  files within this directory:

  .. code-block:: bash
    :name: overcloud-deploy-environment-directory

     (undercloud) [stack@rhosp17-undercloud ~]$ openstack overcloud deploy \
     --templates \
     -e /home/stack/containers-prepare-parameter.yaml \
     --environment-directory /home/stack/templates \
     --stack overcloud


Test the Deployed Back Ends
^^^^^^^^^^^^^^^^^^^^^^^^^^^

After RHOSP Overcloud is deployed, run the following command to check if the
Cinder services are up:

.. code-block:: bash
  :name: cinder-service-list

  [stack@rhosp17-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder service-list


Run the following commands as ``stack`` user in the RHOSP Director command line
to create the volume types mapped to the deployed back ends:

.. code-block:: bash
  :name: create-volume-types

  [stack@rhosp17-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder type-create tripleo_netapp_nfs_1
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder type-key tripleo_netapp_nfs_1 set volume_backend_name=tripleo_netapp_nfs_1
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder type-create tripleo_netapp_nfs_2
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder type-key tripleo_netapp_nfs_2 set volume_backend_name=tripleo_netapp_nfs_2
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder type-create tripleo_netapp_iscsi_1
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder type-key tripleo_netapp_iscsi_1 set volume_backend_name=tripleo_netapp_iscsi_1

Make sure that you're able to create Cinder volumes with the configured volume
types:

.. code-block:: bash
  :name: create-volumes

  [stack@rhosp17-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder create --volume-type tripleo_netapp_nfs_1 --name v1 1
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder create --volume-type tripleo_netapp_nfs_2 --name v2 1
  (overcloud) [stack@rhosp17-undercloud ~]$ cinder create --volume-type tripleo_netapp_iscsi_1 --name v3 1

