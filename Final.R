# Load all required libraries
library(readxl)
library(dplyr)
library(stats)
library(bsts)
library(ggplot2)
library(gridExtra)

###################### Demand data ######################

# Vector to hold the number of tech employees by year according to data from the U.S. Bureau of Labor Statistics
employment_count = c()

# Extract the counts from the Excel spreadsheets by year
for (year in 2019:2023) {
  demand_data <- read_excel(paste("./Demand/", as.character(year), ".xlsx", sep = ""), sheet = 1)
  filtered_demand_data <- filter(demand_data, OCC_CODE %in% c("11-3020", "15-2050", "15-1210", "15-1220", "15-1240", "15-1250", "51-9162", "15-1290"))
  employment_count <- append(employment_count, sum(as.integer(filtered_demand_data$TOT_EMP)))
}

# Create a time series from the vector
employment_ts <- ts(employment_count, start = c(2019), frequency = 1)

# Plot the historic values
## plot(employment_ts, main = "Employment Count Time Series", xlab = "Year", ylab = "Employment Count")

# Construct a BSTS model for demand data
demand_model <- bsts(employment_ts, state.specification = AddLocalLinearTrend(list(), employment_ts), niter = 1000)

# Forecast 4 years using the model
demand_forecast_values <- predict(demand_model, horizon = 4)
plot(demand_forecast_values, ylim=c(4e6, 7e6), main = "Job Market Demand Forecast", ylab = "Total Positions", xlab = "Year")

# Predicted outcome using the mean of the r.v.
demand_mean_ts <- ts(append(as.vector(demand_forecast_values$original.series), demand_forecast_values$mean), start = 2019, frequency = 1)
plot(demand_mean_ts, main = "Predicted Outcome", ylab = "Total Positions", xlab = "Year")

# Best-case scenario using the upper bound of the 95% credible interval
demand_best_case_ts <- ts(append(as.vector(demand_forecast_values$original.series), demand_forecast_values$interval[2,]), start = 2019, frequency = 1)
plot(demand_best_case_ts, main = "Best-Case Scenario", ylab = "Total Positions", xlab = "Year")

###################### Combine retirement data ######################

# Gather data about the occupations mentioned below only
select_occupations = c("Computer and information systems managers", "Computer and information research scientists", "Computer systems analysts", "Information security analysts", "Computer programmers", "Software developers", "Software quality assurance analysts and testers", "Web developers")

retirement_data <- read_excel("Occupation by Age.xlsx", sheet = 1)
filtered_retirement_data <- retirement_data[!is.na(retirement_data[1]) & retirement_data[[1]] %in% select_occupations, ]

# Change the column names to be more descriptive
colnames(filtered_retirement_data) = c("Occupation", "Total", "16 to 19 years", "20 to 24 years", "25 to 34 years", "35 to 44 years", "45 to 54 years", "55 to 64 years", "65 years and over", "Median")

# Change the data type of number columns from string to numeric
filtered_retirement_data <- filtered_retirement_data %>% mutate(across(everything(), ~ifelse(is.na(as.numeric(.)), ., as.numeric(.))))

# Sum across columns
numbers_by_age_range <- filtered_retirement_data %>%
  summarise(across(where(is.numeric), sum))

numbers_by_age_range <- numbers_by_age_range[, -1]

# Extract the first row (frequencies) and convert it into a vector
numbers_by_age_range_vector <- as.numeric(unlist(numbers_by_age_range[1,]))

# Extract the column names for the x-axis
age_ranges <- colnames(numbers_by_age_range)

par(mar = c(8, 4, 4, 2))

# Plot the histogram with custom labels
barplot(numbers_by_age_range_vector, names.arg = age_ranges, 
        main = "Histogram of Ages", col = "lightblue", border = "black", las = 2, ylab = "Frequency")

# Predicted outcome is people retire at 67
current_year_index <- 2025 - 2019 + 1
uniform_dist_per_year_55_to_64 <- numbers_by_age_range_vector[length(numbers_by_age_range_vector)-1] * 1000 / 10

demand_mean_ts[current_year_index:length(demand_mean_ts)] <- demand_mean_ts[current_year_index:length(demand_mean_ts)] + tail(numbers_by_age_range_vector, 1) * 1000
demand_mean_ts[length(demand_mean_ts)] <- demand_mean_ts[length(demand_mean_ts)] + uniform_dist_per_year_55_to_64

# Best-case scenario is people retire at 62
demand_best_case_ts[current_year_index:length(demand_best_case_ts)] <- demand_best_case_ts[current_year_index:length(demand_best_case_ts)] + tail(numbers_by_age_range_vector, 1) * 1000
demand_best_case_ts[current_year_index:length(demand_best_case_ts)] <- demand_best_case_ts[current_year_index:length(demand_best_case_ts)] + uniform_dist_per_year_55_to_64 * 3

for (i in 1:3) {
  demand_best_case_ts[current_year_index+i-1] <- demand_best_case_ts[current_year_index+i-1] + uniform_dist_per_year_55_to_64 * i
}

# Reset the margins
par(mar = c(5, 4, 4, 2))

###################### Supply data ######################

# Get graduation data from the Excel spreadsheet
graduation_data <- read_excel("Supply.xlsx", sheet = 2)
cleaned_graduation_data <- data.frame(Grad_Year = graduation_data$`Graduation Year`, Total_Students = graduation_data$...5)[-1, ]

# Create a time series from the vector
total_grads_ts <- ts(as.integer(cleaned_graduation_data$Total_Students), start = cleaned_graduation_data$Grad_Year[1], frequency = 1)

# Construct a BSTS model for supply data
supply_model <- bsts(total_grads_ts, state.specification = AddLocalLinearTrend(list(), total_grads_ts), niter = 1000)

# Forecast 5 years using the model
supply_forecast_values <- predict(supply_model, horizon = 5)
plot(supply_forecast_values, ylim = c(1e5, 3e5), main = "Graduates Supply Forecast", ylab = "Number of Graduates", xlab = "Year")

supply_mean_ts <- ts(append(as.vector(supply_forecast_values$original.series), supply_forecast_values$mean), start = cleaned_graduation_data$Grad_Year[1], frequency = 1)
## plot(supply_mean_ts, main = "Predicted Outcome")
plot(ts(cumsum(supply_mean_ts), start = cleaned_graduation_data$Grad_Year[1], frequency = 1), main = "Predicted Outcome - Running Total", ylab = "Number of Graduates", xlab = "Year")

supply_best_case_ts <- ts(append(as.vector(supply_forecast_values$original.series), supply_forecast_values$interval[1,]), start = cleaned_graduation_data$Grad_Year[1], frequency = 1)
## plot(supply_best_case_ts, main = "Best-Case Scenario")
plot(ts(cumsum(supply_best_case_ts), start = cleaned_graduation_data$Grad_Year[1], frequency = 1), main = "Best-Case Scenario - Running Total", ylab = "Number of Graduates", xlab = "Year")

###################### Ratio of Employees to Positions ######################

# Difference the time series with a lag of 1 to get the new openings by year
new_positions_best_case_ts <- diff(demand_best_case_ts)
new_positions_mean_ts <- diff(demand_mean_ts)

ratio_best_case_ts <- supply_best_case_ts / new_positions_best_case_ts
ratio_mean_ts <- supply_mean_ts / new_positions_mean_ts


# Convert the time series data to a data frame for ggplot2
best_case_df <- data.frame(
  Year = time(ratio_best_case_ts), 
  Ratio = ratio_best_case_ts
)

mean_case_df <- data.frame(
  Year = time(ratio_mean_ts), 
  Ratio = ratio_mean_ts
)

# Plot for Best-case scenario
p1 <- ggplot(best_case_df, aes(x = Year, y = Ratio)) +
  geom_line(color = "blue") +
  geom_point(color = "red") +
  ylim(0, 4) +
  geom_text(aes(label = round(Ratio, 2)),
            vjust = -0.5, color = "black", size = 3) +
  labs(title = "Number of job seekers per opening", x = "Best-case Scenario", y = "Ratio") +
  theme_minimal()

# Plot for Predicted Outcome scenario
p2 <- ggplot(mean_case_df, aes(x = Year, y = Ratio)) +
  geom_line(color = "blue") +
  geom_point(color = "red") +
  ylim(0, 4) +
  geom_text(aes(label = round(Ratio, 2)),
            vjust = -0.5, color = "black", size = 3) +
  labs(x = "Predicted Outcome", y = "Ratio") +
  theme_minimal()

grid.arrange(p1, p2, ncol = 1)