Data ONTAP Configuration
========================

.. _manila_data_ontap_prerequisites:

Data ONTAP Prerequisites
------------------------

The prerequisites for Data ONTAP are:

-  The driver requires a storage controller running Clustered Data ONTAP
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
      `ONTAP 8 Product
      Documentation <https://mysupport.netapp.com/documentation/productlibrary/index.html?productID=30092>`__.

.. _account-perm:

Account Permission Considerations
---------------------------------

When configuring NetApp's Manila drivers to interact with a clustered
Data ONTAP instance, it is important to choose the correct
administrative credentials to use. While an account with cluster-level
administrative permissions is normally utilized, it is possible to use
an account with reduced scope that has the appropriate privileges
granted to it. In order to use an SVM-scoped account with the Manila
driver and clustered Data ONTAP and have access to the full set of
features (including Manila Share Type Extra Specs support) availed by
the Manila driver, be sure to add the access levels for the commands
shown in :ref:`Table 6.17, “Common Access Level Permissions Required with Any
Manila Driver”<table-6.17>`, :ref:`Table 6.18, “Access Level Permissions Required For
Manila Driver for clustered Data ONTAP with share server management - with
Cluster-wide Administrative Account”<table-6.18>`, and :ref:`Table 6.19, “Access Level
Permissions Required For Manila Driver for clustered Data ONTAP without
share server management - with Cluster-wide Administrative Account”<table-6.19>`.

.. _table-6.17:

+-----------------------------+----------------+
| Command                     | Access Level   |
+=============================+================+
| ``cifs share``              | ``all``        |
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
| ``version``                 | ``readonly``   |
+-----------------------------+----------------+
| ``volume``                  | ``all``        |
+-----------------------------+----------------+
| ``vserver``                 | ``readonly``   |
+-----------------------------+----------------+
| ``security``                | ``readonly``   |
+-----------------------------+----------------+

Table 6.17. Common Access Level Permissions Required with Any Manila Driver

.. _table-6.18:

+-------------------------+----------------+
| Command                 | Access Level   |
+=========================+================+
| ``cifs create``         | ``all``        |
+-------------------------+----------------+
| ``cifs delete``         | ``all``        |
+-------------------------+----------------+
| ``kerberos-config``     | ``all``        |
+-------------------------+----------------+
| ``kerberos-realm``      | ``all``        |
+-------------------------+----------------+
| ``ldap client``         | ``all``        |
+-------------------------+----------------+
| ``ldap create``         | ``all``        |
+-------------------------+----------------+
| ``license``             | ``readonly``   |
+-------------------------+----------------+
| ``dns create``          | ``all``        |
+-------------------------+----------------+
| ``network interface``   | ``all``        |
+-------------------------+----------------+
| ``network port``        | ``readonly``   |
+-------------------------+----------------+
| ``network port vlan``   | ``all``        |
+-------------------------+----------------+
| ``vserver``             | ``all``        |
+-------------------------+----------------+

Table 6.18. Access Level Permissions Required For Manila Driver for clustered
Data ONTAP with share server management - with Cluster-wide
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

Table 6.19. Access Level Permissions Required For Manila Driver for clustered
Data ONTAP without share server management - with Cluster-wide
Administrative Account

Creating Role for Cluster-Scoped Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create a role with the necessary privileges required, with access via
ONTAP API only, use the following command syntax to create the role and
the cDOT ONTAP user:

1. Create role with appropriate command directory permissions (note you
   will need to execute this command for each of the required access
   levels as described in the earlier tables).

   ::

       security login role create –role openstack –cmddirname [required command from earlier tables] -access [Required Access Level]

2. Command to create user with appropriate role

   ::

       security login create –username openstack –application ontapi –authmethod password –role openstack

Creating Role for SVM-Scoped Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create a role with the necessary privileges required, with access via
ONTAP API only, use the following command syntax to create the role and
the cDOT ONTAP user:

1. Create role with appropriate command directory permissions (note you
   will need to execute this command for each of the required access
   levels as described in the earlier tables).

   ::

       security login role create –role openstack -vserver [vserver_name] –cmddirname [required command from earlier tables] -access [Required Access Level]

2. Command to create user with appropriate role

   ::

       security login create –username openstack –application ontapi –authmethod password –role openstack -vserver [vserver_name]

.. tip::

   For more information on how to grant access level permissions to a
   role, and then assign the role to an administrative account, please
   refer to the `System Administration Guide for Cluster
   Administrators <http://support.netapp.com>`__ document in the
   Clustered DATA ONTAP documentation.

Storage Networking Considerations
---------------------------------

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the Data LIF interfaces from Data ONTAP.

2. LIF assignment
