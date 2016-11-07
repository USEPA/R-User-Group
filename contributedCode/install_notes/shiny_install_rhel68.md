# Instructions for install shiny server on Red Hat Enterprise Linux Server release 6.8 (Santiago)

After muddling through R installs on various Red Hat servers, I finally took the time to record what I did...  This assumes no subscription manager availble (which is the case on two servers I tested).  Needs `dzdo` on Centrify systems, `sudo` on others.

# Dependencies for R not available through RHEL repositories

Instructions modified from <https://support.rstudio.com/hc/en-us/community/posts/202802578-EPEL-is-not-sufficient-for-R-on-RedHat>.  

Definetely needs `texinfo-tex` and `libicu-devel`.  Not sure if the linear algebra libraries are required or not.  Might only show up when called and not needed for base install.

```
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/lapack-devel-3.2.1-4.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/blas-devel-3.2.1-4.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/texinfo-tex-4.13a-8.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/libicu-devel-4.2.1-14.el6.x86_64.rpm
dzdo yum localinstall *.rpm
```
# Install R

With appropriate dependencies, can now install R.

```
dzdo yum install R
```

# Install R-Studio Server Open source

Instructions available: <https://www.rstudio.com/products/rstudio/download-server/>

```
wget https://download2.rstudio.org/rstudio-server-rhel-1.0.44-x86_64.rpm
dzdo yum install --nogpgcheck rstudio-server-rhel-1.0.44-x86_64.rpm
```

Server should start on install, but if not commands to start, stop, etc.

```
dzdo rstudio-server stop
dzdo rstudio-server start
dzdo rstudio-server restart
```
Currently not accessible on shiny.rtord.epa.gov:8787 becuase firewalls.

Can change to one of the allowed ports (e.g., 80 and 443).  To do this add
`www-port=443` to `/etc/rstudio/rserver.conf`.  Gets you to log in screen, but log in on Centrify systems is failing.  Might not be an option...

# Install Shiny Server Open source

Instructions avialable: <https://www.rstudio.com/products/shiny/download-server/>

First, `shiny` and `rmarkdown` packages must be installed as root (and any other packages that need to be available for shiny apps (I think)).

```
dzdo su - \
-c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
dzdo su - \
-c "R -e \"install.packages('rmarkdown', repos='https://cran.rstudio.com/')\""
```

Then get and install Shiny server.

```
wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.1.834-rh5-x86_64.rpm
dzdo yum install --nogpgcheck shiny-server-1.5.1.834-rh5-x86_64.rpm
```

Basic server controls.

```
dzdo start shiny-server
dzdo stop shiny-server
dzdo reload shiny-server
dzdo status shiny-server
```

Need to change port to an allowed port on.  For instance, change `listen 3838` to `listen 80` in `/etc/shiny-server/shiny-server.conf`.

