name <- '/my_data_2.xlsx'
knit2html('report.Rmd')
system(paste0('pandoc -o report2.docx report.html'))