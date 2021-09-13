.. _manila_flexgroup_pools:

Deployment Choice: Utilizing FlexGroup Pool
===========================================

An ONTAP FlexGroup volume is a scale-out NAS container that provides high
performance along with automatic load distribution and scalability. A FlexGroup
volume can provision a massive single namespace using the entire cluster
resources. While a FlexVol volume is limited by the maximum of 100TB, a
FlexGroup can grow until 20PB.

Starting from Xena release, NetApp ONTAP driver has support for provisioning
and managing FlexGroup shares. The driver reports an specific pool for
FlexGroup purpose. In another words, before Xena all NetApp ONTAP pools
provision share as FlexVol, with Xena release, the pool is either for FlexGroup
or FlexVol provisioning, depending on the setup.

The main difference of the pool styles is the aggregate view: while the FlexVol
is resided on one of the cluster’s aggregates, the FlexGroup may be resided on
several aggregates in the same cluster.

To keep compatible with previous release, the FlexVol pools continue to be
reported. With FlexGroup setup, the FlexVol and FlexGroup pools will work
together in the same backend by default. The driver supports standalone
FlexGroup pools, though.

.. important::

   The FlexGroup feature requires ONTAP 9.8 or newer.

.. important::

   The FlexGroup share management has some limitations:
       - Migration to another pools is not supported;
       - Migration of share server containing FlexGroup shares is not allowed;
       - Consistency group is not supported;
       - Replication with more than one non-active replica is only allowed with
         ONTAP 9.9.1 or newer.
       - The ``utilization`` metric is currently unsupported for FlexGroup
         pools and is not calculated. It's value is always set to the default
         of 50.

.. warning::

    Configuring FlexGroup pool drops the consistency group support for the
    entire backend. Therefore, if it is planned to work or it has been working
    with consistency groups, it must not configure FlexGroup pools in the
    backend. Even the FlexVol pools lose its support.

The FlexGroup pool is not enabled by default, the administrator has to
configure the ``manila.conf``. There are two modes: auto provisioning pool or
custom pool.

Configuring Auto-Provisioning FlexGroup Pool
--------------------------------------------

The easiest and recommended way to configure the FlexGroup is by using the
auto-provisioning mode. In this mode, the driver will report a single pool
named as ``auto_flexgroup`` that represents the entire cluster's aggregates
(or SVM). In case the scheduler chooses that pool, the ONTAP will select in
which set of aggregates the share will be provisioned based on its own
algorithm. The operator has no control of the aggregate selection for the
FlexGroup share.

.. note::

    ONTAP selects two aggregates with the largest amount of usable space on
    each node to create the FlexGroup volume. If two aggregates are not
    available, ONTAP selects one aggregate per node to create the
    FlexGroup share.

To start working with auto-provisioning FlexGroup, add to the backend
configuration the option ``netapp_enable_flexgroup`` as ``True``.

Configuring Custom FlexGroup Pool
---------------------------------

If desired, the driver can control the set of aggregates where the
FlexGroup share is created. Instead of relying on ONTAP selection, the
administrator can manually configure the FlexGroup pools, informing their names
and their list of aggregates.

To start working with custom FlexGroup pool, add to the backend configuration
the options ``netapp_enable_flexgroup`` as ``True`` together with
``netapp_flexgroup_pools`` with the FlexGroup pools (name and list of
aggregates). Example of a backend:

::

    [cdotWithFlexGroup]
    share_backend_name = cdotWithFlexGroup
    ...
    netapp_enable_flexgroup = True
    netapp_flexgroup_pools = fg1: aggr1 aggr2, fg2: aggr2 aggr3
    ...

.. _manila-conf-with-flexgroup:

In this example, the backend ``cdotWithFlexGroup`` will report two FlexGroup
pools: ``fg1`` that is over ``aggr1`` and ``aggr2`` and pool ``fg2`` that is
over ``aggr2`` and ``aggr3``. So, if the scheduler selected, for instance, the
pool ``fg1``, the created share will be a FlexGroup volume on ``aggr1`` and
``aggr2``.

FlexGroup Pool Standalone
-------------------------

To work with FlexGroup pools standalone, in the backend with FlexGroup
configuration (either auto-provisioning or custom one), add the configuration
option ``netapp_flexgroup_pool_only`` as ``True``.

.. caution::

    Enabling the FlexGroup pool only option will stop reporting the FlexVol
    pools. Make sure that the backend has no FlexVol shares, otherwise those
    shares may not be managed by Manila anymore.
