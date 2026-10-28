"""Capture guidance using the production spirit, without starting services."""
from pathlib import Path
import runpy
import sys
if '--guidance' not in sys.argv:
    sys.argv.append('--guidance')
runpy.run_path(str(Path(__file__).with_name('preview_spirit.py')), run_name='__main__')
