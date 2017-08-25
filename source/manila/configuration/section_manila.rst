.. _manila-conf:

Manila
------

Manila is configured by changing the contents of the ``manila.conf``
file and restarting all of the Manila processes. Depending on the
OpenStack distribution used, this may require issuing commands such as
``service openstack-manila-api restart`` or
``service manila-api restart``.

The ``manila.conf`` file contains a set of configuration options (one
per line), specified as ``option_name``\ =value. Configuration options
are grouped together into a stanza, denoted by ``[stanza_name]``. There
must be at least one stanza named ``[DEFAULT]`` that contains
configuration parameters that apply generically to Manila (and not to
any particular backend). Configuration options that are associated with
a particular Manila backend should be placed in a separate stanza.

.. note::
   While it is possible to specify driver-specific configuration
   options within the ``[DEFAULT]`` stanza, you are unable to define
   multiple Manila backends within the ``[DEFAULT]`` stanza. NetApp
   strongly recommends that you specify driver-specific configuration
   in separate named stanzas, being sure to list the backends that
   should be enabled as the value for the configuration option
   ``enabled_share_backends``; for example::

       enabled_share_backends=clusterOne,clusterTwo

   The ``enabled_share_backends`` option should be specified within the
   ``[DEFAULT]`` configuration stanza.
