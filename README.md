 RSMS — Retail Store Management System 🏬📊

> A centralised digital platform for managing global luxury retail operations.

RSMS (Retail Store Management System) is an enterprise-focused iOS application designed to provide corporate administrators with a centralized platform for managing and monitoring luxury retail operations across multiple boutiques, countries, and regions.

The system brings together **product management, inventory, pricing, campaigns, planograms, CRM, store operations, and business analytics** into a unified platform.


✨ Key Features

📊 Corporate Dashboard

Provides corporate administrators with a high-level overview of retail business performance.

- Total revenue
- Boutique count
- Business health
- Sales performance
- Inventory status
- Regional performance
- Store performance
- Target vs achieved revenue

Example metrics:

Revenue          ₹24.5 Cr
Boutiques        32
Business Health  87 / 100


🏷️ Product Management

Centralized management of the company's product catalog.

* Product master data
* SKU management
* Product categories
* Product details
* Product availability
* Product images
* Product metadata



💰 Pricing & Promotions

Manage pricing across different countries and regions.

* Global pricing
* Regional pricing
* Country-specific currencies
* Promotional pricing
* Campaign-based pricing
* Store-specific pricing



📦 Inventory Management

Provides visibility into inventory across boutiques.

* Stock levels
* Product availability
* SKU-level inventory
* Store inventory
* Regional inventory
* Inventory movement



🏪 Boutique Management

Manage boutiques across multiple countries and cities.


Country
   ↓
City
   ↓
Boutique


The platform supports a global boutique structure across regions including:

* India
* United States
* China
* Germany
* France
* Italy
* Australia
* UAE
* Japan
* United Kingdom



📐 Planogram Management

Corporate administrators can create and distribute visual merchandising guidelines.

* Create planograms
* Define product placement
* Assign planograms to boutiques
* Share visual merchandising guidelines
* Provide implementation instructions

Workflow:

Corporate Admin
       ↓
Create Planogram
       ↓
Assign Boutique
       ↓
Boutique Manager
       ↓
Implementation




📢 Campaign Management

Create and distribute retail campaigns across stores.

Campaigns can be targeted by:

* Country
* Region
* Boutique
* Store group
* Campaign type

Corporate teams can provide campaign information and implementation guidelines directly to boutique managers.



👥 Role-Based Access

RSMS follows a structured retail workflow with different responsibilities for each role.

Corporate Admin

* Global business monitoring
* Product management
* Pricing
* Campaigns
* Planograms
* Global reporting
* Boutique oversight

Boutique Manager

* Store operations
* Campaign implementation
* Planogram implementation
* Store performance
* Boutique-level activities

Inventory Controller

* Inventory tracking
* Stock management
* Product movement
* Stock-related operations

Sales Associate

* Customer-facing sales operations
* Product information
* Customer interactions
* Store-level activities



🔄 System Workflow


                    CORPORATE ADMIN
                          │
          ┌───────────────┼────────────────┐
          ↓               ↓                ↓
      Products         Pricing         Campaigns
          │               │                │
          └───────────────┼────────────────┘
                          ↓
                  Boutique Managers
                          │
              ┌───────────┴───────────┐
              ↓                       ↓
       Inventory Controller     Sales Associate
              │                       │
              └───────────┬───────────┘
                          ↓
                    Boutique Store




👥 CRM

The CRM module is designed to provide visibility into client and customer information.

Potential capabilities include:

* Customer profiles
* Client information
* Purchase history
* Customer segmentation
* Client engagement
* Customer insights



📈 Business Analytics

The analytics layer provides corporate teams with visibility into business performance.

It can include:

* Revenue trends
* Daily performance
* Monthly performance
* Quarterly performance
* Target vs achieved revenue
* Boutique comparisons
* Regional performance
* Inventory health



🌍 Global Retail Management

RSMS is designed around a multi-country retail structure.

Example:

Global Business
      │
      ├── India
      │    ├── Delhi
      │    ├── Mumbai
      │    └── Bengaluru
      │
      ├── USA
      │    ├── New York
      │    ├── Los Angeles
      │    └── Chicago
      │
      ├── France
      │    ├── Paris
      │    └── Lyon
      │
      └── UAE
           ├── Dubai
           └── Abu Dhabi




## 💾 Backend & Data

The project uses **Supabase** and PostgreSQL for backend data management.

Core entities include:


Users
Products
SKUs
Boutiques
Inventory
Pricing
Campaigns
Planograms
Clients
Sales
Reports




🔐 Security

The application follows role-based access principles for protecting business information.

Security considerations include:

* Role-based access
* Authentication
* Authorization
* Corporate-level data restrictions
* Controlled administrative actions
* Secure backend communication
* Protection of business analytics


🎨 Design

RSMS uses a modern **iOS 26-inspired Liquid Glass design language** combined with a premium luxury-retail aesthetic.

The interface focuses on:

* Glass-style cards
* Modern dashboards
* Clear information hierarchy
* Data visualization
* Smooth navigation
* Consistent typography
* Minimal enterprise UI

The design combines the premium visual language of luxury retail with the functionality required by enterprise management software.



🛠️ Technology Stack

iOS

* Swift
* SwiftUI
* Xcode

 Backend

* Supabase
* PostgreSQL

Design

* Figma
* iOS 26 Liquid Glass-inspired UI

Development

* Git
* GitHub

---

🏗️ Architecture

The application follows a modular architecture separating presentation, business logic, and data layers.


Presentation Layer
        ↓
Business Logic
        ↓
Data Layer
        ↓
Supabase / PostgreSQL


Major modules include:


Authentication
Dashboard
Product Management
Inventory
Pricing
Boutiques
Campaigns
Planograms
CRM
Analytics
User Management




⚡ Non-Functional Requirements

Performance

* Dashboard designed to load within approximately 3 seconds under normal conditions.
* Efficient backend queries and data handling.

Scalability

Designed to support:

* Multiple countries
* Multiple regions
* Multiple boutiques
* Large product catalogs
* Multiple user roles

 Reliability

Consistent data across corporate and boutique operations.

 Security

Sensitive business information is restricted to authorized users.



🚀 Future Scope

Potential future improvements include:

* AI-powered sales forecasting
* Inventory demand prediction
* Automated stock recommendations
* Customer segmentation
* Personalized client insights
* Advanced CRM analytics
* Automated campaign recommendations
* Computer-vision based store compliance
* Advanced planogram analysis
* Real-time business alerts
* Multi-language support



💡 Project Objective

RSMS was designed around a simple problem:

> How can a global luxury retail organization manage its products, boutiques, inventory, pricing, campaigns, and business performance from one centralized platform?**

The solution is a unified corporate platform connecting **head-office decision making with boutique-level execution**.

Instead of treating product, inventory, pricing, campaigns, and store operations as separate systems, RSMS brings them together into one connected retail ecosystem.



📱 Core Modules


Product Management
Inventory Management
Pricing & Promotions
Boutique Operations
Planograms
Campaigns
CRM
Analytics
Role-Based Access




👩‍💻 Project

**RSMS — Retail Store Management System**

An enterprise-oriented iOS application designed for centralized management of luxury retail operations.

> One platform. One view of the retail business.


