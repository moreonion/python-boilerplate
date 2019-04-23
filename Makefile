.PHONY: help bootstrap test safety requirements

VENV?=.venv
PYTHON?=python

help:
	@echo
	@echo "make install         -- setup production environment"
	@echo
	@echo "make development     -- setup development environment"
	@echo "make test            -- run full test suite"
	@echo "make safety          -- run safety check on packages"
	@echo
	@echo "make requirements    -- only compile the requirements*.txt files"
	@echo "make .venv           -- bootstrap the virtualenv."
	@echo

install: $(VENV)/.pip-installed-production

development: $(VENV)/.pip-installed-development .git/hooks/pre-commit

test:
	$(VENV)/bin/pytest --cov tests

safety: requirements.txt
	$(VENV)/bin/safety check -r $<

requirements: requirements.txt requirements-dev.txt

%.txt: %.in
	pip-compile -v --output-file $@ $<

# Actual files/directories
################################################################################

# Create this directory as a symbolic link to an existing virtualenv, if you want to use that.
$(VENV):
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install pip-tools
	touch $(VENV)

$(VENV)/.pip-installed-production: $(VENV) requirements.txt
	$(VENV)/bin/pip install -r requirements.txt && touch $@

$(VENV)/.pip-installed-development: $(VENV) requirements-dev.txt
	$(VENV)/bin/pip install -r requirements-dev.txt && touch $@

.git/hooks/pre-commit: $(VENV)
	$(VENV)/bin/pre-commit install
	touch .git/hooks/pre-commit
