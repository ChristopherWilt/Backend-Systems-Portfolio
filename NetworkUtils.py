import urllib.request
from html.parser import HTMLParser

class GoogleDocParser(HTMLParser):
    """
    A simple HTML parser to extract table data from the Google Doc.
    """
    def __init__(self):
        super().__init__()
        self.in_table = False
        self.in_row = False
        self.in_cell = False
        self.table_data = []
        self.current_row = []
        self.current_cell_text = []

    def handle_starttag(self, tag, attrs):
        if tag == 'table':
            self.in_table = True
        elif self.in_table and tag == 'tr':
            self.in_row = True
            self.current_row = []
        elif self.in_row and (tag == 'td' or tag == 'th'):
            self.in_cell = True
            self.current_cell_text = []

    def handle_endtag(self, tag):
        if tag == 'table':
            self.in_table = False
        elif tag == 'tr':
            self.in_row = False
            # Only add the row if it's not empty
            if self.current_row:
                self.table_data.append(self.current_row)
        elif tag == 'td' or tag == 'th':
            self.in_cell = False
            self.current_row.append("".join(self.current_cell_text).strip())

    def handle_data(self, data):
        if self.in_cell:
            self.current_cell_text.append(data)

def print_secret_message(doc_url):
    try:
        # 1. Fetch the data using urllib (Standard Library)
        with urllib.request.urlopen(doc_url) as response:
            html_content = response.read().decode('utf-8')

        # 2. Parse the HTML
        parser = GoogleDocParser()
        parser.feed(html_content)
        data_rows = parser.table_data

        if not data_rows:
            print("No data found.")
            return

        # 3. Parse grid data
        # We assume the first row contains headers or the structure is x, char, y
        # However, to be robust, we look for data that converts to integers.
        parsed_grid = []
        
        # Skip the first row if it contains headers (text that isn't a number)
        start_index = 0
        if len(data_rows) > 0:
            first_row = data_rows[0]
            # specific logic for the provided doc format: usually x, char, y
            # We try to identify columns by content type
            if not first_row[0].isdigit(): 
                start_index = 1

        for row in data_rows[start_index:]:
            if len(row) < 3: continue
            
            # The format is x-coordinate, Character, y-coordinate
            try:
                x = int(row[0])
                char = row[1]
                y = int(row[2])
                parsed_grid.append((x, y, char))
            except ValueError:
                continue

        # 4. Render the grid
        if not parsed_grid:
            print("No valid coordinates found.")
            return

        max_x = max(c[0] for c in parsed_grid)
        max_y = max(c[1] for c in parsed_grid)

        grid = [[' ' for _ in range(max_x + 1)] for _ in range(max_y + 1)]

        for x, y, char in parsed_grid:
            grid[y][x] = char

        for row in grid:
            print("".join(row))

    except Exception as e:
        print(f"An error occurred: {e}")

# Run the function with the provided URL
url = "https://docs.google.com/document/d/e/2PACX-1vRPzbNQcx5UriHSbZ-9vmsTow_R6RRe7eyAU60xIF9Dlz-vaHiHNO2TKgDi7jy4ZpTpNqM7EvEcfr_p/pub"
print_secret_message(url)
