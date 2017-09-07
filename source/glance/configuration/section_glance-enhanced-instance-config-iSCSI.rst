.. _eic-fas-iscsi-or-fc:

Enhanced Instance Creation with ONTAP for iSCSI or Fibre Channel
================================================================

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

Obtain the ``cinder_internal_tenant_project_id``

::

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

Edit cinder.conf to contain the following entry in the DEFAULT stanza

::

    [DEFAULT]
    ...
    cinder_internal_tenant_project_id=6763e676132f4aaabb68cc1517b18d38
    ...

Obtain the ``cinder_internal_tenant_user_id``

::

    $ openstack user list
    +----------------------------------+----------+
    | ID                               | Name     |
    +----------------------------------+----------+
    | 6275bf0ad03743949f7d8752464e30e5 | admin    |
    +----------------------------------+----------+

Edit cinder.conf to contain the following entry in the DEFAULT stanza

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
