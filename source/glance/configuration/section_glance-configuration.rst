Configuration
=============

.. toctree::
   :maxdepth: 1

   section_netapp-config.rst
   section_enhanced-instance.rst

Glance
------

When the file storage backend is used, the ``filesystem_store_datadir``
configuration option in ``glance-api.conf`` declares the directory
Glance uses to store images (relative to the node running the
``glance-api`` service).

::

   $ #for RHEL/CentOS/Fedora derived distributions
   $ sudo openstack-config --get /etc/glance/glance-api.conf \
   DEFAULT filesystem_store_datadir
   /var/lib/glance/images/

   $ #for Ubuntu derived distributions
   $ sudo cat /etc/glance/glance-api.conf|grep \
   filesystem_store_datadir|egrep -v "^#.*"
   filesystem_store_datadir=/var/lib/glance/images/
