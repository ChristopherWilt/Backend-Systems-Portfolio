import re
import datetime

# Christopher Wilt - Log Analysis Parser
# Purpose: Parses raw Apache/Nginx access logs and formats them for SQL ingestion.

class LogParser:
    def __init__(self):
        # Regex pattern to extract IP, Date, Method, URL, Status, and User Agent
        self.log_pattern = r'(\d+\.\d+\.\d+\.\d+) - - \[(.*?)\] "(.*?)" (\d+) (\d+) "(.*?)"'

    def parse_line(self, line):
        match = re.search(self.log_pattern, line)
        if not match:
            return None
        
        # Extract data groups
        ip_address = match.group(1)
        timestamp = match.group(2)
        request_string = match.group(3)
        status_code = int(match.group(4))
        bytes_sent = int(match.group(5))
        user_agent = match.group(6)

        # Security Check: Flag potential brute force (401 Unauthorized)
        if status_code == 401:
            print(f"[SECURITY ALERT] Failed login attempt from IP: {ip_address}")

        return {
            "ip": ip_address,
            "time": timestamp,
            "request": request_string,
            "status": status_code,
            "agent": user_agent
        }

# --- usage ---
if __name__ == "__main__":
    # Simulated raw log line from a game server
    raw_log = '192.168.1.45 - - [10/Feb/2026:14:05:22 -0500] "POST /api/login HTTP/1.1" 401 532 "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"'
    
    parser = LogParser()
    data = parser.parse_line(raw_log)
    
    if data:
        print(f"Parsed Log: {data}")
        # TODO: Connect to SQL Database and run INSERT query here