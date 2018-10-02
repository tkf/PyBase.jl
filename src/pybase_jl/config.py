try:
    from ._config import *
except ImportError:
    class PyBaseJulia:
        mime_include = []
        mime_exclude = []

    global_config = PyBaseJulia
