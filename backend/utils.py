import fitz  # PyMuPDF

def extract_title_from_pdf(file_bytes):
    doc = fitz.open(stream=file_bytes, filetype="pdf")
    meta = doc.metadata
    return meta.get("title") or "Untitled"


def chunk_text(text, max_tokens=3000):
    paragraphs = text.split("\n")
    chunks, chunk = [], ""
    for para in paragraphs:
        if len(chunk) + len(para) < max_tokens:
            chunk += para + "\n"
        else:
            chunks.append(chunk.strip())
            chunk = para + "\n"
    if chunk:
        chunks.append(chunk.strip())
    return chunks
