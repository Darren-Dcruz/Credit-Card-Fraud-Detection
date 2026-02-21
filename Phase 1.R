# ============================================================
# Phase 1: Data Understanding & Cleaning (R)
# Dataset: Credit Card Fraud Detection (Kaggle - ULB)
# ============================================================

# ── 1. Install & Load Libraries ──────────────────────────────
install.packages(c("tidyverse", "skimr", "janitor"))

library(tidyverse)   # Data manipulation
library(skimr)       # Summary statistics
library(janitor)     # Cleaning helpers

# ── 2. Load Dataset ──────────────────────────────────────────
setwd("C:/Users/SRI/OneDrive/Desktop/Desktop/Intro to DS")
df <- read.csv("creditcard.csv")

cat("✅ Dataset Loaded\n")
cat("Rows:", nrow(df), "| Columns:", ncol(df), "\n")

# ── 3. Initial Exploration ────────────────────────────────────
head(df, 5)          # First 5 rows
str(df)              # Data types
dim(df)              # Dimensions

# ── 4. Summary Statistics ─────────────────────────────────────
summary(df)
skim(df)             # Detailed stats: mean, sd, missing, histograms

# ── 5. Check for Missing Values ───────────────────────────────
missing_vals <- colSums(is.na(df))
cat("\n🔍 Missing Values per Column:\n")
print(missing_vals[missing_vals > 0])  # Show only columns with missing data

# If missing values exist, impute with median (safe for skewed data)
df <- df %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))

cat("✅ Missing values handled\n")

# ── 6. Remove Duplicates ──────────────────────────────────────
before <- nrow(df)
df <- df %>% distinct()
after  <- nrow(df)

cat("🗑️ Duplicates removed:", before - after, "\n")
cat("Remaining rows:", after, "\n")

# ── 7. Check Class Distribution (Fraud vs Normal) ─────────────
class_dist <- df %>%
  count(Class) %>%
  mutate(
    Label      = ifelse(Class == 0, "Normal", "Fraud"),
    Percentage = round(n / sum(n) * 100, 2)
  )

print(class_dist)

# ── 8. Outlier Check on 'Amount' ──────────────────────────────
cat("\n💰 Amount column stats:\n")
cat("Min:", min(df$Amount), "\n")
cat("Max:", max(df$Amount), "\n")
cat("Mean:", mean(df$Amount), "\n")
cat("Median:", median(df$Amount), "\n")

# Box plot to visualise outliers
boxplot(df$Amount,
        main = "Boxplot of Transaction Amount",
        ylab = "Amount (USD)",
        col  = "steelblue",
        outline = TRUE)

# ── 9. Normalise 'Amount' and 'Time' columns ──────────────────
# These are raw; all V1–V28 are already PCA-scaled
df$Amount_scaled <- scale(df$Amount)
df$Time_scaled   <- scale(df$Time)

# Drop original raw columns (optional — keep if needed for Tableau)
df_model <- df %>% select(-Amount, -Time)

cat("✅ Amount and Time columns normalised\n")

# ── 10. Sampling — Train/Validation Split ─────────────────────
set.seed(42)  # For reproducibility

sample_index <- sample(1:nrow(df_model), size = 0.8 * nrow(df_model))
train_data   <- df_model[sample_index, ]
valid_data   <- df_model[-sample_index, ]

cat("📊 Training set size:", nrow(train_data), "\n")
cat("📊 Validation set size:", nrow(valid_data), "\n")

# ── 11. Save Cleaned Dataset ──────────────────────────────────
write.csv(df_model,   "creditcard_cleaned.csv",    row.names = FALSE)
write.csv(train_data, "creditcard_train.csv",      row.names = FALSE)
write.csv(valid_data, "creditcard_validation.csv", row.names = FALSE)

cat("✅ Cleaned files saved: creditcard_cleaned.csv, _train.csv, _validation.csv\n")