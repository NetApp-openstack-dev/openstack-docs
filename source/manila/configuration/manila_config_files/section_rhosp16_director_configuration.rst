Deploying NetApp ONTAP Manila driver in a Red Hat OpenStack Platform 16
=======================================================================

.. _manila-rhosp:

Overview
--------

This guide shows how to configure and deploy NetApp ONTAP Manila driver in a
**Red Hat OpenStack Platform (RHOSP) 16** Overcloud, using RHOSP Director.
After reading this, you'll be able to define the proper environment files and
deploy single or multiple ONTAP Manila back ends in RHOSP Overcloud Controller
nodes.

.. note::

  For more information about RHOSP, please refer to its `documentation pages
  <https://access.redhat.com/documentation/en-us/red_hat_openstack_platform>`_.

.. warning::

  RHOSP16 is based on OpenStack Train release. Features included after Train
  release are not available in RHOSP16.

Requirements
------------

In order to deploy NetApp Manila back ends, you should have the following
requirements satisfied:

- NetApp ONTAP storage controllers deployed and ready to be used as Manila
  back ends. See :ref:`manila_data_ontap_prerequisites` for more details.

- RHOSP Director user credentials to deploy Overcloud.

- RHOSP Overcloud Controller nodes where Manila services will be installed.


Deployment Steps
----------------

Prepare the environment files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

RHOSP makes use of **TripleO Heat Templates (THT)**, which allows you to define
the Overcloud resources by creating environment files.

Single back end configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure a single NetApp Manila back end, define an environment file as in
the following example:

- ``/home/stack/templates/tripleo-netapp-single-svm.yaml``

  .. code-block:: yaml
    :name: tripleo-netapp-single-svm.yaml

      resource_registry:
        OS::TripleO::Services::ManilaApi: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-api-container-puppet.yaml
        OS::TripleO::Services::ManilaScheduler: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-scheduler-container-puppet.yaml
        OS::TripleO::Services::ManilaShare: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-share-pacemaker-puppet.yaml
        OS::TripleO::Services::ManilaBackendNetapp: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-backend-netapp.yaml

      parameter_defaults:
        ManilaNetappBackendName: 'tripleo_netapp_single_svm'
        ManilaNetappDriverHandlesShareServers: 'false'
        ManilaNetappLogin: 'admin_username'
        ManilaNetappPassword: 'admin_password'
        ManilaNetappServerHostname: 'hostname'
        ManilaNetappTransportType: 'http'
        ManilaNetappStorageFamily: 'ontap_cluster'
        ManilaNetappServerPort: '80'
        ManilaNetappVserver: 'svm_name'
        ControllerExtraConfig:
          manila::config::manila_config:
            tripleo_netapp_single_svm/backend_availability_zone:
              value: 'manila-zone-0'


  Modify the parameter values according to your NetApp ONTAP back end
  configuration.

.. note::

  Each THT Configuration Parameter corresponds to a Manila
  Configuration Option. See :ref:`Table 7.1, "Manila NetApp THT Configuration
  Parameters "<table-7.1>` for a complete list of the THT Configuration
  Parameters and their correspondence to Manila Configuration Options.

.. note::

  There are some Manila Configuration Options that have no correspondent THT
  Configuration Parameter. If you need to set such options, you can define
  Custom Configuration Parameters. For instance, the previous example sets
  ``backend_availability_zone=manila-zone-0`` for the back end
  ``tripleo_netapp_single_svm``.

  You can define arbitrary Custom
  Configurations using the following syntax:

  .. code-block:: yaml
      :name: custom-config.yaml

      parameter_defaults:
        ControllerExtraConfig:
          manila::config::manila_config:
            <backend_name>/<configuration_name>:
              value: <value>

  See `NetApp Unified Driver for ONTAP with Share Server management (Train)
  <https://netapp-openstack-dev.github.io/openstack-docs/train/manila/configuration/manila_config_files/section_unified-driver-with-share-server.html>`_
  and `NetApp Unified Driver for ONTAP without Share Server management (Train)
  <https://netapp-openstack-dev.github.io/openstack-docs/train/manila/configuration/manila_config_files/section_unified-driver-without-share-server.html>`_
  for a complete list of the available Manila Configuration Options.

.. warning::

  RHOSP16 is based on OpenStack Train release. Features and Configuration
  Options included after Train release are not available in RHOSP16.

Each THT Configuration Parameter corresponds to a Manila Configuration Option.
The following table maps each THT Configuration Parameter to the corresponding
Manila Configuration Option:

.. _table-7.1:

+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| THT Parameter Name                               |  Manila Configuration Option               | Type      | Description                                                                                                                                                                                                                                                                                                      |
+==================================================+============================================+===========+==================================================================================================================================================================================================================================================================================================================+
| ``ManilaNetappBackendName``                      | ``share_backend_name``                     | Required  | The name used by Manila to refer to the Manila backend.                                                                                                                                                                                                                                                          |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappLogin``                            | ``netapp_login``                           | Required  | Administrative user account name used to access the storage system.                                                                                                                                                                                                                                              |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappDriverHandlesShareServers``        | ``driver_handles_share_servers``           | Required  | Denotes whether the driver should handle the responsibility of managing share servers. This must be set to ``true`` if the driver is to manage share servers.                                                                                                                                                    |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappPassword``                         | ``netapp_password``                        | Required  | Password for the administrative user account specified in the ``netapp_login`` option.                                                                                                                                                                                                                           |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappServerHostname``                   | ``netapp_server_hostname``                 | Required  | The hostname or IP address for the storage system or proxy server. *The value of this option should be the IP address of the cluster management LIF.*                                                                                                                                                            |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappTransportType``                    | ``netapp_transport_type``                  | Required  | Transport protocol for communicating with the storage system or proxy server. Valid options include ``http`` and ``https``.                                                                                                                                                                                      |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappStorageFamily``                    | ``netapp_storage_family``                  | Required  | The storage family type used on the storage system; valid values are ``ontap_cluster`` for ONTAP.                                                                                                                                                                                                                |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappServerPort``                       | ``netapp_server_port``                     | Optional  | The TCP port to use for communication with the storage system or proxy server. If not specified, ONTAP drivers will use 80 for HTTP and 443 for HTTPS.                                                                                                                                                           |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappVolumeNameTemplate``               | ``netapp_volume_name_template``            | Optional  | This option specifies a string replacement template that is applied when naming FlexVol volumes that are created as a result of provisioning requests.                                                                                                                                                           |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappVserver``                          | ``netapp_vserver``                         | Required  | This option specifies the storage virtual machine (previously called a Vserver) name on the storage cluster on which provisioning of shared file systems should occur. This parameter is required if the driver is to operate without managing share servers (that is, be limited to the scope of a single SVM). |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappVserverNameTemplate``              | ``netapp_vserver_name_template``           | Optional  | This option specifies a string replacement template that is applied when naming FlexVol volumes that are created as a result of provisioning requests.                                                                                                                                                           |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappLifNameTemplate``                  | ``netapp_lif_name_template``               | Optional  | This option specifies a string replacement template that is applied when naming data LIFs that are created as a result of provisioning requests.                                                                                                                                                                 |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappAggrNameSearchPattern``            | ``netapp_aggregate_name_search_pattern``   | Optional  | This option specifies a regular expression that is applied against all available aggregates. This filtered list will be reported to the Manila scheduler as valid pools for provisioning new shares.                                                                                                             |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappRootVolumeAggr``                   | ``netapp_root_volume_aggregate``           | Required  | This option specifies name of the aggregate upon which the root volume should be placed when a new SVM is created to correspond to a Manila share server.                                                                                                                                                        |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappRootVolume``                       | ``netapp_root_volume``                     | Optional  | This option specifies name of the root volume that will be created when a new SVM is created to correspond to a Manila share server.                                                                                                                                                                             |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappPortNameSearchPattern``            | ``netapp_port_name_search_pattern``        | Optional  | This option allows you to specify a regular expression for overriding the selection of network ports on which to create Vserver LIFs.                                                                                                                                                                            |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappTraceFlags``                       | ``netapp_trace_flags``                     | Optional  | This option is a comma-separated list of options (valid values include ``method`` and ``api``) that controls which trace info is written to the Manila logs when the debug level is set to ``True``.                                                                                                             |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappEnabledShareProtocols``            | ``netapp_enabled_share_protocols``         | Optional  | This option specifies the NFS protocol versions that will be enabled on new SVMs created by the driver. Valid values include nfs3, nfs4.0, nfs4.1.                                                                                                                                                               |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappVolumeSnapshotReservePercent``     | ``netapp_volume_snapshot_reserve_percent`` | Optional  | This option specifies the percentage of share space set aside as reserve for snapshot usage. Valid values range from 0 to 90.                                                                                                                                                                                    |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappSnapmirrorQuiesceTimeout``         | ``netapp_snapmirror_quiesce_timeout``      | Optional  | The maximum time in seconds to wait for existing snapmirror transfers to complete before aborting when promoting a replica.                                                                                                                                                                                      |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``ManilaNetappVolumeSnapshotReservePercent``     | ``netapp_volume_snapshot_reserve_percent`` | Optional  | The percentage of share space set aside as reserve for snapshot usage; valid values range from 0 to 90.                                                                                                                                                                                                          |
+--------------------------------------------------+--------------------------------------------+-----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 7.1. Manila NetApp THT Configuration Parameters


Multiple back end configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

THT has no templates for configuring multiple NetApp Manila back ends.
In order to configure multiple NetApp Manila back ends, you need to define
the first back end with THT, and the additional back ends with Custom
Configurations.

It's possible to define all the back ends in a single environment file,
but for sake of clarity, the following example organizes the back ends in
multiple smaller environment files:

- ``/home/stack/templates/tripleo-netapp-multi-svm-1.yaml``

  This file defines the first Manila share back end
  ``tripleo_netapp_multi_svm_1`` and its parameters. The definition of the
  first back end is the same for both single and multiple back end
  configuration:

  .. code-block:: yaml
    :name: tripleo-netapp-multi-svm-1.yaml

      resource_registry:
        OS::TripleO::Services::ManilaBackendNetapp: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-backend-netapp.yaml
        OS::TripleO::Services::ManilaApi: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-api-container-puppet.yaml
        OS::TripleO::Services::ManilaScheduler: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-scheduler-container-puppet.yaml
        OS::TripleO::Services::ManilaShare: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-share-pacemaker-puppet.yaml
        OS::TripleO::Services::ManilaBackendNetapp: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-backend-netapp.yaml

      parameter_defaults:
        ManilaNetappBackendName: 'tripleo_netapp_multi_svm_1'
        ManilaNetappDriverHandlesShareServers: 'true'
        ManilaNetappLogin: 'admin_username'
        ManilaNetappPassword: 'admin_password'
        ManilaNetappServerHostname: 'hostname'
        ManilaNetappTransportType: 'http'
        ManilaNetappStorageFamily: 'ontap_cluster'
        ManilaNetappServerPort: '80'
        ManilaNetappRootVolumeAggr: 'aggr0'
        ControllerExtraConfig:
          manila::config::manila_config:
            tripleo_netapp_multi_svm_1/replication_domain:
              value: 'netapp_replication_domain'
            tripleo_netapp_multi_svm_1/backend_availability_zone:
              value: 'manila-zone-0'

  Modify the parameter values according to your NetApp ONTAP back end
  configuration.

- ``/home/stack/templates/manila-enabled-backends.yaml``

  This file defines which additional back ends will be enabled. In this
  example, one additional back end ``tripleo_netapp_multi_svm_2`` will be
  enabled:

  .. code-block:: yaml
    :name: manila-enabled-backends.yaml

       parameter_defaults:
         ControllerExtraConfig:
           manila_user_enabled_backends:
             - 'tripleo_netapp_multi_svm_2'

- ``/home/stack/templates/tripleo-netapp-multi-svm-2.yaml``

  This file defines the second Manila share back end
  ``tripleo_netapp_multi_svm_2`` and its parameters:

  .. code-block:: yaml
    :name: tripleo-netapp-multi-svm-2.yaml

      parameter_defaults:
        ControllerExtraConfig:
          manila::config::manila_config:
            tripleo_netapp_multi_svm_2/share_backend_name:
              value: 'tripleo_netapp_multi_svm_2'
            tripleo_netapp_multi_svm_2/share_driver:
              value: 'manila.share.drivers.netapp.common.NetAppDriver'
            tripleo_netapp_multi_svm_2/driver_handles_share_servers:
              value: 'True'
            tripleo_netapp_multi_svm_2/netapp_login:
              value: 'admin_username'
            tripleo_netapp_multi_svm_2/netapp_password:
              value: 'admin_password'
            tripleo_netapp_multi_svm_2/netapp_server_hostname:
              value: 'hostname'
            tripleo_netapp_multi_svm_2/netapp_storage_family:
              value: 'ontap_cluster'
            tripleo_netapp_multi_svm_2/netapp_transport_type:
              value: 'http'
            tripleo_netapp_multi_svm_2/netapp_server_port:
              value: '80'
            tripleo_netapp_multi_svm_2/netapp_root_volume_aggregate:
              value: 'aggr0'
            tripleo_netapp_multi_svm_2/replication_domain:
              value: 'netapp_replication_domain'
            tripleo_netapp_multi_svm_2/backend_availability_zone:
              value: 'manila-zone-0'

  Modify the parameter values according to your NetApp ONTAP back end
  configuration.

Deploy Overcloud
^^^^^^^^^^^^^^^^

Now that you have the Manila back end environment files defined, you can run
the command to deploy RHOSP Overcloud. Run the following command as ``stack``
user in the RHOSP Director commandline, specifying the YAML file(s) you
defined:

.. code-block:: bash
  :name: overcloud-deploy

   (undercloud) [stack@rhosp16-undercloud ~]$ openstack overcloud deploy \
   --templates \
   -e /home/stack/templates/tripleo-netapp-single-svm.yaml \
   --stack overcloud

Alternatively, you can use ``--environment-directory`` parameter and specify
the whole directory to the deployment command. It will consider all the YAML
files within this directory:

.. code-block:: bash
  :name: overcloud-deploy-environment-directory

   (undercloud) [stack@rhosp16-undercloud ~]$ openstack overcloud deploy \
   --templates \
   --environment-directory /home/stack/templates \
   --stack overcloud

After RHOSP Overcloud is deployed, run the following command to check if the
Manila services are up:

.. code-block:: bash
  :name: manila-service-list

  [stack@rhosp16-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp16-undercloud ~]$ manila service-list

Create Default Share Type
^^^^^^^^^^^^^^^^^^^^^^^^^^^

RHOSP16 Director sets Manila Configuration Option ``default_share_type`` to
``default``, but does not create the actual share type. Run the following
command as ``stack`` user in the RHOSP Director commandline to create the
``default`` share type:

.. code-block:: bash
  :name: create-default-share-type

  [stack@rhosp16-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp16-undercloud ~]$ manila type-create default false

Replace ``false`` to ``true`` in the command above if you want the shares to be
created in ``DHSS=True`` back ends by default.

For more information about Manila share types, see `Shared File System Service
<https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.0/html/storage_guide/ch-shares#creating_a_share_type>`_
guide.
