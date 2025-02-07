**This study examines the labor market supply and demand for tech (CS) jobs in the United States, and predicts its status within the next few years. The purpose is to provide insights into the potential career prospects for individuals considering a CS degree.**

## Data Sources
- Labor Force Positions by Year (Demand): https://www.bls.gov/oes/tables.htm
- Computer Science Graduates by Year (Supply): https://nces.ed.gov/programs/digest/d23/tables/xls/tabn318.20.xlsx
- Labor Force Age Groups and Positions: https://www.bls.gov/cps/cpsaat11b.xlsx

Labor market data is obtained from the US Bureau of Labor Statistics (BLS), and graduates data is obtained from the National Center for Education Statistics (NCES). NCES data is generally assumed to be highly accurate and reliable as postsecondary educational institutions have mandatory reporting requirements to participate in federal financial aid programs. BLS data is considered less accurate as it relies on sampling and voluntary survey participation, but is generally highly reliable due to the large sample sizes and the use of statistical techniques (including imputation) to account for non-responses.

## Methodologies
1. Data Preprocessing
	- Demand Data: Sourced from multiple Excel files, each representing a year (2019-2023). Then, it is filtered to include only the relevant occupations in the CS field. The employment counts are then aggregated and converted into a time series object for further analysis. The following OCC codes are chosen: *11-3020, 15-2050, 15-1210, 15-1220, 15-1240, 15-1250, 51-9162, 15-1290*

	- Supply Data: Graduation data is cleaned and formatted by extracting the relevant columns from the dataset. The data is transformed into a time series format for forecasting.

2. Model Construction
	- Due to having limited data, a BSTS model is applied to both the demand and supply time series. A local linear trend is added to both models to account for underlying trends in the data. Sampling is done through 1,000 iterations of Markov Chain Monte Carlo (MCMC) simulations which generate samples from the posterior distribution of model parameters.

3. Forecasting
	- Forecasts for both demand and supply are made for 4 to 5 years into the future (depending on the data). The mean and credible intervals (95%) from the BSTS model are used to generate both the Predicted Outcome and Best-Case Scenario for both demand and supply.

4. Retirement Adjustments
	- Adjustments for workforce retirements are made by subtracting the number of retiring workers from the demand time series. Two scenarios are considered:
		 - For the Predicted Outcome, workers retire at the age of 67 (age of retirement to receive full social security benefits).
		 - For the Best-Case Scenario, workers retire earlier at the age of 62 (minimum age of retirement to receive social security benefits).

5. Ratio Calculation
	- The new openings are calculated by differencing the demand time series. The ratio of new graduates to new job openings is computed for both the Best-Case Scenario and the Predicted Outcome.

## Assumptions
1. The growth in both demand and supply remain unaffected by the new administration.
2. The best-case scenario is taken as the minimum possible supply and the maximum possible demand.
3. Minimum and maximum refer to the upper and lower bounds of a 95% credible interval.
4. While the rise of AI has certainly decreased the demand of software developers, it has increased the demand of AI and ML engineers. The effect is included in the calculations.
5. Bayesian structural time series (BSTS) is used to fit the models for both supply and demand.
6. The ratio is calculated using the number of graduates each year relative to the number of **NEW** openings during that same year.
7. Prediction is more accurate near the present time, and gets less accurate for future time.
8. The workforce headcount by age range is assumed to be uniformly distributed among all ages in that range.
9. Labor market behavior remains relatively stable and free of major disruptions.
10. Graduates join the work force directly after graduation.
11. Government policies regarding immigration and foreign labor remain unchanged.

## Shortfalls
1. The data isn't up to date. Graduation data is available up until the year 2022. Job market data is available up until the year 2023.
2. The model doesn't take into account the number of bootcamp graduates and self-taught professionals.
3. The number of data points available is limited.
4. The workforce headcount by age range is approximated to the nearest thousand.
5. Data about the current active jobseekers isn't available.
6. Monthly data isn’t available, limiting the ability to analyze seasonal trends or fluctuations in the labor market that may impact both supply and demand on a short-term basis.
7. The impact of labor force shrinkage due to factors other than retirement is not considered.
8. BLS data may not fully represent the true population due to the methods of data collection used. It may not be a perfect reflection of the actual labor market, yet it is a very reliable source.

## Findings
<img width="630" alt="Screen Shot 2025-02-07 at 12 36 26 AM" src="https://github.com/user-attachments/assets/6f132f60-0247-4769-baf0-b904b06473b0" />

Results show that getting a CS degree still has a promising future, and that the number of new jobseekers per position remain balanced, mostly below 1 jobseeker per position; indicating a strong demand and balanced supply. However, 2025 seems to be a challenging year for job seekers relative to 2024 (which was tough already).
