Deploying NetApp SolidFire Cinder driver in a Red Hat OpenStack Platform 16
===========================================================================

.. _solidfire-solidfire-rhosp:

Overview
--------

This guide shows how to configure and deploy NetApp SolidFire Cinder driver in a
**Red Hat OpenStack Platform (RHOSP) 16** Overcloud, using RHOSP Director.
After reading this, you'll be able to define the proper environment files and
deploy single or multiple SolidFire Cinder back ends in RHOSP Overcloud Controller
nodes.

.. note::

  For more information about RHOSP, please refer to its `documentation pages
  <https://access.redhat.com/documentation/en-us/red_hat_openstack_platform>`_.

.. warning::

  RHOSP16 is based on OpenStack Train release. Features included after Train
  release are not available in RHOSP16.

Requirements
------------

In order to deploy NetApp SolidFire Cinder back ends, you should have the
following requirements satisfied:

- NetApp SolidFire storage controllers deployed and ready to be used as Cinder
  back ends. See :ref:`cinder_solidfire_prerequisites` for more details.

- RHOSP Director user credentials to deploy Overcloud.

- RHOSP Overcloud Controller nodes where Cinder services will be installed.


Deployment Steps
----------------

Prepare the environment files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

RHOSP makes use of **TripleO Heat Templates (THT)**, which allows you to define
the Overcloud resources by creating environment files.

Multiple back end configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Define NetApp SolidFire Cinder back ends using Custom THT Configuration syntax.
It's possible to define all the back ends in a single environment file, but for
sake of clarity, the following example organizes the back ends in multiple
smaller environment files:

- ``/home/stack/templates/cinder-solidfire-backend1.yaml``

  This file defines the first Cinder volume back end
  ``tripleo_solidfire_1`` and its parameters:

  .. code-block:: yaml
    :name: cinder-solidfire-backend1.yaml

    parameter_defaults:
      ControllerExtraConfig:
        cinder::config::cinder_config:
          tripleo_solidfire_1/volume_backend_name:
            value: tripleo_solidfire_1
          tripleo_solidfire_1/volume_driver:
            value: cinder.volume.drivers.solidfire.SolidFireDriver
          tripleo_solidfire_1/san_ip:
            value: san_ip_1
          tripleo_solidfire_1/san_login:
            value: admin_username
          tripleo_solidfire_1/san_password:
            value: admin_password

- ``/home/stack/templates/cinder-solidfire-backend2.yaml``

  This file defines the second Cinder volume back end
  ``tripleo_solidfire_2`` and its parameters:

  .. code-block:: yaml
    :name: cinder-solidfire-backend2.yaml

    parameter_defaults:
      ControllerExtraConfig:
        cinder::config::cinder_config:
          tripleo_solidfire_2/volume_backend_name:
            value: tripleo_solidfire_2
          tripleo_solidfire_2/volume_driver:
            value: cinder.volume.drivers.solidfire.SolidFireDriver
          tripleo_solidfire_2/san_ip:
            value: san_ip_2
          tripleo_solidfire_2/san_login:
            value: admin_username
          tripleo_solidfire_2/san_password:
            value: admin_password

  Modify the parameter values according to your NetApp SolidFire back end
  configuration.

- ``/home/stack/templates/cinder-enabled-backends.yaml``

  This file defines which back ends will be enabled. In this example, two
  back ends ``tripleo_solidfire_1`` and ``tripleo_solidfire_2`` will be
  enabled:

  .. code-block:: yaml
    :name: cinder-enabled-backends.yaml

    parameter_defaults:
      ControllerExtraConfig:
        cinder_user_enabled_backends:
          - 'tripleo_solidfire_1'
          - 'tripleo_solidfire_2'

.. note::

  You can define arbitrary Custom THT Configurations using the following syntax:

  .. code-block:: yaml
      :name: custom-config.yaml

      parameter_defaults:
        ControllerExtraConfig:
          cinder::config::cinder_config:
            <backend_name>/<configuration_name>:
              value: <value>

  Each configuration will be rendered in ``cinder.conf`` file as:

  .. code-block::
      :name: cinder.conf

      [backend_name]
      configuration_name=value

  See `Optional Cinder Configuration Attributes (Train)
  <https://netapp-openstack-dev.github.io/openstack-docs/train/cinder/configuration/cinder_config_files/section_solidfire-conf.html#optional-cinder-configuration-attributes>`_
  for a complete list of the available Cinder Configuration Options.

.. warning::

  RHOSP16 is based on OpenStack Train release. Features and Configuration
  Options included after Train release are not available in RHOSP16.


Deploy Overcloud
^^^^^^^^^^^^^^^^

Now that you have the Cinder back end environment files defined, you can run
the command to deploy RHOSP Overcloud. Run the following command as ``stack``
user in the RHOSP Director command line, specifying the YAML file(s) you
defined:

.. code-block:: bash
  :name: overcloud-deploy

   (undercloud) [stack@rhosp16-undercloud ~]$ openstack overcloud deploy \
   --templates \
   -e /home/stack/containers-prepare-parameter.yaml \
   -e /home/stack/templates/cinder-solidfire-backend1.yaml \
   -e /home/stack/templates/cinder-solidfire-backend2.yaml \
   -e /home/stack/templates/cinder-enabled-backends.yaml \
   --stack overcloud

.. note::
  Alternatively, you can use ``--environment-directory`` parameter and specify
  the whole directory to the deployment command. It will consider all the YAML
  files within this directory:

  .. code-block:: bash
    :name: overcloud-deploy-environment-directory

     (undercloud) [stack@rhosp16-undercloud ~]$ openstack overcloud deploy \
     --templates \
     -e /home/stack/containers-prepare-parameter.yaml \
     --environment-directory /home/stack/templates \
     --stack overcloud


Test the Deployed Back Ends
^^^^^^^^^^^^^^^^^^^^^^^^^^^

After RHOSP Overcloud is deployed, run the following command to check if the
Cinder services are up:

.. code-block:: bash
  :name: cinder-service-list

  [stack@rhosp16-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp16-undercloud ~]$ cinder service-list


Run the following commands as ``stack`` user in the RHOSP Director command line
to create the volume types mapped to the deployed back ends:

.. code-block:: bash
  :name: create-volume-types

  [stack@rhosp16-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp16-undercloud ~]$ cinder type-create solidfire1
  (overcloud) [stack@rhosp16-undercloud ~]$ cinder type-key solidfire1 set volume_backend_name=tripleo_solidfire_1
  (overcloud) [stack@rhosp16-undercloud ~]$ cinder type-create solidfire2
  (overcloud) [stack@rhosp16-undercloud ~]$ cinder type-key solidfire1 set volume_backend_name=tripleo_solidfire_2

Make sure that you're able to create Cinder volumes with the configured volume
types:

.. code-block:: bash
  :name: create-volumes

  [stack@rhosp16-undercloud ~]$ source ~/overcloudrc
  (overcloud) [stack@rhosp16-undercloud ~]$ cinder create --volume-type solidfire1 --name v1 1
  (overcloud) [stack@rhosp16-undercloud ~]$ cinder create --volume-type solidfire2 --name v2 1

