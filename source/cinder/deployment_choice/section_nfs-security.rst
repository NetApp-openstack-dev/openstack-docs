.. _nfs_security:

Deployment Choices: NFS Security
================================

Options
-------

Starting with the Kilo release of OpenStack, two NAS security options were
introduced to improve NFS security.

The Cinder design assumes that the connections from OpenStack nodes to NFS
backends use trusted physical networks. Also, OpenStack services are assumed
to run on dedicated nodes whose processes are trusted. Exposure of storage
resources to tenants is mediated by the hypervisor under control of Cinder
and Nova. Prior to the introduction of the two NAS security options, operations
on the backing files for Cinder volumes only ran as *root* and the files
themselves were readable and writable by any user on OpenStack nodes that
mounted the NFS backend shares.


.. note::

   Consult with the OpenStack distribution documentation to determine
   supportability of this feature.

+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                            | Type       | Default Value   | Description                                                                                                                                                                                                                                                                                     |
+===================================+============+=================+=================================================================================================================================================================================================================================================================================================+
| ``nas_secure_file_operations``    | Optional   | "auto"          | Run operations on backing files for Cinder volumes as *cinder* user rather than *root* if 'True'; as *root* if 'False'. If 'auto', run as 'True' if in a "greenfield" environment and run as 'False' if existing volumes are found on startup.                                                  |
+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nas_secure_file_permissions``   | Optional   | "auto"          | Create backing files for Cinder volumes to only be readable and writable by owner and group if 'True'; as readable and writable by owner, group, and world if 'False'. If 'auto', run as 'True' if in a "greenfield" environment and run as 'False' if existing volumes are found on startup.   |
+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.10. Configuration options for NFS Security

When ``nas_secure_file_operations`` is set to 'true', Cinder operations run as
the dedicated *cinder* user rather than as *root*.

When the ``nas_secure_file_permissions`` is set to 'true', backing files for
Cinder volumes are only readable and writable by owner and group (mode 0660
rather than 0666). Since Cinder creates these files with both owner and group
*cinder*, only system processes running with UID or GID *cinder* are allowed
to read or write these files.

When both ``nas_secure_file_operations`` and ``nas_secure_file_permissions``
are set to 'true' setting the *Superuser Security Type* (also known as
"root squash") to none on the ONTAP export policy is recommended.

The default value of both of these options is 'auto'. For backwards
compatibility, if cinder volumes already exist when Cinder starts
up and the value of one of these options is 'auto', it is set to 'false'
internally. If no cinder volumes already exist, a greenfield environment,
the option is set to 'true' and a marker file *.cinderSecureEnvIndicator*
is created under the mount directory. On startup, the marker file is
checked so that the 'true' option will be persisted for subsequent
startups after volumes have been created. It is recommended that the
``nas_secure_file_operations`` and ``nas_secure_file_permissions`` are
both specified in the ``/etc/cinder.conf`` as either 'true' or 'false'.

Setup
-----

When NAS security options are enabled, OpenStack Cinder, Nova, and Glance
nodes, as well as Data ONTAP, must be configured appropriately for OpenStack
operations to succeed. If not configured appropriately read and write
operations of the backing files will fail.

The overall objective is to limit all read and write permissions of the backing
file for cinder volumes to only the cinder user's UID and GID.

ONTAP Setup
-----------
-  If you are using an identity service (i.e. NIS, LDAP, etc...) with ONTAP,
   ensure that there are *cinder*, *nova*, and *glance* user and group
   identities with *UID* and *GID* that match the corresponding users on the
   OpenStack Cinder, Nova, and Glance nodes.

-  In ONTAP, put the *cinder*, *nova*, and *glance* users in the *cinder* group.

-  Ensure that the exported ONTAP volume has owner *cinder* and group *cinder*.

-  Set permissions on the exported share to 0755.

-  Disable ``Superuser Security Type`` (i.e. root squash) and ``SetUID`` access in
   export policies.

-  See `NetApp TR3850: NFSv4 Enhancements and Best Practices Guide: Data
   ONTAP Implementation <http://www.netapp.com/us/media/tr-3580.pdf>`__
   and `NetApp TR4067: Clustered Data ONTAP NFS Best Practice and
   Implementation Guide <http://www.netapp.com/us/media/tr-4067.pdf>`__,
   as well as the File Access and Protocols Management Guides available
   from the NetApp NOW site for setup information.

OpenStack Setup
---------------

-  On Cinder and Nova nodes, for NFSv4, set the *Domain* in
   */etc/idmapd.conf* on both storage and compute nodes to match that of
   the NFS server. Restart idmapd service.

-  On Nova nodes, add the *nova* user to the *cinder* group.

-  On Nova nodes, set "user = 'nova'", "group = 'cinder'", and
   "dynamic\_ownership = 0" in */etc/libvirt/qemu.conf*.

-  On Nova nodes, restart libvirt, qemu, and kvm processes or reboot the
   hypervisor. Also, restart Nova services.


NAS Security Checklists
-----------------------

The following checklists can be used as a reference to disable or enable NAS
security. Some commands may differ based on the version of Linux being used.
Disabling or enabling NAS security is disruptive to OpenStack processes.

Disable NAS Security
^^^^^^^^^^^^^^^^^^^^

The following checklist provides the steps necessary for disabling NAS security.

+------+------------------------------------------------------------+---------+
| #    | Description of Step                                        | Done?   |
+======+============================================================+=========+
| 1    | Cinder: Change NAS security options                        |         |
+------+------------------------------------------------------------+---------+
| 2    | Cinder: Delete .cinderSecureEnvIndicator file              |         |
+------+------------------------------------------------------------+---------+
| 3    | ONTAP: Allow Superuser access in export policy             |         |
+------+------------------------------------------------------------+---------+
| 4    | Cinder: Change file permissions                            |         |
+------+------------------------------------------------------------+---------+
| 5    | Cinder: Verify mounts and permissions                      |         |
+------+------------------------------------------------------------+---------+

Table 4.11 Checklist to Disable NAS Security

1. Set the ``nas_secure_file_operations`` and ``nas_secure_file_permissions`` to specify
the NAS security mode.

Make changes to /etc/cinder/cinder.conf in the ``[DEFAULT]`` stanza.

   ::

       [DEFAULT]
       ...
       nas_secure_file_operations = false
       nas_secure_file_permissions = false
       ...
 
2. Delete the .cinderSecureEnvIndicator file if it exists.

The Cinder volume service will create the .cinderSecureEnvIndicator file as an
indicator that NAS security is enabled.

   ::

       $ mount
       ...
       192.168.100.10:/cinder_flexvol_1 on /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c type nfs (rw,...,addr=192.168.100.10)
       192.168.100.10:/cinder_flexvol_2 on /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b type nfs (rw,...,addr=192.168.100.10)
       ...
       $ cd /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c
       $ rm .cinderSecureEnvIndicator 
       $ cd /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b
       $ rm .cinderSecureEnvIndicator 

3. Enable Superuser access in the export policy.

   ::

       CDOT:> vserver export-policy rule show -vserver replace-with-vserver-name -policyname replace-with-policy-name -ruleindex replace-with-rule-index 
       ...
       Superuser Security Types: none
       ...
       CDOT:> vserver export-policy rule modify -vserver replace-with-vserver-name -policyname replace-with-policy-name -ruleindex replace-with-rule-index -protocol nfs -superuser any --allow-suid true
       CDOT:> vserver export-policy rule show -vserver replace-with-vserver-name -policyname replace-with-policy-name -ruleindex replace-with-rule-index 
       ...
       Superuser Security Types: any 
       ...

4. Change file permissions to 0666.

Other OpenStack services (i.e. Nova and Glance) need "world" rw privileges in order to access the cinder volumes.
This is accomplished by running chmod 0666 on all files in the mount points. Order of operations are stop Cinder
services, run chmod, unmount mount points, and start Cinder services.

   ::

       $ systemctl stop openstack-cinder-{api,scheduler,volume}
       $ mount
       ...
       192.168.100.10:/cinder_flexvol_1 on /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c type nfs (rw,...,addr=192.168.100.10)
       192.168.100.10:/cinder_flexvol_2 on /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b type nfs (rw,...,addr=192.168.100.10)
       ...
       $ cd /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c
       $ chmod -R 0666 *
       $ cd /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b
       $ chmod -R 0666 *
       $ cd /var/lib/cinder/mnt
       $ sudo umount 69809486d67b39d4baa19744ef3ef90c 
       $ sudo umount 5821d3908bfae68920f0c7be2dfc0c7b
       $ systemctl start openstack-cinder-{api,scheduler,volume}

5. Verify mounts and permissions.

 In the previous step we unmounted the NFS mounts to prove that they are mounted properly when the Cinder volume service
 starts. Verify this by examining the Cinder volume service log, creating a new Cinder volume, and listing the volume
 on the mount point.

   ::

       $ cinder create --name test-vol-01 1
       ...
       | id                             | 9c989cba-eff6-4847-b5fc-bff2ab5d35da |
       ...
       $ ls -l /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b/volume-9c989cba-eff6-4847-b5fc-bff2ab5d35da
       ...
       -rw-rw-rw- 1 root root 1073741824 Oct 12 13:15 /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b/volume-9c989cba-eff6-4847-b5fc-bff2ab5d35da
       ...


Enable NAS Security
^^^^^^^^^^^^^^^^^^^

The following checklist provides the steps necessary for disabling NAS security.

+------+------------------------------------------------------------+---------+
| #    | Description of Step                                        | Done?   |
+======+============================================================+=========+
| 1    | Cinder: Change NAS security options                        |         |
+------+------------------------------------------------------------+---------+
| 2    | Cinder: Determine cinder user's UID and GID                |         |
+------+------------------------------------------------------------+---------+
| 3    | Nova & Glance: Add users to cinder group                   |         |
+------+------------------------------------------------------------+---------+
| 4    | QEMU: Change QEMU configuration                            |         |
+------+------------------------------------------------------------+---------+
| 5    | ONTAP: Disable superuser access in export policy           |         |
+------+------------------------------------------------------------+---------+
| 6    | ONTAP: Set exported Flexvol owner and group                |         |
+------+------------------------------------------------------------+---------+
| 7    | ONTAP: Set exported Flexvol permissions                    |         |
+------+------------------------------------------------------------+---------+
| 8    | Cinder: Change file permissions                            |         |
+------+------------------------------------------------------------+---------+
| 9    | Cinder: Verify mounts and permissions                      |         |
+------+------------------------------------------------------------+---------+

Table 4.12 Checklist to Disable NAS Security


1. Set the ``nas_secure_file_operations`` and ``nas_secure_file_permissions`` to specify
the NAS security mode.

Make changes to /etc/cinder/cinder.conf in the ``[DEFAULT]`` stanza.

   ::

       [DEFAULT]
       ...
       nas_secure_file_operations = true 
       nas_secure_file_permissions = true 
       ...
 

2. Determine the cinder user's UID and GID.

   ::

       $ id -u cinder
       500
       $ id -g cinder
       510

3. Add users to cinder group.

To have file access, Nova and Glance service users need to belong to the same group as the Cinder
user. As commands for manipulating Linux users vary across environments an example is not provided
for this step.

4. Change QEMU configuration.

Certain compute operations (i.e. attaching a volume) require that Libvirt, Qemu, and KVM run as a user
belonging to the correct group. Edit the /etc/libvirt/qemu.conf file and make the following changes.
After making the configuration changes restart the needed libvirt, QEMU, KVM processes or restart the 
hypervisor. The Nova services also need to be restarted.

Make changes to /etc/libvirt/qemu.conf.

   ::

       ...
       #user = "root"
       user= "nova"
       ...
       #group = "root"
       group = "cinder"
       ...
       #dynamic_ownership = 1
       dynamic_ownership = 0
       ...

5. Disable superuser access in export policy.

Disabling superuser access in the export policy is effectively the same as enabling root squash. Any
root access from a NFS client (i.e. UID 0) is remapped to the anonymous user, default UID is 65534,
when superuser access is disabled. This step also disables set user ID (suid) access.

   ::

       CDOT:> vserver export-policy rule show -vserver replace-with-vserver-name -policyname replace-with-policy-name -ruleindex replace-with-rule-index 
       ...
       Superuser Security Types: any 
       ...
       CDOT:> vserver export-policy rule modify -vserver replace-with-vserver-name -policyname replace-with-policy-name -ruleindex replace-with-rule-index -protocol nfs -superuser none --allow-suid false 

       CDOT:> vserver export-policy rule show -vserver replace-with-vserver-name -policyname replace-with-policy-name -ruleindex replace-with-rule-index 
       ...
       Superuser Security Types: none 
       ...

6.  Set exported Flexvol owner and group.

Access to a Flexvol can be further restricted by only allowing a specific User ID (UID) and Group ID (GID).
The UID must match the cinder UID of the Cinder node. The GID must match the cinder GID of the Cinder node.
In this example, the UID is 500 and the GID is 510. These values will be different on your cinder node and
must be determined prior to running the following commands.

   ::

       CDOT:> volume show -vserver replace-with-vserver-name -volume replace-with-volume-name
       ...
       User ID: 0
       Group ID: 0
       ...
       CDOT:> volume modify -vserver replace-with-vserver-name -volume replace-with-volume-name -user 500 -group 510
       CDOT:> volume show -vserver replace-with-vserver-name -volume replace-with-volume-name
       ...
       User ID: 500 
       Group ID: 510 
       ...

7. Set exported Flexvol permissions.

Access can be further restricted by setting the UNIX permissions on a volume. In this example we set the
Flexvol permissions, of the shared volume, to 0755.

   ::

       CDOT:> volume show -vserver replace-with-vserver-name -volume replace-with-volume-name
       ...
       UNIX Permissions: ---rwxrwxrwx
       ...
       CDOT:> volume modify -vserver replace-with-vserver-name -volume replace-with-volume-name -unix-permissions 0755 
       CDOT:> volume show -vserver replace-with-vserver-name -volume replace-with-volume-name
       ...
       UNIX Permissions: ---rwxr-xr-x
       ...

8. Change file permissions to 0660.

Other OpenStack services (i.e. Nova and Glance) need "group" rw privileges in order to access the cinder volumes.
This is accomplished by running chmod 0660 on all files in the mount points. Order of operations are stop Cinder
services, run chmod, unmount mount points, and start Cinder services.

   ::

       $ systemctl stop openstack-cinder-{api,scheduler,volume}
       $ mount
       ...
       192.168.100.10:/cinder_flexvol_1 on /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c type nfs (rw,...,addr=192.168.100.10)
       192.168.100.10:/cinder_flexvol_2 on /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b type nfs (rw,...,addr=192.168.100.10)
       ...
       $ cd /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c
       $ chmod -R 0660 *
       $ cd /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b
       $ chmod -R 0660 *
       $ cd /var/lib/cinder/mnt
       $ sudo umount 69809486d67b39d4baa19744ef3ef90c 
       $ sudo umount 5821d3908bfae68920f0c7be2dfc0c7b
       $ systemctl start openstack-cinder-{api,scheduler,volume}

9. Verify mounts and permissions.

 In the previous step we unmounted the NFS mounts to prove that they are mounted properly when the Cinder volume service
 starts. Verify this by examining the Cinder volume service log, creating a new Cinder volume, and listing the volume
 on the mount point.

   ::

       $ cinder create --name test-vol-01 1
       ...
       | id                             | 9c989cba-eff6-4847-b5fc-bff2ab5d35da |
       ...
       $ ls -l /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b/volume-9c989cba-eff6-4847-b5fc-bff2ab5d35da
       ...
       -rw-rw-rw- 1 root root 1073741824 Oct 12 13:15 /var/lib/cinder/mnt/5821d3908bfae68920f0c7be2dfc0c7b/volume-9c989cba-eff6-4847-b5fc-bff2ab5d35da
       ...
