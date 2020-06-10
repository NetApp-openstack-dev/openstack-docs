Deploying NetApp ONTAP Manila driver in a Red Hat OpenStack Platform Overcloud
==============================================================================

.. _manila-rhosp:

Overview
--------

This guide shows how to configure and deploy NetApp ONTAP Manila driver in a
**Red Hat OpenStack Platform (RHOSP)** Overcloud, using RHOSP Director. After
reading this, you'll be able to define the proper environment files and run
the command to deploy single or multiple ONTAP Manila back ends in RHOSP
Overcloud Controller nodes.

For more information about RHOSP, please refer to its `documentation pages
<https://access.redhat.com/documentation/en-us/red_hat_openstack_platform>`_.


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

.. code-block:: yaml

    resource_registry:
      OS::TripleO::Services::ManilaApi: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-api-container-puppet.yaml
      OS::TripleO::Services::ManilaScheduler: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-scheduler-container-puppet.yaml
      OS::TripleO::Services::ManilaShare: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-share-pacemaker-puppet.yaml
      OS::TripleO::Services::ManilaBackendNetapp: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-backend-netapp.yaml

    parameter_defaults:
      ManilaNetappBackendName: 'tripleo_netapp_single_svm'
      ManilaNetappDriverHandlesShareServers: 'false'
      ManilaNetappLogin: 'admin'
      ManilaNetappPassword: 'password'
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

Each THT Configuration Parameter corresponds to a ``manila.conf``
Configuration Option. See :ref:`Table 7.1, "Manila NetApp THT Configuration
Parameters "<table-7.1>` for a complete list of the THT Configuration
Parameters and their correspondence to ``manila.conf`` Configuration Options.

There are some manila configuration options that has no correspondent THT
configuration parameter. You can define custom configuration parameters if you
need to set such options. For instance, the previous example sets
``backend_availability_zone=manila-zone-0`` for the back end
``tripleo_netapp_single_svm``. You can define arbitrary extra
configurations using the following syntax:

.. code-block:: yaml

    parameter_defaults:
      ControllerExtraConfig:
        manila::config::manila_config:
          <backend_name>/<configuration_name>:
            value: <value>

See :ref:`with-share` and :ref:`without-share` for a complete list of the
available configuration options.

Multiple back end configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

THT has no templates for configuring multiple NetApp Manila back ends.
In order to configure multiple NetApp Manila back ends, you need to specify
custom configurations for the additional back ends.

It's possible to define all the back ends in a single environment file,
but for sake of clarity, the following example organizes the back ends in
multiple smaller environment files:

WIP WIP WIP

- ``/home/stack/templates/manila-enabled-backends.yaml``

This file enables the resources for Manila services, and defines which
back ends will be enabled. In this example, two back ends will be enabled.

.. code-block:: yaml

     # /home/stack/templates/manila-enabled-backends.yaml
     resource_registry:
       OS::TripleO::Services::ManilaApi: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-api-container-puppet.yaml
       OS::TripleO::Services::ManilaScheduler: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-scheduler-container-puppet.yaml
       OS::TripleO::Services::ManilaShare: /usr/share/openstack-tripleo-heat-templates/deployment/manila/manila-share-pacemaker-puppet.yaml

     parameter_defaults:
       ControllerExtraConfig:
         manila_user_enabled_backends:
           - 'tripleo_netapp_nfs_ss_2'

- ``/home/stack/templates/manila-netapp-nfs-ss-backend1.yaml``

This file defines the first Manila share back end and its parameters. In
this example, the back end being defined will be configured to operate in
DHSS=True mode.

.. code-block:: yaml

    # /home/stack/templates/manila-netapp-nfs-ss-backend1.yaml
    parameter_defaults:
      ControllerExtraConfig:
        manila::config::manila_config:
          tripleo_netapp_nfs_ss_1/share_backend_name:
            value: tripleo_netapp_nfs_ss_1
          tripleo_netapp_nfs_ss_1/share_driver:
            value: manila.share.drivers.netapp.common.NetAppDriver
          tripleo_netapp_nfs_ss_1/driver_handles_share_servers:
            value: True
          tripleo_netapp_nfs_ss_1/netapp_login:
            value: admin
          tripleo_netapp_nfs_ss_1/netapp_password:
            value: Netapp123
          tripleo_netapp_nfs_ss_1/netapp_server_hostname:
            value: 10.193.154.42
          tripleo_netapp_nfs_ss_1/netapp_storage_family:
            value: ontap_cluster
          tripleo_netapp_nfs_ss_1/netapp_transport_type:
            value: http
          tripleo_netapp_nfs_ss_1/netapp_server_port:
            value: 80
          tripleo_netapp_nfs_ss_1/netapp_root_volume_aggregate:
            value: aggr0
          tripleo_netapp_nfs_ss_1/replication_domain:
            value: netapp_replication_domain
          tripleo_netapp_nfs_ss_1/backend_availability_zone:
            value: manila-zone-0

- ``/home/stack/templates/manila-netapp-nfs-ss-backend2.yaml``

This file defines the second Manila share back end and its parameters. In
this example, the back end being defined will be configured to operate in
DHSS=True mode as well.

.. code-block:: yaml

    parameter_defaults:
      ControllerExtraConfig:
        manila::config::manila_config:
          tripleo_netapp_nfs_ss_2/share_backend_name:
            value: tripleo_netapp_nfs_ss_2
          tripleo_netapp_nfs_ss_2/share_driver:
            value: manila.share.drivers.netapp.common.NetAppDriver
          tripleo_netapp_nfs_ss_2/driver_handles_share_servers:
            value: True
          tripleo_netapp_nfs_ss_2/netapp_login:
            value: admin
          tripleo_netapp_nfs_ss_2/netapp_password:
            value: Netapp123
          tripleo_netapp_nfs_ss_2/netapp_server_hostname:
            value: 10.193.154.107
          tripleo_netapp_nfs_ss_2/netapp_storage_family:
            value: ontap_cluster
          tripleo_netapp_nfs_ss_2/netapp_transport_type:
            value: http
          tripleo_netapp_nfs_ss_2/netapp_server_port:
            value: 80
          tripleo_netapp_nfs_ss_2/netapp_root_volume_aggregate:
            value: aggr0
          tripleo_netapp_nfs_ss_2/replication_domain:
            value: netapp_replication_domain
          tripleo_netapp_nfs_ss_2/backend_availability_zone:
            value: manila-zone-1


.. note::

  The parameters are written in the format ``<section_name>/<parameter>:``
  followed by a line in the format ``value: <value>``. ``manila.conf`` file
  will be populated with the specified sections, parameters and values.

  You can add arbitrary parameters to these sections. So if you need to
  specify some parameter not present in the above examples, just add it. For
  instance, if you want to specify ``netapp_api_trace_pattern=(.+)`` to
  the back end ``tripleo_netapp_nfs_ss_1``, append the following lines:


.. code-block:: yaml

          tripleo_netapp_nfs_ss_1/netappapi_trace_pattern:
            value: (.+)

.. _table-7.1:

+--------------------------------------------------+--------------------------------------------+
| THT Parameter Name                               |  manila.conf Configuration Option          |
+==================================================+============================================+
| ``ManilaNetappBackendName``                      | ``share_backend_name``                     |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappLogin``                            | ``netapp_login``                           |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappDriverHandlesShareServers``        | ``driver_handles_share_servers``           |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappPassword``                         | ``netapp_password``                        |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappServerHostname``                   | ``netapp_server_hostname``                 |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappTransportType``                    | ``netapp_transport_type``                  |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappStorageFamily``                    | ``netapp_storage_family``                  |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappServerPort``                       | ``netapp_server_port``                     |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappVolumeNameTemplate``               | ``netapp_volume_name_template``            |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappVserver``                          | ``netapp_vserver``                         |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappVserverNameTemplate``              | ``netapp_vserver_name_template``           |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappLifNameTemplate``                  | ``netapp_lif_name_template``               |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappAggrNameSearchPattern``            | ``netapp_aggregate_name_search_pattern``   |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappRootVolumeAggr``                   | ``netapp_root_volume_aggregate``           |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappRootVolume``                       | ``netapp_root_volume``                     |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappPortNameSearchPattern``            | ``netapp_port_name_search_pattern``        |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappTraceFlags``                       | ``netapp_trace_flags``                     |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappEnabledShareProtocols``            | ``netapp_enabled_share_protocols``         |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappVolumeSnapshotReservePercent``     | ``netapp_volume_snapshot_reserve_percent`` |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappSnapmirrorQuiesceTimeout``         | ``netapp_snapmirror_quiesce_timeout``      |
+--------------------------------------------------+--------------------------------------------+
| ``ManilaNetappVolumeSnapshotReservePercent``     | ``netapp_volume_snapshot_reserve_percent`` |
+--------------------------------------------------+--------------------------------------------+

Table 7.1. Manila NetApp THT Configuration Parameters


Deploy Overcloud
^^^^^^^^^^^^^^^^


.. code-block:: bash

   (undercloud) [stack@rhosp16-undercloud ~]$ openstack overcloud deploy \
   --templates \
   -e /home/stack/containers-prepare-parameter.yaml \
   --environment-directory /home/stack/templates \
   --stack overcloud
