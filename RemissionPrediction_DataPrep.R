### Individualized Prediction of Remission, Part I 
### Author: Michelle Worthington, 2020 

library(dplyr)
library(dummies)

# Import data and restructure for analysis #
NAPLS3_data = read.csv("/Users/maw/Documents/Documents/Yale/Cannon Lab/Optimizing baseline models/Remission/Data/N3_6month_remission_8.20.21.csv")
NAPLS2_data = read.csv("/Users/maw/Documents/Documents/Yale/Cannon Lab/Optimizing baseline models/Remission/Data/N2_updated_6month_remission.csv")

## Remission variables based on SOPS positive symptom items rated as below a 3 (sub-prodromal) 
## for two consecutive study visits 6 months apart 

NAPLS2_data$SOPS_rem.6months = factor(NAPLS2_data$SOPS_rem.6months)
NAPLS3_data$SOPS_rem.6months = factor(NAPLS3_data$SOPS_rem.6months)

names(NAPLS2_data)[163] = "gaf_current.BL"
names(NAPLS2_data)[164] = "gaf_pastyr.BL"
names(NAPLS2_data)[4] = "SITE"


# Filter to just variables of interest #
NAPLS3_data_sub = subset(NAPLS3_data, select = c(SOPS_rem.6months, demo_age_ym, demo_sex, demo_racial, 
                                         demo_hispanic_latino, demo_education_dad, demo_education_mom, 
                                         demo_education_years, P1_SOPS.BL, P2_SOPS.BL, P3_SOPS.BL, P4_SOPS.BL, 
                                         P5_SOPS.BL, N1_SOPS.BL, N2_SOPS.BL, N3_SOPS.BL, N4_SOPS.BL, 
                                         N5_SOPS.BL, N6_SOPS.BL, D1_SOPS.BL, D2_SOPS.BL, D3_SOPS.BL, 
                                         D4_SOPS.BL, G1_SOPS.BL, G2_SOPS.BL, G3_SOPS.BL, G4_SOPS.BL, 
                                         gaf_current.BL, gaf_pastyr.BL, gfr_current.BL, gfr_past_year_highest.BL, 
                                         gfr_past_year_lowest.BL, gfs_current.BL, gfs_past_year_highest.BL, 
                                         gfs_past_year_lowest.BL, bacsraw, hvlttotal, CDS1.BL, CDS2.BL, 
                                         CDS3.BL, CDS4.BL, CDS5.BL, CDS6.BL, CDS7.BL, CDS8.BL, CDS9.BL, C_CDSTOTAL.BL))
NAPLS3_data_dum = NAPLS3_data_sub %>%
  dummy.data.frame(names = c("demo_racial")) %>% 
  subset(select = -demo_racialNA) %>%
  na.omit()

NAPLS2_data_sub = subset(NAPLS2_data, select = c(SOPS_rem.6months, demo_age_ym, demo_sex, demo_racial, 
                                         demo_hispanic_latino, demo_education_dad, demo_education_mom, 
                                         demo_education_years, P1_SOPS.BL, P2_SOPS.BL, P3_SOPS.BL, P4_SOPS.BL, 
                                         P5_SOPS.BL, N1_SOPS.BL, N2_SOPS.BL, N3_SOPS.BL, N4_SOPS.BL, 
                                         N5_SOPS.BL, N6_SOPS.BL, D1_SOPS.BL, D2_SOPS.BL, D3_SOPS.BL, 
                                         D4_SOPS.BL, G1_SOPS.BL, G2_SOPS.BL, G3_SOPS.BL, G4_SOPS.BL,  
                                         gaf_current.BL, gaf_pastyr.BL, gfr_current.BL, gfr_past_year_highest.BL, 
                                         gfr_past_year_lowest.BL, gfs_current.BL, gfs_past_year_highest.BL, 
                                         gfs_past_year_lowest.BL, bacsraw, hvlttotal, CDS1.BL, CDS2.BL, 
                                         CDS3.BL, CDS4.BL, CDS5.BL, CDS6.BL, CDS7.BL, CDS8.BL, CDS9.BL, C_CDSTOTAL.BL))
NAPLS2_data_dum = NAPLS2_data_sub %>%
  dummy.data.frame(names = c("demo_racial")) %>% 
  na.omit()


## Calculate variables: ##
#### - decline in functioning
#### - sum of positive symptom scores 
#### - racial demographics 

NAPLS3_data_dum$gaf_decline.BL = NAPLS3_data_dum$gaf_pastyr.BL - NAPLS3_data_dum$gaf_current.BL
NAPLS3_data_dum$gaf_decl_30 = ifelse((NAPLS3_data_dum$gaf_decline.BL/NAPLS3_data_dum$gaf_pastyr.BL) >= 30, 1, 0)
NAPLS3_data_dum$gfs_decline.BL = NAPLS3_data_dum$gfs_past_year_highest.BL - NAPLS3_data_dum$gfs_current.BL
NAPLS3_data_dum$gfr_decline.BL = NAPLS3_data_dum$gfr_past_year_highest.BL - NAPLS3_data_dum$gfr_current.BL
NAPLS3_data_dum$demo_race_white = ifelse(NAPLS3_data_dum$demo_racial8 == 1, 1, 0)
NAPLS3_data_dum$demo_race_black = ifelse(NAPLS3_data_dum$demo_racial5 == 1, 1, 0)
NAPLS3_data_dum$demo_race_asian = ifelse(NAPLS3_data_dum$demo_racial2 | 
                                       NAPLS3_data_dum$demo_racial3 | 
                                       NAPLS3_data_dum$demo_racial7 | 
                                       NAPLS3_data_dum$demo_racial4 == 1, 1, 0)
NAPLS3_data_dum$demo_race_other = ifelse(NAPLS3_data_dum$demo_racial1 | 
                                       NAPLS3_data_dum$demo_racial6 | 
                                       NAPLS3_data_dum$demo_racial9 | 
                                       NAPLS3_data_dum$demo_racial10 == 1, 1, 0)
NAPLS3_data_dum$race_min = ifelse(NAPLS3_data_dum$demo_race_white == 1, 1, 0)
NAPLS3_data_dum$parental_education = with(NAPLS3_data_dum, (demo_education_dad + demo_education_mom)/2)
NAPLS3_data_dum$SOPS_pos_sum.BL = with(NAPLS3_data_dum, (P1_SOPS.BL + P2_SOPS.BL + P3_SOPS.BL + P4_SOPS.BL + P5_SOPS.BL))

NAPLS2_data_dum$gaf_decline.BL = NAPLS2_data_dum$gaf_pastyr.BL - NAPLS2_data_dum$gaf_current.BL
NAPLS2_data_dum$gaf_decl_30 = ifelse((NAPLS2_data_dum$gaf_decline.BL/NAPLS2_data_dum$gaf_pastyr.BL) >= 30, 1, 0)
NAPLS2_data_dum$gfs_decline.BL = NAPLS2_data_dum$gfs_past_year_highest.BL - NAPLS2_data_dum$gfs_current.BL
NAPLS2_data_dum$gfr_decline.BL = NAPLS2_data_dum$gfr_past_year_highest.BL - NAPLS2_data_dum$gfr_current.BL
NAPLS2_data_dum$demo_race_white = ifelse(NAPLS2_data_dum$demo_racial8 == 1, 1, 0)
NAPLS2_data_dum$demo_race_black = ifelse(NAPLS2_data_dum$demo_racial5 == 1, 1, 0)
NAPLS2_data_dum$demo_race_asian = ifelse(NAPLS2_data_dum$demo_racial2 | 
                                       NAPLS2_data_dum$demo_racial3 | 
                                       NAPLS2_data_dum$demo_racial7 | 
                                       NAPLS2_data_dum$demo_racial4 == 1, 1, 0)
NAPLS2_data_dum$demo_race_other = ifelse(NAPLS2_data_dum$demo_racial1 | 
                                       NAPLS2_data_dum$demo_racial6 | 
                                       NAPLS2_data_dum$demo_racial9 | 
                                       NAPLS2_data_dum$demo_racial10 == 1, 1, 0)
NAPLS2_data_dum$race_min = ifelse(NAPLS2_data_dum$demo_race_white == 1, 1, 0)
NAPLS2_data_dum$parental_education = with(NAPLS2_data_dum, (demo_education_dad + demo_education_mom)/2)
NAPLS2_data_dum$SOPS_pos_sum.BL = with(NAPLS2_data_dum, (P1_SOPS.BL + P2_SOPS.BL + P3_SOPS.BL + P4_SOPS.BL + P5_SOPS.BL))

## Finalize variables in datasets that will be used for analysis 
NAPLS3_train = subset(NAPLS3_data_dum, select = c(SOPS_rem.6months, demo_age_ym, demo_sex,
                                        parental_education, demo_education_years, race_min,
                                        P1_SOPS.BL, P2_SOPS.BL, P3_SOPS.BL, P4_SOPS.BL, 
                                        P5_SOPS.BL, N1_SOPS.BL, N2_SOPS.BL, N3_SOPS.BL, N4_SOPS.BL, 
                                        N5_SOPS.BL, N6_SOPS.BL, D1_SOPS.BL, D2_SOPS.BL, D3_SOPS.BL, 
                                        D4_SOPS.BL, G1_SOPS.BL, G2_SOPS.BL, G3_SOPS.BL, G4_SOPS.BL,  
                                        gaf_decl_30, gfs_decline.BL, gfr_decline.BL, bacsraw, hvlttotal, CDS1.BL, CDS2.BL, 
                                        CDS3.BL, CDS4.BL, CDS5.BL, CDS6.BL, CDS7.BL, CDS8.BL, CDS9.BL))
NAPLS2_test = subset(NAPLS2_data_dum, select = c(SOPS_rem.6months, demo_age_ym, demo_sex,
                                        parental_education, demo_education_years, race_min,
                                        P1_SOPS.BL, P2_SOPS.BL, P3_SOPS.BL, P4_SOPS.BL, 
                                        P5_SOPS.BL, N1_SOPS.BL, N2_SOPS.BL, N3_SOPS.BL, N4_SOPS.BL, 
                                        N5_SOPS.BL, N6_SOPS.BL, D1_SOPS.BL, D2_SOPS.BL, D3_SOPS.BL, 
                                        D4_SOPS.BL, G1_SOPS.BL, G2_SOPS.BL, G3_SOPS.BL, G4_SOPS.BL, 
                                        gaf_decl_30, gfs_decline.BL, gfr_decline.BL, bacsraw, hvlttotal, CDS1.BL, CDS2.BL, 
                                        CDS3.BL, CDS4.BL, CDS5.BL, CDS6.BL, CDS7.BL, CDS8.BL, CDS9.BL))

