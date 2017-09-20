.. _eic-fas-nfs:

Enhanced Instance Creation with ONTAP NFS as a Cinder Backend
=============================================================

The following checklist provides the steps necessary for configuration
of Enhanced Instance Creation and Copy Offload with NetApp FAS (ONTAP)
for NFS:

+------+------------------------------------------------------------+---------+
| #    | Description of Step                                        | Done?   |
+======+============================================================+=========+
| 1    | ONTAP: Enable ``vstorage``                                 |         |
+------+------------------------------------------------------------+---------+
| 2    | ONTAP: Enable NFSv3, NFSv4, and NFSv4.1                    |         |
+------+------------------------------------------------------------+---------+
| 3    | ONTAP: Set ownership of Glance FlexVol                     |         |
+------+------------------------------------------------------------+---------+
| 4    | ONTAP: Set ownership of Cinder FlexVol                     |         |
+------+------------------------------------------------------------+---------+
| 5    | Download the ``copy_offload_tool`` from NetApp Support     |         |
+------+------------------------------------------------------------+---------+
| 6    | Make changes to the cinder.conf                            |         |
+------+------------------------------------------------------------+---------+
| 6a   | Change ``netapp_copy_offload_tool_path``                   |         |
+------+------------------------------------------------------------+---------+
| 6b   | Change ``glance_api_version``                              |         |
+------+------------------------------------------------------------+---------+
| 6c   | Add ``nfs_mount_options=lookupcache=pos`` in cinder.conf   |         |
+------+------------------------------------------------------------+---------+
| 7    | Create JSON file for Glance metadata                       |         |
+------+------------------------------------------------------------+---------+
| 8    | Perform additional steps in glance-api.conf                |         |
+------+------------------------------------------------------------+---------+
| 9    | Add the ``cinder`` user to the ``glance`` group            |         |
+------+------------------------------------------------------------+---------+
| 10   | Restart Cinder and Glance services                         |         |
+------+------------------------------------------------------------+---------+
| 11   | Check mounts                                               |         |
+------+------------------------------------------------------------+---------+
| 12   | Upload a Glance Image                                      |         |
+------+------------------------------------------------------------+---------+
| 13   | Boot from Cinder                                           |         |
+------+------------------------------------------------------------+---------+
| 14   | Verify functionality                                       |         |
+------+------------------------------------------------------------+---------+

Table 5.1. Checklist of Steps for Enhanced Instance Creation and Copy
Offload tool for NFS

1) Enable ``vstorage`` on
Storage Virtual Machine

::

    CDOT::> nfs modify -vserver replace-with-vserver-name -vstorage enabled

2) Enable NFSv3, NFSv4, and NFSv4.1 on
Storage Virtual Machine

::

    CDOT::> vserver nfs modify -vserver replace-with-vserver-name -access true -v3 enabled -v4.0 enabled -v4.1 enabled

3) Set ownership of Glance
FlexVol

Obtain the user and group ids for ``glance`` service user

::

    $ cat /etc/passwd | grep glance
    glance:x:161:161:OpenStack Glance Daemons:/var/lib/glance:/sbin/nologin

Set ownership for the FlexVol backing Glance accordingly

::

    CDOT::> volume modify –vserver replace-with-vserver-name -volume replace-with-glance-flexvol-name -user 161 –group 161
    CDOT::> volume show –vserver replace-with-vserver-name -volume replace-with-glance-flexvol-name -fields user,group

4) Set ownership of Cinder
FlexVol

Obtain the user and group ids for ``cinder`` service user

::

    $ cat /etc/passwd | grep cinder
    cinder:x:165:165:OpenStack Cinder Daemons:/var/lib/cinder:/sbin/nologin

Set ownership for the FlexVol(s) backing Cinder accordingly

::

    CDOT::> volume modify –vserver replace-with-vserver-name -volume replace-with-cinder-flexvol -user 165 –group 165
    CDOT::> volume show –vserver replace-with-vserver-name -volume replace-with-cinder-flexvol -fields user,group

5) Download, unpack, and set ownership of the copy offload tool from
`NetApp Support <http://mysupport.netapp.com/tools/info/ECMLP2429244I.html?productID=61945>`_.

::

    $ mkdir /etc/cinder/copyoffload

::

    $ mv copyoffload.tar /etc/cinder/copyoffload/

::

    $ cd /etc/cinder/copyoffload

::

    $ tar xzvf copyoffload.tar

::

    $ ls
    copyoffload.tar  na_copyoffload_64  NetApp_End_User_License_Agreement2014.pdf  NOTICE.pdf  README.txt

::

    $ chown cinder:cinder /etc/cinder/copyoffload/na_copyoffload_64

6) Make changes to
/etc/cinder/cinder.conf

Set the following in each NFS backend stanza, paying attention to
set glance_api_version to 2 in the DEFAULT stanza as well.

::
   
    [DEFAULT]
    ...
    glance_api_version = 2
    ...
    ...
    [NetAppONTAPBackend]
    ...
    ...
    netapp_copyoffload_tool_path=/etc/cinder/copyoffload/na_copyoffload_64
    nfs_mount_options=lookupcache=pos
    ...


7) Create a json file at /etc/glance/filesystem_store_metadata.json
with the following content

::
   
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
     "nfs://192.168.100.10/glance_flexvol"
   
   
8) Update the following entries in the
/etc/glance/glance-api.conf file

::

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

9) Add the ``cinder`` user to the ``glance``
group

::

    $ gpasswd –a cinder glance

10) Restart Cinder and Glance
services

::

    $ systemctl restart openstack-cinder-{api,scheduler,volume}
    $ systemctl restart openstack-glance-{api,registry}

11) Confirm that the NFS mounts are
in place


::

    # mount
    ...
    192.168.100.10:/cinder_flexvol on /var/lib/cinder/mnt/69809486d67b39d4baa19744ef3ef90c type nfs4 (rw,relatime,vers=4,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.100.20,local_lock=none,addr=192.168.100.10)
    192.168.100.10:/glance_flexvol on /var/lib/glance/images type nfs4 (rw,relatime,vers=4,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.100.20,local_lock=none,addr=192.168.100.10)
    ...

12) Upload a Glance
image

The following command uses an image that is publicly available. Please
use the image you prefer and replace the URL accordingly.

::

    $ wget https://s3-us-west-2.amazonaws.com/testdrive-bucket/images/trusty-server-cloudimg-amd64-disk1-nfs-edit.img | glance image-create --name=ubuntu-nfs-image --container-format=bare --disk-format=qcow2 --file=trusty-server-cloudimg-amd64-disk1-nfs-edit.img –-progress

13) Boot from
Cinder

::

    $ nova boot --flavor m1.medium --key-name openstack_key --nic net-id=replace-with-neutron-net-id --block-device source=image,id=replace-with-glance-image-id,dest=volume,shutdown=preserve,bootindex=0,size=5  ubuntu-vm

14) Verify
functionality

Please open /var/log/cinder/volume.log and look for a message similar to
the following to confirm that copy offload was used successfully
  
::

    ...
    2016-08-13 13:25:16.646 6626 INFO cinder.volume.drivers.netapp.dataontap.nfs_cmode [req-...] Copied image 7080dac2-6272-4c05-a2ed-56888a34e589 to volume 06d081da-7220-4526-bfdf-5b9e8eb4aac3 using copy offload workflow.
    ...

.. tip::

   Search for the word "offload" to help locate the copy offload log
   entry in volume.log.
