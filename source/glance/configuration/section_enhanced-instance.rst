Configuration of Enhanced Instance Creation
===========================================

.. _eic-fas-nfs:

Configuration of Enhanced Instance Creation and Copy Offload with NetApp FAS for NFS
------------------------------------------------------------------------------------

The following checklist provides the steps necessary for configuration
of Enhanced Instance Creation and Copy Offload with NetApp FAS (ONTAP)
for NFS:

+------+------------------------------------------------------------+---------+
| #    | Description of Step                                        | Done?   |
+======+============================================================+=========+
| 1    | ONTAP: Enable ``vstorage``                                 |         |
+------+------------------------------------------------------------+---------+
| 2    | ONTAP: Enable NFSv3 and NFSv4. Disable NFSv4.1             |         |
+------+------------------------------------------------------------+---------+
| 3    | ONTAP: Set ownership of Glance FlexVol                     |         |
+------+------------------------------------------------------------+---------+
| 4    | ONTAP: Set ownership of Cinder FlexVol                     |         |
+------+------------------------------------------------------------+---------+
| 5    | Change ``netapp_copy_offload_tool_path`` in cinder.conf    |         |
+------+------------------------------------------------------------+---------+
| 6    | Add ``nfs_mount_options=lookupcache=pos`` in cinder.conf   |         |
+------+------------------------------------------------------------+---------+
| 7    | Change ownership of copy offload binary                    |         |
+------+------------------------------------------------------------+---------+
| 8    | Change ``glance_api_version`` in cinder.conf               |         |
+------+------------------------------------------------------------+---------+
| 9    | Perform additional steps in glance-api.conf                |         |
+------+------------------------------------------------------------+---------+
| 10   | Create JSON file for Glance metadata                       |         |
+------+------------------------------------------------------------+---------+
| 11   | Add the ``cinder`` user to the ``glance`` group            |         |
+------+------------------------------------------------------------+---------+
| 12   | Restart Cinder and Glance services                         |         |
+------+------------------------------------------------------------+---------+
| 13   | Check mounts                                               |         |
+------+------------------------------------------------------------+---------+
| 14   | Upload a Glance Image                                      |         |
+------+------------------------------------------------------------+---------+
| 15   | Boot from Cinder                                           |         |
+------+------------------------------------------------------------+---------+
| 16   | Verify functionality                                       |         |
+------+------------------------------------------------------------+---------+

Table 5.1. Checklist of Steps for Enhanced Instance Creation and Copy
Offload tool for NFS

1) Enable ``vstorage`` on Storage Virtual Machine

::

    CDOT::> nfs modify -vserver replace-with-vserver-name -vstorage enabled

2) Enable NFSv3 and NFSv4; disable NFSv4.1 on Storage Virtual Machine

::

    CDOT::> vserver nfs modify -vserver replace-with-vserver-name -access true -v3 enabled -v4.0 enabled -v4.1 disabled

.. important::

   Please disable NFS v4.1 as NetApp's copy offload tool is not
   supported with this protocol.

3) Set ownership of Glance FlexVol

Obtain the user and group ids for ``glance`` service user::

    $ cat /etc/passwd | grep glance
    glance:x:161:161:OpenStack Glance Daemons:/var/lib/glance:/sbin/nologin

Set ownership for the FlexVol backing Glance accordingly::

    CDOT::> volume modify –vserver replace-with-vserver-name -volume replace-with-glance-flexvol-name -user 161 –group 161
    CDOT::> volume show –vserver replace-with-vserver-name -volume replace-with-glance-flexvol-name -fields user,group

4) Set ownership of Cinder FlexVol

Obtain the user and group ids for ``cinder`` service user::

    $ cat /etc/passwd | grep cinder
    cinder:x:165:165:OpenStack Cinder Daemons:/var/lib/cinder:/sbin/nologin

Set ownership for the FlexVol backing Cinder accordingly::

    CDOT::> volume modify –vserver replace-with-vserver-name -volume replace-with-cinder-flexvol -user 165 –group 165
    CDOT::> volume show –vserver replace-with-vserver-name -volume replace-with-cinder-flexvol -fields user,group

5) Change ``netapp_copy_offload_tool_path`` in cinder.conf

Download the copy offload tool from NetApp Support.
(http://mysupport.netapp.com/tools/info/ECMLP2429244I.html?productID=61945.)

Place the archive on the OpenStack Controller(s)::

    $ mkdir /etc/cinder/copyoffload
    $ mv copyoffload.tar /etc/cinder/copyoffload/
    $ cd /etc/cinder/copyoffload
    $ tar xzvf copyoffload.tar
    $ ls
    copyoffload.tar  na_copyoffload_64  NetApp_End_User_License_Agreement2014.pdf  NOTICE.pdf  README.txt
    $ pwd
    /etc/cinder/copyoffload

Edit cinder.conf to contain the following entry in the NetApp ONTAP
backend stanza::

    [DEFAULT]
    ...
    [NetAppONTAPBackend]
    ...
    netapp_copyoffload_tool_path=/etc/cinder/copyoffload/na_copyoffload_64
    ...

6) Add ``nfs_mount_options=lookupcache=pos`` in cinder.conf

.. note::

   It is recommended to set the value of ``nfs_mount_options`` to
   ``lookupcache=pos`` if your environment is set up with negative
   cache lookup.

Edit cinder.conf to contain the following entry in the NetApp ONTAP
backend stanza::

    [DEFAULT]
    ...
    [NetAppONTAPBackend]
    ...
    nfs_mount_options=lookupcache=pos
    ...

7) Change ownership for the copyoffload binary

::

    $ chown cinder:cinder /etc/cinder/copyoffload/na_copyoffload_64

8) Change ``glance_api_version`` in cinder.conf

::

    [DEFAULT]
    ...
    glance_api_version = 2
    ...

9) Update the following entries in the glance-api.conf file::

    ...
    filesystem_store_datadir="/var/lib/glance/images/"
    ...
    default_store=file
    ...
    show_image_direct_url=True
    ...
    show_multiple_locations=True
    ...
    filesystem_store_metadata_file="/etc/glance/filesystem_store_metadata.json"
    ...
                

.. tip::

   Search for each of these entries in glance-api.conf using a text
   editor and update it accordingly.

10) Create a json file at /etc/glance/filesystem\_store\_metadata.json
with the following content::

    {
        "id":"NetAppNFS",
        "share_location":"nfs://[replace-with-ip-address]/[replace-with-glance-export]",
        "mountpoint": "/var/lib/glance/images",
        "type": "nfs"
    }

.. important::

   Please follow these guidelines for the JSON file, in addition to
   regular conventions:

   - Four spaces for each line entry (other than the braces)

   - ``share_location`` must be in the format above. ex.
     "nfs://192.168.100.10/glance\_flexvol"

11) Add the ``cinder`` user to the ``glance`` group

::

    $ gpasswd –a cinder glance

12) Restart Cinder and Glance services

::

    $ systemctl restart openstack-cinder-{api,scheduler,volume}
    $ systemctl restart openstack-glance-{api,registry}

13) Check mounts

::

    # mount
    ...
    192.168.100.10:/cinder_flexvol on /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c type nfs4 (rw,relatime,vers=4,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.100.20,local_lock=none,addr=192.168.100.10)
    192.168.100.10:/glance_flexvol on /var/lib/glance/images type nfs4 (rw,relatime,vers=4,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.100.20,local_lock=none,addr=192.168.100.10)
    ...

14) Upload a Glance image

The following command uses an image that is publicly available. Please
use the image you prefer and replace the URL accordingly.

::

    $ wget https://s3-us-west-2.amazonaws.com/testdrive-bucket/images/trusty-server-cloudimg-amd64-disk1-nfs-edit.img | glance image-create --name=ubuntu-nfs-image --container-format=bare --disk-format=qcow2 --file=trusty-server-cloudimg-amd64-disk1-nfs-edit.img –-progress

15) Boot from Cinder

::

    $ nova boot --flavor m1.medium --key-name openstack_key --nic net-id=replace-with-neutron-net-id --block-device source=image,id=replace-with-glance-image-id,dest=volume,shutdown=preserve,bootindex=0,size=5  ubuntu-vm

16) Verify functionality

Please open /var/log/cinder/volume.log and look for a message similar to
the following to confirm that copy offload was used successfully::

    ...
    2016-08-13 13:25:16.646 6626 INFO cinder.volume.drivers.netapp.dataontap.nfs_cmode [req-...] Copied image 7080dac2-6272-4c05-a2ed-56888a34e589 to volume 06d081da-7220-4526-bfdf-5b9e8eb4aac3 using copy offload workflow.
    ...

.. tip::

   Search for the word "offload" to help locate the copy offload log
   entry in volume.log.

Configuration of Enhanced Instance Creation with NetApp FAS for iSCSI or Fibre Channel
--------------------------------------------------------------------------------------

The following checklist provides the steps necessary for configuration
of Enhanced Instance Creation with NetApp FAS (ONTAP) for iSCSI or Fibre
Channel:

+-----+-------------------------------------------------------+---------+
| Step| Description of Step                                   | Done?   |
+=====+=======================================================+=========+
| 1   | Configure internal tenant settings in cinder.conf     |         |
+-----+-------------------------------------------------------+---------+
| 2   | Configure Image-Volume cache setting in cinder.conf   |         |
+-----+-------------------------------------------------------+---------+
| 3   | Change ``glance_api_version`` in cinder.conf          |         |
+-----+-------------------------------------------------------+---------+
| 4   | Restart Cinder and Glance services                    |         |
+-----+-------------------------------------------------------+---------+
| 5   | Upload a Glance Image                                 |         |
+-----+-------------------------------------------------------+---------+
| 6   | Boot from Cinder                                      |         |
+-----+-------------------------------------------------------+---------+
| 7   | Verify functionality                                  |         |
+-----+-------------------------------------------------------+---------+

Table 5.2: Checklist of Steps for Enhanced Instance Creation

|

1) Configure internal tenant settings in cinder.conf

Review Cinder's Image-Volume cache reference:
(http://docs.openstack.org/admin-guide/blockstorage-image-volume-cache.html.)

Obtain the ``cinder_internal_tenant_project_id``::

    $ openstack service list
    +----------------------------------+-------------+----------------+
    | ID                               | Name        | Type           |
    +----------------------------------+-------------+----------------+
    | 468a57b3acd24aaaa41d65efd38cf9b3 | cinder      | volume         |
    | 6763e676132f4aaabb68cc1517b18d38 | cinderv3    | volumev3       |
    | 68c02f549aff48a8bd1a217af2acaf3d | cinderv2    | volumev2       |
    | c4d4d6fad70842159e85927aba7b51f4 | glance      | image          |
    | da0958b746ad43e5844c09de23aae2b1 | keystone    | identity       |
    | ea78b41d174b4476be6d6bf6cc3c081c | neutron     | network        |
    | f030c2914d77496c8dfc8c58acd0d833 | nova        | compute        |
    +----------------------------------+-------------+----------------+

Edit cinder.conf to contain the following entry in the DEFAULT stanza::

    [DEFAULT]
    ...
    cinder_internal_tenant_project_id=6763e676132f4aaabb68cc1517b18d38
    ...

Obtain the ``cinder_internal_tenant_user_id``::

    $ openstack user list
    +----------------------------------+----------+
    | ID                               | Name     |
    +----------------------------------+----------+
    | 6275bf0ad03743949f7d8752464e30e5 | admin    |
    +----------------------------------+----------+

Edit cinder.conf to contain the following entry in the DEFAULT stanza::

    [DEFAULT]
    ...
    cinder_internal_tenant_user_id=a05232baaeda49b589b11a3198efb054
    ...

2) Configure Image-Volume cache settings in cinder.conf

::

    [DEFAULT]
    ...
    image_volume_cache_enabled = True
    ...

3) Change ``glance_api_version`` in cinder.conf

::

    [DEFAULT]
    ...
    glance_api_version = 2
    ...

4) Restart Cinder services

::

    $ systemctl restart openstack-cinder-{api,scheduler,volume}

5) Upload a Glance image

The following command uses an image that is publicly available. Please
use the image you prefer and replace the URL accordingly.

::

    $ wget https://s3-us-west-2.amazonaws.com/testdrive-bucket/images/trusty-server-cloudimg-amd64-disk1-nfs-edit.img | glance image-create --name=ubuntu-nfs-image --container-format=bare --disk-format=qcow2 --file=trusty-server-cloudimg-amd64-disk1-nfs-edit.img –-progress
                
6) Boot from Cinder

::

    $ nova boot --flavor m1.medium --key-name openstack_key --nic net-id=replace-with-neutron-net-id --block-device source=image,id=replace-with-glance-image-id,dest=volume,shutdown=preserve,bootindex=0,size=5  ubuntu-vm

7) Verify functionality

Please open /var/log/cinder/volume.log and look for a message similar to
the following to confirm that the image-volume was cached successfully::

    ...
    2016-09-30 16:38:52.211 DEBUG cinder.volume.flows.manager.create_volume [req-9ea8022f-1dd4-4203-b1f3-019f3c1b377a None None] Downloaded image 16d996d3-87aa-47da-8c82-71a21e8a06fb ((None, None)) to volume 6944e5be-7c56-4a7d-a90b-5231e7e94a6e successfully. from (pid=20926) _copy_image_to_volume /opt/stack/cinder/cinder/volume/flows/manager/create_volume.py
    ...
