Operational Concerns with Data ONTAP
====================================

Considerations for the use of thin provisioning with FlexVol volumes
--------------------------------------------------------------------

Using thin provisioning, FlexVol volumes can be configured to appear to
provide more storage than available. If FlexVol volumes associated with
an aggregate show more storage as available than the physical resources
available to the aggregates (disk pools) backing the FlexVol, the
aggregate is over committed. When an aggregate is over committed, it is
possible for writes to LUNs or files in FlexVols contained by that
aggregate to fail if there is insufficient free space available to
accommodate those writes.

Consider the following scenarios:

.. note::

   For the following scenarios, assume that the reserved\_percentage is
   set to 0, and max\_over\_subscription\_ratio is set to 1.0.

Before we begin, note the cinder syntax to create a volume type that
supports thin provisioning::

    [admin@openstack ~(keystonerc_admin)]$ cinder type-create thin
    [admin@openstack ~(keystonerc_admin)]$ cinder type-key thin set thin_provisioning_support="<is> True"

Scenario A: Creating a Cinder Volume with Sufficient Available Space in
Aggregate Aggregate Capacity: 10 TB FlexVol Size: 100 TB (Thin
Provisioned) Cinder Volume 1 Size: 10TB (Thin Provisioned Extra Spec),
1TB used (volume is already provisioned). Available Space: ~9TB Cinder
Volume 2 Requirement: 5TB (Thin Provisioned)

::

    [admin@openstack ~(keystonerc_admin)]$ cinder create --name cinder-vol-a --volume-type thin 5000

The above command to create a new 5TB thin provisioned Cinder volume
will succeed. Note that the underlying aggregate (disk pool) only has
10TB of usable capacity, whereas each of the total of Cinder volume
capacities is 15TB. Both volumes will be usable, but if the aggregate
runs out of free space, it will not be possible to write to either of
these Cinder volumes, or other volumes that are backed by this
aggregate.

Scenario B: Insufficient Available Space in Aggregate Aggregate
Capacity: 10 TB FlexVol Size: 100 TB (Thin Provisioned) Cinder Volume 1
Size: 10TB (Thin Provisioned Extra Spec), 10TB used for a database
(volume is already provisioned). Available Space: ~0 Cinder Volume 2
Requirement: 10TB (Thin Provisioned)

::

    [admin@openstack ~(keystonerc_admin)]$ cinder create --name cinder-vol-b --volume-type thin 10000

The above command to create a new thin provisioned Cinder volume will
fail since there is no space available in the aggregate to satisfy the
provisioning request.

Scenario C: Resizing Thin Provisioned FlexVol Volume for Cinder
Volume(s) Aggregate Capacity: 500 TB FlexVol Size: 50 TB (Thin
Provisioned) Cinder Volume 1 Size: 10TB (Thin Provisioned Extra Spec),
10TB used (volume is already provisioned). Available: 40 TB Cinder
Volume 2 Requirement: 100TB (Thin Provisioned)

::

    [admin@openstack ~(keystonerc_admin)]$ cinder create --name cinder-vol-c --volume-type thin 100000

The above command to create a new thin provisioned Cinder volume will
fail since the FlexVol size is smaller than the requirement for
cinder-vol-c. In order to provision this 100TB Cinder volume, resize the
FlexVol and try the provisioning request again. As an alternative,
please adjust the max\_over\_subscription\_ratio from 1.0 to a higher
value. Details on this ``cinder.conf`` parameter are available below.

If you have over committed your aggregate, you must monitor your
available space and add storage to the aggregate as needed to avoid
write errors due to insufficient space. Aggregates can provide storage
to FlexVol volumes associated with more than one Storage Virtual Machine
(SVM). When sharing aggregates for thin-provisioned volumes in a
multi-tenancy environment, be aware that one tenant's aggregate space
availability can be adversely affected by the growth of another tenant's
volumes.

For more information about thin provisioning, see the following
technical reports:

-  `TR 3965: NetApp Thin Provisioning Deployment and Implementation
   Guide <http://media.netapp.com/DOCUMENTS/TR-3965.PDF>`__

-  `TR 3483: Thin Provisioning in a NetApp SAN or IP SAN Enterprise
   Environment <http://media.netapp.com/DOCUMENTS/TR3483.PDF>`__

.. note::

   Thin provisioning helps maximize storage utilization. However, if
   aggregates are over committed through thin provisioning, usage must
   be monitored, and capacity must be increased as usage nears
   predefined thresholds.

In order to provision a larger capacities than allowed, use the
``max_over_subscription_ratio`` parameter in the ``cinder.conf`` file.
For example::

    # /etc/cinder/cinder.conf

    [DEFAULT]
    …
    …
    [NetAppBackend]
    …
    …
    max_over_subscription_ratio = 2.0

In this case, the max\_over\_subscription\_ratio will permit the
creation of volumes that that are oversubscribed by a factor of 2.
Consider the following scenarios:

Scenario X: FlexVol Volume Size: 10GB max\_over\_subscription\_ratio =
1.0 Total Perceived Free Capacity for Provisioning: 1.0 \* 10 = 10GB

::

    # cinder create 10 # success
    # cinder create 11 # failure, since no oversubscription is allowed

Scenario Y: FlexVol Volume Size: 10GB max\_over\_subscription\_ratio =
2.0 Total Perceived Free Capacity for Provisioning: 2.0 \* 10 = 20GB

::

    # cinder create 10 # success
    # cinder create 20 # success, since up to 10GB of capacity can be oversubscribed
    # cinder create 21 # failure

Scenario Z: FlexVol Volume Size: 10GB max\_over\_subscription\_ratio = 4
Total Perceived Free Capacity for Provisioning: 4.0 \* 10 = 40GB

::

    # cinder create 40 # success, since up to 40GB of capacity can be oversubscribed
    # cinder create 41 # failure    

.. note::

   After adjusting the max\_over\_subscription\_ratio, restart the
   cinder scheduler and volume services. ex:

   ::

       systemctl restart openstack-cinder-{scheduler,volume}

Reserved Percentage
-------------------

This represents a part of the FlexVol that is reserved and cannot be
used for provisioning. This can be useful, for example, if a FlexVol is
used for multiple applications, some of them using storage that is not
managed by OpenStack Cinder. Specify this parameter in ``cinder.conf``:

::

    #/etc/cinder/cinder.conf

    [DEFAULT]
    …
    …
    [NetAppBackend]
    …
    …
    reserved_percentage=50

Consider another example:

FlexVol Size: 100GB Snapshot reserve: 10% Effective FlexVol Size: 90GB
max\_over\_subscription\_ratio = 1.5 reserved\_percentage = 50
#specified in ``cinder.conf`` Total Perceived Free Capacity for
Provisioning: 1.5 \* 50%\*90 = 67.5GB

::

    # cinder create 67 # succeeds since that much free space is perceived to be available
    # cinder create 68 # fails

NFS v4.0 and NFS v4.1 Configuration
-----------------------------------

Be sure to refer to the `Clustered Data ONTAP NFS Best Practices and
Implementation
Guide <http://www.netapp.com/us/system/pdf-reader.aspx?pdfuri=tcm:10-61288-16&m=tr-4067.pdf>`__
for information on how to optimally set up NFS exports for use with
OpenStack storage services such as Cinder, Manila, and Glance.

.. note::

   In order to use NFS v4 and NFS v4.1 please modify the Export Rule’s
   Access Details to Read-Only access using UNIX using System Manager
   or via command line.

.. figure:: ../images/create_export_rule_screenshot.png
   :alt: Creating Export Rule
   :width: 5.75000in

   Figure 9.1. Creating Export Rule

Volume Migration
----------------

Volume migration for Cinder has been available since the Havana release
for clustered Data ONTAP and the Icehouse release for E-Series.

The volume migration feature of Cinder can be used to aid in the
transition from Data ONTAP operating in 7-Mode to clustered Data ONTAP
with minimal disruption. If you have volumes managed by Cinder on a Data
ONTAP operating in 7-Mode storage system, you can configure the
clustered Data ONTAP instance as a new backend in the Cinder
configuration and leverage the migration feature to move existing
volumes to the new backend and then retire the Data ONTAP operating in
7-Mode system.

Once the two storage systems to operate with Cinder, please verify that
both backends have been enabled successfully and are ready to support
the migration process.

::

    $ cinder service list
    +------------------+-------------------+------+---------+-------+--------------------------+
    |      Binary      |       Host        | Zone |  Status | State |        Updated_at        |
    +------------------+-------------------+------+---------+-------+--------------------------+
    | cinder-scheduler |     openstack1    | nova | enabled |   up  | 2013-1-1T19:01:26.000000 |
    |  cinder-volume   |  openstack1@7mode | nova | enabled |   up  | 2013-1-1T19:01:18.000000 |
    |  cinder-volume   |  openstack1@cDOT  | nova | enabled |   up  | 2013-1-1T19:01:27.000000 |
    +------------------+-------------------+------+---------+-------+--------------------------+

The host openstack1@7mode represents the backend representing the Data
ONTAP operating in 7-Mode system, and openstack1@cDOT represents the
backend representing the clustered Data ONTAP system. Volumes can be
migrated individually to the new backend, through the use of the cinder
migrate CLI command. For example, consider a Cidner volume with ID
781501e1-af79-4d3e-be90-f332a5841f5e on the openstack1@7mode storage
backend. In order to migrate it to the openstack1@cDOT backend, please
execute::

    # cinder migrate 781501e1-af79-4d3e-be90-f332a5841f5e openstack1@cDOT

The command is asynchronous and completes in the background. In order to
check the status of the migration, use the cinder show command, and
ensure that migration\_status indicates success::

    # cinder show 781501e1-af79-4d3e-be90-f332a5841f5e
    ...
    |        migration_status        |         success      |
    ...

While a volume migration is in progress, Cinder commands from tenants
that involve operations on the volume (such as attach/detach, snapshot,
clone, etc) will fail. If using a hypervisor that does not support live
migration of volumes and the volume is currently attached, it is
necessary to detach the volume from the Nova instance before performing
the migration. If the volume is the boot volume or otherwise critical to
the operation of the instance, please shutdown the Nova instance before
using cinder migrate.

Live Migration
--------------

Current support for live migration, a Nova feature, is available in the
Nova Feature Support Matrix. Details on using live migration for Nova
instances are available in the OpenStack Admin Guide and the Instance
Storage Options at the Hypervisor section.

.. note::

   In order to use live migration with E-Series it is necessary to set
   netapp\_enable\_multiattach in ``cinder.conf``. Please refer to Nova
   Live Migration of Instances with Attached E-Series Volumes.
