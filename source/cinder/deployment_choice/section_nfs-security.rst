Deployment Choices: NFS Security
================================

Options
-------

Starting with the Kilo release of OpenStack, deployers of NFS backends
for Cinder have a choice: to enable *NAS security* options, or not.

Cinder traditionally worked on the assumption that the connections from
OpenStack nodes to NFS backends used trusted physical networks and that
OpenStack services run on dedicated nodes whose users and processes were
trusted. Exposure of storage resources to tenants was always mediated by
the hypervisor under control of Cinder and Nova. Operations on the
backing files for Cinder volumes ran as *root* and the files themselves
were readable and writable by any user or process on OpenStack nodes
that mounted the NFS backend shares.

Starting with Kilo, two NAS security options were introduced that enable
the OpenStack operator, in concert with the NAS storage administrator,
to reduce the potential attack surface created by allowing such liberal
access to users and processes running on OpenStack storage and compute
nodes.

+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                            | Type       | Default Value   | Description                                                                                                                                                                                                                                                                                     |
+===================================+============+=================+=================================================================================================================================================================================================================================================================================================+
| ``nas_secure_file_operations``    | Optional   | "auto"          | Run operations on backing files for Cinder volumes as *cinder* user rather than *root* if 'true'; as *root* if 'false'. If 'auto', run as 'true' if in a "greenfield" environment and run as 'false' if existing volumes are found on startup.                                                  |
+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nas_secure_file_permissions``   | Optional   | "auto"          | Create backing files for Cinder volumes to only be readable and writable by owner and group if 'true'; as readable and writable by owner, group, and world if 'false'. If 'auto', run as 'true' if in a "greenfield" environment and run as 'false' if existing volumes are found on startup.   |
+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Tablei 4.10. Configuration options for NFS Security

When ``nas_secure_file_operations`` is set to 'true', Cinder operations
on the backing files for Cinder volumes run as the dedicated *cinder*
user rather than as *root*. With this option enabled, the NFS storage
administrator can export shares with *root* "squashed", i.e. mapped to
an anonymous user without privileges. When the
``nas_secure_file_permissions`` is set to 'true', backing files for
Cinder volumes are only readable and writable by owner and group - mode
0660 rather than 0666. Since Cinder creates these files with both owner
and group *cinder*, only system processes running with uid or gid
*cinder* are allowed to read or write these files, assuming that *root*
has been squashed in the share export.

The default value of both of these options is 'auto'. For backwards
compatibility, if there already exist cinder volumes when Cinder starts
up and the value of one of these options is 'auto', it is set to 'false'
internally, whereas if there is a green field environment, the option is
set to 'true' and a marker file *.cinderSecureEnvIndicator* is created
under the mount directory. On startup, the marker file is checked so
that this automatic green field environment choice will be persisted for
subsequent startups after volumes have been created.

Setup
-----

When NAS security options are deployed, OpenStack Cinder and Nova nodes
must be configured appropriately, as well as Data ONTAP, for Cinder
volume operations and Nova attaches to succeed. For example, if *root*
root is "squashed" and "set uid" is disabled but the NAS security
options are set to 'false', the driver will attempt to run "chown" as
root, read and write backing files as root, and the like and these
operations will fail.

ONTAP Side Setup
----------------
-  Ensure that ONTAP has *cinder* and *nova* user and group
   identities with *uid* and *gid* that match the corresponding users on
   the OpenStack Cinder and Nova nodes.

-  In ONTAP, put both the *cinder* and the *nova* users in the
   *cinder* group.

-  Ensure that the exported ONTAP volume has owner *cinder* and group
   *cinder*.

-  Set permissions on the exported share to 0755.

-  "Squash" access on the share for *root* and disable "set uid".

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

-  On Nova nodes, restart libvirt-bin, qemu-kvm, and nova services (or
   reboot).

The overall objective here is to set up the exported share so that only
OpenStack processes with *cinder* user identity or group identity have
permission to read and write the backing files for cinder volumes, and
set up Cinder and Nova nodes in OpenStack such that Cinder operations on
the backing files run with *cinder* user identity and that Nova/libvirt
operations run with *cinder* group identity.
