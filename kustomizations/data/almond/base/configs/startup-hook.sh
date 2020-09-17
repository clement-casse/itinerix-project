#!/bin/bash

set -eux;

# jupyter labextension install @jupyterlab/toc;
jupyter labextension install @telamonian/theme-darcula --no-build;
jupyter labextension install @deathbeds/jupyterlab-fonts --no-build;
jupyter labextension install @deathbeds/jupyterlab-font-fira-code --no-build;
#jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build;
#jupyter labextension install algorithmx-jupyter;

jupyter lab build;
