
# --- 0. Load Input Data ----------------------------------------------------------------------------------------------------

table <- as.matrix(read.table("./input/LUAD14_bulk_merge.ann.meth.bed",sep="\t",header=T))

# --- 1. Data Preprocessing -------------------------------------------------------------------------------------------------

sample_name <- colnames(table)[grep("^R[0-9]*r",colnames(table))]
options(warn=-1)
calculation_table <- matrix(as.numeric(table[,sample_name]),ncol=length(sample_name))
options(warn=0)

# to extract genes that do not contain any NA values in five regions
filter1 <- !is.na(apply(calculation_table,1,sum))
# to extract genes that differ by 30% or more in any combination of five regions
filter2 <- apply(calculation_table,1,max) - apply(calculation_table,1,min) >= 30

# create a table
heatmap <- calculation_table[filter1&filter2,]
rownames(heatmap) <- table[filter1&filter2,"Gene.Name"]
colnames(heatmap) <- gsub("r","",sample_name)

# --- 2. Visualization -------------------------------------------------------------------------------------------------------

par(mar=c(5, 4, 4, 8))
pdf("./output/Figure5D.pdf")
heatmap.2(scale(heatmap),Rowv=TRUE,Colv=TRUE,dendrogram="both",trace="none",col="bluered",labRow=NA,
          cexRow=0.7,cexCol=1,density.info="none",margins=c(5,6),hclustfun=function(x){hclust(x,method="ward.D2")})
dev.off()