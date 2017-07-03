setwd('/Users/mpinsky/Documents/Rutgers/NorthAmerican_survey_data/Taxonomy/')
dat = read.csv('spptaxonomy_2014-10-08_plusManual.csv', stringsAsFactors=FALSE)


dat$common = gsub('^a ', '', dat$common)
dat$common = gsub('^an ', '', dat$common)

j = !grepl('.*[[:blank:]].*', dat$name) # everything that's not a binomial name
dat$name[j] = paste(dat$name[j], 'spp.')
write.csv(dat, file='spptaxonomy_2014-10-09_plusManual.csv', row.names=FALSE)