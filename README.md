# Climate Change and Internal Displacement: Global Panel Evidence (2000–2024)

This project examines the impact of climate-related disasters on internal 
displacement across more than 180 countries over the period 2000–2024. 
Using a two-way fixed-effects panel regression framework, the analysis 
investigates how exposure to flood and drought events drives forced 
displacement, controlling for economic development, population size, 
urbanization, governance quality, and armed conflict.

## Key Results

The empirical findings reveal strong and statistically significant 
relationships between climate disasters and internal displacement:

- **Flood Events:** Robustly positive and significant across all model 
  specifications (+0.225, p < 0.001), indicating that each additional 
  flood event is associated with a 22.5% increase in internal displacement
- **Drought Events:** Significant in baseline models but loses significance 
  once country fixed effects are introduced (−0.006, p > 0.1), suggesting 
  drought operates through longer-term structural channels
- **Population Size:** Large positive effect (+4.752, p < 0.001), 
  confirming that more populous countries experience greater absolute 
  displacement

Additionally, higher GDP per capita shows a positive but insignificant 
association with displacement in the two-way fixed effects model, 
suggesting that wealth alone does not insulate countries from 
climate-induced displacement.

## Regression Results

|                  | Baseline     | Controls     | Country FE   | Two-Way FE   |
|------------------|--------------|--------------|--------------|--------------|
| (Intercept)      | 7.622***     | 1.360        |              |              |
|                  | (0.184)      | (1.447)      |              |              |
| flood_events     | 0.752***     | 0.389***     | 0.216***     | 0.225***     |
|                  | (0.093)      | (0.067)      | (0.048)      | (0.049)      |
| drought_events   | 1.030***     | 0.451*       | −0.042       | −0.006       |
|                  | (0.224)      | (0.186)      | (0.147)      | (0.144)      |
| log_gdp_pc       |              | −0.503***    | −0.136       | 0.253        |
|                  |              | (0.131)      | (0.422)      | (0.439)      |
| log_pop          |              | 0.676***     | 3.027***     | 4.752***     |
|                  |              | (0.074)      | (0.794)      | (1.024)      |
| urban_rate       |              | −0.002       | −0.052+      | −0.021       |
|                  |              | (0.007)      | (0.028)      | (0.031)      |
| governance       |              | 0.087        | −0.359       | −0.428       |
|                  |              | (0.159)      | (0.370)      | (0.372)      |
| conflict         |              | 0.379        | −0.186       | −0.189       |
|                  |              | (0.243)      | (0.180)      | (0.185)      |
| Num. Obs.        | 1965         | 1878         | 1871         | 1871         |
| R²               | 0.254        | 0.465        | 0.673        | 0.682        |
| R² Adj.          | 0.253        | 0.463        | 0.636        | 0.643        |
| R² Within        |              |              | 0.038        | 0.046        |
| R² Within Adj.   |              |              | 0.034        | 0.042        |
| AIC              | 9416.2       | 8360.8       | 7761.3       | 7739.9       |
| BIC              | 9433.0       | 8405.1       | 8823.9       | 8891.0       |
| RMSE             | 2.65         | 2.23         | 1.74         | 1.71         |
| FE: Country      |              |              | ✓            | ✓            |
| FE: Year         |              |              |              | ✓            |

+ p < 0.1, * p < 0.05, ** p < 0.01, *** p < 0.001  
Standard errors in parentheses, clustered by country.

## Conclusion

Overall, the results provide robust evidence that climate-related flood 
events significantly increase internal displacement across countries, 
even after accounting for country-level heterogeneity and global time 
trends. Drought effects, while visible in simple specifications, appear 
to be mediated by structural country characteristics rather than 
year-to-year variation. These findings reinforce the importance of 
integrating climate disaster risk into displacement prevention and 
humanitarian response policy frameworks, particularly for flood-prone 
developing nations.

## Data Sources
| Dataset | Source | Years |
|---|---|---|
| Internal Displacement | IDMC Global Displacement Database | 2000–2024 |
| Disaster Events | EM-DAT International Disaster Database | 2000–2024 |
| GDP, Population, Urbanization | World Bank WDI | 2000–2024 |
| Governance | World Governance Indicators (WGI) | 2000–2024 |
| Armed Conflict | UCDP/PRIO Armed Conflict Dataset v25.1 | 2000–2024 |


