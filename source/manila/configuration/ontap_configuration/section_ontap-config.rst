ONTAP Configuration
===================

.. _manila_data_ontap_prerequisites:

ONTAP Prerequisites
-------------------

The prerequisites for ONTAP are:

-  The driver requires a storage controller running ONTAP
   8.2 or later.

-  The storage system should have the following licenses applied:

   -  Base

   -  NFS (if the NFS storage protocol is to be used)

   -  CIFS (if the CIFS/SMB storage protocol is to be used)

   -  SnapMirror (if share replication is to be enabled)

   -  FlexClone

.. _storage_virtual_machine_considerations:

Storage Virtual Machine Considerations
--------------------------------------

When using the NetApp Manila driver in the mode where it does not manage
share servers, it is important to pay attention to the following
considerations:

1. Ensure the appropriate licenses (as described previously) are enabled
   on the storage system for the desired use case.

2. The SVM referenced in the ``netapp_vserver`` option must be created
   (and associated with aggregates) before it can be utilized as a
   provisioning target for Manila.  If cluster-level credentials have
   not been specified in the configuration file, ensure that no root
   aggregates are associated with the SVM, since the driver will not
   be able to guarantee that automatically.

3. Data LIFs must be created and assigned to SVMs before configuring
   Manila.

4. If NFS is used as the storage protocol:

   1. Be sure to enable the NFS service on the SVM.

   2. Be sure to enable the desired version of the NFS protocol (e.g.
      ``v4.0, v4.1-pnfs``) on the SVM.

5. If CIFS is used as the storage protocol:

   1. Be sure to enable the CIFS service on the SVM.

   2. Be sure to set CIFS as the data protocol on the data LIF.

6. In order to support share replication:

   1. Ensure all ONTAP clusters with the same ``replication_domain`` are
      peered, have intercluster LIFs configured, and are of equal ONTAP
      versions.

   2. Ensure all SVMs with the same ``replication_domain`` are peered
      and have unique names.

   3. For more information about ONTAP data protection, please see the
      `ONTAP 9 Product
      Documentation <https://mysupport.netapp.com/documentation/productlibrary/index.html?productID=62286>`__.

7. If setting up Manila without share servers, ensure that one or 
   more aggregates are permitted to be used by the SVM. Use ``vserver 
   show -vserver <vserver> -fields aggr-list`` to see which aggregates 
   are all ready assigned.  You can use ``vserver add-aggregates 
   -vserver <vserver> -aggregates <first aggr,second aggr>`` to add 
   aggregates to your SVM that Manila will be able to use.

8. If you wish to assign QoS policies to Manila shares, do not assign the SVM
   used to a QoS policy group on ONTAP. Manila shares correspond to FlexVols
   on ONTAP and FlexVols are constituents of an SVM. ONTAP does not
   support nested QoS policies.

.. _account-perm:

Account Permission Considerations
---------------------------------

When configuring NetApp's Manila drivers to interact with an
ONTAP instance, it is important to choose the correct
administrative credentials to use.

While an account with cluster-level
administrative permissions is normally utilized, it is possible to use
an account with reduced scope that has the appropriate privileges
granted to it. In order to use an SVM-scoped account with the Manila
driver and ONTAP and have access to the full set of
features (including Manila Share Type Extra Specs support) availed by
the Manila driver, be sure to add the access levels for the commands
shown in :ref:`Table 6.17, “Common Access Level Permissions Required with Any
Manila Driver”<table-6.17>`, :ref:`Table 6.18, “Access Level Permissions Required For
Manila Driver for ONTAP with share server management - with
Cluster-wide Administrative Account”<table-6.18>`, and :ref:`Table 6.19, “Access Level
Permissions Required For Manila Driver for ONTAP without
share server management - with Cluster-wide Administrative Account”<table-6.19>`.

.. note::

   The commands listed in the tables below are for ONTAP 9 releases.

.. _table-6.17:

+-----------------------------+----------------+
| Command                     | Access Level   |
+=============================+================+
| ``vserver cifs share``      | ``all``        |
+-----------------------------+----------------+
| ``event``                   | ``all``        |
+-----------------------------+----------------+
| ``network interface``       | ``readonly``   |
+-----------------------------+----------------+
| ``vserver export-policy``   | ``all``        |
+-----------------------------+----------------+
| ``volume snapshot``         | ``all``        |
+-----------------------------+----------------+
| ``version``                 | ``readonly``   |
+-----------------------------+----------------+
| ``system node``             | ``readonly``   |
+-----------------------------+----------------+
| ``volume``                  | ``all``        |
+-----------------------------+----------------+
| ``vserver``                 | ``readonly``   |
+-----------------------------+----------------+
| ``security``                | ``readonly``   |
+-----------------------------+----------------+
| ``statistics``              | ``all``        |
+-----------------------------+----------------+
| ``job`` [#f1]_              | ``readonly``   |
+-----------------------------+----------------+

Table 6.17. Common Access Level Permissions Required with Any Manila Driver

.. _table-6.18:

+-------------------------------------------------------+----------------+
| Command                                       	| Access Level   |
+=======================================================+================+
| ``vserver cifs create``                		| ``all``        |
+-------------------------------------------------------+----------------+
| ``vserver cifs delete``                		| ``all``        |
+-------------------------------------------------------+----------------+
| ``vserver nfs kerberos interface``     		| ``all``        |
+-------------------------------------------------------+----------------+
| ``vserver nfs kerberos realm``         		| ``all``        |
+-------------------------------------------------------+----------------+
| ``vserver services name-service ldap client``         | ``all``        |
+-------------------------------------------------------+----------------+
| ``vserver services name-service ldap create``         | ``all``        |
+-------------------------------------------------------+----------------+
| ``license``                                           | ``readonly``   |
+-------------------------------------------------------+----------------+
| ``vserver services name-service dns create``          | ``all``        |
+-------------------------------------------------------+----------------+
| ``network interface``                                 | ``all``        |
+-------------------------------------------------------+----------------+
| ``network port``                                      | ``readonly``   |
+-------------------------------------------------------+----------------+
| ``network port vlan``                                 | ``all``        |
+-------------------------------------------------------+----------------+
| ``vserver``                                           | ``all``        |
+-------------------------------------------------------+----------------+
| ``qos policy-group``                                  | ``all``        |
+-------------------------------------------------------+----------------+

Table 6.18. Access Level Permissions Required For Manila Driver for
ONTAP with share server management - with Cluster-wide
Administrative Account

.. _table-6.19:

+-------------------------+----------------+
| Command                 | Access Level   |
+=========================+================+
| ``license``             | ``readonly``   |
+-------------------------+----------------+
| ``storage aggregate``   | ``readonly``   |
+-------------------------+----------------+
| ``storage disk``        | ``readonly``   |
+-------------------------+----------------+
| ``qos policy-group``    |   ``all``      |
+-------------------------+----------------+

Table 6.19. Access Level Permissions Required For Manila Driver for
ONTAP without share server management - with Cluster-wide
Administrative Account

Creating Role for Cluster-Scoped Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create a role with the necessary privileges required, with access via
ONTAP API only, use the following command syntax to create the role and
the ONTAP user:

1. Create role with appropriate command directory permissions (note you
   will need to execute this command for each of the required access
   levels as described in the earlier tables).

   ::

       security login role create –role openstack –cmddirname [required command from earlier tables] -access [Required Access Level]

2. Command to create user with appropriate role

   ::

       security login create –username openstack –application ontapi –authmethod password –role openstack

3. (REST mode only) Add access for ``http`` application [#f2]_

   ::

       security login create –username openstack –application http –authmethod password –role openstack

Creating Role for SVM-Scoped Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create a role with the necessary privileges required, with access via
ONTAP API only, use the following command syntax to create the role and
the ONTAP user:

1. Create role with appropriate command directory permissions (note you
   will need to execute this command for each of the required access
   levels as described in the earlier tables).

   ::

       security login role create –role openstack -vserver [vserver_name] –cmddirname [required command from earlier tables] -access [Required Access Level]

2. Command to create user with appropriate role

   ::

       security login create –username openstack –application ontapi –authmethod password –role openstack -vserver [vserver_name]

3. (REST mode only) Add access for ``http`` application [#f2]_

   ::

       security login create –username openstack –application http –authmethod password –role openstack -vserver [vserver_name]

.. tip::

   For more information on how to grant access level permissions to a
   role, and then assign the role to an administrative account, please
   refer to the `System Administration Guide for Cluster
   Administrators <http://support.netapp.com>`__ document in the
   ONTAP documentation.

.. note::

   SVM-Scoped user accounts do not support the configuration of the
   ``reserved_share_percentage`` config option. SVM-Scoped user
   accounts can only work if the option is set to ``0``.

Storage Networking Considerations
---------------------------------

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the Data LIF interfaces from ONTAP.

2. LIF assignment

.. rubric:: Footnotes

.. [#f1] ``job`` access is only required if a FlexGroup pool is configured or
         running with REST mode.

.. [#f2] The step 3 is only required if enabling the REST communication mode.
         See :ref:`manila_rest_communication` for more details.
