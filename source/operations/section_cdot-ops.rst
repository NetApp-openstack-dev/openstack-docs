Operational Concerns with ONTAP
====================================

NFS v4.0 and NFS v4.1 Configuration
-----------------------------------

Be sure to refer to the `ONTAP NFS Best Practices and
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
for ONTAP.

The volume migration feature of Cinder can be used to aid in the
transition from ONTAP operating in 7-Mode to ONTAP
with minimal disruption. If you have volumes managed by Cinder on an
ONTAP operating in 7-Mode storage system, you can configure the
ONTAP instance as a new backend in the Cinder
configuration and leverage the migration feature to move existing
volumes to the new backend and then retire the ONTAP operating in
7-Mode system.

Once the two storage systems operate with Cinder, please verify that
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

The host openstack1@7mode represents the backend representing the
ONTAP operating in 7-Mode system, and openstack1@cDOT represents the
backend representing the ONTAP system. Volumes can be
migrated individually to the new backend, through the use of the cinder
migrate CLI command. For example, consider a Cinder volume with ID
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
