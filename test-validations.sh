#!/usr/bin/env bash

# Test rápido de validaciones
cd "$(dirname "$0")"

# Ejecutar solo las validaciones
source modules/00-checks.sh 2>&1 | tail -20
