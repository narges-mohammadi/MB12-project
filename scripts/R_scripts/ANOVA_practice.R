install.packages("vctrs")
install.packages("rlang")
install.packages("gplots")
install.packages("multcomp")

library(dplyr)
library(vctrs)
library(magrittr)


my_data <- PlantGrowth

# Show a random sample
set.seed(1234)
dplyr::sample_n(my_data, 10)

# Show the levels
levels(my_data$group)

my_data$group <- ordered(my_data$group,
                         levels = c("ctrl", "trt1", "trt2"))


group_by(my_data, group) %>%
  summarise(
    count = n(),
    mean = mean(weight, na.rm = TRUE),
    sd = sd(weight, na.rm = TRUE)
  )


# Box plot
boxplot(weight ~ group, data = my_data,
        xlab = "Treatment", ylab = "Weight",
        frame = FALSE, col = c("#00AFBB", "#E7B800", "#FC4E07"))
# plotmeans
library("gplots")
plotmeans(weight ~ group, data = my_data, frame = FALSE,
          xlab = "Treatment", ylab = "Weight",
          main="Mean Plot with 95% CI") 


#Compute one-way ANOVA test
# Compute the analysis of variance
res.aov <- aov(weight ~ group, data = my_data)
# Summary of the analysis
summary(res.aov)


# Tukey multiple pairwise-comparisons
TukeyHSD(res.aov)

# Multiple comparisons using multcomp package
library(multcomp)
summary(glht(res.aov, linfct = mcp(group = "Tukey")))

#Pairewise t-test (pairwise comparisons between group levels)
pairwise.t.test(my_data$weight, my_data$group,
                p.adjust.method = "BH")

#Check ANOVA assumptions: test validity?
#The residuals versus fits plot can be used to check the homogeneity of variances.

# 1. Homogeneity of variances
plot(res.aov, 1)

#Use Bartlett’s test or Levene’s test to check the homogeneity of variances.
library(car)
leveneTest(weight ~ group, data = my_data)

#Relaxing the homogeneity of variance assumption

## ANOVA test with no assumption of equal variances
oneway.test(weight ~ group, data = my_data)
## Pairwise t-tests with no assumption of equal variances
pairwise.t.test(my_data$weight, my_data$group,
                p.adjust.method = "BH", pool.sd = FALSE)

#Check the normality assumption
# 2. Normality 
# As shown in the following plot,all the points fall approximately along this reference line,
# we can assume normality.
plot(res.aov, 2)

# Extract the residuals
aov_residuals <- residuals(object = res.aov )
# Run Shapiro-Wilk test
shapiro.test(x = aov_residuals )

#Non-parametric alternative to one-way ANOVA test
kruskal.test(weight ~ group, data = my_data)
