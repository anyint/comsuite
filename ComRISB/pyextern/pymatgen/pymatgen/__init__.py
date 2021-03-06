from __future__ import unicode_literals

import os
import warnings
import yaml

__author__ = "Pymatgen Development Team"
__email__ ="pymatgen@googlegroups.com"
__maintainer__ = "Shyue Ping Ong"
__maintainer_email__ ="shyuep@gmail.com"
__date__ = "May 27 2017"
__version__ = "4.7.7"


SETTINGS_FILE = os.path.join(os.path.expanduser("~"), ".pmgrc.yaml")


def _load_pmg_settings():
    try:
        with open(SETTINGS_FILE, "rt") as f:
            d = yaml.load(f)
    except IOError:
        # If there are any errors, default to using environment variables
        # if present.
        d = {}
        for k, v in os.environ.items():
            if k.startswith("PMG_"):
                d[k] = v
            elif k in ["VASP_PSP_DIR", "MAPI_KEY", "DEFAULT_FUNCTIONAL"]:
                d["PMG_" + k] = v
    clean_d = {}
    for k, v in d.items():
        if not k.startswith("PMG_"):
            warnings.warn('With effect from pmg 5.0, all pymatgen settings are'
                          ' prefixed with a "PMG_". E.g., "PMG_VASP_PSP_DIR" '
                          'instead of "VASP_PSP_DIR".')
            clean_d["PMG_" + k] = v
        else:
            clean_d[k] = v
    return clean_d

SETTINGS = _load_pmg_settings()


def get_structure_from_mp(formula):
    """
    Convenience method to get a crystal from the Materials Project database via
    the API. Requires PMG_MAPI_KEY to be set.
    
    Args:
        formula (str): A formula
    
    Returns:
        (Structure) The lowest energy structure in Materials Project with that
            formula.
    """
    if not SETTINGS.get("PMG_MAPI_KEY"):
        raise RuntimeError("PMG_MAPI_KEY must be set in .pmgrc.yaml to use this "
                           "function.")

    from pymatgen.matproj.rest import MPRester
    m = MPRester()
    entries = m.get_entries(formula, inc_structure=True)
    if len(entries) == 0:
        raise ValueError("No structure with formula %s in Materials Project!" %
                         formula)
    elif len(entries) > 1:
        warnings.warn("%d structures with formula %s found in Materials Project."
                      "The lowest energy structure will be returned." %
                      (len(entries), formula))
    return min(entries, key=lambda e: e.energy_per_atom).structure


# Order of imports is important on some systems to avoid
# failures when loading shared libraries.
# import spglib
# from . import optimization, util
# del(spglib, optimization, util)

# Useful aliases for commonly used objects and modules.
# Allows from pymatgen import <class> for quick usage.

from pymatgen.core import *
from .electronic_structure.core import Spin, Orbital
from .matproj.rest import MPRester
from monty.json import MontyEncoder, MontyDecoder, MSONable
