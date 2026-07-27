#!/usr/bin/env python3
"""Generate a professional PDF manual for Rental Hub (RH-001)."""

import os
from pathlib import Path
from fpdf import FPDF

IMAGES_DIR = Path(__file__).parent / "manual_images"
DOC_NUM = "RH-001"
REV = "A"
DATE = "July 2026"
PRODUCT = "Rental Hub"
SUBTITLE = "Rental Marketplace Platform"
PAGE_W = 210
PAGE_H = 297
MARGIN_L = 20
MARGIN_R = 15
CONTENT_W = PAGE_W - MARGIN_L - MARGIN_R


class RentalHubManual(FPDF):

    def __init__(self):
        super().__init__(orientation="P", unit="mm", format="A4")
        self.set_auto_page_break(auto=True, margin=25)
        self.section_num = 0
        self.section_title = ""

    def header(self):
        if self.page_no() == 1:
            return
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(100, 100, 100)
        self.cell(90, 5, f"{DOC_NUM} Rev. {REV}", align="L")
        self.cell(90, 5, DATE, align="R")
        self.ln(4)
        self.set_draw_color(180, 180, 180)
        self.line(MARGIN_L, self.get_y(), PAGE_W - MARGIN_R, self.get_y())
        self.ln(3)

    def footer(self):
        if self.page_no() == 1:
            return
        self.set_y(-18)
        self.set_draw_color(180, 180, 180)
        self.line(MARGIN_L, self.get_y(), PAGE_W - MARGIN_R, self.get_y())
        self.ln(2)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(100, 100, 100)
        self.cell(90, 5, PRODUCT, align="L")
        self.cell(90, 5, str(self.page_no()), align="R")

    def section_heading(self, num, title):
        self.section_num = num
        self.section_title = title
        self.add_page()
        self.set_font("Helvetica", "B", 18)
        self.set_text_color(30, 60, 110)
        self.cell(0, 12, f"Section {num}: {title}", new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(30, 60, 110)
        self.line(MARGIN_L, self.get_y(), PAGE_W - MARGIN_R, self.get_y())
        self.ln(6)

    def sub_heading(self, num, title):
        self.ln(2)
        self.set_font("Helvetica", "B", 13)
        self.set_text_color(50, 80, 130)
        self.cell(0, 8, f"{num}    {title}", new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def sub_sub_heading(self, num, title):
        self.ln(1)
        self.set_font("Helvetica", "B", 11)
        self.set_text_color(70, 100, 150)
        self.cell(0, 7, f"{num}    {title}", new_x="LMARGIN", new_y="NEXT")
        self.ln(1)

    def body(self, text):
        self.set_font("Helvetica", "", 10)
        self.set_text_color(40, 40, 40)
        self.multi_cell(0, 5, text)
        self.ln(2)

    def body_bold(self, text):
        self.set_font("Helvetica", "B", 10)
        self.set_text_color(40, 40, 40)
        self.multi_cell(0, 5, text)
        self.ln(1)

    def bullet(self, text):
        self.set_font("Helvetica", "", 10)
        self.set_text_color(40, 40, 40)
        self.cell(5, 5, "-")
        self.multi_cell(0, 5, text)
        self.ln(1)

    def numbered_step(self, num, text):
        self.set_font("Helvetica", "", 10)
        self.set_text_color(40, 40, 40)
        self.cell(8, 5, f"{num}.")
        self.multi_cell(0, 5, text)
        self.ln(1)

    def figure(self, name, caption, img_path, img_w=160):
        self.ln(3)
        self.set_font("Helvetica", "B", 10)
        self.set_text_color(30, 60, 110)
        self.cell(0, 6, name, new_x="LMARGIN", new_y="NEXT")
        if os.path.exists(img_path):
            self.image(img_path, x=MARGIN_L + 10, w=img_w)
            self.ln(2)
        else:
            self.set_font("Helvetica", "I", 9)
            self.set_text_color(150, 150, 150)
            self.cell(0, 5, f"[Image placeholder: {os.path.basename(img_path)}]",
                      new_x="LMARGIN", new_y="NEXT")
            self.ln(2)
        self.set_font("Helvetica", "I", 9)
        self.set_text_color(80, 80, 80)
        self.cell(0, 5, caption, new_x="LMARGIN", new_y="NEXT")
        self.ln(3)

    def code_block(self, text):
        self.ln(1)
        self.set_fill_color(240, 240, 245)
        self.set_font("Courier", "", 9)
        self.set_text_color(30, 30, 30)
        for line in text.split("\n"):
            self.cell(0, 5, f"  {line}", new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def note(self, text):
        self.ln(1)
        x0 = self.get_x()
        y_before = self.get_y()
        self.set_fill_color(255, 255, 230)
        self.rect(x0, y_before, CONTENT_W, 10, style="F")
        self.set_xy(x0 + 2, y_before)
        self.set_font("Helvetica", "B", 9)
        self.set_text_color(120, 100, 0)
        self.cell(10, 5, "Note:")
        self.set_font("Helvetica", "", 9)
        self.set_text_color(80, 70, 30)
        self.multi_cell(CONTENT_W - 14, 5, text)
        self.ln(3)

    def warning(self, text):
        self.ln(1)
        x0 = self.get_x()
        y_before = self.get_y()
        self.set_fill_color(255, 240, 240)
        self.rect(x0, y_before, CONTENT_W, 12, style="F")
        self.set_xy(x0 + 14, y_before)
        self.set_font("Helvetica", "B", 9)
        self.set_text_color(180, 0, 0)
        self.cell(14, 5, "Warning:")
        self.set_font("Helvetica", "", 9)
        self.set_text_color(120, 30, 30)
        self.multi_cell(CONTENT_W - 16, 5, text)
        self.ln(3)

    def table_header(self, cols, widths):
        self.set_font("Helvetica", "B", 9)
        self.set_fill_color(30, 60, 110)
        self.set_text_color(255, 255, 255)
        for i, col in enumerate(cols):
            self.cell(widths[i], 7, col, border=1, fill=True, align="C")
        self.ln()

    def table_row(self, cols, widths, fill=False):
        self.set_font("Helvetica", "", 9)
        self.set_text_color(40, 40, 40)
        if fill:
            self.set_fill_color(240, 245, 250)
        for i, col in enumerate(cols):
            self.cell(widths[i], 6, str(col), border=1, fill=fill,
                      align="C" if i > 0 else "L")
        self.ln()

    def table_2col(self, left, right, widths=None, bold_left=False):
        if widths is None:
            widths = [55, CONTENT_W - 55]
        self.set_font("Helvetica", "B" if bold_left else "", 9)
        self.set_text_color(40, 40, 40)
        self.cell(widths[0], 6, left, border=1)
        self.set_font("Helvetica", "", 9)
        self.cell(widths[1], 6, right, border=1)
        self.ln()

    def cover_page(self):
        self.add_page()
        self.ln(50)
        self.set_font("Helvetica", "", 11)
        self.set_text_color(100, 100, 100)
        self.cell(0, 6, "User Manual", align="C", new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 6, f"{DOC_NUM}", align="C", new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 6, DATE, align="C", new_x="LMARGIN", new_y="NEXT")
        self.ln(20)
        self.set_font("Helvetica", "B", 28)
        self.set_text_color(30, 60, 110)
        self.cell(0, 14, PRODUCT, align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_font("Helvetica", "", 16)
        self.set_text_color(60, 60, 60)
        self.cell(0, 10, SUBTITLE, align="C", new_x="LMARGIN", new_y="NEXT")
        self.ln(40)
        self.set_font("Helvetica", "I", 10)
        self.set_text_color(100, 100, 100)
        self.cell(0, 6, f"{DOC_NUM} Rev. {REV}", align="C", new_x="LMARGIN", new_y="NEXT")
        self.cell(0, 6, DATE, align="C", new_x="LMARGIN", new_y="NEXT")
        self.ln(40)
        self.set_font("Helvetica", "I", 9)
        self.set_text_color(130, 130, 130)
        self.multi_cell(0, 5, (
            f"This manual covers installation, configuration, operation, and full API reference for "
            f"{PRODUCT}. Read this manual carefully before deploying the platform. "
            f"Keep this manual in a safe place for future reference."
        ), align="C")

    def toc(self, entries):
        self.add_page()
        self.set_font("Helvetica", "B", 18)
        self.set_text_color(30, 60, 110)
        self.cell(0, 12, "Contents", new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(30, 60, 110)
        self.line(MARGIN_L, self.get_y(), PAGE_W - MARGIN_R, self.get_y())
        self.ln(8)
        for item, desc, _ in entries:
            if item.startswith("Section"):
                self.ln(3)
                self.set_font("Helvetica", "B", 11)
                self.set_text_color(30, 60, 110)
                self.cell(0, 6, f"  {item}  {desc}", new_x="LMARGIN", new_y="NEXT")
            else:
                self.set_font("Helvetica", "", 10)
                self.set_text_color(40, 40, 40)
                self.cell(15, 5, "")
                self.cell(120, 5, f"{item}  {desc}")
                self.ln(5)


def build_manual():
    pdf = RentalHubManual()
    pdf.set_left_margin(MARGIN_L)

    # ── COVER ──
    pdf.cover_page()

    # ── TOC ──
    pdf.toc([
        ("Section 1:", "Getting Started", "3"),
        ("1.1", "System Requirements", "3"),
        ("1.2", "Installation & Setup", "3"),
        ("1.3", "Running the API", "4"),
        ("1.4", "Platform Overview", "5"),
        ("Section 2:", "Authentication & User Roles", "6"),
        ("2.1", "Registration", "6"),
        ("2.2", "Login", "7"),
        ("2.3", "User Roles", "7"),
        ("Section 3:", "Property Management", "8"),
        ("3.1", "Listing Properties", "8"),
        ("3.2", "Search & Filter", "9"),
        ("3.3", "Property Details", "10"),
        ("3.4", "Photo Uploads", "10"),
        ("Section 4:", "Agent Dashboard & Rent Reminders", "11"),
        ("4.1", "Creating Reminders", "11"),
        ("4.2", "Managing Reminders", "12"),
        ("4.3", "Overdue Detection", "12"),
        ("Section 5:", "Favorites & Bookings", "13"),
        ("5.1", "Saving Favorites", "13"),
        ("5.2", "Inquiring / Booking", "13"),
        ("Section 6:", "Subscriptions & M-Pesa", "14"),
        ("6.1", "Subscription Plans", "14"),
        ("6.2", "M-Pesa STK Push", "14"),
        ("6.3", "Mock Mode vs Live", "15"),
        ("Section 7:", "Flutter Mobile App", "16"),
        ("7.1", "App Structure", "16"),
        ("7.2", "All Screens Reference", "17"),
        ("7.3", "Building & Running", "19"),
        ("Section 8:", "API Reference", "20"),
        ("8.1", "Auth Endpoints", "20"),
        ("8.2", "Properties Endpoints", "21"),
        ("8.3", "Agents Endpoints", "22"),
        ("8.4", "Favorites Endpoints", "23"),
        ("8.5", "Bookings Endpoints", "23"),
        ("8.6", "Subscriptions Endpoints", "24"),
        ("Section 9:", "Deployment", "25"),
        ("9.1", "Docker Deployment", "25"),
        ("9.2", "Systemd Service", "26"),
        ("9.3", "PostgreSQL Setup", "26"),
        ("Section 10:", "Troubleshooting", "27"),
        ("10.1", "Common Issues", "27"),
        ("10.2", "Support", "28"),
        ("Section 11:", "Appendix", "29"),
        ("11.1", "Database Schema", "29"),
        ("11.2", "Revision History", "29"),
    ])

    # ════════════════════════════════════════
    # SECTION 1: GETTING STARTED
    # ════════════════════════════════════════
    pdf.section_heading(1, "Getting Started")

    pdf.sub_heading("1.1", "System Requirements")
    pdf.body("Rental Hub requires the following minimum system specifications:")
    pdf.table_2col("Component", "Requirement")
    pdf.table_2col("Operating System", "Linux (Ubuntu 22.04+), macOS 13+, Windows 10+ via WSL2")
    pdf.table_2col("Python", "3.10 or higher")
    pdf.table_2col("RAM", "2 GB minimum; 4 GB recommended")
    pdf.table_2col("Disk Space", "500 MB for application + SQLite data")
    pdf.table_2col("Database", "SQLite (dev) or PostgreSQL 14+ (production)")
    pdf.table_2col("Flutter SDK", "3.2+ (optional — only needed to build the mobile app)")
    pdf.table_2col("Browser", "Chrome 100+, Firefox 100+, or Edge 100+")
    pdf.ln(2)
    pdf.body("For M-Pesa integration, a Safaricom Daraja API account is required. The system works in mock mode without one.")

    pdf.sub_heading("1.2", "Installation & Setup")
    pdf.body("Clone the repository and set up a Python virtual environment:")
    pdf.code_block(
        "git clone <repository-url> rental-hub\n"
        "cd rental-hub\n"
        "python3 -m venv venv\n"
        "source venv/bin/activate\n"
        "pip install -r backend/requirements.txt"
    )
    pdf.body("Installation installs Flask, SQLAlchemy, JWT authentication, CORS support, and HTTP clients. "
             "No database server is required for development — SQLite is used by default.")

    pdf.sub_heading("1.3", "Running the API")
    pdf.body("Start the API server with:")
    pdf.code_block("python run.py")
    pdf.body("The server starts on http://localhost:8200. Verify it is running:")
    pdf.code_block("curl http://localhost:8200/api/health")
    pdf.body("Expected response:")
    pdf.code_block('{"status":"ok"}')
    pdf.note("The API runs in debug mode by default. Set FLASK_ENV=production for deployment.")

    pdf.sub_heading("1.4", "Platform Overview")
    pdf.body("Rental Hub is a rental marketplace platform consisting of two main components:")
    pdf.bullet("Backend API (Flask, port 8200) — RESTful API handling authentication, property management, "
               "rent reminders, subscriptions, favorites, and bookings.")
    pdf.bullet("Flutter Mobile App — Cross-platform mobile application for tenants, landlords, and agents. "
               "Communicates with the backend API over HTTP.")
    pdf.ln(1)
    pdf.body("The platform supports three user roles:")
    pdf.table_2col("Role", "Capabilities", [40, CONTENT_W - 40])
    pdf.table_2col("Tenant", "Browse properties, save favorites, send booking inquiries, manage profile")
    pdf.table_2col("Landlord", "Post and manage property listings, manage subscription, receive inquiries")
    pdf.table_2col("Agent", "Manage rent reminders for tenants, track overdue payments, manage profile")
    pdf.ln(2)
    pdf.note("Landlords and agents require an active subscription to use the platform. "
             "Subscriptions are managed via M-Pesa payments.")

    # ════════════════════════════════════════
    # SECTION 2: AUTHENTICATION
    # ════════════════════════════════════════
    pdf.section_heading(2, "Authentication & User Roles")

    pdf.sub_heading("2.1", "Registration")
    pdf.body("New users register by providing their name, phone number, email, password, and user type. "
             "The registration endpoint validates all fields and returns a JWT token for immediate use.")
    pdf.body("Example registration request:")
    pdf.code_block(
        'curl -X POST http://localhost:8200/api/auth/register \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{\n'
        '    "name": "John Kamau",\n'
        '    "phone": "+254712345678",\n'
        '    "email": "john@example.com",\n'
        '    "password": "securepass123",\n'
        '    "user_type": "tenant"\n'
        '  }\''
    )
    pdf.body("The response includes a JWT token and the user object:")
    pdf.code_block(
        '{\n'
        '  "token": "eyJhbGciOiJIUzI1NiIs...",\n'
        '  "user": {\n'
        '    "id": "uuid-here",\n'
        '    "name": "John Kamau",\n'
        '    "phone": "+254712345678",\n'
        '    "email": "john@example.com",\n'
        '    "user_type": "tenant",\n'
        '    "created_at": "2026-07-12T..."\n'
        '  }\n'
        '}'
    )
    pdf.note("The token expires after 7 days. Include it in all authenticated requests via the "
             "Authorization: Bearer <token> header.")

    pdf.sub_heading("2.2", "Login")
    pdf.body("Users can log in using either their email address or phone number combined with their password:")
    pdf.code_block(
        'curl -X POST http://localhost:8200/api/auth/login \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{"email": "john@example.com", "password": "securepass123"}\''
    )
    pdf.body("The response mirrors the registration response, returning a new JWT token and user object.")

    pdf.sub_heading("2.3", "User Roles")
    pdf.body("Three user roles are supported, each with distinct permissions:")
    pdf.ln(1)
    pdf.body_bold("Tenant")
    pdf.bullet("Browse and search available properties")
    pdf.bullet("Save properties as favorites")
    pdf.bullet("Send booking inquiries to landlords")
    pdf.bullet("View own booking history and status")
    pdf.ln(1)
    pdf.body_bold("Landlord")
    pdf.bullet("All tenant capabilities")
    pdf.bullet("Post new property listings with photos")
    pdf.bullet("Edit and delete own listings")
    pdf.bullet("Receive and manage booking inquiries")
    pdf.bullet("Requires active subscription (KSh 1,000/month)")
    pdf.ln(1)
    pdf.body_bold("Agent")
    pdf.bullet("Create and manage rent reminders for tenants")
    pdf.bullet("Track overdue, unpaid, and paid statuses")
    pdf.bullet("Filter and search reminders by status")
    pdf.bullet("Requires active subscription (KSh 500/month)")

    # ════════════════════════════════════════
    # SECTION 3: PROPERTY MANAGEMENT
    # ════════════════════════════════════════
    pdf.section_heading(3, "Property Management")

    pdf.sub_heading("3.1", "Listing Properties")
    pdf.body("Landlords can post new property listings with the following fields:")
    pdf.table_2col("Field", "Required", bold_left=True)
    pdf.table_2col("title", "Yes")
    pdf.table_2col("price", "Yes (numeric, in KSh)")
    pdf.table_2col("location", "Yes")
    pdf.table_2col("bedrooms", "Yes (integer)")
    pdf.table_2col("contact_phone", "Yes")
    pdf.table_2col("house_type", "No (apartment, maisonette, bungalow, townhouse)")
    pdf.table_2col("description", "No")
    pdf.table_2col("security_details", "No")
    pdf.table_2col("parking", "No (boolean)")
    pdf.table_2col("water_available", "No (boolean)")
    pdf.table_2col("latitude / longitude", "No")
    pdf.ln(2)
    pdf.body("Properties are submitted as multipart form data to support photo uploads:")
    pdf.code_block(
        'curl -X POST http://localhost:8200/api/properties \\\n'
        '  -H "Authorization: Bearer <token>" \\\n'
        '  -F "title=2BR Apartment in Langoni" \\\n'
        '  -F "price=25000" \\\n'
        '  -F "location=Langoni, Lamu" \\\n'
        '  -F "bedrooms=2" \\\n'
        '  -F "contact_phone=+254712345678" \\\n'
        '  -F "photos=@photo1.jpg" \\\n'
        '  -F "photos=@photo2.jpg"'
    )

    pdf.sub_heading("3.2", "Search & Filter")
    pdf.body("Properties can be searched and filtered with the following query parameters:")
    pdf.table_2col("Parameter", "Description")
    pdf.table_2col("location", "Case-insensitive partial match on location field")
    pdf.table_2col("min_price", "Minimum monthly rent in KSh")
    pdf.table_2col("max_price", "Maximum monthly rent in KSh")
    pdf.table_2col("bedrooms", "Exact number of bedrooms")
    pdf.table_2col("house_type", "Type of house (apartment, maisonette, bungalow)")
    pdf.table_2col("page", "Page number for pagination (default: 1)")
    pdf.table_2col("per_page", "Results per page (default: 20)")
    pdf.ln(2)
    pdf.body("Example search for 2-bedroom apartments in Langoni under KSh 30,000:")
    pdf.code_block(
        "curl 'http://localhost:8200/api/properties?location=Langoni&min_price=10000&max_price=30000&bedrooms=2&house_type=apartment'"
    )
    pdf.body("The response includes pagination metadata:")
    pdf.code_block(
        '{\n'
        '  "properties": [...],\n'
        '  "total": 15,\n'
        '  "page": 1,\n'
        '  "pages": 1\n'
        '}'
    )

    pdf.sub_heading("3.3", "Property Details")
    pdf.body("Fetch a single property by its UUID:")
    pdf.code_block("curl http://localhost:8200/api/properties/<property-id>")
    pdf.body("The response includes all property fields plus an array of photo URLs. "
             "Each photo object contains an ID, URL, and is_primary flag.")

    pdf.sub_heading("3.4", "Photo Uploads")
    pdf.body("Photos are uploaded as multipart files during property creation. Supported formats: "
             "PNG, JPG, JPEG, and WebP. Maximum file size is 16 MB per upload.")
    pdf.body("Uploaded photos are stored in the uploads/ directory, organised by property ID. "
             "They are served via the /uploads/<path:filename> static route.")
    pdf.note("For production deployments, configure a dedicated file storage service "
             "or a reverse proxy to serve static files efficiently.")

    # ════════════════════════════════════════
    # SECTION 4: AGENT DASHBOARD
    # ════════════════════════════════════════
    pdf.section_heading(4, "Agent Dashboard & Rent Reminders")

    pdf.sub_heading("4.1", "Creating Reminders")
    pdf.body("Agents can create rent reminders for tenants they manage. Required fields:")
    pdf.table_2col("Field", "Description")
    pdf.table_2col("tenant_name", "Full name of the tenant")
    pdf.table_2col("due_date", "Rent due date (ISO format: YYYY-MM-DD)")
    pdf.table_2col("tenant_phone", "Optional phone number")
    pdf.table_2col("unit_number", "Optional unit/apartment identifier")
    pdf.table_2col("rent_amount", "Optional rent amount in KSh")
    pdf.table_2col("notes", "Optional notes about the tenant or agreement")
    pdf.ln(2)
    pdf.code_block(
        'curl -X POST http://localhost:8200/api/agents/reminders \\\n'
        '  -H "Authorization: Bearer <token>" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{\n'
        '    "tenant_name": "Mary Wanjiku",\n'
        '    "tenant_phone": "+254723456789",\n'
        '    "unit_number": "Block A, Unit 3",\n'
        '    "rent_amount": 15000,\n'
        '    "due_date": "2026-08-01"\n'
        '  }\''
    )

    pdf.sub_heading("4.2", "Managing Reminders")
    pdf.body("Agents can view, update, and delete their reminders. The list endpoint supports "
             "optional filtering by status:")
    pdf.code_block(
        "curl 'http://localhost:8200/api/agents/reminders?status=unpaid' \\\n"
        '  -H "Authorization: Bearer <token>"'
    )
    pdf.body("Update a reminder's status (e.g., mark as paid):")
    pdf.code_block(
        'curl -X PUT http://localhost:8200/api/agents/reminders/<id> \\\n'
        '  -H "Authorization: Bearer <token>" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{"status": "paid"}\''
    )

    pdf.sub_heading("4.3", "Overdue Detection")
    pdf.body("The system automatically detects overdue reminders. The overdue endpoint "
             "compares each unpaid reminder's due date against the current date. "
             "Reminders past their due date are flagged as overdue:")
    pdf.code_block(
        "curl http://localhost:8200/api/agents/reminders/overdue \\\n"
        '  -H "Authorization: Bearer <token>"'
    )
    pdf.body("The overdue endpoint updates the status of overdue reminders in the database "
             "before returning them. This ensures the status field remains accurate.")

    # ════════════════════════════════════════
    # SECTION 5: FAVORITES & BOOKINGS
    # ════════════════════════════════════════
    pdf.section_heading(5, "Favorites & Bookings")

    pdf.sub_heading("5.1", "Saving Favorites")
    pdf.body("Tenants can save properties as favorites for quick access later. "
             "The favorites system uses a unique constraint on (user_id, property_id) "
             "to prevent duplicates.")
    pdf.body("Add a property to favorites:")
    pdf.code_block(
        'curl -X POST http://localhost:8200/api/favorites \\\n'
        '  -H "Authorization: Bearer <token>" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{"property_id": "<property-uuid>"}\''
    )
    pdf.body("List all favorites (includes full property details):")
    pdf.code_block(
        "curl http://localhost:8200/api/favorites \\\n"
        '  -H "Authorization: Bearer <token>"'
    )
    pdf.body("Remove a favorite:")
    pdf.code_block(
        "curl -X DELETE http://localhost:8200/api/favorites/<property-id> \\\n"
        '  -H "Authorization: Bearer <token>"'
    )

    pdf.sub_heading("5.2", "Inquiring / Booking")
    pdf.body("Tenants can send booking inquiries to landlords about specific properties. "
             "Each booking tracks status through a workflow:")
    pdf.table_2col("Status", "Meaning")
    pdf.table_2col("pending", "Inquiry sent, awaiting landlord response")
    pdf.table_2col("confirmed", "Landlord has accepted the inquiry")
    pdf.table_2col("cancelled", "Inquiry cancelled by tenant or rejected by landlord")
    pdf.ln(2)
    pdf.body("Create a booking inquiry:")
    pdf.code_block(
        'curl -X POST http://localhost:8200/api/bookings \\\n'
        '  -H "Authorization: Bearer <token>" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{\n'
        '    "property_id": "<property-uuid>",\n'
        '    "message": "I am interested in this property. Is it still available?"\n'
        '  }\''
    )
    pdf.body("Tenants can view their bookings and cancel pending ones. "
             "Landlords can view bookings on their properties via the /api/bookings/landlord endpoint.")

    # ════════════════════════════════════════
    # SECTION 6: SUBSCRIPTIONS & M-PESA
    # ════════════════════════════════════════
    pdf.section_heading(6, "Subscriptions & M-Pesa")

    pdf.sub_heading("6.1", "Subscription Plans")
    pdf.body("Landlords and agents must have an active subscription to use the platform. "
             "Monthly pricing:")
    pdf.table_2col("Plan", "Price (KSh/month)")
    pdf.table_2col("Landlord", "1,000")
    pdf.table_2col("Agent", "500")
    pdf.ln(2)
    pdf.body("Tenants use the platform for free — no subscription required.")

    pdf.sub_heading("6.2", "M-Pesa STK Push")
    pdf.body("Subscription payments are processed via Safaricom's M-Pesa Daraja API "
             "using the STK Push (Simulate Transaction) endpoint. The flow:")
    pdf.numbered_step(1, "User selects a subscription plan in the app.")
    pdf.numbered_step(2, "The API calls the M-Pesa STK Push endpoint with the user's phone number and amount.")
    pdf.numbered_step(3, "The user receives an M-Pesa prompt on their phone and enters their PIN.")
    pdf.numbered_step(4, "Safaricom sends a callback to the configured callback URL.")
    pdf.numbered_step(5, "The API verifies the callback and activates the subscription.")
    pdf.ln(2)
    pdf.body("Initiate a subscription payment:")
    pdf.code_block(
        'curl -X POST http://localhost:8200/api/subscriptions/initiate \\\n'
        '  -H "Authorization: Bearer <token>" \\\n'
        '  -H "Content-Type: application/json" \\\n'
        '  -d \'{"plan_type": "landlord"}\''
    )

    pdf.sub_heading("6.3", "Mock Mode vs Live")
    pdf.body("The M-Pesa integration is designed as plug-and-play:")
    pdf.ln(1)
    pdf.body_bold("Mock Mode (default)")
    pdf.bullet("Activated when MPESA_CONSUMER_KEY and MPESA_CONSUMER_SECRET are empty.")
    pdf.bullet("Returns a simulated CheckoutRequestID without calling the Safaricom API.")
    pdf.bullet("Subscriptions are created in pending status — suitable for development and testing.")
    pdf.ln(1)
    pdf.body_bold("Live Mode")
    pdf.bullet("Fill in MPESA_CONSUMER_KEY, MPESA_CONSUMER_SECRET, and MPESA_PASSKEY in .env.")
    pdf.bullet("Set MPESA_ENV to sandbox for testing or production for live payments.")
    pdf.bullet("Configure the callback URL (via ngrok or a public domain) in your Daraja API settings.")
    pdf.ln(2)
    pdf.warning("Never commit M-Pesa credentials to version control. "
               "Use the .env file which is included in .gitignore.")

    # ════════════════════════════════════════
    # SECTION 7: FLUTTER MOBILE APP
    # ════════════════════════════════════════
    pdf.section_heading(7, "Flutter Mobile App")

    pdf.sub_heading("7.1", "App Structure")
    pdf.body("The Flutter mobile app is located in the mobile/ directory. "
             "It follows a standard Flutter project structure:")
    pdf.code_block(
        "mobile/\n"
        "  lib/\n"
        "    main.dart              -- App entry point + MultiProvider setup\n"
        "    config.dart            -- API base URL, constants\n"
        "    models/                -- Data models (User, Property, Reminder, etc.)\n"
        "    services/              -- AuthService, ApiService (HTTP client)\n"
        "    screens/               -- 14 screen files (see below)\n"
        "  pubspec.yaml             -- Dependencies (provider, http, url_launcher, etc.)\n"
        "  assets/                  -- Static assets (images, placeholders)"
    )
    pdf.note("The app uses Provider for state management. AuthService is a ChangeNotifier "
             "that rebuilds the UI on login/logout. ApiService is provided as a plain Provider "
             "and includes automatic retry with exponential backoff for network errors.")

    pdf.sub_heading("7.2", "All Screens Reference")
    pdf.body("The app contains 14 screens, each handling a distinct function:")
    pdf.ln(1)
    screens = [
        ("SplashScreen", "App entry point. Initializes auth from local storage, navigates to Home or Login."),
        ("LoginScreen", "Email or phone-based login with JWT token persistence."),
        ("RegisterScreen", "New user registration with role selection (tenant/landlord/agent)."),
        ("HomeScreen", "Main hub. Tenants see 3-tab navigation (Browse, Saved, Bookings). "
                       "Landlords/agents see search bar + quick actions + property lists."),
        ("SearchScreen", "Filter properties by location, price range, bedrooms, house type. Paginated results."),
        ("PropertyDetailScreen", "Full property view with photo gallery, amenity chips, call/WhatsApp/Inquire buttons. "
                                  "Landlords see edit + delete actions. All users see heart toggle for favorites."),
        ("PostPropertyScreen", "Multi-field form with photo picker. Supports both create and edit modes."),
        ("AgentDashboardScreen", "Reminder list with summary cards (overdue/unpaid/paid counts). "
                                  "Functional filter chips. Edit + delete via popup menu. Mark paid inline."),
        ("ReminderFormScreen", "Create or edit rent reminders with date picker. Supports create and edit modes."),
        ("ProfileScreen", "User profile display with avatar, subscription status, subscribe buttons, sign out."),
        ("FavoritesScreen", "List of saved properties with unfavorite button and empty state."),
        ("BookingsScreen", "List of booking inquiries with status indicators and cancel action."),
    ]
    for name, desc in screens:
        pdf.table_2col(name, desc, [45, CONTENT_W - 45])
    pdf.ln(2)

    pdf.sub_heading("7.3", "Building & Running")
    pdf.body("To build and run the Flutter app, ensure the Flutter SDK is installed:")
    pdf.numbered_step(1, "Navigate to the mobile directory: cd mobile")
    pdf.numbered_step(2, "Install dependencies: flutter pub get")
    pdf.numbered_step(3, "Update the API base URL in lib/config.dart to point to your backend.")
    pdf.numbered_step(4, "Run on a connected device: flutter run")
    pdf.ln(2)
    pdf.note("The app requires Flutter SDK 3.2+ and either an Android emulator, "
             "physical device, or iOS simulator to run. "
             "For Android builds, the Android SDK must be installed and configured.")
    pdf.warning("The google_maps_flutter, cached_network_image, and fluttertoast packages "
               "have been removed as they were unused. Do not re-add them without purpose.")

    # ════════════════════════════════════════
    # SECTION 8: API REFERENCE
    # ════════════════════════════════════════
    pdf.section_heading(8, "API Reference")
    pdf.body("All API endpoints are prefixed with /api. "
             "Authenticated endpoints require the header: Authorization: Bearer <token>.")

    pdf.sub_heading("8.1", "Auth Endpoints")
    pdf.table_header(["Method", "Path", "Auth", "Description"], [20, 50, 15, CONTENT_W - 85])
    endpoints = [
        ("POST", "/api/auth/register", "No", "Create a new user account. Body: name, phone, email, password, user_type."),
        ("POST", "/api/auth/login", "No", "Authenticate user. Body: email or phone + password."),
        ("GET", "/api/auth/me", "Yes", "Get the authenticated user's profile."),
    ]
    for i, (m, p, a, d) in enumerate(endpoints):
        pdf.table_row([m, p, a, d], [20, 50, 15, CONTENT_W - 85], fill=(i % 2 == 0))

    pdf.sub_heading("8.2", "Properties Endpoints")
    pdf.table_header(["Method", "Path", "Auth", "Description"], [20, 50, 15, CONTENT_W - 85])
    endpoints = [
        ("GET", "/api/properties", "No", "List/search properties. Query params: location, min_price, max_price, bedrooms, house_type, page, per_page."),
        ("GET", "/api/properties/<id>", "No", "Get a single property by UUID."),
        ("POST", "/api/properties", "Yes", "Create a property listing (multipart). Landlord only."),
        ("PUT", "/api/properties/<id>", "Yes", "Update property fields (JSON). Landlord owner only."),
        ("DELETE", "/api/properties/<id>", "Yes", "Delete a property listing. Landlord owner only."),
    ]
    for i, (m, p, a, d) in enumerate(endpoints):
        pdf.table_row([m, p, a, d], [20, 50, 15, CONTENT_W - 85], fill=(i % 2 == 0))

    pdf.sub_heading("8.3", "Agents Endpoints")
    pdf.table_header(["Method", "Path", "Auth", "Description"], [20, 50, 15, CONTENT_W - 85])
    endpoints = [
        ("GET", "/api/agents/reminders", "Yes", "List reminders for the authenticated agent. Query: status."),
        ("POST", "/api/agents/reminders", "Yes", "Create a new rent reminder."),
        ("PUT", "/api/agents/reminders/<id>", "Yes", "Update a reminder (status, name, amount, etc.)."),
        ("DELETE", "/api/agents/reminders/<id>", "Yes", "Delete a reminder."),
        ("GET", "/api/agents/reminders/overdue", "Yes", "Get overdue reminders and auto-update their status."),
    ]
    for i, (m, p, a, d) in enumerate(endpoints):
        pdf.table_row([m, p, a, d], [20, 50, 15, CONTENT_W - 85], fill=(i % 2 == 0))

    pdf.sub_heading("8.4", "Favorites Endpoints")
    pdf.table_header(["Method", "Path", "Auth", "Description"], [20, 50, 15, CONTENT_W - 85])
    endpoints = [
        ("GET", "/api/favorites", "Yes", "List the authenticated user's favorites with full property details."),
        ("POST", "/api/favorites", "Yes", "Add a property to favorites. Body: property_id."),
        ("DELETE", "/api/favorites/<property_id>", "Yes", "Remove a favorite by property ID."),
    ]
    for i, (m, p, a, d) in enumerate(endpoints):
        pdf.table_row([m, p, a, d], [20, 50, 15, CONTENT_W - 85], fill=(i % 2 == 0))

    pdf.sub_heading("8.5", "Bookings Endpoints")
    pdf.table_header(["Method", "Path", "Auth", "Description"], [20, 50, 15, CONTENT_W - 85])
    endpoints = [
        ("GET", "/api/bookings", "Yes", "List the authenticated tenant's booking inquiries."),
        ("POST", "/api/bookings", "Yes", "Create a booking inquiry. Body: property_id, message (optional)."),
        ("PUT", "/api/bookings/<id>", "Yes", "Update booking status or message."),
        ("GET", "/api/bookings/landlord", "Yes", "List bookings on the authenticated landlord's properties."),
    ]
    for i, (m, p, a, d) in enumerate(endpoints):
        pdf.table_row([m, p, a, d], [20, 50, 15, CONTENT_W - 85], fill=(i % 2 == 0))

    pdf.sub_heading("8.6", "Subscriptions Endpoints")
    pdf.table_header(["Method", "Path", "Auth", "Description"], [20, 50, 15, CONTENT_W - 85])
    endpoints = [
        ("GET", "/api/subscriptions/plans", "No", "List available subscription plans and prices."),
        ("POST", "/api/subscriptions/initiate", "Yes", "Initiate M-Pesa STK Push for a subscription. Body: plan_type."),
        ("POST", "/api/subscriptions/callback", "No", "M-Pesa API callback endpoint (configure in Daraja)."),
        ("GET", "/api/subscriptions/status", "Yes", "Check the authenticated user's subscription status."),
    ]
    for i, (m, p, a, d) in enumerate(endpoints):
        pdf.table_row([m, p, a, d], [20, 50, 15, CONTENT_W - 85], fill=(i % 2 == 0))

    # ════════════════════════════════════════
    # SECTION 9: DEPLOYMENT
    # ════════════════════════════════════════
    pdf.section_heading(9, "Deployment")

    pdf.sub_heading("9.1", "Docker Deployment")
    pdf.body("A Dockerfile and docker-compose.yml are provided for containerised deployment:")
    pdf.code_block(
        "# Build and start the API service\n"
        "docker compose up -d\n\n"
        "# Verify it is running\n"
        "curl http://localhost:8200/api/health"
    )
    pdf.body("The Dockerfile uses Python 3.11-slim with gunicorn (4 workers). "
             "Persistent data is stored in named volumes: api_data (SQLite) and api_uploads (photos).")
    pdf.body("For PostgreSQL, uncomment the db service in docker-compose.yml and set DATABASE_URL "
             "to point to the PostgreSQL container.")

    pdf.sub_heading("9.2", "Systemd Service")
    pdf.body("A systemd service file (rental-hub.service) is provided for bare-metal deployments:")
    pdf.code_block(
        "# Install the service\n"
        "sudo cp rental-hub.service /etc/systemd/system/\n"
        "sudo systemctl daemon-reload\n"
        "sudo systemctl enable rental-hub\n"
        "sudo systemctl start rental-hub\n\n"
        "# Check status\n"
        "sudo systemctl status rental-hub"
    )
    pdf.body("The service runs as the karasko user from the project directory using gunicorn. "
             "It auto-restarts on failure with a 5-second delay.")

    pdf.sub_heading("9.3", "PostgreSQL Setup")
    pdf.body("For production, PostgreSQL is recommended over SQLite:")
    pdf.numbered_step(1, "Install PostgreSQL: sudo apt install postgresql")
    pdf.numbered_step(2, "Create a database: sudo -u postgres createdb rental_hub")
    pdf.numbered_step(3, "Update .env: DATABASE_URL=postgresql://user:pass@localhost:5432/rental_hub")
    pdf.numbered_step(4, "Restart the API — tables are auto-created on first request.")
    pdf.ln(2)
    pdf.note("The psycopg2-binary package is included in requirements.txt for PostgreSQL connectivity.")

    # ════════════════════════════════════════
    # SECTION 10: TROUBLESHOOTING
    # ════════════════════════════════════════
    pdf.section_heading(10, "Troubleshooting")

    pdf.sub_heading("10.1", "Common Issues")
    pdf.ln(1)
    pdf.body_bold("API won't start -- port in use")
    pdf.body("Change the port via the PORT environment variable: PORT=8201 python run.py")
    pdf.ln(1)
    pdf.body_bold("Database errors -- tables not created")
    pdf.body("Ensure the database path in .env is writable. For SQLite, check parent directory permissions.")
    pdf.ln(1)
    pdf.body_bold("M-Pesa payments not working")
    pdf.body("Verify MPESA_CONSUMER_KEY, MPESA_CONSUMER_SECRET, and MPESA_PASSKEY are set in .env. "
             "The system falls back to mock mode automatically if credentials are missing.")
    pdf.ln(1)
    pdf.body_bold("Flutter app cannot connect to API")
    pdf.body("Update the API base URL in mobile/lib/config.dart. "
             "For Android emulator, use 10.0.2.2 instead of localhost to reach the host machine.")
    pdf.ln(1)
    pdf.body_bold("Photo uploads failing")
    pdf.body("Check that the uploads/ directory exists and is writable. Max file size is 16 MB. "
             "Accepted formats: PNG, JPG, JPEG, WebP.")
    pdf.ln(1)
    pdf.body_bold("JWT token expired")
    pdf.body("Tokens expire after 7 days. Log in again to obtain a fresh token.")

    pdf.sub_heading("10.2", "Support")
    pdf.body("For issues, feature requests, or questions:")
    pdf.bullet("Open an issue in the project repository")
    pdf.bullet("Contact the development team via email")

    # ════════════════════════════════════════
    # SECTION 11: APPENDIX
    # ════════════════════════════════════════
    pdf.section_heading(11, "Appendix")

    pdf.sub_heading("11.1", "Database Schema")
    pdf.body("The platform uses 7 database tables:")
    pdf.ln(1)
    tables = [
        ("users", "User accounts with role-based access control"),
        ("properties", "Property listings with location, pricing, amenity flags"),
        ("property_photos", "Photo URLs linked to property listings"),
        ("reminders", "Rent reminders managed by agents"),
        ("favorites", "User-to-property saved links (unique constraint)"),
        ("bookings", "Tenant booking inquiries with status workflow"),
        ("subscriptions", "Subscription records linked to M-Pesa transactions"),
    ]
    for name, desc in tables:
        pdf.table_2col(name, desc)
    pdf.ln(2)
    pdf.body("Tables are created automatically by SQLAlchemy on the first request. "
             "All primary keys use UUID v4 strings for distributed compatibility.")

    pdf.sub_heading("11.2", "Revision History")
    pdf.table_header(["Rev", "Date", "Description"], [25, 35, CONTENT_W - 60])
    pdf.table_row(["A", DATE, "Initial release."], [25, 35, CONTENT_W - 60], fill=True)

    # ── OUTPUT ──
    os.makedirs(IMAGES_DIR, exist_ok=True)
    output_path = Path(__file__).parent / f"{DOC_NUM}_Rev{REV}_{PRODUCT}_Manual.pdf"
    pdf.output(str(output_path))
    print(f"PDF saved to {output_path}")


if __name__ == "__main__":
    build_manual()
