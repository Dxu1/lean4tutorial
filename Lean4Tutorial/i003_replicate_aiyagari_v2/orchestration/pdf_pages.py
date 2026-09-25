"""Optional local pypdf adapter; no OCR, downloads or installation."""
import sys,json,hashlib
from pathlib import Path
from pypdf import PdfReader,PdfWriter
source,target,expected,pages=sys.argv[1:];data=Path(source).read_bytes()
assert hashlib.sha256(data).hexdigest()==expected
reader=PdfReader(source);writer=PdfWriter();pages=json.loads(pages)
for p in pages:
    assert 1<=p<=len(reader.pages)
    writer.add_page(reader.pages[p-1])
writer.write(target)
assert len(PdfReader(target).pages)==len(pages)
