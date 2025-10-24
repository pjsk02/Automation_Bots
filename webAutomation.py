USERNAME = "lucygboviet"
PASSWORD = "LGarcia27834"

# pip install playwright
# playwright install

import time
from playwright.sync_api import sync_playwright,expect
from pathlib import Path
from datetime import datetime


# add at the very top
# import os, sys

# BASE = Path(getattr(sys, "_MEIPASS", Path(__file__).parent))  # works for exe & .py
# # We'll ship the browsers folder inside the exe bundle under "ms-playwright"
# os.environ["PLAYWRIGHT_BROWSERS_PATH"] = str(BASE / "ms-playwright")
# print("PW path:", os.environ.get("PLAYWRIGHT_BROWSERS_PATH"))

DOWNLOAD_DIR = Path("downloads")
DOWNLOAD_DIR.mkdir(exist_ok=True)
# -------------------------------------------------------------------------------------------------

def login(page):

    # Entering Username and password
    page.get_by_label("Username").first.fill(USERNAME)
    
    page.get_by_placeholder("Enter your Password").first.fill(PASSWORD)
    
    # Clicking Login Button
    loginBtn = page.get_by_role('button',name="LOGIN")
    loginBtn.click()

    # Waiting until post Logs-in element appearing
    page.wait_for_load_state("networkidle")

    # Selecting Menu Item Shipments
    shipments = page.locator("div.menuText:has-text('Shipments')")
    shipments.first.wait_for(state="visible", timeout=15000)
    shipments.first.click()
    page.wait_for_load_state("networkidle")

# -------------------------------------------------------------------------------------------------

def handle_dialog(dialog):
        print(f"Dialog type: {dialog.type}")
        print(f"Dialog message: {dialog.message}")
        if dialog.type == "prompt":
            dialog.accept("My input")  # For prompt dialogs, provide input
        else:
            dialog.accept()  # For alert/confirm dialogs, simply accept

# -------------------------------------------------------------------------------------------------

def filterSelect(pg):
     dropdown = pg.locator("button#combo-1174-trigger-picker")
     dropdown.click()

     dropdown.locator("div.dropdown-menu:visible a:text('Annu')").click()
     
# -------------------------------------------------------------------------------------------------

def btnRefresh(p):
     p.locator("span.fa-refresh").click()

# -------------------------------------------------------------------------------------------------

def changeRecords1000(p):
    view = p.locator("//div[contains(@class,'x-toolbar')][.//span[normalize-space()='View:']]//input[contains(@role,'combobox')]").first
    view.click()
    p.keyboard.type("1000")

# -------------------------------------------------------------------------------------------------

def pressingButton(page):
    btnActions = page.get_by_role('button',name="Actions").first()
    btnActions.click()

# -------------------------------------------------------------------------------------------------

def wait_for_load_completed(page):
    # Wait until the span shows 'Load Completed'
    # print("Wait started ",datetime.now())
    done = page.locator("span#button-1162-btnInnerEl")
    # If that ID changes, use contains-text instead:
    # done = page.locator("span:has-text('Load Completed')")
    expect(done).to_have_text("Load Completed", timeout=60000)


# starting instance
with sync_playwright() as playwright:

    #Launching the browser
    browser= playwright.chromium.launch(headless=False,args=["--start-maximized"],slow_mo=500)
    
    #creating new tab
    context = browser.new_context(accept_downloads=True)
    page = context.new_page()
    # page = browser.new_page()
    
    #opening website
    page.goto("https://tracking.magaya.com/?orgname=37508#livetrack",wait_until="domcontentloaded")

    # Login Func
    login(page)

    # Allowing user to select the Date Time Frame
    time.sleep(5)

    # Selecting Filter Annu
    # filterSelect(page)

    # Pressing Refresh button
    # print("At refresh Button")
    btnRefresh(page)

    # Entering 1000 Records
    changeRecords1000(page)
    time.sleep(1)

    btnRefresh(page)
    # time.sleep(1)
    wait_for_load_completed(page)
    # print("wait ended",datetime.now())

    # ---------------- # Exporting the File -----------

    # Pressing the button Actions
    # pressingButton(page)
    btnActions = page.locator("a.x-btn:has(span.x-btn-inner:has-text('Actions'))").first
    btnActions.click()

    # Pressing Export Button
    btnExport = page.locator("a.x-menu-item-link:has(span.x-menu-item-text:has-text('Export'))")
    btnExport.click()

    # Pressing Download Button
    btnDownload = page.locator("a.x-btn:not(.x-item-disabled):has(span.x-btn-inner:has-text('Download'))")
    # btnDownload.click()

    with page.expect_download() as d_info:
        btnDownload.click()
    dl = d_info.value  # Download object
    filename = dl.suggested_filename  # often .csv, .xlsx, or .xls
    save_path = DOWNLOAD_DIR / filename
    dl.save_as(str(save_path))
    print(f"Saved to: {save_path}")


    #closing the browser
    time.sleep(5)
    context.close()
    browser.close()
# -------------------------------------------------------------------------------------------------
