
# --- 0. Load Input Data ----------------------------------------------------------------------------------------------------

table <- as.matrix(read.xlsx("./input/LUAD14_hap_merge.ann.meth.xlsx",sep="\t"))

# --- 1. Data Preprocessing -------------------------------------------------------------------------------------------------

colnames(table)[20:29] <- paste0(sort(rep(paste0("R",1:5),2)),"_HP",1:2)
colnames(table)[40:44] <- paste0("R",1:5,"_abs")
calculation_table <- matrix(as.numeric(table[,paste0("R",1:5,"_abs")]),ncol=5)
colnames(calculation_table) <- paste0("R",1:5,"_abs")

# to extract genes that do not contain any NA values in five regions
filter1 <- !is.na(apply(calculation_table,1,sum))
# to extract genes that have a difference between alleles by 50% or more in at least one region 
filter2 <- apply(calculation_table >= 50,1,sum) >= 1
filter2[is.na(filter2)] <- FALSE
# to extract genes that are located within ±10 kb of the TSS of RefSeq transcripts
filter3 <- abs(as.numeric(table[,"Distance\tto\tTSS"])) <= 10000

# create a table
heatmap <- matrix(as.numeric(table[filter1&filter2&filter3,paste0(sort(rep(paste0("R",1:5),2)),"_HP",1:2)]),ncol=10)
colnames(heatmap) <- paste0(sort(rep(paste0("R",1:5),2)),"_HP",1:2)
rowname <- table[filter1&filter2&filter3,"Gene\tName"]

# if multiple locations share the same name in table2, assign numbers to distinguish them.  
for (i in unique(rowname)){
  location <- which(rowname==i)
  if(length(location)>1){
    rowname[which(rowname==i)[c(seq(1,length(which(rowname==i))))]] <- paste0(i,"(",seq(1,length(which(rowname==i))),")")
  }
}
rownames(heatmap) <- rowname

# create a label
inprinting <- table[filter1&filter2&filter3,"Imprinted\tgene"]
names(inprinting)<-rowname
inprinting[inprinting=="1"] <- "orange"
inprinting[inprinting=="0"] <- "green"

# --- 2. Visualization -------------------------------------------------------------------------------------------------------

par(mar=c(5, 4, 4, 8))
pdf("./output/Figure5F.pdf")
heatmap.2(scale(heatmap),Rowv=TRUE,Colv=FALSE,dendrogram="row",trace="none",col="bluered",density.info="none",labRow=NA,
          cexRow=0.75,cexCol=1,margins=c(5,6),RowSideColors=inprinting,hclustfun=function(x){hclust(x,method="ward.D2")})
dev.off()