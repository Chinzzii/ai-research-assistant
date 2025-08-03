import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

# In-memory DB for demo purposes
PAPERS_DB = {
    # 'title': ('summary', np.array([embedding]))
}

model = SentenceTransformer("all-MiniLM-L6-v2")
DIM = 384  # depends on model used
index = faiss.IndexFlatL2(DIM)


def store_embedding(title, summary):
    embedding = model.encode(summary)
    PAPERS_DB[title] = (summary, embedding)
    index.add(np.array([embedding]))


def get_similar_papers(title, top_k=3):
    if title not in PAPERS_DB:
        return []
    query_embedding = PAPERS_DB[title][1]
    D, I = index.search(np.array([query_embedding]), top_k)
    results = []
    keys = list(PAPERS_DB.keys())
    for idx in I[0]:
        if idx < len(keys) and keys[idx] != title:
            results.append({"title": keys[idx], "summary": PAPERS_DB[keys[idx]][0]})
    return results
