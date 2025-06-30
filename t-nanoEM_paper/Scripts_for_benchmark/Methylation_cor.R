library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 4) {
  stop("Usage: Rscript your_script_name.R <input_file.tsv> <output_file.pdf> <sample1_name> <sample2_name>", call. = FALSE)
}

input_file <- args[1]
output_file <- args[2]
sample1_name <- args[3]
sample2_name <- args[4]

data <- read.table(input_file, header = TRUE)

rf <- colorRampPalette(rev(brewer.pal(11, 'Spectral')))
r <- rf(32)

c <- cor(data$frequency_1, data$frequency_2)
title <- sprintf("N = %d r = %.3f", nrow(data), c)

pdf(output_file, width = 8)
ggplot(data, aes(frequency_1, frequency_2)) +
  geom_bin2d(bins = 25) +
  scale_fill_gradientn(colors = r, trans = "log10") +
  xlab(paste0(sample1_name, " Methylation Rate (%)")) +
  ylab(paste0(sample2_name, " Methylation Rate (%)")) +
  theme_bw(base_size = 20) +
  ggtitle(title)
dev.off()
