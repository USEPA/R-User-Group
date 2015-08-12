
# basics 

lc <- factor(letters[1:5])
lc
attributes(lc)
levels(lc)
class(lc)
mode(lc)   # R will generally hide

# levels() on expression lefthand side (assignment)

lf <- factor(letters[1:5])
lf2 <- lf; levels(lf2)[1] <- "A"
table(lf,lf2)

# sparse table print 
compare <- function(a,b) print(table(a,b), zero.print=".")
compare(lf,lf2)

# everyone knows you can't do this:  (violate levels)

lf <- factor(letters[1:10])
lf[1] <- "o"  # wrong, "o" is not among levels
"o"  %in% levels(lf)
lf[1] <- "c"  # ok "c" is a level

# more violation of levels()

lf  <- factor(letters[1:5])
lf2 <- factor(letters[2:6])
any(lf == lf2)    # different levels() => not comparable 
any(as.character(lf)==as.character(lf2)) # ok
intersect(lf,lf2)  # btw, above is not this

# unexpected (?) results of as.numeric()
# random vector (Marcus)

vec <- sample(4:6, 25, replace = T)
vec <- factor(vec)
levels(vec)      # represents actual values as character
as.numeric(vec)  # probably not what is desired 
as.numeric(factor(letters))   # analogous to this
as.numeric(as.character(vec)) # probably what you were thinking 

# unexpected (?) behavior in matrix manipulations

lc <- letters       # character
lf <- factor(lc)    
cbind(lc)      # ok 
cbind(lf,data.frame(lc))  # ok (but converts character to factor)
cbind(lf)   # ???
methods(cbind) # how R might interpret cbind()
cbind.data.frame(lf,lc) # ok - override default method dispatch

# procedure;  count levels actually present (possibly after subsetting)
# or set levels to levels present 

lf <- factor(letters[1:5])
lf2 <- lf[1:2]           # subset 
lf2                      # note levels not updated 
length(levels(lf2))      # don't use
length(droplevels(lf2))  # works

lf3 <- droplevels(lf[1:2]) # better (?) drop unused levels from get-go
length(lf3)

levels(factor(lf2))      # works (stackxchange)
levels(as.factor(lf2))   # doesn't work
as.factor

# stringsAsFactor for default character to factor conversation

class(letters)
da <- data.frame(letters)  # default 
lapply(da, class)

da <- data.frame( # over-ride default
  letters, 
  stringsAsFactors = F  
)
lapply(da, class)

# procedure:  control the order of category presentation

lf <- factor(letters[1:5])
lf2 <- factor(lf, levels = rev(levels(lf)))  # reverse order w/out really modifying data
table(lf)
table(lf2)
all(lf==lf2) # the data was not changed fundamentally
compare(lf,lf2)

# procedure : set a reference level

lf <- factor(letters[1:5])
lf2 <- relevel(lf, ref = "e")
compare(lf, lf2)

# lump two categories with recode() - Fox and Weisburg car book

library(car)
lf  <- factor(letters[1:5])
lf2 <- recode(lf, "'a'='a.OR.b';'b'='a.OR.b'" )
compare(lf, lf2)

# Cartesian product (all combinations)

mo <- factor(c("may","jun","may","jun"), levels=c("may","jun"))
yr <- factor(c("2012","2012","2014","2014"))
paste(mo, yr, sep="-")           # character not factor 
factor(paste(mo, yr, sep="-"))   # sort of works - ordering not ideal

# paste conserving input level order 

factor( paste(mo, yr, sep="-"),
        levels=with(
          expand.grid(levels(mo), levels(yr)),
          paste(Var1, Var2, sep="-")
          )
        )

interaction(levels(mo), levels(yr))   # also useful (thanks Tony)

# define factor based on numeric ranges

x <- 100*runif(10000) # uniform on [0,100]
table(cut(x, 25*(0:4)))

# ordered factors & more S3 ideas 

lf <- factor(letters[1:5])
lordd <- ordered(lf)
lordd
attributes(lordd) # note 'dual membership' (factor, ordered)
is.factor(lordd)
is.ordered(lordd)
methods(summary) # summary.factor exists, summary.ordered doesn't (ok)
summary(lordd)   # same as summary.factor()
summary.factor(lordd)
