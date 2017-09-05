Configuration of Glance with NetApp Storage Systems and Software
================================================================

.. _glance-fas-config:

Configuration of Glance with NetApp FAS
---------------------------------------

By specifying the value of ``filesystem_store_datadir`` to be a
directory that is the mount point for an NFS share that is served from a
NetApp FlexVol volume, you can have a single filesystem that can be
mounted from one or more ``glance-registry`` servers.

.. warning::

   The NFS mount for the ``filesystem_store_datadir`` is not managed by
   Glance; therefore, you must use the standard Linux mechanisms (e.g.
   ``/etc/fstab`` or NFS automounter) to ensure that the NFS mount
   exists before Glance starts.

.. tip::

   Be sure to refer to the `Clustered Data ONTAP NFS Best Practices and
   Implementation
   Guide <http://www.netapp.com/us/system/pdf-reader.aspx?pdfuri=tcm:10-61288-16&m=tr-4067.pdf>`__
   for information on how to optimally set up the NFS export for use
   with Glance, and `NetApp Data Compression and Deduplication
   Deployment and Implementation
   Guide <http://www.netapp.com/us/system/pdf-reader.aspx?pdfuri=tcm:10-60107-16&m=tr-3958.pdf>`__.

.. _glance-eseries-config:

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

**Steps:**

1. Create the LUN from a disk pool or volume group using SANtricity and
   map it to the host. Assuming that the volume has been mapped to
   ``/dev/sdc`` on the host, create a partition on the volume and then
   create a filesystem on the partition (e.g. ext4)::

     $ fdisk /dev/sdc
     $ mkfs.ext4 /dev/sdc1
     $ mount /dev/sdc1 /mnt/sdc1
     $ mkdir /mnt/sdc1/glanceImageStore

2. Edit the Glance configuration file ``glance-api.conf`` so that it
   contains the ``filesystem_store_datadir`` option, and ensure the
   value refers to the Glance image store directory created in the
   previous step::

     $ filesystem_store_datadir=/mnt/sdc1/glanceImageStore

Configuration of Glance with NetApp StorageGRID Webscale
--------------------------------------------------------

StorageGRID Webscale can be used as a backing store for Glance images
using the Amazon S3 API.

**Configure the following in StorageGRID Webscale:**

1. Port redirect: Glance will only talk to port 443. Redirect port on
   gateway or storage node (8082 for CLB and 18082 for LDR)::

       $ iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8082

2. Set domain root::

       Grid Management > Grid Configuration > Root Domain Name

**Configure Openstack:**

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

2. Restart Glance service: ``$ openstack-service restart glance``

3. Edit DNS or Hosts file: Create entry for bucket.hostname example:
   glance55.webscalertp.stl.netapp.com

4. Test::

       Grab an image file to test – cirros is a very small image used for testing.

       $ source /root/keystonerc_admin

       $ glance image-create --name cirros --disk-format qcow2 --container-format bare --file /root/cirros.img
