# How to scale your running app

You can set the number of instances, amount of memory, and disk size for your app in the manifest.yml file.  Next time you push the app will implement these changes.  However, if you have running apps, it is likely easier to scale the app from the command line.  All this information is available from <https://docs.cloudfoundry.org/devguide/deploy-apps/cf-scale.html>.  I have collated the many ideas below.

1. Change memory

```
cf scale appname -m 512M
```

2. Change disk size

```
cf scale appname -k 2G
```

3. Change number of instances

```
cf scale appname -i 3
```

5. If you want to see how much memory is available for the organization you are pushing your app to, it isn't completely straightforward.  You first need to find the id for your orgs quota, then query that id.

```
cf org epa-prototyping
```

This will return info on the org, including the id of the quota.  Copy that then run:

```
cf quota c9f393c172b7c6bdab52364b492bc4c8
```