import csv
import os
from pathlib import Path
from office365.runtime.auth.client_credential import ClientCredential
from office365.sharepoint.client_context import ClientContext
from office365.sharepoint.folders.folder import Folder

# ====== CONFIG ======
SITE_URL = "https://contoso.sharepoint.com/sites/BovietITTeam"
DOC_LIB = "Shared Documents"  # library internal name for "Documents"
PARENT_PATH = "Boviet IT Team Channel/Intern/Je/AP Email Automation/Logistics"  # no leading/trailing slash
INPUT_PATH = "folders.csv"  # CSV with column 'FolderName' or TXT with one per line

# App (Entra ID) creds
CLIENT_ID = os.getenv("SP_APP_CLIENT_ID") or "<CLIENT_ID>"
CLIENT_SECRET = os.getenv("SP_APP_CLIENT_SECRET") or "<CLIENT_SECRET>"
# ====================

INVALID = ['~','"','#','%','&','*',':','<','>','?','/','\\','{','|','}','.']

def sanitize(name: str) -> str:
    s = (name or "").strip()
    for ch in INVALID:
        s = s.replace(ch, "")
    return s.rstrip(". ")  # SharePoint quirk

def read_names(path: str):
    p = Path(path)
    if p.suffix.lower() == ".csv":
        with p.open(newline="", encoding="utf-8-sig") as f:
            for row in csv.DictReader(f):
                yield row.get("FolderName", "")
    else:
        # txt or any plain list (one per line)
        for line in p.read_text(encoding="utf-8").splitlines():
            yield line

def ensure_folder(ctx: ClientContext, rel_url: str):
    """
    Ensures nested folder(s) exist. Example rel_url:
    'Shared Documents/Parent/Child'
    """
    Folder.ensure_folder_path(ctx, rel_url)
    ctx.execute_query()

def main():
    ctx = ClientContext(SITE_URL).with_credentials(
        ClientCredential(CLIENT_ID, CLIENT_SECRET)
    )

    base = f"{DOC_LIB}/{PARENT_PATH}" if PARENT_PATH else DOC_LIB

    count = 0
    for raw in read_names(INPUT_PATH):
        name = sanitize(raw)
        if not name:
            continue
        rel = f"{base}/{name}"
        ensure_folder(ctx, rel)
        print("Ensured:", rel)
        count += 1

    print(f"Done. Ensured {count} folders under: {base}")

if __name__ == "__main__":
    main()
