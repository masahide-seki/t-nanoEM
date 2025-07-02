
# --- 0. Load Input Data ----------------------------------------------------------------------------------------------------

table1 <- as.matrix(read.xlsx("./input/BRC26_hap_DMR_with_meth.xlsx",sep="\t"))

# --- 1. Data Preprocessing -------------------------------------------------------------------------------------------------

colnames(table1)[1] <- "PeakID"
colnames(table1)[21:28] <- paste0(sort(rep(paste0("R",1:4),2)),"_HP",1:2)
colnames(table1)[37:40] <- paste0("R",1:4,"_abs")
abs_table <- matrix(as.numeric(table1[,paste0("R",1:4,"_abs")]),ncol=4)
colnames(abs_table) <- paste0("R",1:4,"_abs")

# to extract genes that do not contain any NA values in four regions
filter1 <- !is.na(apply(abs_table,1,sum))
# to extract genes that are located within ±10 kb of the TSS of RefSeq transcripts
filter2 <- abs(as.numeric(table1[,"Distance\tto\tTSS"])) <= 10000
# to extract genes that have a difference between haplotypes in non-tumor regions R1 and R2 was less than 10%
# and 40% or more in tumor regions R3 and R4
filter3 <- as.numeric(table1[,"R3_abs"]) >= 40 & as.numeric(table1[,"R4_abs"]) >= 40 &
           as.numeric(table1[,"R1_abs"]) <= 10 & as.numeric(table1[,"R2_abs"]) <= 10

# create a table
table2 <- table1[filter1&filter2&filter3,paste0(sort(rep(paste0("R",1:4),2)),"_HP",1:2)]
rowname <- table1[filter1&filter2&filter3,"Gene\tName"]

# if multiple locations share the same name in table2, assign numbers to distinguish them.  
for (i in unique(rowname)){
  location <- which(rowname==i)
  if(length(location)>1){
    rowname[which(rowname==i)[c(seq(1,length(which(rowname==i))))]] <- paste0(i,"(",seq(1,length(which(rowname==i))),")")
  }
}
colname <- colnames(table2)

# create a table
heatmap <- matrix(as.numeric(table2),nrow=nrow(table2),ncol=ncol(table2))
rownames(heatmap) <- rowname
colnames(heatmap) <- colname

# --- 2. Visualization -------------------------------------------------------------------------------------------------------

par(mar=c(5, 4, 4, 8))
pdf("./output/Figure4H.pdf")
heatmap.2(scale(heatmap),Rowv=TRUE,Colv=FALSE,dendrogram="row",trace="none",col="bluered",density.info="none",
          labRow=NA,cexRow=0.75,cexCol=1,margins=c(5,6),hclustfun=function(x){hclust(x, method="ward.D2")})
dev.off()
