# How to vendor packages for your shiny app

1. make dir vendor_r/src/contrib in app
2. use `miniCRAN::makeRepo(miniCRAN::pkgDep(c("pkg_name1","pkg_name2")),"vendor_r", type="source")`.  In the pkgDep function, you will need to list all of the packages that your app requires.  You should have these listed in the `r.yml`  This can take some time.
3. In the apps `r.yml` file, remove the line

```
- cran_mirror: https://cran.r-project.org
```

Your `r.yml` should look something like:

```
---
packages: 
  - packages:
      - name: dplyr
      - name: ggplot2
      - name: cowplot
```
    
4. Your app is now using vendored packages so it will not be installing these from CRAN.  If you need to update or change packages in the future, you will need to be sure to repeat step 2 above to add those new packages/versions to the vendor_r folder.

