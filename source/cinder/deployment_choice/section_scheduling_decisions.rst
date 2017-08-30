Construct Mappings between Cinder and Data ONTAP
================================================

Cinder Scheduling and Resource Pool Selection
---------------------------------------------

When Cinder volumes are created, the Cinder scheduler selects a resource
pool from the available storage pools: see
:ref:`storage-pools` for an overview.
:ref:`Table 4.9, “Behavioral Differences in Cinder Volume Placement”
<cinder-theory-table-4.9>` details the behavioral changes in NetApp's
Cinder drivers when scheduling the provisioning of new Cinder volumes.

Beginning with Juno, each of NetApp's Cinder drivers report per-pool
capacity to the scheduler. When a new volume is provisioned, the
scheduler capacity filter eliminates too-small pools from consideration.
Similarly, the scheduler's capability, availability zone and other
filters narrow down the list of potential backends that may receive a
new volume based on the volume type and other volume characteristics.

The scheduler also has an evaluator filter that evaluates an optional
arithmetic expression to determine whether a pool may contain a new
volume. Beginning with Mitaka, the Data ONTAP drivers report per-pool
controller utilization values to the scheduler, along with a "filter
function" that prevents new volumes from being created on pools that are
overutilized. Controller utilization is computed by the drivers as a
function of CPU utilization and other internal I/O metrics. The default
filter function supplied by the Data ONTAP drivers is
"capabilities.utilization < 70". A utilization of 70% is a good starting
point beyond which I/O throughput and latency may be adversely affected
by additional Cinder volumes. The filter function may be overridden on a
per-backend basis in the Cinder configuration file. See `Configure and
use driver filter and weighing for
scheduler <http://docs.openstack.org/admin-guide/blockstorage-driver-filter-weighing.html>`__
for details about using the evaluator functions in Cinder.

Each candidate pool that passes the filters is then considered by the
scheduler's weighers so that the optimum one is chosen for a new volume.
As of Juno, the Cinder scheduler has per-pool capacity information, and
the scheduler capacity weigher may be configured to spread new volumes
among backends uniformly or to fill one backend before using another.

Beginning with Mitaka, the Data ONTAP drivers report per-pool controller
utilization values to the scheduler, along with a "goodness function"
that allows the scheduler to prioritize backends that are less utilized.
Controller utilization is reported as a percentage, and the goodness
function is expected to yield a value between 0 and 100, with 100
representing maximum "goodness". The default goodness function supplied
by the Data ONTAP drivers is "100 - capabilities.utilization", and it
may be overridden on a per-backend basis in the Cinder configuration
file.

.. note::

   The storage controller utilization metrics are reported by the
   Mitaka Cinder drivers for Data ONTAP 8.2 or higher, operating in
   either Cluster or 7-mode.

Beginning with Newton, additional information such as aggregate name and
aggregate space utilization is reported to the scheduler and may be used
in filter and weigher expressions. For example, to keep from filling an
aggregate completely, a filter expression of
"capabilities.aggregate_used_percent < 80" might be used.

Beginning with Ocata, additional information such as per-pool
consumption of the Data ONTAP shared block limit is reported to the
scheduler and may be used in filter and weigher expressions.  For
example, to steer new Cinder volumes away from a FlexVol nearing its
shared block limit, a filter expression of
"capabilities.netapp_dedupe_used_percent < 90" might be used.
 
.. _cinder-theory-table-4.9:

+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Driver                           | Scheduling Behavior (as of Juno)                                                                                                                                                                                                  | Scheduling Behavior (as of Mitaka)                                                                                                                                                                                    |
+==================================+===================================================================================================================================================================================================================================+=======================================================================================================================================================================================================================+
| Clustered Data ONTAP             | Each FlexVol volume’s capacity and SSC data is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.               | Same as Juno. Also, per-pool storage controller utilization is reported to the scheduler, along with filter and goodness expressions that take controller utilization into account when making placement decisions.   |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Data ONTAP operating in 7-mode   | Each FlexVol volume’s capacity is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.                            | Same as Juno. Also, per-pool storage controller utilization is reported to the scheduler, along with filter and goodness expressions that take controller utilization into account when making placement decisions.   |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| E-Series                         | -  Each dynamic disk pool's and volume group’s capacity is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.   | Same as Juno.                                                                                                                                                                                                         |
|                                  |                                                                                                                                                                                                                                   |                                                                                                                                                                                                                       |
|                                  | -  E-Series volume groups are supported as of the Liberty release.                                                                                                                                                                |                                                                                                                                                                                                                       |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.9. Behavioral Differences in Cinder Volume Placement

