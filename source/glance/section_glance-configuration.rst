Configuration
=============

Glance
------

When the file storage backend is used, the ``filesystem_store_datadir``
configuration option in ``glance-api.conf`` declares the directory
Glance uses to store images (relative to the node running the
``glance-api`` service).

.. code:: ini

    $ #for RHEL/CentOS/Fedora derived distributions
    $ sudo openstack-config --get /etc/glance/glance-api.conf \
    DEFAULT filesystem_store_datadir
    /var/lib/glance/images/

    $ #for Ubuntu derived distributions
    $ sudo cat /etc/glance/glance-api.conf|grep \
    filesystem_store_datadir|egrep -v "^#.*"
    filesystem_store_datadir=/var/lib/glance/images/
            

Configuration of Glance with NetApp FAS
---------------------------------------

By specifying the value of ``filesystem_store_datadir`` to be a
directory that is the mount point for an NFS share that is served from a
NetApp FlexVol volume, you can have a single filesystem that can be
mounted from one or more ``glance-registry`` servers.

    **Warning**

    The NFS mount for the ``filesystem_store_datadir`` is not managed by
    Glance; therefore, you must use the standard Linux mechanisms (e.g.
    ``/etc/fstab`` or NFS automounter) to ensure that the NFS mount
    exists before Glance starts.

    **Tip**

    Be sure to refer to the `Clustered Data ONTAP NFS Best Practices and
    Implementation
    Guide <http://www.netapp.com/us/system/pdf-reader.aspx?pdfuri=tcm:10-61288-16&m=tr-4067.pdf>`__
    for information on how to optimally set up the NFS export for use
    with Glance, and `NetApp Data Compression and Deduplication
    Deployment and Implementation
    Guide <http://www.netapp.com/us/system/pdf-reader.aspx?pdfuri=tcm:10-60107-16&m=tr-3958.pdf>`__.

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

Table: Checklist of Steps for Enhanced Instance Creation and Copy
Offload tool for NFS

1) Enable ``vstorage`` on Storage Virtual Machine

::

    CDOT::> nfs modify -vserver replace-with-vserver-name -vstorage enabled
                

2) Enable NFSv3 and NFSv4; disable NFSv4.1 on Storage Virtual Machine

::

    CDOT::> vserver nfs modify -vserver replace-with-vserver-name -access true -v3 enabled -v4.0 enabled -v4.1 disabled
                

    **Important**

    Please disable NFS v4.1 as NetApp's copy offload tool is not
    supported with this protocol.

3) Set ownership of Glance FlexVol

Obtain the user and group ids for ``glance`` service user:

::

    # cat /etc/passwd | grep glance
    glance:x:161:161:OpenStack Glance Daemons:/var/lib/glance:/sbin/nologin
                

Set ownership for the FlexVol backing Glance accordingly:

::

    CDOT::> volume modify –vserver replace-with-vserver-name -volume replace-with-glance-flexvol-name -user 161 –group 161
    CDOT::> volume show –vserver replace-with-vserver-name -volume replace-with-glance-flexvol-name -fields user,group
                

4) Set ownership of Cinder FlexVol

Obtain the user and group ids for ``cinder`` service user:

::

    # cat /etc/passwd | grep cinder
    cinder:x:165:165:OpenStack Cinder Daemons:/var/lib/cinder:/sbin/nologin
                

Set ownership for the FlexVol backing Cinder accordingly:

::

    CDOT::> volume modify –vserver replace-with-vserver-name -volume replace-with-cinder-flexvol -user 165 –group 165
    CDOT::> volume show –vserver replace-with-vserver-name -volume replace-with-cinder-flexvol -fields user,group
                

5) Change ``netapp_copy_offload_tool_path`` in cinder.conf

Download the copy offload tool from NetApp Support.
(http://mysupport.netapp.com/tools/info/ECMLP2429244I.html?productID=61945.)

Place the archive on the OpenStack Controller(s):

::

    # mkdir /etc/cinder/copyoffload
    # mv copyoffload.tar /etc/cinder/copyoffload/
    # cd /etc/cinder/copyoffload
    # tar xzvf copyoffload.tar
    # ls
    copyoffload.tar  na_copyoffload_64  NetApp_End_User_License_Agreement2014.pdf  NOTICE.pdf  README.txt
    # pwd
    /etc/cinder/copyoffload
                

Edit cinder.conf to contain the following entry in the NetApp ONTAP
backend stanza:

::

    [DEFAULT]
    ...
    [NetAppONTAPBackend]
    ...
    netapp_copyoffload_tool_path=/etc/cinder/copyoffload/na_copyoffload_64
    ...
                

6) Add ``nfs_mount_options=lookupcache=pos`` in cinder.conf

    **Note**

    It is recommended to set the value of ``nfs_mount_options`` to
    ``lookupcache=pos`` if your environment is set up with negative
    cache lookup.

Edit cinder.conf to contain the following entry in the NetApp ONTAP
backend stanza:

::

    [DEFAULT]
    ...
    [NetAppONTAPBackend]
    ...
    nfs_mount_options=lookupcache=pos
    ...
                

7) Change ownership for the copyoffload binary

::

    # chown cinder:cinder /etc/cinder/copyoffload/na_copyoffload_64
                

8) Change ``glance_api_version`` in cinder.conf

::

    [DEFAULT]
    ...
    glance_api_version = 2
    ...
                

9) Update the following entries in the glance-api.conf file:

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
                

    **Tip**

    Search for each of these entries in glance-api.conf using a text
    editor and update it accordingly.

10) Create a json file at /etc/glance/filesystem\_store\_metadata.json
with the following content:

::

    {
        "id":"NetAppNFS",
        "share_location":"nfs://[replace-with-ip-address]/[replace-with-glance-export]",
        "mountpoint": "/var/lib/glance/images",
        "type": "nfs"
    }
                

    **Important**

    Please follow these guidelines for the JSON file, in addition to
    regular conventions:

    - Four spaces for each line entry (other than the braces)

    - ``share_location`` must be in the format above. ex.
    "nfs://192.168.100.10/glance\_flexvol"

11) Add the ``cinder`` user to the ``glance`` group

::

    # gpasswd –a cinder glance
                

12) Restart Cinder and Glance services

::

    # systemctl restart openstack-cinder-{api,scheduler,volume}
    # systemctl restart openstack-glance-{api,registry}
                

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

    # wget https://s3-us-west-2.amazonaws.com/testdrive-bucket/images/trusty-server-cloudimg-amd64-disk1-nfs-edit.img | glance image-create --name=ubuntu-nfs-image --container-format=bare --disk-format=qcow2 --file=trusty-server-cloudimg-amd64-disk1-nfs-edit.img –-progress
                

15) Boot from Cinder

::

    # nova boot --flavor m1.medium --key-name openstack_key --nic net-id=replace-with-neutron-net-id --block-device source=image,id=replace-with-glance-image-id,dest=volume,shutdown=preserve,bootindex=0,size=5  ubuntu-vm
                

16) Verify functionality

Please open /var/log/cinder/volume.log and look for a message similar to
the following to confirm that copy offload was used successfully:

::

    ...
    2016-08-13 13:25:16.646 6626 INFO cinder.volume.drivers.netapp.dataontap.nfs_cmode [req-...] Copied image 7080dac2-6272-4c05-a2ed-56888a34e589 to volume 06d081da-7220-4526-bfdf-5b9e8eb4aac3 using copy offload workflow.
    ...
                

    **Tip**

    Search for the word "offload" to help locate the copy offload log
    entry in volume.log.

Configuration of Enhanced Instance Creation with NetApp FAS for iSCSI or Fibre Channel
--------------------------------------------------------------------------------------

The following checklist provides the steps necessary for configuration
of Enhanced Instance Creation with NetApp FAS (ONTAP) for iSCSI or Fibre
Channel:

+-----+-------------------------------------------------------+---------+
| #   | Description of Step                                   | Done?   |
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

Table: Checklist of Steps for Enhanced Instance Creation

1) Configure internal tenant settings in cinder.conf

Review Cinder's Image-Volume cache reference:
(http://docs.openstack.org/admin-guide/blockstorage-image-volume-cache.html.)

Obtain the ``cinder_internal_tenant_project_id``:

::

    # openstack service list
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
                

Edit cinder.conf to contain the following entry in the DEFAULT stanza:

::

    [DEFAULT]
    ...
    cinder_internal_tenant_project_id=6763e676132f4aaabb68cc1517b18d38
    ...
                

Obtain the ``cinder_internal_tenant_user_id``:

::

    # openstack user list
    +----------------------------------+----------+
    | ID                               | Name     |
    +----------------------------------+----------+
    | 6275bf0ad03743949f7d8752464e30e5 | admin    |
    +----------------------------------+----------+
                

Edit cinder.conf to contain the following entry in the DEFAULT stanza:

::

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

    # systemctl restart openstack-cinder-{api,scheduler,volume}
                

5) Upload a Glance image

The following command uses an image that is publicly available. Please
use the image you prefer and replace the URL accordingly.

::

    # wget https://s3-us-west-2.amazonaws.com/testdrive-bucket/images/trusty-server-cloudimg-amd64-disk1-nfs-edit.img | glance image-create --name=ubuntu-nfs-image --container-format=bare --disk-format=qcow2 --file=trusty-server-cloudimg-amd64-disk1-nfs-edit.img –-progress
                

6) Boot from Cinder

::

    # nova boot --flavor m1.medium --key-name openstack_key --nic net-id=replace-with-neutron-net-id --block-device source=image,id=replace-with-glance-image-id,dest=volume,shutdown=preserve,bootindex=0,size=5  ubuntu-vm
                

7) Verify functionality

Please open /var/log/cinder/volume.log and look for a message similar to
the following to confirm that the image-volume was cached successfully:

::

    ...
    2016-09-30 16:38:52.211 DEBUG cinder.volume.flows.manager.create_volume [req-9ea8022f-1dd4-4203-b1f3-019f3c1b377a None None] Downloaded image 16d996d3-87aa-47da-8c82-71a21e8a06fb ((None, None)) to volume 6944e5be-7c56-4a7d-a90b-5231e7e94a6e successfully. from (pid=20926) _copy_image_to_volume /opt/stack/cinder/cinder/volume/flows/manager/create_volume.py
    ...
                

Configuration of Glance with NetApp E-Series and EF-Series
----------------------------------------------------------

E-Series and EF-Series storage systems can alternatively be used as the
backing store for Glance images. An E-Series volume should be created
(with SANtricity specifying the desired RAID level and capacity) and
then mapped to the Glance node. After the volume is visible to the host
it is formatted with a file system, mounted, and a directory structure
created on it. This directory path can be specified as the
``filesystem_store_datadir`` in the Glance configuration file
``glance-api.conf``.

Steps:

1. Create the LUN from a disk pool or volume group using SANtricity and
   map it to the host. Assuming that the volume has been mapped to
   ``/dev/sdc`` on the host, create a partition on the volume and then
   create a filesystem on the partition (e.g. ext4):

   ::

       fdisk /dev/sdc
       mkfs.ext4 /dev/sdc1
       mount /dev/sdc1 /mnt/sdc1
       mkdir /mnt/sdc1/glanceImageStore
                       

2. Edit the Glance configuration file ``glance-api.conf`` so that it
   contains the ``filesystem_store_datadir`` option, and ensure the
   value refers to the Glance image store directory created in the
   previous step:

   ::

       filesystem_store_datadir=/mnt/sdc1/glanceImageStore
                       

Configuration of Glance with NetApp StorageGRID Webscale
--------------------------------------------------------

StorageGRID Webscale can be used as a backing store for Glance images
using the Amazon S3 API.

Configure the following in StorageGRID Webscale:

1. Port redirect: Glance will only talk to port 443. Redirect port on
   gateway or storage node (8082 for CLB and 18082 for LDR):

   ::

       iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8082
                       

2. Set domain root

   ::

       Grid Management > Grid Configuration > Root Domain Name
                       

Configure Openstack:

1. Edit /etc/glance/glance-api.conf. Make the following changes. Account
   information and bucket names are examples and will be different for
   your installation.

   ::

       # Which backend scheme should Glance use by default is not specified
       # in a request to add a new image to Glance? Known schemes are determined
       # by the known_stores option below.
       # Default: 'file'
       #default_store=file
       default_store=s3
       [glance_store]
       # List of which store classes and store class locations are
       # currently known to glance at startup.
       # Existing but disabled stores:
       #      glance.store.rbd.Store,
       glance.store.s3.Store,
       #      glance.store.swift.Store,
       #      glance.store.sheepdog.Store,
       #      glance.store.cinder.Store,
       #      glance.store.gridfs.Store,
       #      glance.store.vmware_datastore.Store,
       #stores=glance.store.filesystem.Store,
       #         glance.store.http.Store

       # ============ S3 Store Options =============================
       # Address where the S3 authentication service lives
       # Valid schemes are 'http://' and 'https://'
       # If no scheme specified,  default to 'http://'
       s3_store_host=https://webscalertp.stl.netapp.com:8082
       # User to authenticate against the S3 authentication service
       s3_store_access_key=VXVJ0GKKP90XINQTJQUH
       # Auth key for the user authenticating against the
       # S3 authentication service
       s3_store_secret_key=5mi1M8bIybnNF21OvRKOd7TgCbk/JjPB7dw0Aioc
       # Container within the account that the account should use
       # for storing images in S3. Note that S3 has a flat namespace,
       # so you need a unique bucket name for your glance images. An
       # easy way to do this is append your AWS access key to "glance".
       # S3 buckets in AWS *must* be lowercased, so remember to lowercase
       # your AWS access key if you use it in your bucket name below!
       s3_store_bucket=glance55
       # Do we create the bucket if it does not exist?
       s3_store_create_bucket_on_put=True
                       

2. Restart Glance service: ``openstack-service restart glance``

3. Edit DNS or Hosts file: Create entry for bucket.hostname example:
   glance55.webscalertp.stl.netapp.com

4. Test:

   ::

       Grab an image file to test – cirros is a very small image used for testing.

       source /root/keystonerc_admin

       glance image-create --name cirros --disk-format qcow2 --container-format bare --file /root/cirros.img
