#!/usr/bin/env python3
"""
Script de verificação de cobertura de testes do Frontend (Flutter).
Analisa o arquivo coverage/lcov.info e valida se a cobertura de linhas atinge o threshold mínimo exigido.
SPEC-040: Medir e garantir cobertura de testes backend e frontend.
"""

import argparse
import os
import sys

DEFAULT_THRESHOLD = 80.0
IGNORED_FILES = {
    "lib/main.dart",
    "lib/features/attachment/domain/services/platform_file_picker_io.dart",
    "lib/features/attachment/domain/services/platform_file_saver_io.dart",
}


def parse_lcov(lcov_path, ignored_files=None):
    if ignored_files is None:
        ignored_files = set()

    if not os.path.isfile(lcov_path):
        print(f"Erro: Arquivo de cobertura não encontrado: {lcov_path}", file=sys.stderr)
        return None

    files_data = {}
    current_file = None

    with open(lcov_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("SF:"):
                raw_path = line[3:].replace("\\", "/")
                # Normaliza para caminho relativo a partir de lib/
                idx = raw_path.find("lib/")
                rel_path = raw_path[idx:] if idx != -1 else raw_path
                current_file = rel_path
                files_data[current_file] = {"lines_found": 0, "lines_hit": 0}
            elif line.startswith("DA:") and current_file:
                parts = line[3:].split(",")
                if len(parts) >= 2:
                    hit = int(parts[1])
                    files_data[current_file]["lines_found"] += 1
                    if hit > 0:
                        files_data[current_file]["lines_hit"] += 1

    # Filtra arquivos ignorados
    filtered = {}
    for f_path, stats in files_data.items():
        if any(f_path.endswith(ign) or ign in f_path for ign in ignored_files):
            continue
        filtered[f_path] = stats

    return filtered


def main():
    parser = argparse.ArgumentParser(description="Verificador de cobertura de testes Flutter")
    parser.add_argument(
        "--file",
        "-f",
        default="coverage/lcov.info",
        help="Caminho para o arquivo lcov.info (padrão: coverage/lcov.info)",
    )
    parser.add_argument(
        "--threshold",
        "-t",
        type=float,
        default=DEFAULT_THRESHOLD,
        help=f"Percentual mínimo de cobertura de linhas exigido (padrão: {DEFAULT_THRESHOLD}%%)",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Exibir relatório linha a linha de cada arquivo",
    )
    args = parser.parse_args()

    files = parse_lcov(args.file, IGNORED_FILES)
    if files is None:
        sys.exit(1)

    total_found = sum(s["lines_found"] for s in files.values())
    total_hit = sum(s["lines_hit"] for s in files.values())
    total_pct = (total_hit / total_found * 100.0) if total_found > 0 else 0.0

    print("=" * 80)
    print("RELATÓRIO DE COBERTURA DE TESTES FRONTEND (FLUTTER) - SPEC-040")
    print("=" * 80)
    print(f"{'Arquivo':<55} | {'Linhas':<10} | {'Cobertura':<10}")
    print("-" * 80)

    for path in sorted(files.keys()):
        stats = files[path]
        found = stats["lines_found"]
        hit = stats["lines_hit"]
        pct = (hit / found * 100.0) if found > 0 else 100.0
        if args.verbose or pct < args.threshold:
            flag = " [!] ABAIXO" if pct < args.threshold else ""
            print(f"{path:<55} | {hit:4d}/{found:<5d} | {pct:6.2f}%{flag}")

    print("-" * 80)
    print(f"{'TOTAL GERAL':<55} | {total_hit:4d}/{total_found:<5d} | {total_pct:6.2f}%")
    print("=" * 80)
    print(f"Meta mínima exigida: {args.threshold:.2f}%")

    if total_pct < args.threshold:
        print(f"FALHA: Cobertura total ({total_pct:.2f}%) abaixo do threshold mínimo de {args.threshold:.2f}%.", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"SUCESSO: Cobertura total atingida ({total_pct:.2f}% >= {args.threshold:.2f}%).")
        sys.exit(0)


if __name__ == "__main__":
    main()
