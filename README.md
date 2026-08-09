# Customer Usage Segmentation & Data Mining

## 📊 Project Overview

This project analyzes customer telephone usage patterns using R and a combination of statistical and data mining techniques. The analysis examines customer behavior across fixed calls, call duration, mobile usage, international usage, and broadband activity to identify patterns, unusual observations, and meaningful customer segments.

The project applies descriptive statistics, classification models, outlier detection, K-means clustering, and Principal Component Analysis (PCA). Together, these methods provide multiple perspectives on customer usage behavior and demonstrate how R can be used throughout the analytical process, from data exploration and preprocessing to modeling, visualization, and customer segmentation.

## 🎯 Project Objective

The objective of this project was to analyze customer telephone usage data and identify meaningful patterns in customer behavior. The analysis focused on several questions:

- How do customer usage variables relate to one another?
- Can customers be classified based on their call duration?
- Are there unusual or extreme usage patterns within the dataset?
- Can customers be grouped into distinct segments based on similar usage behaviors?
- How can dimensionality reduction help visualize differences among the identified customer segments?

## 📁 Dataset & Variables

The dataset used for this project was provided as part of the course materials and contains 2,057 customer telephone usage records. Each record includes a customer ID and five variables representing different types of telephone and service usage.

| Variable | Description |
|---|---|
| `ID` | Unique identifier for each customer record |
| `Fixed Calls` | Customer fixed-line call usage |
| `Duration` | Customer call duration |
| `Mobile` | Customer mobile usage |
| `International` | Customer international usage |
| `Broadband` | Customer broadband usage |

The five usage variables were analyzed to explore relationships among customer behaviors, identify unusual observations, develop classification models, and group customers with similar usage patterns.

For the classification portion of the analysis, `Duration` was transformed into a categorical **High/Low** variable using the median call duration as the dividing point. This allowed classification models to examine which customer usage characteristics were associated with higher or lower call duration.

> **Data Source:** The dataset was provided as part of the course materials. Because the original external source and redistribution permissions could not be verified, the raw dataset is not included in this public repository.

## 🔎 Analytical Approach

The analysis followed a multi-step data mining process to examine customer usage patterns from several perspectives.

### 1. Descriptive Analysis
Descriptive statistics were calculated for the five customer usage variables, including the mean, median, standard deviation, minimum, and maximum. A correlation matrix was also used to examine relationships among the variables.

### 2. Classification
Customer call duration was categorized as **High** or **Low** based on the median duration. Two classification approaches were then used to examine which customer usage characteristics were associated with these categories:

- CART decision tree using `rpart`
- Conditional inference tree using `ctree`

### 3. Outlier Detection
Potentially unusual customer usage patterns were evaluated using two methods:

- Z-score detection using a ±3 standard deviation threshold
- Interquartile Range (IQR) detection

Boxplots were also used to visualize the distributions and potential outliers across the usage variables.

### 4. Customer Segmentation
The usage variables were standardized before applying K-means clustering so that differences in measurement scales would not disproportionately influence the results. Customers were then grouped into **five clusters** based on similarities in their usage behavior.

### 5. Principal Component Analysis
Principal Component Analysis (PCA) was applied to the standardized usage variables to reduce the five-dimensional dataset to two dimensions. The resulting principal components were used to visualize the customer segments identified through K-means clustering.
