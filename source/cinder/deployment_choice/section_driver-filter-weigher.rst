Theory of Operation: Driver Filter and Weigher for Scheduler
============================================================

Overview
--------

Cinder provides the DriverFilter and GoodnessWeigher to exercise
more fine grained control when choosing a volume backend based
on backend specific properties. It is possible to customize
the backend definition to schedule the creation of Cinder volumes
on specific backends, based on the volume properties and the
backend specific properties. Refer to the
":ref:`Configuration<driver-filter-config>`"
section to take a look at how this would work.

Setup
-----

To enable the driver filter, set the ``scheduler_default_filters``
option in the ``cinder.conf`` file to include DriverFilter.

To enable the goodness filter as a weigher, set the
``scheduler_default_weighers`` option in the cinder.conf file to
``GoodnessWeigher`` or add it to the list if other weighers are
already present.

Example ``cinder.conf`` configuration file:

.. code-block:: ini

   scheduler_default_filters = DriverFilter,AvailabilityFilter,CapabilityFilter,CapacityFilter
   scheduler_default_weighers = GoodnessWeigher

You can choose to use the DriverFilter without the GoodnessWeigher
or vice-versa. The filter and weigher working together, however,
create the most benefits when helping the scheduler choose an
ideal back end.

.. important::

   The GoodnessWeigher can be used along with CapacityWeigher
   and others, but must be used with caution as it might
   obfuscate the CapacityWeigher.

Refer to https://docs.openstack.org/cinder/latest/admin/blockstorage-driver-filter-weighing.html
which contains a more detailed explanation on how to use the driver
filter and goodness weigher to customize the scheduling mechanism.

There exist three property sets that can be referenced in the
``filter_funtion`` and ``goodness_function`` definitions:

- **Host stats for a backend**: These refer to the parameters
  that are specific for the host containing a defined
  backend. This would be analogous to an ONTAP/SolidFire
  cluster.
  
- **Requested volume properties**: These statistics are used
  to control scheduling based on the specifications
  of the volume requested during creation.

- **Backend specific capabilities**: The following table
  contains a list of capabilities reported by the ONTAP
  and SolidFire Cinder drivers.

.. _table-4.99:

+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Property                                | Type      | Products Supported               | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
+=========================================+===========+==================================+==============================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================+
| ``netapp_aggregate_used_percent``       | String    | ONTAP                            | The percentage of usage for the aggregate.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``utilization``                         | String    | ONTAP                            | Node utilization percentage.                                                                                                                                                                                                                                                                                          																											       																							        |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_dedupe_used_percent``          | String    | ONTAP                            | The percentage of shared block limit that has been consumed by dedupe and cloning operations.                                                                                                                                                                                                          																																																					|
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``allocated_capacity_gb``               | String    | ONTAP                            | The capacity that has been allocated on the backend pool.                                                                                                                                                                       																																																														|
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``max_over_subscription_ratio``         | String    | ONTAP                            | The amount of over-provisioning to allow when thin provisioning is being used in the storage pool.                                                                                                                                                                         																																																									|
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``thin_provision_percent``              | String    | SolidFire                        | The percentage of thin provision.                                                                                                                                                                       																																																																	|
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``compression_percent``                 | String    | SolidFire                        | The percentage of compression.                                                                                                                                                                        																																																																	|
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``deduplicaton_percent``                | String    | SolidFire                        | The percentage of deduplication.                                                                                                                                                                        																																																																	|
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.99 Backend capabilities reported by ONTAP and SolidFire Cinder drivers


Configuration
-------------

To utilize the driver filter and goodness weigher, update the
``scheduler_default_filters`` and ``scheduler_default_weighers``
options in ``cinder.conf``. The required ``filter_function``
and ``goodness_function`` are defined on a per-backend basis
as shown below.

.. _driver-filter-config:

**Example1: Using Driver Filter**

.. code-block:: ini

   [default]
   .
   .
   scheduler_default_filters = DriverFilter,AvailabilityFilter,CapabilityFilter,CapacityFilter
   scheduler_default_weighers = GoodnessWeigher
   enabled_backends = ontap-iscsi-1,ontap-iscsi-2
   .
   .
   [ontap-iscsi-1]
   volume_driver = cinder.volume.drivers.netapp.common.NetAppDriver
   netapp_login = admin
   netapp_password = *********
   volume_backend_name = ontap-iscsi
   netapp_server_hostname = 192.168.0.101
   netapp_server_port = 80
   netapp_transport_type = http
   netapp_vserver = svm1
   netapp_storage_protocol = iscsi
   netapp_storage_family = ontap_cluster
   filter_function = "volume.size < 5"

   [ontap-iscsi-2]
   volume_driver = cinder.volume.drivers.netapp.common.NetAppDriver
   netapp_login = admin
   netapp_password = *********
   volume_backend_name = ontap-iscsi
   netapp_server_hostname = 192.168.0.102
   netapp_server_port = 80
   netapp_transport_type = http
   netapp_vserver = svm2
   netapp_storage_protocol = iscsi
   netapp_storage_family = ontap_cluster
   filter_function = "volume.size >= 5 and capabilities.netapp_aggregate_used_percent < 45"

This ``cinder.conf`` file will schedule the creation of volumes as follows:

-   Cinder volumes that are of size < 5GB will be placed on the ``ontap-iscsi-1``
    backend.
-   Cinder volumes that are of size >= 5GB will be placed on the ``ontap-iscsi-2``
    backend, if the aggregate has a usage percent of lesser than 45%. Otherwise,
    volume creation will fail.

**Example2: Using Goodness Weigher**

.. code-block:: ini

   [default]
   .
   .
   scheduler_default_filters = DriverFilter,AvailabilityFilter,CapabilityFilter,CapacityFilter
   scheduler_default_weighers = GoodnessWeigher
   enabled_backends = ontap-iscsi-1,ontap-iscsi-2
   .
   .
   [ontap-iscsi-1]
   volume_driver = cinder.volume.drivers.netapp.common.NetAppDriver
   netapp_login = admin
   netapp_password = *********
   volume_backend_name = ontap-iscsi
   netapp_server_hostname = 192.168.0.101
   netapp_server_port = 80
   netapp_transport_type = http
   netapp_vserver = svm1
   netapp_storage_protocol = iscsi
   netapp_storage_family = ontap_cluster
   goodness_function = "(capabilities.utilization < 60.0) ? 60 : 30"

   [ontap-iscsi-2]
   volume_driver = cinder.volume.drivers.netapp.common.NetAppDriver
   netapp_login = admin
   netapp_password = *********
   volume_backend_name = ontap-iscsi
   netapp_server_hostname = 192.168.0.102
   netapp_server_port = 80
   netapp_transport_type = http
   netapp_vserver = svm2
   netapp_storage_protocol = iscsi
   netapp_storage_family = ontap_cluster
   goodness_function = "(capabilities.utilization < 60.0) ? 75 : 25"

In this example, the ``goodness_function`` is set for the available
backends. For every volume request, the goodness function is
calculated and used as follows:

-  If the node utilization for both backends ``ontap-iscsi-1`` and
   ``ontap-iscsi-2`` are lesser than 60%, the goodness weigher is
   set to 60 and 75 respectively. ``ontap-iscsi-2`` would be preferred
   for the Cinder volume.
-  If the node utilization for ``ontap-iscsi-1`` is greater than 60%
   and is lesser than 60 % for ``ontap-iscsi-2``, the good weigher is
   higher (75%) for ``ontap-iscsi-2`` than for ``ontap-iscsi-1`` (30%).
-  If both backends have node utilization greater than 60%, then
   ``ontap-iscsi-1`` would be preferred as it has a higher goodness
   weigher value (30 over 25)

**Example3: Using Driver Filter and Goodness Weigher**

.. code-block:: ini

   [default]
   .
   .
   scheduler_default_filters = DriverFilter,AvailabilityFilter,CapabilityFilter,CapacityFilter
   scheduler_default_weighers = GoodnessWeigher
   enabled_backends = ontap-iscsi-1,ontap-iscsi-2
   .
   .
   [ontap-iscsi-1]
   volume_driver = cinder.volume.drivers.netapp.common.NetAppDriver
   netapp_login = admin
   netapp_password = *********
   volume_backend_name = ontap-iscsi
   netapp_server_hostname = 192.168.0.101
   netapp_server_port = 80
   netapp_transport_type = http
   netapp_vserver = svm1
   netapp_storage_protocol = iscsi
   netapp_storage_family = ontap_cluster
   filter_function = "(stats.allocated_capacity_gb + volume.size) < (stats.total_capacity_gb * 10.0)"
   goodness_function = "(capabilities.utilization < 60.0) ? 60 : 30"

   [ontap-iscsi-2]
   volume_driver = cinder.volume.drivers.netapp.common.NetAppDriver
   netapp_login = admin
   netapp_password = *********
   volume_backend_name = ontap-iscsi
   netapp_server_hostname = 192.168.0.102
   netapp_server_port = 80
   netapp_transport_type = http
   netapp_vserver = svm2
   netapp_storage_protocol = iscsi
   netapp_storage_family = ontap_cluster
   goodness_function = "(capabilities.utilization < 60.0) ? 75 : 25"

This example shows how the ``filter_function`` and ``goodness_function``
can be combined together. The ``filter_function`` for ``ontap-iscsi-1``
evaluates if creating a requested volume can be performed without
exceeding ``10 * total capacity``.

-  If this check passes, the ``goodness_function`` is evaluated for
   both backends based on node utilization. The backend with the higher value
   is ultimately selected.

-  If the ``filter_function`` check fails, the Driver Filter returns only
   one host, ``ontap-iscsi-2``. The Goodness Weigher is calculated and the
   Cinder volume is placed on ``ontap-iscsi-2``
