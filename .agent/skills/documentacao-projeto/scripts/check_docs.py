#!/usr/bin/env python3
"""Compara código e documentação e aponta divergências.

Uso: python check_docs.py [raiz-do-projeto]
Saída: código 0 se tudo coerente, 1 se houver divergência.

Verifica:
  - endpoints dos controllers Spring x títulos "### METHOD /rota" em docs/api.md
  - tabelas CREATE TABLE das migrations x menções em docs/modelo-de-dados.md
"""
import re
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
docs = root / "docs"

MAPPING = re.compile(
    r'@(Get|Post|Put|Patch|Delete)Mapping\s*(?:\(\s*(?:(?:value|path)\s*=\s*)?\{?\s*"([^"]*)")?'
)
CLASS_MAPPING = re.compile(
    r'@RequestMapping\s*\(\s*(?:(?:value|path)\s*=\s*)?\{?\s*"([^"]*)"'
)
DOC_ENDPOINT = re.compile(r'^#{1,6}\s+(GET|POST|PUT|PATCH|DELETE)\s+(\S+)', re.M)
CREATE_TABLE = re.compile(
    r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?[`"]?(\w+)[`"]?', re.I
)


def norm(path: str) -> str:
    path = re.sub(r'/+', '/', '/' + path.strip('/'))
    return path if path == '/' else path.rstrip('/')


def code_endpoints():
    found = set()
    for java in (root / "src" / "main").rglob("*.java"):
        text = java.read_text(encoding="utf-8", errors="ignore")
        if "@RestController" not in text and "@Controller" not in text:
            continue
        class_idx = re.search(r'\b(class|interface)\s+\w+', text)
        head = text[: class_idx.start()] if class_idx else ""
        base = CLASS_MAPPING.search(head)
        prefix = base.group(1) if base else ""
        for m in MAPPING.finditer(text[class_idx.start():] if class_idx else text):
            found.add((m.group(1).upper(), norm(prefix + "/" + (m.group(2) or ""))))
    return found


def doc_endpoints():
    api = docs / "api.md"
    if not api.exists():
        return None
    text = api.read_text(encoding="utf-8")
    return {(m.group(1), norm(m.group(2).strip('`'))) for m in DOC_ENDPOINT.finditer(text)}


def code_tables():
    found = set()
    mig = root / "src" / "main" / "resources" / "db" / "migration"
    if mig.exists():
        for sql in mig.glob("*.sql"):
            found.update(CREATE_TABLE.findall(sql.read_text(encoding="utf-8", errors="ignore")))
    return found


problems = []

ce, de = code_endpoints(), doc_endpoints()
if de is None:
    if ce:
        problems.append("docs/api.md não existe, mas há %d endpoint(s) no código." % len(ce))
else:
    for method, path in sorted(ce - de):
        problems.append(f"Endpoint no código sem documentação: {method} {path}")
    for method, path in sorted(de - ce):
        problems.append(f"Endpoint documentado que não existe no código: {method} {path}")

tables = code_tables()
model = docs / "modelo-de-dados.md"
if tables:
    if not model.exists():
        problems.append("docs/modelo-de-dados.md não existe, mas há tabelas nas migrations.")
    else:
        text = model.read_text(encoding="utf-8").lower()
        for t in sorted(tables):
            if t.lower() not in text:
                problems.append(f"Tabela criada em migration sem menção em modelo-de-dados.md: {t}")

if problems:
    print("Divergências entre código e documentação:")
    for p in problems:
        print(" -", p)
    sys.exit(1)

print(f"OK: {len(ce)} endpoint(s) e {len(tables)} tabela(s) coerentes com a documentação.")
