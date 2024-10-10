## MEthylation alaysis using bioconductor package methylkit 
library(methylKit)

## Data 
## Example data were taken from Bioiconductorr package. 
file.list=list( system.file("extdata", 
                            "test1.myCpG.txt", package = "methylKit"),
                system.file("extdata",
                            "test2.myCpG.txt", package = "methylKit"),
                system.file("extdata", 
                            "control1.myCpG.txt", package = "methylKit"),
                system.file("extdata", 
                            "control2.myCpG.txt", package = "methylKit") )


# read the files to a methylRawList object: myobj
myobj=methRead(file.list,
               sample.id=list("test1","test2","ctrl1","ctrl2"),
               assembly="hg18",
               treatment=c(1,1,0,0),
               context="CpG",
               mincov = 10
)


##Comparative analysis
meth=methylKit::unite(myobj, destrand = TRUE)

## correlation bet mc and hmc 
getCorrelation(meth, plot=TRUE)

#Finding differentially methylated bases
myDiff=calculateDiffMeth(meth, mc.cors = 8)

## Filter methyldiff based on q value and p value and diff greater than 25%
filtered.diff= getMethylDiff(myDiff, difference = 25, qvalue = 0.01)

## To filter based on p-values 
## filter.diff <- myDiff[myDiff$pvalue < 0.05 ,]

## Save file as csv file
meth.diff <- as(filtered.diff, "data.frame")
# write.csv(meth.diff, file=""location/to/save/file/meth.diff.csv)


#Annotating differentially methylated bases or regions
library(genomation)

# read the gene BED file
# We can download the ref bed file from ucsc browser.
gene.obj=readTranscriptFeatures(system.file("extdata", "refseq.hg18.bed.txt", 
                                            package = "methylKit"))

# annotate differentially methylated CpGs with 
# promoter/exon/intron using annotation data
diff.anno <- annotateWithGeneParts(as(filtered.diff,"GRanges"),gene.obj)

# TSS annotation 
tss.anno <- (getAssociationWithTSS(diff.anno))

##Save as csv file
# write.csv(tss.anno, file="location/to/save/file/tss_annotation.csv")


#plot the percentage of differentially methylated bases overlapping with exon/intron/promoters
plotTargetAnnotation(diff.anno, precedence=TRUE,
                     main="differential methylation annotation")
