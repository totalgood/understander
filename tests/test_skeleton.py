#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pytest
from understander.skeleton import fib

__author__ = "hobs"
__copyright__ = "hobs"
__license__ = "affero"


def test_fib():
    assert fib(1) == 1
    assert fib(2) == 1
    assert fib(7) == 13
    with pytest.raises(AssertionError):
        fib(-10)
