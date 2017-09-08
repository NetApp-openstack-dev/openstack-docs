NetApp OpenStack Deployment & Operations Guide
==============================================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This repository contains documentation to aid operators and users of
OpenStack clouds powered by NetApp Storage Systems.

The latest build of this documentation is live here:

 https://netapp-openstack-dev.github.io/openstack-docs/draft/


Contributing
------------

We welcome contributions and requests for enhancement. If you find bugs in
the documentation, please file
an [issue](https://github.com/NetApp-openstack-dev/openstack-docs/issues). You
may also do this from within the documentation webpage, using the bug links
provided on each page.

This documentation is written and built with Sphinx using
[reStructured Text](http://www.sphinx-doc.org/en/stable/rest.html) as the
markup language.

To build this guide, you will need
[tox](https://tox.readthedocs.io/en/latest/).

Install tox by running:

```
pip install tox
```

From inside the repository, build this guide with:

```
tox -e docs
```

A "build" folder is created with doctrees and html output.


If you're building this on macOS, it is possible you'll run into dependency
issues if you do not have Xcode Command Line utilities enabled. You can
enable it with:

```
xcode-select --install
```


Attributions
------------

The theme used by the builds of this documentation was [developed by the
OpenStack community](https://docs.openstack.org/openstackdocstheme/latest/).

