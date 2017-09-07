.. _glance-sg-config:

Basic Configuration of Glance with NetApp StorageGRID Webscale
==============================================================

StorageGRID Webscale can be used as a backing store for Glance images
using the Amazon S3 API.

**Configure the following in StorageGRID Webscale:**

1. Port redirect: Glance will only talk to port 443. Redirect port on
   gateway or storage node (8082 for CLB and 18082 for LDR)

::

     $ iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8082

2. Set domain root

::

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

2. Restart Glance service:

::

     $ openstack-service restart glance

3. Edit DNS or Hosts file: Create entry for bucket.hostname example:

::

     glance55.webscale.stl.netapp.com

4. Test: Grab an image file to test
   used for testing.

::

     $ source /root/keystonerc_admin

::

     $ wget https://s3-us-west-2.amazonaws.com/testdrive-bucket/images/trusty-server-cloudimg-amd64-disk1-nfs-edit.img | glance image-create --name=ubuntu-nfs-image --container-format=bare --disk-format=raw --file=trusty-server-cloudimg-amd64-disk1-nfs-edit.img –-progress
