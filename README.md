# Dailyrounds-Assignment

# **Monitoring System Script**

A Bash script to monitor system performance and generate customizable reports. This script meets the assignment requirements for system information collection, alerting, and custom reporting. It is designed for educational and practical purposes.

---

## **Features**

### **1. System Information Collection**
The script retrieves and displays:
- **CPU Usage**: Percentage of CPU usage.
- **Memory Usage**: Total, used, and free memory details.
- **Disk Usage**: Total, used, and available space for each mounted filesystem.
- **Top 5 CPU-Consuming Processes**: Lists the most resource-intensive processes.

### **2. Alert Mechanism**
- Triggers a warning in the terminal when:
  - **CPU usage** exceeds 80%.
  - **Memory usage** exceeds 75%.
  - **Disk usage** exceeds 90%.

### **3. Customization**
- Optional arguments:
  - `--interval`: Specify the monitoring interval in seconds.
  - `--format`: Choose the output format (`text`, `JSON`, or `CSV`).
  - `--output`: Define the name of the output file.

### **4. Error Handling**
- Handles invalid inputs, permission issues, and unsupported operating systems gracefully.

### **5. Bonus Feature**
- Real-time monitoring with a visualized CLI graph using the `watch` command.

---
## Output Screenshots
![cluster created](https://github.com/AnandPattanashetti/cloud-devops-task/blob/main/Screenshot%20(722).png)

## **Usage**
### **Step 1: Clone the Repository**
```bash
- Step1: git clone https://github.com/AnandPattanashetti/Dailyrounds-Assignment.git

- Step 2: cd system-monitor.sh

- step 3:./system-monitor.sh --interval 10 --format Text --output report.txt

- step 4:./system-monitor.sh --interval 10 --format JSON --output report.json

- step 5:./system-monitor.sh --interval 10 --format CSV --output report.csv

- step 6: watch -n 2 ./system-monitor.sh --format text
---
