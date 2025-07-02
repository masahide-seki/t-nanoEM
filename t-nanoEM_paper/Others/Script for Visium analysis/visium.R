Library(Seurat)
library(ggplot2)

#Load RDS file of Visium
LUAD14 <- readRDS(file = "lung_visium.rds")

#Visualization of UMAP with cluster numbers
DimPlot(LUAD14, reduction = "umap", label = TRUE, pt.size = 0.5)

#Addition of Regional ID
new.cluster.ids <- c("R2","R2","R4","R3","Others","Others","R5","Others","R1","Others","R1","Others","Others","R1","Others","R2","R5","R4")
names(new.cluster.ids)<-levels(LUAD14)
LUAD14R <- RenameIdents(LUAD14, new.cluster.ids)
LUAD14R@active.ident <- factor(LUAD14R@active.ident, levels = c("R1","R2","R3","R4","R5","Others"))

#Visualization of UMAP with Regional ID
DimPlot(LUAD14R, reduction = "umap", label = TRUE, pt.size = 0.5)

#Violin plot of gene expression for each region
VlnPlot(LUAD14R, features = c("HOPX"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()
VlnPlot(LUAD14R, features = c("FBXO32"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()
VlnPlot(LUAD14R, features = c("HSPA1A"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()
VlnPlot(LUAD14R, features = c("GNAS"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()
VlnPlot(LUAD14R, features = c("ZFP36L2"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()
VlnPlot(LUAD14R, features = c("DSP"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()
VlnPlot(LUAD14R, features = c("ESRRG"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()
VlnPlot(LUAD14R, features = c("OTX1"), pt.size =0, idents = c("R1","R2","R3","R4","R5")) + NoLegend()

#Violin plot of gene expression for each cluster (reordered)
LUAD14@active.ident <- factor(LUAD14@active.ident, levels = c("5","8","10","13","0","1","15","3","2","17","6","16","4","7","9","11","12","14"))
VlnPlot(LUAD14, features = c("HOPX"), pt.size =0) + NoLegend()
VlnPlot(LUAD14, features = c("SFTPA1"), pt.size =0) + NoLegend()
VlnPlot(LUAD14, features = c("SFTPB"), pt.size =0) + NoLegend()
VlnPlot(LUAD14, features = c("SFTPC"), pt.size =0) + NoLegend()
VlnPlot(LUAD14, features = c("VEGFA"), pt.size =0) + NoLegend()
VlnPlot(LUAD14, features = c("SLC2A1"), pt.size =0) + NoLegend()
VlnPlot(LUAD14, features = c("TNC"), pt.size =0) + NoLegend()
VlnPlot(LUAD14, features = c("HMGA1"), pt.size =0) + NoLegend()





