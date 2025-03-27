#######################################
# 1. Convert VCF to PLINK format
#######################################
plink --vcf input.vcf --recode --out mydata


#######################################
# 2. Quality Control (QC)
#######################################

# a. Remove individuals with >10% missing genotypes
plink --bfile mydata --mind 0.1 --make-bed --out qc_step1

# b. Remove SNPs with >5% missingness
plink --bfile qc_step1 --geno 0.05 --make-bed --out qc_step2

# c. Filter SNPs with MAF < 1%
plink --bfile qc_step2 --maf 0.01 --make-bed --out qc_step3

# d. Remove SNPs not in Hardy-Weinberg Equilibrium
plink --bfile qc_step3 --hwe 1e-6 --make-bed --out qc_final
# or
plink --bfile chr7_kin --geno 0.01 --mind 0.01 --hwe 0.001 --make-bed --out chr7_filtered
#######################################
# 3. Sample Checks
#######################################

# a. Check for sex discrepancies
plink --bfile qc_final --check-sex --out sexcheck

# b. Detect related individuals
plink --bfile qc_final --genome --out relatedness


#######################################
# 4. Population Stratification
#######################################

# Run Principal Component Analysis (PCA)
plink --bfile qc_final --pca 10 --out pca_result


#######################################
# 5. Association Analysis (GWAS)
#######################################

# a. Case-control association (basic)
plink --bfile qc_final --pheno phenotype.txt --assoc --out gwas_assoc

# b. Logistic regression with covariates (e.g. age, sex, PCs)
plink --bfile qc_final --pheno phenotype.txt --covar covariates.txt --logistic --out gwas_logistic


#######################################
# 6. Polygenic Risk Score (PRS)
#######################################

# Score individuals based on SNP weights (effect sizes)
plink --bfile qc_final --score snp_effects.txt 1 2 3 --out prs_scores


#######################################
# 7. Export Data to VCF
#######################################

# Convert final dataset to VCF format
plink --bfile qc_final --recode vcf --out final_data
