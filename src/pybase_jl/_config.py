from traitlets.config.configurable import SingletonConfigurable
from traitlets.config import get_config
from traitlets import Unicode, List


class PyBaseJulia(SingletonConfigurable):

    def __init__(self, **kwargs):
        c = get_config()
        if "PyBaseJulia" in c:
            kwargs = dict(c.PyBaseJulia, **kwargs)
        super(PyBaseJulia, self).__init__(**kwargs)

    mime_include = List(
        Unicode,
        [],
        help="Default list of MIME to include in rich display.",
    ).tag(config=True)

    mime_exclude = List(
        Unicode,
        [],
        help="Default list of MIME to exclude from rich display.",
    ).tag(config=True)


global_config = PyBaseJulia
