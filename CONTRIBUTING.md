How to contribute to R-User-Group
================================

### Bugs or Questions?

* Submit an issue on [the Issues page](https://github.com/USEPA/R-User-Group/issues)

### Contributions
These instructions should work for any file type.

* Fork this repo to your Github account
* Clone your version on your account down to your machine from your account, e.g,. `git clone https://github.com/<yourgithubusername>/R-User-Group.git`
* Make sure to track progress upstream (i.e., on our version of `R-User-Group` at `USEPA/R-User-Group`) by doing `git remote add upstream https://github.com/USEPA/R-User-Group.git`. Before making changes make sure to pull changes in from upstream by doing either `git fetch upstream` then merge later or `git pull upstream` to fetch and merge in one step
* Make your changes (bonus points for making changes on a new branch)
    * If you are adding a new function, or changing functionality of a function, include new tests, and make sure those pass before submittint the PR.
* Push up to your account
* Submit a pull request to home base at `USEPA/R-User-Group`

###Note
Thanks to [rOpenSci](https://github.com/rOpenSci) and @sckott whose contributing file I very blatantly stole.  It was just so good, why make significant changes?