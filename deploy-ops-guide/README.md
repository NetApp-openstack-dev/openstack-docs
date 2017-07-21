NetApp OpenStack Deployment & Operations Guide
===============================================
You must have Maven (and a JDK) installed, and the first time you run mvn you will need internet connectivity to download requisite dependencies.

You must set the Maven options environment variable to allocate sufficient memory to the JVM:

```
export MAVEN_OPTS='-Xms256m -XX:MaxPermSize=512m -Xmx512m'
```

To build in draft mode, run:

```
mvn clean generate-resources -B -Ddraft.status=on -Ddraft.mode=yes
```

or for a clean copy:

```
mvn clean generate-resources -B
```

If successful, the PDF output will be in target/docbkx/pdf/bk-deployment-ops-guide.pdf; HTML output in target/docbkx/webhelp/bk-deployment-ops-guide-external/

TODO:

- add spell check as part of build process

See [this page](https://wikid.netapp.com/w/OpenStack/Development/OpenStackDeployOpsGuideAuthoring) for more information on how to make changes to this using our CI system.
