import os
from pypdf import PdfReader

pdf_path = "c:/Users/drago/OneDrive/Desktop/Hybrid/Doko Platform Development Guide.pdf"
out_path = "c:/Users/drago/OneDrive/Desktop/Hybrid/doko_guide.md"

if not os.path.exists(pdf_path):
    print("PDF not found!")
    exit(1)

reader = PdfReader(pdf_path)
text = ""
for i, page in enumerate(reader.pages):
    text += f"\n\n--- Page {i+1} ---\n\n"
    text += page.extract_text()

with open(out_path, "w", encoding="utf-8") as f:
    f.write(text)

print(f"Extracted {len(reader.pages)} pages to {out_path}")
