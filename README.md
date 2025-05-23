# 🚘 Car Price Prediction & Recommendation System (Shiny App)

## 📌 Overview

This Shiny app is an interactive **Car Price Prediction and Recommendation Portal** developed in R. It enables users to:

* Predict car prices based on user-defined criteria
* Filter and explore available car models in India
* Visualize pricing trends, mileage comparisons, and residual analysis
* Log in securely using Google OAuth 2.0 authentication

---

## 🧰 Technologies & Libraries Used

| Library   | Purpose                                                              |
| --------- | -------------------------------------------------------------------- |
| `shiny`   | UI & server-side logic for interactive web apps in R                 |
| `dplyr`   | Data manipulation and filtering                                      |
| `ggplot2` | Base plotting system for data visualization                          |
| `plotly`  | Interactive plots from `ggplot2` charts                              |
| `shinyjs` | Enables JavaScript features within Shiny (for login/logout handling) |
| `httr`    | Google OAuth 2.0 authentication                                      |

---

## ✨ Key Features

### 🔐 Google OAuth Login

* Users must log in via Google before accessing the app
* Ensures secure and personalized access
* Google OAuth 2.0 scope includes user profile and email

### 🧮 Car Price Prediction

* Based on features such as:

  * Mileage
  * Fuel Type
  * Price Range
  * Transmission Type
  * Seating Capacity

### 🚙 Car Recommendations

* Filters cars using dynamic sliders and dropdowns
* Sorts by:

  * Price
  * Certified Mileage
* Displays filtered recommendations in a table

### 📊 Visualization Dashboard

Provides multiple insights using `ggplot2` and `plotly`:

* 📈 **Actual vs. Predicted Prices** (Linear Regression Line)
* 📦 **Boxplot** of Prices by Car Type
* 🔄 **Scatterplot** for Price vs. Mileage colored by Fuel Type
* 📉 **Residual Plot** to assess model performance

---

## 🖼️ User Interface (UI)

* **Landing Page**: Requires Google sign-in with a branded welcome screen
* **Tabs**:

  * `Dashboard`: About section explaining platform features
  * `Explore Cars`: Filter sidebar with real-time data rendering
  * `Model Visualization`: Dropdown for selecting interactive plots
  * `Logout`: Logout confirmation and session reset

---

## 🏗️ App Structure

```
shiny-app/
│
├── app.R                    # Complete Shiny app code (UI + Server)
├── data/                    # Contains car dataset (e.g., car_data.csv)
├── images/                  # Optional UI images
├── www/                     # Static assets (CSS/images)
└── README.md                # Project documentation
```

---

## 🧪 Example Filters

**User Inputs**:

```r
Mileage: 12 - 18 km/l
Price Range: ₹5,00,000 – ₹15,00,000
Fuel Type: Petrol
Transmission: Manual
Seating Capacity: 5
```

**Output**:

* List of cars matching filter
* Price and mileage comparison charts
* Model performance visualization

---

## 🧠 Model Summary

The app integrates a **predictive model** (such as Linear Regression), trained on real-world car data to predict price based on user-defined input. The residuals and predicted vs. actual values help evaluate the model’s accuracy.

> *Note: The model predictions and data must be pre-loaded (`testSet`, `lm_pred`). Ensure these variables are defined in your R session.*

---

## 🚀 How to Run

1. Clone the repo:

   ```bash
   git clone https://github.com/yourusername/car-price-predictor.git
   cd car-price-predictor
   ```

2. Open `app.R` in RStudio.

3. Ensure all required libraries are installed:

   ```r
   install.packages(c("shiny", "dplyr", "ggplot2", "plotly", "shinyjs", "httr"))
   ```

4. Run the app:

   ```r
   shiny::runApp()
   ```

---

## 📌 Prerequisites

* R ≥ 4.0
* RStudio (recommended)
* A valid **Google OAuth 2.0 client ID & secret**
* A car dataset (`car_data`) with the following columns:

  * `ARAI.Certified.Mileage`
  * `Ex.Showroom_Price.Rs..`
  * `Fuel_Type`
  * `Transmission`
  * `Seating.Capacity`
  * `Type` (optional for boxplot)

<img width="889" alt="Screenshot 2025-05-23 at 3 12 55 PM" src="https://github.com/user-attachments/assets/aff3fdca-ed7a-4bb6-82eb-af1d9de2065c" />

