#As of 2018-12-17 this moved into R-User-Group/contributedCode

# Notes on setting up shiny on cloud.gov via dockerfile

1. install cloud foundry (if not already done) and log into cloud.gov with cloud foundry
  - https://cloud.gov/docs/getting-started/setup/
2. get access to cloud.gov and login.
  - if using ID, select 2nd certificate (at least that what it was on Jeff's ID)
  - You can login via the browswer to see the dashboard, but most of cloud foundry tools you need to access via the command line interface (CLI).  
  - Log-in via the CLI is accomplished with:
    - `cf login -a api.fr.cloud.gov  --sso`
  - You will be directed to go to <https://login.fr.cloud.gov/passcode> to get a temporary authorization code.  If you have already logged in it will take you straght there, otherwise you will need to jump through the EPA authentication hoops.
  - A page will show your temporary authorization code.
  - Copy this code and paste it (or just type it) onto the line in your command prompt after `Temporary Authentication Code ( Get one at https://login.fr.cloud.gov/passcode )>`.  Nothing will show up on the screen.  This is normal.  Hit return.
  - If it accepts the code, you will need to select the appropriate org to use for your cloud.gov session.
  - You should now be logged into cloud.gov and be ready to use the cloud foundry tools to push up your app.
3. Build your app. 
  - Mostly on your own here, but ...
  - Apps with just CRAN available packages are going to be much more straightforward.
  - External dependendices (e.g. gdal) are not yet figured out.  Working with cloud.gov and Cloud Foundry for a solution.
  - Use the absolute minimum number of packages.  Adds considerably to the time to deploy the app and there is a 15 minute time out on cloud.gov that is pretty easy to hit.
  - The structure of your app (e.g. one file or two file) will have some implications.  
      - If using a one file app (e.g. with `app.R`) make sure that your server is all contained in a single object called `server` and that your user interface is contained within a single object named `ui`.  The last line of your `app.R` file should have `shinyApp(ui, server, uiPattern = ".*")`.  If you follow the standard structure of a one file app, you should be fine.  An example of this is available at <https://github.com/USEPA/R-User-Group/tree/master/contributedCode/cloud_gov_shiny/simple_epa_app_onefile> 
      - If using a two file app (e.g. with `ui.R` and `server.R`) make sure that you output your server to a `server` object and your user interface to a `ui` object.  An example of this is available at <https://github.com/USEPA/R-User-Group/tree/master/contributedCode/cloud_gov_shiny/simple_epa_app_twofile>
4. Set-up files needed for the cloud.gov push
  - r.yml
    - This file tells the r-buildpack what R packages are needed.
    - And we want to make sure this is lean as possible so that we don't run into timeout problems when we deploy.
    - We are using cloud.r-project.org as it should be faster for package downloads and are spreading the installs over the 4 cpus that we get with each cloud.gov instance.
    - it looks like:
    
```
---
packages: 
  - cran_mirror: https://cloud.r-project.org
    num_threads: 4
    packages:
      - name: dplyr
      - name: stringr
```
  - manifest.yml
    - This provides cloud.gov with all the clound foundry bits and pieces.  You can include almost all of these via the command line, but the manifest.yml provides a level of reproducibility and simplifies the push process for others.  So, do not use cli options, instead codify all of this in the manifest.yml.
    - A bare bones example is first and a second, more complete example is second.  Use the first when you are developing the app.  The second is close to what you need when you are about ready to push to production.
    
```
---
applications:
- name: myshinyapp
  buildpacks: 
  - https://github.com/cloudfoundry/r-buildpack.git 
```
```
---
applications:
- name: myshinyapp
  buildpacks: 
  - https://github.com/cloudfoundry/r-buildpack.git
  stack: cflinuxfs3
  memory: 512M
  routes:
  - route: shiny.epa.gov/awesome
  env:
    CF_STAGING_TIMEOUT: 15
```    
  - Procfile
    - This is a one-line file that gets run once your cloud.gov instance has started.  For Shiny apps this starts the Shiny application.  It looks like:
    
```
web: R -f shiny.R
```
  - shiny.R (one file app)
    - This is the R script that starts the Shiny app is what the Procfile points to.  
    - When using a one file shiny app (e.g. with just an `app.R`), It looks like:

```
library(shiny)
runApp(host="0.0.0.0", port=strtoi(Sys.getenv("PORT")))
```
  - shiny.R (two file app)
    - This is the R script that starts the Shiny app is what the Procfile points to.  
    - When using a two file shiny app (e.g. with a `server.R` and `ui.R`), It looks like:

```
library(shiny)
source("ui.R")
source("server.R")
app <- shinyApp(ui = ui, server = server, uiPattern = ".*")
runApp(app, host="0.0.0.0", port=strtoi(Sys.getenv("PORT")))
```
    
