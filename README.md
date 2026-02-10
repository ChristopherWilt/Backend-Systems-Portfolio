# Backend Systems & Database Architecture Portfolio
Backend engineering portfolio focusing on Database Architecture and Security. Contains SQL scripts for the "Weblog Security Analysis System" (Threat Detection) and "Vehicle Data Warehouse" (3NF Normalization &amp; Query Optimization).

## Overview
This repository contains backend engineering projects focusing on **Data Normalization**, **Query Optimization**, and **Security Log Analysis**. The goal was to architect scalable relational schemas capable of handling high-volume transactional data and generating security insights.

## Project 1: User Session & Security Analysis System
**Objective:** Architect a system to parse, store, and analyze server traffic logs to detect security anomalies and track user session behavior.

* **Schema Design:** Designed a normalized relational database to store raw server logs (IPs, Timestamps, User Agents).
* **Threat Detection:** Wrote complex SQL scripts to detect anomalies, such as bot traffic and unauthorized access attempts, by analyzing `UserAgent` strings and request frequency.
* **Automated Reporting:** Implemented Stored Procedures and Views to auto-generate daily traffic reports.

**Key File:** `security_analysis_queries.sql`

## Project 2: Vehicle Data Warehouse Optimization
**Objective:** Optimize a legacy flat-file dataset for performance and data integrity.

* **Normalization (3NF):** Decomposed a monolithic dataset of 30,000+ records into Third Normal Form, reducing data redundancy by ~60%.
* **Performance Tuning:** Utilized Clustered and Non-Clustered Indexes to optimize execution plans for complex joins.
* **Data Integrity:** Enforced referential integrity via Foreign Key constraints and ACID transactions.

**Key File:** `vehicle_normalization_logic.sql`

---

## 🛠️ Project 3: Python Automation & Data Ingestion
To bridge the gap between raw application logs and the SQL backend, I developed custom Python utility scripts.

### 1. Log Ingestion Tool (`LogParser.py`)
A Regex-based parser designed to read raw server access logs (Apache/Nginx format) and structure them for database insertion.
* **Feature:** Extracts IP, Timestamp, Status Code, and User Agent.
* **Security:** Automatically flags `401 Unauthorized` attempts during the parsing phase before they reach the database.

### 2. Network Data Stream Utility (`NetworkUtils.py`)
A utility script demonstrating external data fetching and parsing.
* **Function:** Connects to remote data streams (via HTTP), parses HTML structures using `html.parser`, and formats the output for processing.
* **Core Concept:** Demonstrates handling of non-standard data formats and grid-coordinate mapping from unstructured web sources.
