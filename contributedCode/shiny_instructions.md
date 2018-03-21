# Shiny Instructions

This document lays out the steps to request a new shiny app on the NCC Shiny Server as well as provides direction on how to move your application files over to the server via FileZilla.

These instructions assume you have developed and tested your shiny app locally and are ready to create a new app on the Shiny server at the NCC in RTP.  Once succesfully set-up these apps will be available to any users on the EPA network.  The process for making apps publically available has not yet been developed and currently this is not available to us.  We plan to address this in the coming months and will hopefully have a process completed in late 2018.

- [Request a new app](#request-a-new-app)
- [Move files to the Shiny server](#move-files-to-the-server)

## Request a new app

Once your app is working locally and ready to be moved to the NCC Shiny Server you will need to request access to the server.  To do so:

1. Send an email to analytics@epa.gov to let them know you have a Shiny app you want to put on the Shiny server.  They need to provide you access.  Make sure to cc vega.ann@epa.gov on this email.
2. In the email, include a list of all R packages needed to run your Shiny app. Request that they be installed on the server.

Once you have been granted access to the server and all the packages you requested have been installed, you will receive an email with next steps.  The most important of which will be moving your application files to the server.

## Move files to the Shiny server

If you have not worked much with remote linux servers, then the process for getting your files moved will seem a bit foreign.  The instructions below should help.

There are many ways to access remote servers from our Windows machines, but the most straightforward method is to use a Windows application, FileZilla, to make the connection to the server and move your application files.  The following instructions explain how to do this.

1. You will need to have FileZilla installed on your machine.  This can be accomplished with the typical Freeware/Shareware request.  

2. With FileZilla installed you can now move your files.  Open up FileZilla.  It will look like this when you do:

![FileZilla Opened](img/filezilla_open.jpg)


