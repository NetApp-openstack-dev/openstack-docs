NetApp OpenStack Deployment & Operations Guide
==============================================

To build this guide, you will need `tox`.

Install tox by running::

  pip install tox


From inside the repository, build this guide with::

  tox -e docs


A "build" folder is created with doctrees and html output.


If you're building this on macOS, it is possible you'll run into dependency
issues if you do not have Xcode Command Line utilities enabled. You can
enable it with::

  xcode-select --install


If you find bugs in documentation, please file an `issue`.

.. _tox: https://tox.readthedocs.io/en/latest/
.. _issue: https://github.com/NetApp-openstack-dev/openstack-docs/issues
